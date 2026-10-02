# Spec 01 — Application API

状态：已确认（API 设计模块二）
最后更新：2026-09-30

---

## 1. 设计目标

定义 application 生命周期（DRAFT → SUBMITTED → AUDITING → …）的前端 API 与状态改变模式。审核动作（review）与终审（approval）不在本册。

## 2. 状态机（已确认，含 DRAFT）

```
DRAFT → SUBMITTED → AUDITING ─┬→ NEED_SUPPLEMENT ─→ AUDITING（补件重审，round+1）
                              └→ WAIT_TEACHER_APPROVAL ─→ APPROVED / REJECTED
```

- DRAFT 为新增枚举值（数据库同步待办见 §10）
- "待老师复核"**不是业务状态**，由 agent_run.status = WAITING_HUMAN_REVIEW 派生
- AUDITING 涵盖"AI 审核中 + 等待老师复核"整个审核大阶段

## 3. 创建申请

`POST /api/applications`

- 语义：创建草稿；初始状态 **DRAFT**；**不启动 Agent**
- 调用方：STUDENT；权限：`application:submit`
- 请求体字段（示意，不锁死校验细节）：replace_type / course_name / course_code / credit_amount / reason
- 响应：申请资源（含 id 与 status=DRAFT）

## 4. 修改草稿

`PATCH /api/applications/{id}`

- **仅 DRAFT 状态可用**
- 允许修改：replace_type / course_name / course_code / credit_amount / reason
- 明确禁止出现在请求体：status / student_id / current_round / decided_at
- 正式提交后（SUBMITTED 起）申请业务字段**冻结**——AI 审核的对象是提交那一刻的申请内容

## 5. 提交申请

`POST /api/applications/{id}/submit`

- 语义：正式提交申请并启动第 1 轮 AI 审核
- 流程原则（**同一业务链 ≠ 同一数据库事务**）：

```
DRAFT
→ 校验申请与材料（必传材料类型是否齐备，校验细则 TBD）
→ SUBMITTED（Spring Boot 本地事务提交）
→ AgentClient 调 FastAPI 创建第 1 轮 Run（事务后外部动作）
→ Run 创建成功 → AUDITING
```

- Run 创建失败时停留在 SUBMITTED（短暂过渡态），通过幂等重试 / 补偿恢复（见 03 §5）
- 首次提交启动第 1 轮审核：**current_round 不递增**（创建时即为 1）
- 权限：application:submit（仅本人申请）
- 不引入分布式事务（Seata / MQ 等）

## 6. 查询（已确认路径）

| 路径 | 说明 | 调用方 |
|---|---|---|
| `GET /api/applications` | 申请列表（学生查自己的 / 老师查全部）；分页 TBD | STUDENT / TEACHER |
| `GET /api/applications/{id}` | 申请详情 | 本人或 `application:read:all` |
| `GET /api/applications/{id}/review` | 老师复核视图：该轮 audit_result + 逐规则结果 + 补件状态 | TEACHER；响应结构 TBD |
| `GET /api/applications/{id}/agent-runs/latest` | 最近一次 Agent Run 状态与摘要（透传 FastAPI，只读代理） | 申请相关方 |
| `GET /api/applications/{id}/agent-trace` | Agent 执行 Trace 明细（Node / Tool / 耗时 / Token） | 申请相关方 |

## 7. 状态写入规则（已确认）

- status **永远不由前端直接传入或修改**；禁止 `PATCH application.status`
- 状态变化必须由明确业务动作触发；`SUBMITTED / AUDITING / NEED_SUPPLEMENT / WAIT_TEACHER_APPROVAL / APPROVED / REJECTED` 由后端内部决定
- 状态迁移校验**统一收口**：全项目仅 application Service 的唯一 transition 入口允许写 status；Controller / 前端 / 其他 Service 不得直接 update
- 状态归属：
  - DRAFT → SUBMITTED → AUDITING：application / submit 链
  - AUDITING → NEED_SUPPLEMENT：review:return 动作
  - AUDITING → WAIT_TEACHER_APPROVAL：review:confirm / review:modify 动作
  - NEED_SUPPLEMENT → AUDITING：supplement 提交动作
  - WAIT_TEACHER_APPROVAL → APPROVED / REJECTED：approval 动作

## 8. 事务边界（已确认）

- 申请落库 + 校验 = 本地事务；Run 创建 = **事务提交后**的外部动作
- SUBMITTED 为短暂过渡态：Run 创建成功前停留，失败时通过幂等重试 / 补偿恢复
- 不引入分布式事务

## 9. 当前明确不做

- 不做 PUT / PATCH status
- 不做"创建即提交"
- 不向前端暴露 Run 创建 / Resume
- 不做申请内容提交后编辑（含 NEED_SUPPLEMENT 期间：补件只动材料，不动申请字段）

## 10. TBD

- 完整请求 / 响应 DTO
- 分页参数与列表筛选条件
- 提交校验细则：必传材料类型集合的来源（一期固定清单 vs 知识库规则推导）
- Review 视图响应结构

## 11. 数据库同步（已落地，2026-09-30）

- application.status 枚举已含 **DRAFT**，列默认值已由 'SUBMITTED' 改为 **'DRAFT'**（与"创建即草稿"语义一致；服务层仍显式写状态）
- 已通过 ALTER 同步至本机 business_db，business_db.sql 建库脚本同步更新
