-- ============================================================
-- agent_db — Agent 基础设施库（FastAPI / Python 管理）
-- 学分置换 AI 审核协同平台 · MySQL 8.x · InnoDB · utf8mb4
-- 说明：
--   1. 本库零物理外键：application_id / run_id 等跨域与域内关联
--      均为逻辑引用，只保存 ID
--   2. 业务数据一律在 business_db，本库只存 Agent 自身运行数据
--   3. JSON 摘要列（args/result/summary）超长截断，不存全量 State
-- ============================================================

CREATE DATABASE IF NOT EXISTS agent_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE agent_db;

-- ------------------------------------------------------------
-- agent_run 审核运行（Trace 根；前端轮询的状态来源）
-- 状态机与业务状态严格分离，禁止写入 NEED_SUPPLEMENT 等业务状态
-- ------------------------------------------------------------
CREATE TABLE agent_run (
  run_id            VARCHAR(64)  NOT NULL COMMENT 'Run ID（FastAPI 生成，如 RUN-20260929-0042）',
  application_id    BIGINT       NOT NULL COMMENT '业务申请 ID（逻辑引用 business_db.application）',
  user_id           BIGINT       NOT NULL COMMENT '触发者（学生提交=学生；老师确认 Resume=老师）',
  audit_round       INT          NOT NULL COMMENT '审核轮次',
  trigger_type      VARCHAR(30)  NOT NULL DEFAULT 'STUDENT_SUBMIT' COMMENT '触发类型：STUDENT_SUBMIT/SUPPLEMENT_RESUBMIT/TEACHER_RETRY/EVAL_REPLAY',
  status            VARCHAR(30)  NOT NULL DEFAULT 'RUNNING' COMMENT '运行状态：RUNNING/WAITING_HUMAN_REVIEW/SUCCESS/FAILED/CANCELLED/EXPIRED',
  model             VARCHAR(50)  NOT NULL COMMENT '模型标识，如 deepseek-chat',
  started_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  finished_at       DATETIME     NULL COMMENT '结束时间',
  total_latency_ms  INT          NULL COMMENT '总耗时（毫秒，不含人工等待）',
  prompt_tokens     INT          NULL COMMENT 'Prompt Token 数（终态汇总）',
  completion_tokens INT          NULL COMMENT 'Completion Token 数（终态汇总）',
  error_message     VARCHAR(500) NULL COMMENT '失败/过期原因',
  resume_action     VARCHAR(20)  NOT NULL DEFAULT 'NONE' COMMENT '运行级恢复行为：NONE/CONFIRM/MODIFY/RETURN/CANCEL（Runtime 语义，区别于业务复核动作）',
  updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '状态更新时间（轮询排查用）',
  PRIMARY KEY (run_id),
  KEY idx_run_app_round (application_id, audit_round),
  KEY idx_run_user (user_id),
  KEY idx_run_status (status)
) ENGINE=InnoDB COMMENT='Agent 审核运行';

-- ------------------------------------------------------------
-- agent_tool_log Tool 调用日志
-- ------------------------------------------------------------
CREATE TABLE agent_tool_log (
  id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  run_id        VARCHAR(64)  NOT NULL COMMENT '所属 Run（逻辑引用 agent_run）',
  seq           INT          NOT NULL COMMENT '调用序号（排序兼防重）',
  tool_name     VARCHAR(50)  NOT NULL COMMENT '工具名：query_application/submit_audit_result/create_supplement_task/notify_student 等',
  tool_args     JSON         NOT NULL COMMENT '调用参数',
  tool_result   JSON         NULL COMMENT '结果摘要（超长截断，不存全量）',
  status        VARCHAR(10)  NOT NULL COMMENT 'SUCCESS/FAILED/DENIED（DENIED=被 Spring Security 403 拒绝）',
  duration_ms   INT          NULL COMMENT '耗时（毫秒）',
  error_message VARCHAR(500) NULL COMMENT '错误信息',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调用时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_tool_run_seq (run_id, seq)
) ENGINE=InnoDB COMMENT='Tool 调用日志';

