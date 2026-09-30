# Spec 02 — Supplement API（补件流程）

状态：已确认（API 设计模块三）
最后更新：2026-09-30

---

## 1. 设计目标

定义学生补件流程：上传只保存文件，显式"提交补件"才推进轮次并触发重审；保证材料历史可追溯、轮次语义唯一。

## 2. 上传材料

`POST /api/applications/{id}/materials`

- 语义：**上传只负责保存 material**（追加式版本历史，不覆盖原文件）
- 上传本身：
  - 不修改 application.status
  - 不完成 supplement_task
  - 不创建 Agent Run
  - 不增加 current_round
- 学生可以分多次上传
- 已确认可上传状态：DRAFT / NEED_SUPPLEMENT；其余状态是否开放 TBD
- 权限：material:upload（学生本人）

## 3. 提交补件

`POST /api/supplements/{id}/submit`

- **必须显式提交补件**；不允许上传某个文件后自动启动重审（学生一次需补多份、分多次上传，自动触发会在材料未补齐时误启动 Agent）
- 提交时序：

```
1. 校验 required_materials 是否补齐（is_current=1 材料覆盖要求的全部 material_type，缺则 400 返回缺失清单）
2. supplement_task → COMPLETED
3. application.current_round + 1
4. 本地事务提交
5. Spring Boot AgentClient 创建新一轮 Run（事务后外部动作）
6. Run 创建成功后 application → AUDITING
```

- 权限：学生本人（权限码 TBD）

## 4. current_round

定义：**最近一次已经启动 / 准备启动的正式审核轮次**。

| 时点 | 值 |
|---|---|
| 创建 application | 1（默认值） |
| 首次 submit | 启动第 1 轮，**不递增** |
| 老师退回 / 补件上传期间 | 不变 |
| **学生正式提交补件** | **唯一 +1 时机**（与 task→COMPLETED 同一本地事务） |
| 上传材料 | 绝不递增 |

前端永远不能传入 current_round。

## 5. material.round / version / is_current

| 字段 | 语义 | 示例 |
|---|---|---|
| version | 同 application + material_type 下的**全局版本序号**（跨轮累计） | 实习证明 v1（version=1）→ v2（version=2） |
| round | 该材料版本产生于**哪一轮材料批次** | 第一轮上传 round=1；第二轮补件上传 round=2；新增材料第二轮首传 round=2、version=1 |
| is_current | 同类型当前生效版本；上传新版后同类型旧行置 0；不同类型互不影响 | |

**审核读取规则（已确认）**：第 N 轮审核读取 **is_current = 1** 的全部有效材料——不能只读 round=N，因为上一轮仍然有效、未重新上传的材料必须继续参与审核。

## 6. supplement_task

| 字段 | 已确认语义 |
|---|---|
| round | **目标审核轮次**。第 1 轮审核发现问题（audit_result.audit_round=1）→ 产生的补件任务 round=2；audit_result_id 记录该任务由哪轮审核结果产生 |
| status | **PENDING / COMPLETED / CANCELLED**（已确认弃用 SUBMITTED） |

## 7. Run 创建失败（已确认）

补件事务已完成（current_round=2、task=COMPLETED）但 FastAPI 创建 Run 失败时：

- **不回滚**业务事务（学生补齐、进入下一轮准备是既成业务事实）
- application 暂时保持 **NEED_SUPPLEMENT**
- 前端展示规则：结合 supplement_task=COMPLETED 显示 **"补件已提交，等待系统启动下一轮审核"**，而不是"仍需补材料"
- 第一版**不新增** PENDING_AUDIT / AUDIT_QUEUED 状态
- 后续通过幂等重试 / 补偿创建 Run（幂等基准见 00 §6 / 03 §3）

## 8. TBD

- `/api/supplements/*` 完整清单（学生查看补件任务的读接口、老师侧视角）
- 提交补件的请求 / 响应 DTO
- supplement 域权限码（复用 material:upload 还是新增）
- 非可上传状态（SUBMITTED / AUDITING 等）下上传接口的开放性

## 9. 数据库同步待办（已确认，尚未同步 DDL）

- supplement_task.status 枚举：DDL 注释当前为 PENDING/SUBMITTED/CANCELLED → 确认改为 **PENDING/COMPLETED/CANCELLED**
- supplement_task 新增 **UNIQUE(audit_result_id)**（一次正式审核结果最多产生一个补件任务）

以上两处统一在 API Spec 阶段结束后做数据库小修正。
