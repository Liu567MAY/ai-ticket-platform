-- ============================================================
-- business_db — 业务库（Spring Boot / Java 管理）
-- 学分置换 AI 审核协同平台 · MySQL 8.x · InnoDB · utf8mb4
-- 说明：
--   1. 物理外键仅存在于业务域内部，全部 ON DELETE RESTRICT
--   2. 枚举使用 VARCHAR + 应用层校验；布尔使用 TINYINT(1)
--   3. 文件本体不存库，material 只保存元数据与存储路径
-- ============================================================

CREATE DATABASE IF NOT EXISTS business_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE business_db;

-- ------------------------------------------------------------
-- role 角色（先于 user 创建并初始化：1 role = N user）
-- ------------------------------------------------------------
CREATE TABLE role (
  id         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  role_code  VARCHAR(30) NOT NULL COMMENT '角色编码：STUDENT/TEACHER/ADMIN',
  role_name  VARCHAR(50) NOT NULL COMMENT '角色名称',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_code (role_code)
) ENGINE=InnoDB COMMENT='角色';

-- ------------------------------------------------------------
-- permission 权限码（按钮/接口级，Tool 过滤与接口鉴权的共同依据）
-- ------------------------------------------------------------
CREATE TABLE permission (
  id         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  perm_code  VARCHAR(100) NOT NULL COMMENT '权限码，如 application:submit',
  perm_name  VARCHAR(50)  NOT NULL COMMENT '权限名称',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_perm_code (perm_code)
) ENGINE=InnoDB COMMENT='权限';

