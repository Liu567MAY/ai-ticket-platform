# Spec 00 — API 边界与分类

状态：已确认（API 设计模块一、模块二）
最后更新：2026-09-30

---

## 1. 设计目标

界定项目三类 API 的调用方、路径空间、认证方式与契约归属，防止前端接口、Agent 管理接口、Agent 工具接口混用。

## 2. 三类 API

### A. Frontend API（前端 API）

- 链路：Vue → Spring Boot
- 路径空间：`/api/*`
- 调用方：Vue3 前端（**唯一浏览器入口**）
- 认证：用户 JWT（Authorization），Spring Security 鉴权
- 响应：面向前端展示的 VO
- 明确：Vue 不直接访问 FastAPI

### B. Agent Management API（Agent 管理接口，内部）

- 链路：Spring Boot 内部 AgentClient → FastAPI
- FastAPI 路径空间：`/runs/*`
- 仅内网，不暴露公网

必须区分两个概念：

1. **Frontend Agent Query Proxy**（前端可访问的 Agent 查询代理，第一版**只读**）：
   - `GET /api/applications/{id}/agent-runs/latest`（最近一次 Run 状态与摘要）
   - `GET /api/applications/{id}/agent-trace`（Trace 明细）
   - 后续可扩展：`GET /api/applications/{id}/agent-runs`（历史列表）
   - 前端**不能**：创建 Run、Resume Run
2. **Spring Boot Internal AgentClient**（Java 内部，承担写调用）：
   - create run（submit / 补件事务后触发）
   - resume run（老师复核业务动作事务后触发）
   - 这些不是前端接口

### C. Tool API（Agent 工具接口，内部）

- 链路：FastAPI Tool 执行器 → Spring Boot
- 路径空间：`/internal/tools/*`（**不属于 `/api` 命名空间**）
- 只供 Agent 使用，不给 Vue
- 认证：原始用户 JWT 透传 + `X-Agent-Run-Id` 头；Spring Security 最终鉴权
- Agent 不直接访问 business_db
- 与 Frontend API **不共用 Controller / DTO 契约**

## 3. 契约分离原则（已确认）

- Frontend API：面向**人的展示与操作**
- Tool API：面向 **Agent 的事实读取与业务动作**
- 两边字段集和演进节奏不同，禁止共用 Controller / DTO

## 4. 职责边界（已确认）

| 边界 | 结论 |
|---|---|
| Vue 访问范围 | 只访问 Spring Boot |
| 业务数据权威 | Spring Boot（business_db） |
| Agent 执行 | FastAPI（agent_db 由 FastAPI 管理） |
| Agent 对业务的读写 | 必须经 Tool API → Spring Boot |
| agent_run 数据 | Java 不保存 agent_run 表；agent_db 是唯一权威；Java 仅日志记录 X-Agent-Run-Id |
| Java 缓存 Agent 状态 | 不缓存。轮询每次代理 FastAPI；Redis 属于 LangGraph Checkpoint，不做 Java 查询缓存 |
| run_id | FastAPI 生成；前端不记忆 run_id，按 application_id 查询 |

## 5. Frontend API 分组（骨架已确认，端点细节见各分册）

| 分组 | 判定 |
|---|---|
| `/api/auth/*` | 保留：login、me |
| `/api/users/*` | 保留：ADMIN 用户管理 |
| `/api/applications/*` | 保留：资源主体（见 01） |
| `/api/materials/*` | 拆两半：上传挂申请子资源 `POST /api/applications/{id}/materials`；文件流 `GET /api/materials/{id}/file` |
| `/api/reviews/*` | 保留：audit_result 的业务别名；动作 confirm / modify / return；详情 `GET /api/applications/{id}/review` |
| `/api/supplements/*` | 保留：学生补件任务与提交（见 02） |
| `/api/approvals/*` | 保留：最终审批动作 |
| `/api/notifications/*` | 保留：学生收件箱 |
| `/api/agent/*` | 收窄：原设想的创建 / Resume 端点删除；只保留挂申请下的只读查询（见 03） |
| `/api/admin/*` | 保留：知识库列表（v1 只读）、评估结果查看、经验库启停 |

## 6. 跨服务一致性原则（已确认）

- **同一业务链 ≠ 同一数据库事务**：business_db（Spring Boot）与 agent_db（FastAPI）不使用分布式事务
- 不引入 Seata / MQ / Kafka / RabbitMQ
- 跨服务失败通过：幂等、重试、状态补偿解决
- Run 创建幂等基准：同 application + 同 audit_round 至多一个**活跃 Run**（RUNNING / WAITING_HUMAN_REVIEW）；重复创建优先返回现有活跃 Run
- 不使用 `UNIQUE(application_id, audit_round, trigger_type)` 绝对约束（FAILED 后同轮重试需要放开）。实现细节 TBD

## 7. TBD

- HTTP Status 规范
- 全局响应包装格式
- 错误码 / Trace ID / 分页格式
- AgentClient 具体 URL 约定
- Review / Approval / Admin API 完整清单