-- ------------------------------------------------------------
-- agent_node_log LangGraph 节点日志（Trace 瀑布图数据源）
-- ------------------------------------------------------------
CREATE TABLE agent_node_log (
  id             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  run_id         VARCHAR(64)  NOT NULL COMMENT '所属 Run（逻辑引用 agent_run）',
  seq            INT          NOT NULL COMMENT '节点执行序号',
  node_name      VARCHAR(50)  NOT NULL COMMENT 'LangGraph 节点名：load_application/retrieve_rules/audit_rule/aggregate/submit_result/…',
  input_summary  JSON         NULL COMMENT '入参 State 摘要',
  output_summary JSON         NULL COMMENT '节点产出摘要',
  status         VARCHAR(10)  NOT NULL COMMENT 'SUCCESS/FAILED/RUNNING',
  duration_ms    INT          NULL COMMENT '耗时（毫秒）',
  error_message  VARCHAR(500) NULL COMMENT '错误信息',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_node_run_seq (run_id, seq)
) ENGINE=InnoDB COMMENT='LangGraph 节点日志';

-- ------------------------------------------------------------
-- evaluation_result 评估结果（一行 = 一次案例回放；重评覆盖）
-- 案例本体在 agent-service/evaluation/datasets/（JSONL 文件），不建表
-- ------------------------------------------------------------
CREATE TABLE evaluation_result (
  id                  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  case_id             VARCHAR(50)  NOT NULL COMMENT '案例编号（对应 datasets/cases.jsonl）',
  run_id              VARCHAR(64)  NOT NULL COMMENT '回放的 Run（逻辑引用 agent_run）',
  rule_selection_ok   TINYINT(1)   NOT NULL COMMENT '检索到的审核规则是否正确',
  audit_accuracy      DECIMAL(4,3) NOT NULL COMMENT '逐规则判定正确率 0~1',
  issue_extraction_ok TINYINT(1)   NOT NULL COMMENT '问题清单是否正确',
  missing_material_ok TINYINT(1)   NOT NULL COMMENT '缺失材料识别是否正确',
  tool_selection_ok   TINYINT(1)   NOT NULL COMMENT '流程推进 Tool 选择是否正确',
  tool_args_ok        TINYINT(1)   NOT NULL COMMENT 'Tool 参数是否正确',
  human_intervention  TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1=老师修改过 AI 判断（Human Intervention Rate 数据源）',
  invalid_action      TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1=出现越权/错误动作（Invalid Action Rate 数据源）',
  workflow_success    TINYINT(1)   NOT NULL COMMENT 'Agent 审核 + 后续业务流程是否达到预期最终结果',
  llm_judge_score     DECIMAL(4,2) NULL COMMENT 'LLM Judge 评分 0~10（NULL=未启用）',
  judge_comment       VARCHAR(500) NULL COMMENT 'Judge 评语',
  passed              TINYINT(1)   NOT NULL COMMENT '综合判定（确定性指标优先于 LLM Judge）',
  metrics_json        JSON         NULL COMMENT '逐规则预期 vs 实际明细及扩展指标',
  evaluated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评估时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_eval_run (run_id),
  KEY idx_eval_case (case_id)
) ENGINE=InnoDB COMMENT='评估结果';

-- ------------------------------------------------------------
-- experience 结构化经验库（标签过滤检索，一期不做向量检索）
-- ------------------------------------------------------------
CREATE TABLE experience (
  id                    BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  source_type           VARCHAR(30)  NOT NULL COMMENT '来源：TEACHER_MODIFICATION/EVALUATION_FAILURE/SUCCESS_CASE/MANUAL',
  source_run_id         VARCHAR(64)  NULL COMMENT '来源 Run（逻辑引用；MANUAL 时为 NULL）',
  source_application_id BIGINT       NULL COMMENT '来源申请（逻辑引用 business_db.application）',
  rule_code             VARCHAR(20)  NULL COMMENT '匹配键：规则编码',
  document_type         VARCHAR(30)  NULL COMMENT '匹配键：材料类型',
  issue_type            VARCHAR(30)  NULL COMMENT '匹配键：问题类型，如 missing_date_range',
  experience_text       TEXT         NOT NULL COMMENT '经验正文',
  confidence            DECIMAL(3,2) NOT NULL DEFAULT 0.50 COMMENT '抽取置信度 0~1（检索排序用）',
  enabled               TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=启用（坏经验下线不删）',
  hit_count             INT          NOT NULL DEFAULT 0 COMMENT '被召回次数',
  created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_exp_rule (rule_code),
  KEY idx_exp_doc_type (document_type),
  KEY idx_exp_source (source_type)
) ENGINE=InnoDB COMMENT='结构化经验库';
