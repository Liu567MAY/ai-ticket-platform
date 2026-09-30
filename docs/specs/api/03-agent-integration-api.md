# Spec 03 — Agent Integration API（Spring Boot ↔ FastAPI）

状态：已确认（API 设计模块一、二）
最后更新：2026-09-30

---

## 1. 设计目标

界定 Spring Boot 与 FastAPI 之间的调用契约：内部 AgentClient 的写调用（创建 Run / Resume）与前端只读查询代理的边界。

## 2. Run 创建（Spring Boot AgentClient → FastAPI）

- **Run 不对前端提供创建 API**
- 创建时机（仅两个，均为业务动作的事务后外部动作）：
  1. 学生正式提交申请（submit 链）
  2. 学生正式提交补件（supplement submit 链）
- Spring Boot AgentClient 调 FastAPI 创建；**run_id 由 FastAPI 生成**
- agent_db 是 Agent Run 唯一权威数据源；**Java 不保存 agent_run 表**
- 创建请求语义（示意）：application_id / audit_round / trigger_type + 当前用户 JWT（透传）；完整 DTO TBD
- 幂等：同 application + 同 audit_round 至多一个活跃 Run（RUNNING / WAITING_HUMAN_REVIEW）；重复创建优先返回现有活跃 Run；不使用 `UNIQUE(application_id, audit_round, trigger_type)` 绝对约束（FAILED 后同轮重试需要放开）。实现细节 TBD

## 3. Run Resume（Spring Boot AgentClient → FastAPI）

- **Resume 不对前端开放**
- 老师点击：确认 / 修改 / 退回补件——操作的是 Java 业务 API（/api/reviews/*）
- 时序：Java 先完成业务复核数据落库（本地事务提交）→ 事务后 Java 调 FastAPI Resume
- 前端完全不需要理解 Resume
- Resume 请求携带内容：TBD（Human-in-the-loop 模块）
- Resume 失败时的业务补偿：TBD（Human-in-the-loop 模块）
- Resume 调用携带的老师 JWT：透传（Tool 回调时以此身份过 Spring Security）

## 4. Frontend Agent Query Proxy（前端只读代理，已确认路径）

| 路径 | 说明 |
|---|---|
| `GET /api/applications/{id}/agent-runs/latest` | 最近一次 Agent Run 状态与摘要；Java 透传 FastAPI |
| `GET /api/applications/{id}/agent-trace` | Agent 执行 Trace 明细（Node / Tool / 耗时 / Token / Error） |

- 每次查询**实时代理** FastAPI，Java 不缓存
- 后续可扩展：`GET /api/applications/{id}/agent-runs`（历史列表）

## 5. FastAPI 侧路径空间（内部）

- `/runs/*`：创建 / 查询 / Resume；具体端点清单 TBD
- Trace 查询端点：TBD
- FastAPI 不暴露公网，仅内网；Java 是否转发 Authorization：**是**（透传当前用户 JWT）

## 6. 认证与调用头（已确认）

| 项 | 结论 |
|---|---|
| Java → FastAPI 是否转发 Authorization | 是，原样透传当前用户 JWT（submit 链=学生 JWT；Resume 链=老师 JWT） |
| Java 是否额外传 permission_codes | 是（架构已拍板）；传递形式（头 / 请求体）TBD |
| FastAPI 是否自己验证 JWT | 不解析权限。信任模型：内网服务 + 只接受 Spring Boot 转发；JWT 作为透传凭证供 Tool 回调 Java |
| Tool 回调 Java | 继续使用原 JWT + `X-Agent-Run-Id`；Spring Security 执行与普通请求相同的最终权限校验 |
| X-Agent-Run-Id | Tool 回调 Java 时必须携带；用途=审计 / Trace 关联 / 排查；**不能因该头绕过 Spring Security** |

## 7. 失败与补偿

- Run 创建失败：
  - submit 链：application 停留 SUBMITTED（见 01 §5/§8）
  - 补件链：application 保持 NEED_SUPPLEMENT（见 02 §7）
  - 恢复手段：幂等重试 / 补偿；不引入分布式事务中间件
- Resume 失败：TBD（Human-in-the-loop 模块）

## 8. TBD

- AgentClient 具体 URL / 路径约定
- FastAPI `/runs` 端点清单与请求 / 响应 DTO
- permission_codes 传递形式
- Trace 响应结构
- Resume 失败补偿方案