-- ------------------------------------------------------------
-- user 用户（登录主体 + 学籍信息；1 user = 1 role）
-- ------------------------------------------------------------
CREATE TABLE user (
  id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  role_id      BIGINT       NOT NULL COMMENT '角色（role 1:N user）',
  username     VARCHAR(50)  NOT NULL COMMENT '登录名：学号/工号',
  password     VARCHAR(100) NOT NULL COMMENT 'BCrypt 密文',
  real_name    VARCHAR(50)  NOT NULL COMMENT '姓名',
  student_no   VARCHAR(20)  NULL COMMENT '学号（学生填写）',
  college      VARCHAR(50)  NULL COMMENT '学院',
  major        VARCHAR(50)  NULL COMMENT '专业',
  class_name   VARCHAR(50)  NULL COMMENT '班级',
  wecom_userid VARCHAR(64)  NULL COMMENT '企业微信成员 ID（Mock 阶段可空）',
  status       TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1 启用 0 禁用',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_username (username),
  UNIQUE KEY uk_user_wecom (wecom_userid),
  KEY idx_user_role (role_id),
  CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES role (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='用户';

-- ------------------------------------------------------------
-- role_permission 角色-权限（N:M）
-- ------------------------------------------------------------
CREATE TABLE role_permission (
  role_id       BIGINT NOT NULL COMMENT '角色',
  permission_id BIGINT NOT NULL COMMENT '权限',
  PRIMARY KEY (role_id, permission_id),
  KEY idx_rp_permission (permission_id),
  CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES role (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permission (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='角色-权限关联';

-- ------------------------------------------------------------
-- application 学分置换申请（业务状态机宿主）
-- ------------------------------------------------------------
CREATE TABLE application (
  id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键，即 Tool 的 application_id',
  student_id    BIGINT       NOT NULL COMMENT '学生 user.id',
  replace_type  VARCHAR(20)  NOT NULL DEFAULT 'INTERNSHIP' COMMENT '置换类型：INTERNSHIP/COMPETITION/CERTIFICATE',
  course_name   VARCHAR(100) NOT NULL COMMENT '申请置换课程',
  course_code   VARCHAR(30)  NULL COMMENT '课程代码（可空，漏填即审核点）',
  credit_amount DECIMAL(4,1) NOT NULL COMMENT '申请学分',
  reason        TEXT         NOT NULL COMMENT '申请说明',
  status        VARCHAR(30)  NOT NULL DEFAULT 'SUBMITTED' COMMENT '业务状态：SUBMITTED/AUDITING/NEED_SUPPLEMENT/WAIT_TEACHER_APPROVAL/APPROVED/REJECTED',
  current_round INT          NOT NULL DEFAULT 1 COMMENT '当前审核轮次（退回补件事务内 +1）',
  decided_at    DATETIME     NULL COMMENT '进入 APPROVED/REJECTED 终态时间',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_app_student (student_id),
  KEY idx_app_status (status),
  CONSTRAINT fk_app_student FOREIGN KEY (student_id) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='学分置换申请';

-- ------------------------------------------------------------
-- material 申请材料（追加式版本历史，文件本体存本地磁盘）
-- ------------------------------------------------------------
CREATE TABLE material (
  id                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  application_id    BIGINT       NOT NULL COMMENT '所属申请',
  material_type     VARCHAR(30)  NOT NULL COMMENT '材料类型：APPLICATION_FORM/INTERNSHIP_PROOF/UNIT_STAMP_PROOF/OTHER',
  round             INT          NOT NULL DEFAULT 1 COMMENT '上传所处审核轮次（1=初审）',
  version           INT          NOT NULL DEFAULT 1 COMMENT '同类型内版本号',
  is_current        TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=当前生效版本（上传新版后旧行置 0）',
  original_filename VARCHAR(255) NOT NULL COMMENT '原始文件名',
  storage_path      VARCHAR(500) NOT NULL COMMENT '本地存储相对路径（后续可换对象存储 key）',
  file_format       VARCHAR(10)  NOT NULL COMMENT '文件格式：PDF/IMG/DOCX',
  file_size         BIGINT       NOT NULL COMMENT '文件大小（字节）',
  uploaded_by       BIGINT       NOT NULL COMMENT '上传人 user.id',
  uploaded_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_material_version (application_id, material_type, version),
  KEY idx_material_current (application_id, is_current),
  CONSTRAINT fk_material_app FOREIGN KEY (application_id) REFERENCES application (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_material_uploader FOREIGN KEY (uploaded_by) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='申请材料';

-- ------------------------------------------------------------
-- audit_result 审核结果（每轮正式审核一条；老师复核读取的正式记录）
-- ------------------------------------------------------------
CREATE TABLE audit_result (
  id                BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  application_id    BIGINT      NOT NULL COMMENT '所属申请',
  agent_run_id      VARCHAR(64) NOT NULL COMMENT '产生本结果的 Run（逻辑引用 agent_db.agent_run）',
  audit_round       INT         NOT NULL COMMENT '审核轮次',
  outcome           VARCHAR(30) NOT NULL COMMENT 'AI 原始结论：PASS/FAIL/NEED_SUPPLEMENT',
  final_outcome     VARCHAR(30) NULL COMMENT '老师修改后的生效结论（未复核时 NULL）',
  summary           TEXT        NULL COMMENT 'AI 审核总结',
  missing_materials JSON        NULL COMMENT '缺失材料清单 [{material_type, reason}]',
  total_rules       INT         NOT NULL DEFAULT 0 COMMENT '规则总数',
  passed_rules      INT         NOT NULL DEFAULT 0 COMMENT '通过数',
  failed_rules      INT         NOT NULL DEFAULT 0 COMMENT '不通过数（FAIL + NEED_SUPPLEMENT）',
  ai_completed_at   DATETIME    NOT NULL COMMENT 'AI 完成时间',
  human_action      VARCHAR(30) NOT NULL DEFAULT 'NONE' COMMENT '老师复核动作：NONE/CONFIRM/MODIFY/RETURN_FOR_SUPPLEMENT（终审批准/驳回由 approval_record 负责）',
  reviewed_by       BIGINT      NULL COMMENT '复核老师 user.id',
  reviewed_at       DATETIME    NULL COMMENT '复核时间',
  created_at        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_audit_run (agent_run_id),
  KEY idx_audit_app_round (application_id, audit_round),
  CONSTRAINT fk_audit_app FOREIGN KEY (application_id) REFERENCES application (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_audit_reviewer FOREIGN KEY (reviewed_by) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='审核结果';

-- ------------------------------------------------------------
-- audit_rule_result 逐规则审核结果（AI 原始判断与老师终审判断同行对照）
-- ------------------------------------------------------------
CREATE TABLE audit_rule_result (
  id              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  audit_result_id BIGINT       NOT NULL COMMENT '所属审核结果',
  rule_code       VARCHAR(20)  NOT NULL COMMENT '规则编码，如 R03',
  rule_name       VARCHAR(100) NOT NULL COMMENT '规则名称（冗余展示）',
  rule_version    VARCHAR(20)  NOT NULL COMMENT '审核时依据的知识库规则版本（Markdown frontmatter）',
  material_id     BIGINT       NULL COMMENT '涉及的材料（NULL=作用于材料集合，如 R01 文件数量）',
  ai_status       VARCHAR(20)  NOT NULL COMMENT 'AI 判定：PASS/FAIL/NEED_SUPPLEMENT/NEED_REVIEW',
  ai_problem      VARCHAR(500) NULL COMMENT 'AI 发现的问题',
  ai_evidence     VARCHAR(500) NULL COMMENT '原文证据摘录',
  confidence      DECIMAL(3,2) NULL COMMENT 'AI 置信度 0~1',
  final_status    VARCHAR(20)  NULL COMMENT '老师终审判定（未修改时 NULL）',
  final_problem   VARCHAR(500) NULL COMMENT '老师改写后的问题描述',
  modified        TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '老师是否修改过判定',
  modify_note     VARCHAR(500) NULL COMMENT '老师修改说明（Experience 抽取来源）',
  reviewed_by     BIGINT       NULL COMMENT '复核老师 user.id',
  reviewed_at     DATETIME     NULL COMMENT '复核时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rule_result (audit_result_id, rule_code),
  KEY idx_rule_material (material_id),
  CONSTRAINT fk_rule_audit FOREIGN KEY (audit_result_id) REFERENCES audit_result (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_rule_material FOREIGN KEY (material_id) REFERENCES material (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_rule_reviewer FOREIGN KEY (reviewed_by) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='逐规则审核结果';

-- ------------------------------------------------------------
-- supplement_task 补件任务（每次退回一条；记录补什么/为什么/是否完成）
-- ------------------------------------------------------------
CREATE TABLE supplement_task (
  id                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  application_id     BIGINT       NOT NULL COMMENT '所属申请',
  audit_result_id    BIGINT       NOT NULL COMMENT '来源审核结果',
  student_id         BIGINT       NOT NULL COMMENT '需补材料的学生 user.id',
  round              INT          NOT NULL COMMENT '本任务开启的补件轮次',
  status             VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/SUBMITTED/CANCELLED',
  reason             VARCHAR(500) NOT NULL COMMENT '退回原因概述',
  required_materials JSON         NOT NULL COMMENT '补充清单 [{material_type, requirement}]',
  created_by         BIGINT       NOT NULL COMMENT '确认退回的老师 user.id',
  created_by_run_id  VARCHAR(64)  NULL COMMENT '创建本任务的 Run（逻辑引用 agent_run）',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  completed_at       DATETIME     NULL COMMENT '学生重交材料时间',
  PRIMARY KEY (id),
  KEY idx_sup_app (application_id),
  KEY idx_sup_student_status (student_id, status),
  CONSTRAINT fk_sup_app FOREIGN KEY (application_id) REFERENCES application (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_sup_audit FOREIGN KEY (audit_result_id) REFERENCES audit_result (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_sup_student FOREIGN KEY (student_id) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_sup_creator FOREIGN KEY (created_by) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='补件任务';

-- ------------------------------------------------------------
-- approval_record 最终审批记录（历史全保留，最新一条为生效审批）
-- ------------------------------------------------------------
CREATE TABLE approval_record (
  id                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  application_id    BIGINT       NOT NULL COMMENT '所属申请',
  audit_result_id   BIGINT       NOT NULL COMMENT '依据的审核结果',
  decision          VARCHAR(20)  NOT NULL COMMENT '审批决定：APPROVED/REJECTED',
  comment           VARCHAR(500) NULL COMMENT '审批意见',
  approver_id       BIGINT       NOT NULL COMMENT '审批老师 user.id',
  created_by_run_id VARCHAR(64)  NULL COMMENT '执行审批的 Run（逻辑引用）',
  decided_at        DATETIME     NOT NULL COMMENT '审批时间',
  created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_approval_app (application_id),
  CONSTRAINT fk_approval_app FOREIGN KEY (application_id) REFERENCES application (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_approval_audit FOREIGN KEY (audit_result_id) REFERENCES audit_result (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_approval_approver FOREIGN KEY (approver_id) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='最终审批记录';

-- ------------------------------------------------------------
-- notification 通知记录（企微真实发送与开发期 Mock 统一落库）
-- ------------------------------------------------------------
CREATE TABLE notification (
  id                  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  application_id      BIGINT       NOT NULL COMMENT '关联申请',
  receiver_id         BIGINT       NOT NULL COMMENT '接收人 user.id（学生）',
  channel             VARCHAR(10)  NOT NULL DEFAULT 'WECOM' COMMENT '通道：WECOM/SYSTEM（SYSTEM=开发期 Mock）',
  notification_type   VARCHAR(30)  NOT NULL COMMENT '通知类型：SUPPLEMENT_REQUIRED/WAITING_APPROVAL/APPROVED/REJECTED',
  title               VARCHAR(200) NOT NULL COMMENT '标题',
  content             TEXT         NOT NULL COMMENT '内容',
  send_status         VARCHAR(10)  NOT NULL DEFAULT 'PENDING' COMMENT '发送状态：PENDING/SENT/FAILED',
  external_message_id VARCHAR(100) NULL COMMENT '企业微信返回的 msgid',
  error_message       VARCHAR(500) NULL COMMENT '发送失败原因',
  created_by_run_id   VARCHAR(64)  NULL COMMENT '触发通知的 Run（逻辑引用）',
  sent_at             DATETIME     NULL COMMENT '发送时间',
  created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_noti_app (application_id),
  KEY idx_noti_receiver (receiver_id, send_status),
  CONSTRAINT fk_noti_app FOREIGN KEY (application_id) REFERENCES application (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_noti_receiver FOREIGN KEY (receiver_id) REFERENCES user (id)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB COMMENT='通知记录';
