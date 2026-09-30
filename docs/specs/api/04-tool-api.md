# Spec 04 — Tool API（FastAPI Tool → Spring Boot）

状态：已确认（API 设计模块四）
最后更新：2026-09-30

---

## 1. 设计目标

定义 Agent 经 Tool API 对业务事实的读取与业务动作的执行；Spring Boot 是业务规则最终执行者。

## 2. 通用约定（已确认）

- 路径空间：`/internal/tools/*`（不属于 `/api/*`，完整路径列表 TBD）
- 只供 Agent 内部调用，不给 Vue 前端
- 认证：原始用户 JWT 透传 + `X-Agent-Run-Id` 头；Spring Security 最终鉴权（等同普通请求，不因 Tool 头豁免）
- Agent 不直接操作 business_db
- 与 Frontend API 不共用 Controller / DTO 契约
- **Read / Command 分治**：
  - Read Tool：按"Agent 需要什么业务事实"拆，可以相对细粒度
  - Command Tool：按"业务规则原子"设计，不能按数据库 CRUD 原子设计
  - Agent 表达业务意图；Java 负责校验、状态机、数据库事务、副作用

## 3. Read Tools（v1 确认两个）

| Tool | 职责 |
|---|---|
| get_application | 读取 Agent 审核需要的申请事实（含学生学籍信息，供与申请表内容交叉核对） |
| get_materials | 读取当前有效材料元数据；**审核读取 is_current=1 的全部有效材料**（不是 round=N 的材料） |

- 暂不增加 get_review_context：Resume 的上下文由 Checkpoint State + Resume 入参携带；实现中确认有需要再新增
- HTTP 路径与请求 / 响应 DTO：TBD

### 材料文件内容

- Agent **不允许**通过 storage_path 直接读取 Java 服务器磁盘
- 确认方向：FastAPI → Java internal 文件流 API（Java 校验业务文件访问权限）→ 返回文件内容 → **Python 侧解析 PDF / DOCX**（文档解析属 AI 域职责，Java 保持薄）
- internal 文件流具体路径：TBD

## 4. Command Tools（v1 确认三个）

### 4.1 submit_audit_result（核心写入）

不是简单 insert，是完整业务写入动作：

1. 校验 run / application / audit_round 一致
2. 创建 audit_result
3. 批量创建 audit_rule_result
4. 保存 AI 原始 outcome / evidence / confidence
5. 保证同一 agent_run_id 不重复生成正式结果
6. 返回 audit_result_id

- 幂等：`audit_result.agent_run_id UNIQUE` 兜底；重复调用**返回已有正式 audit_result_id**，不重复写
- submit 后 application.status **继续保持 AUDITING**（老师复核期间仍属审核大阶段）；待人工复核由 agent_run.status = WAITING_HUMAN_REVIEW 表达
- 单事务：audit_result + audit_rule_result 批量落库
- 可选防幻觉校验（实现期决定）：提交的 rule_code / rule_version 与本次 Run 的 retrieve_rules 日志对账

### 4.2 return_for_supplement

**不拆成** create_supplement_task / update_application_status / create_notification / notify_student。

一个业务 Tool，Java 内部完成：

1. 校验该审核结果已被老师确认退回（RETURN_FOR_SUPPLEMENT）
2. 创建 supplement_task
3. application → NEED_SUPPLEMENT
4. 创建 notification 记录
5. 本地事务提交
6. 事务后发送企业微信

Agent 只表达："将该申请退回补件"。

### 4.3 prepare_for_approval

- 作用：将已完成老师复核、没有未解决 FAIL / NEED_SUPPLEMENT 的申请推进至 WAIT_TEACHER_APPROVAL
- Java 负责校验：final_outcome / 老师复核状态 / 是否存在未解决项
- 成功后：当前 Agent Run 结束为 SUCCESS

## 5. 明确不属于 Agent Tool 的动作

### 最终审批（APPROVED / REJECTED）

- 由 `/api/approvals/*` Java 业务 API 直接处理
- 原因：最终审批是人工行政决定，LLM 不参与判断；Agent 不拥有 approve / reject Tool
- Agent 在审批阶段最多做到 prepare_for_approval
- 审批完成后的通知由 Java 业务动作内部负责

### notify_student

- **不作为独立 Agent Tool**
- 通知属于业务动作副作用：return_for_supplement / approve / reject 等动作自身负责写 notification + 发送企业微信
- Agent 不自由决定：通知谁 / 通知几次 / 通知内容
- 避免重复通知、漏通知、越权通知

## 6. Tool 幂等原则（已确认方向）

- 优先：**业务自然键 + 状态机前置校验**（重复调用被守卫拒绝或幂等返回）
- 兜底：Redis `agent:idempotent:{run_id}:{action}`
- 已确认新增：supplement_task **UNIQUE(audit_result_id)**——一次正式审核结果最多产生一个补件任务（待同步 DDL，见 02 §9）

## 7. 当前明确不做

- 不做 update_application_status 这类裸状态写 Tool
- 不做 notify_student 独立 Tool
- 不做 approve / reject Tool
- 不做 get_review_context（缓设）
- 不拆 return_for_supplement 为多个原子 Tool

## 8. TBD

- 完整 `/internal/tools/*` HTTP 路径列表与命名（get_application 等为 Tool 语义名）
- 各 Tool 请求 / 响应 DTO
- 材料内容 internal 文件流路径与契约
- 防幻觉校验（rule_code 与 retrieve_rules 日志对账）是否一期实现
- Read Tool 是否需要独立权限码细分
