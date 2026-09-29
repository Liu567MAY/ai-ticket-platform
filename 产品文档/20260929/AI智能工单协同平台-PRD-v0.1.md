# AI 智能工单协同平台 PRD

## 文档信息

| 项 | 内容 |
|---|---|
| 版本 | v0.1 |
| 日期 | 2026-09-29 |
| 状态 | 架构设计已冻结；数据库字段层设计待最终确认 |
| 范围 | 项目定位、技术栈、架构职责、核心决策、关键机制、数据库设计、开发计划 |

---

## 1. 项目定位

传统 Java 业务系统 + Python AI Agent 服务结合的完整个人项目。

目标体现的能力：

1. Java 后端开发能力
2. Python AI 应用开发能力
3. LangChain / LangGraph Agent 工程能力
4. Agent Tool Calling
5. Agent 权限控制
6. Agent 可观测
7. Agent Evaluation
8. Agent 经验自进化

**项目不是**：普通聊天机器人、单纯 CRUD 项目、Harness、复杂微服务系统。

**规模约束**：整体保持在"实习生可以独立完成并且能够深入讲清楚"的范围。

一句话定位：**用 LangGraph 做一个权限受控、人工把关、全程留痕、可持续改进的业务 Copilot**，前端形态是"工单工作台 + 右侧 Copilot 面板"，不是聊天框。

---

## 2. 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Vue 3、Vite、Vue Router、Pinia、Axios |
| UI | 不预设组件库，后续通过 Skill 辅助设计和生成 |
| Java 后端 | Spring Boot 3、Spring Security、JWT、MyBatis / MyBatis-Plus（待定）、MySQL、Redis |
| Python Agent | FastAPI、LangChain、LangGraph、langchain-deepseek（ChatDeepSeek，不做 OpenAI 兼容适配层） |
| 外部能力 | 企业微信 API |
| 工程化 | Docker 后期加入 |

## 3. 根目录结构（只固定最外层）

```
ai-ticket-platform/
├── frontend/                  # Vue3 + Vite
├── backend-java/              # Spring Boot
├── agent-service/             # FastAPI + LangChain + LangGraph
├── docs/                      # 项目文档
├── deploy/                    # Docker，后期补
├── .gitignore
└── README.md
```

内部目录在开发对应模块时再设计，不过度拆分。

---

## 4. 系统职责划分

### 4.1 Vue3 前端

登录、工单工作台、工单管理、任务中心、Agent Copilot、Agent 执行过程展示、Agent Trace 页面。

### 4.2 Spring Boot

用户、角色、权限、工单、任务、业务状态、企业微信通知、对 FastAPI 的调用、Spring Security 权限校验。

### 4.3 FastAPI

Agent API、LangChain、LangGraph、Agent State、Tool Calling、Interrupt / Resume、Agent Trace、Evaluation、Experience / Evolution。

### 4.4 核心原则

Agent 不允许直接操作业务数据表。所有业务操作必须：

```
Agent Tool → HTTP → Spring Boot API → Spring Security → Service → MySQL
```

---

## 5. 数据访问边界

| 数据类型 | 归属 | 说明 |
|---|---|---|
| 业务数据（user / role / permission / ticket / task / notification） | **Java 独占** | FastAPI 不允许直接 CRUD |
| Agent 运行数据（agent_run / agent_tool_log / agent_node_log / evaluation_result / experience） | **Python 独占** | Agent Infrastructure Data，FastAPI 自行持久化，避免 Trace 绕 Java API |

物理隔离：同一 MySQL 实例 + 两个 schema（`business_db` / `agent_db`），两个独立账号（`business_user` / `agent_user`），互相无对方库权限。

---

## 6. 已拍板的核心决策

1. **`/agent/*` 查询接口采用方案 A**：Java 只做代理（Vue → Spring Boot → FastAPI），agent_* 表由 Python 独占管理，Java 不建 Mapper、不直读。
2. **Run 状态枚举**：RUNNING / WAITING_CONFIRM / SUCCESS / FAILED / CANCELLED / EXPIRED。
3. **run_id 由 FastAPI 生成**并写入 agent_run；Java 不写 agent_* 表。
4. **Redis 定位**：运行时状态 / Checkpoint / 幂等控制；MySQL 为长期持久化层。每次 Run 状态变化由 FastAPI 同步更新 Redis 和 MySQL，终态后清理 Redis 临时状态。Redis Checkpoint 需明确持久化配置（如 AOF），不当作纯内存缓存。
5. **JWT 原样穿透**：FastAPI 不解析 JWT 权限，JWT 作为透传凭证供 Tool 回调 Java。
6. **权限码下发**：Spring Boot 转发 Agent 请求时携带当前用户 permission codes，Agent 据此过滤可用 Tool；Spring Security 仍为最终权限兜底。
7. **修改 Plan = 同一 run_id 的 Resume**，不创建新 Run。
8. **Experience 一期用结构化标签 / 规则匹配**，不提前引入向量检索。
9. **MyBatis / MyBatis-Plus 暂不决定**，进入 Java 实现阶段前再定。
10. **外键策略**：业务域内部可用物理外键；Agent 域内部优先逻辑引用；跨域全部逻辑引用。
11. **评估案例集不建表**：案例文件放 agent-service 仓库（JSON/JSONL/YAML），库中只存回放结果。
12. **Tool 回调携带 `X-Agent-Run-Id`**：用于审计与 Trace 关联，不能因此绕过 Spring Security。
13. **FastAPI 网络边界**：内部服务，不直接暴露公网，入口统一在 Java 后端。

---

## 7. 关键机制设计

### 7.1 JWT 调用链

```
Vue → Spring Boot → FastAPI → Agent Tool → Spring Boot
```

- Spring Boot 转发 Agent 请求时把当前用户 JWT 一起传给 FastAPI
- FastAPI 不修改 JWT；Tool 调用 Java API 时重新携带原 JWT（`Authorization: Bearer xxx`）
- Spring Security 对 Agent Tool 调用和普通用户调用执行相同权限校验
- **Agent 永远不能拥有比当前用户更高的业务权限**
- FastAPI 信任模型：内网服务，只接受 Java 转发，不校验 JWT

### 7.2 双层权限控制

第一层（Agent 能力约束）：生成计划前，根据当前用户权限码只暴露可用的 Tool。例如 USER 只有 query_ticket / query_task，不暴露 close_ticket / assign_ticket，使 LLM 原则上不会生成非法计划。

第二层（Spring Security 兜底）：即使 LLM 出错、Prompt Injection、Agent Bug、Tool Bug，Java API 仍重新验证 JWT 权限。

### 7.3 异步 Run 与前端轮询

- `POST /agent/runs` 立即返回 `{run_id, status}`，HTTP 请求不等待 Agent 执行结束
- FastAPI 侧 Run 图执行放后台任务
- 一期前端轮询 `GET /agent/runs/{run_id}`（Java 代理）获取状态；二期升级 SSE / WebSocket

### 7.4 Interrupt / Resume

- Agent 生成涉及写操作的 Plan 后 Interrupt，status = WAITING_CONFIRM，Checkpoint → Redis，释放执行资源
- 确认执行 → Resume 当前 Run
- 修改计划 → 基于原 checkpoint Resume 并传入 modified_plan，Agent 结合旧 State 重新分析
- 同一用户任务始终属于同一个 run_id（对 Trace / Evaluation / Experience 至关重要）

### 7.5 写操作幂等

create_task、update_ticket_status、resume、notify_owner 等关键写操作必须防重复提交（如用户双击"确认执行"）。Redis 幂等 Key 形如 `agent:idempotent:{run_id}:{action}`，SET 成功才执行，重复请求拒绝。实现细节后续设计。

### 7.6 企业微信通知

- 实际调用由 Spring Boot 完成；Agent 只决定是否通知、通知谁、通知内容
- 链路：notify_owner Tool → Spring Boot → 企业微信 API
- 开发环境允许 Mock（无真实配置时只记录 Notification + 日志），不阻塞 MVP
- 正式联调配置 CorpId / AgentId / Secret / UserId

---

## 8. Agent 工程能力

### 8.1 可观测

每次 Run 必须可追踪，长期 Trace 存 MySQL（agent_db）：

- `agent_run`：run_id、user_id、ticket_id、instruction、model、status、started_at、finished_at、total_latency、prompt_tokens、completion_tokens
- `agent_tool_log`：run_id、tool_name、tool_args、tool_result、status、duration、error_message
- `agent_node_log`：run_id、node_name、input_summary、output_summary、status、duration

前端 Trace 页面展示：Agent Node → query_ticket → Agent Node → WAITING_CONFIRM → create_task → notify_owner → SUCCESS。

### 8.2 Evaluation

- 建立在真实 Trace 上；30~50 条案例，正式写量在主链稳定后，早期先少量 fixture
- 每条案例：用户输入、初始业务数据、预期 Tool、预期参数、预期最终业务状态、是否应人工确认、禁止出现的行为
- 指标：Tool Selection Accuracy、Tool Argument Accuracy、Task Success Rate、Human Intervention Rate、Invalid Action Rate + LLM Judge（辅助）
- **业务确定性指标优先级高于 LLM Judge**
- 必须有 seed / fixture 机制：准备固定业务状态 → 执行 → 取 Trace → 检查终态 → 算指标 → 重置；不依赖线上随机数据

### 8.3 自进化（一期范围）

不做 Fine-tuning / 强化学习 / 自动改代码 / 自动改 Prompt 上线。定义为：基于历史执行结果与人工反馈的经验学习。

```
Agent Run → Observability → Trace → Evaluation
→ 成功/失败/人工修改 → Experience Extraction
→ Experience Store → Experience Retrieval
→ Next Agent Run
```

示例：原 Plan 直接创建高优先级任务，人工修改为"创建任务前先检查值班负责人"——该修改即高质量 Feedback，提炼为 Experience，后续相似工单召回注入 Context。

"人工确认 + 修改方案"既是安全机制，也是自进化数据来源。

---

## 9. 角色设计

| 角色 | 说明 | 主要权限 |
|---|---|---|
| USER | 普通用户 / 提单人 | 创建工单、查看自己工单、查看进度、用 Agent 查询总结 |
| OPERATOR | 处理人员 | 查看待处理工单、修改工单状态、创建处理任务、用 Agent 分析、确认 Agent 写操作 |
| ADMIN | 管理员 | 查看全部工单、用户与角色管理、工单分配、查看 Agent 运行记录与 Tool 日志 |

Agent 本身不是 Role，始终继承当前调用用户的权限。

---

## 10. 数据库设计

### 10.1 全局约定

- **主键**：业务域统一 BIGINT 自增；例外 `agent_run` 直接用 run_id（VARCHAR）做主键，与 `X-Agent-Run-Id`、task.created_by_run_id 类型天然一致
- **外键**：物理外键只在 business_db 内部；agent_db 整库零物理外键
- **时间**：DATETIME，created_at 默认 CURRENT_TIMESTAMP，updated_at 自动更新
- **不做软删除**：v1 不加 deleted 字段，user 用 status 禁用代替删除
- **JSON 字段**：MySQL 原生 JSON 类型；tool_result / input_summary / output_summary 存摘要（超长截断）
- **枚举一律 VARCHAR 存储**，可读性优先

### 10.2 business_db（Java 独占，8 张）

#### user

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| username | VARCHAR(50) | N | | UQ | 登录名 |
| password | VARCHAR(100) | N | | | BCrypt 密文 |
| nickname | VARCHAR(50) | N | | | 显示名 |
| wecom_userid | VARCHAR(64) | Y | | UQ | 企微成员 ID，通知映射必需；Mock 阶段可空 |
| status | TINYINT | N | 1 | | 1 启用 / 0 禁用 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |
| updated_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### role

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| role_code | VARCHAR(30) | N | | UQ | USER / OPERATOR / ADMIN |
| role_name | VARCHAR(50) | N | | | 显示名 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### permission

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| perm_code | VARCHAR(100) | N | | UQ | 权限码（如 ticket:create），Tool 过滤与 Spring Security 的共同依据 |
| perm_name | VARCHAR(50) | N | | | 显示名 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### user_role（复合主键）

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| user_id | BIGINT | N | | PK / FK→user | |
| role_id | BIGINT | N | | PK / FK→role / IDX | |

#### role_permission（复合主键）

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| role_id | BIGINT | N | | PK / FK→role | |
| permission_id | BIGINT | N | | PK / FK→permission / IDX | |

#### ticket

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | 即 Tool 的 ticket_id |
| title | VARCHAR(200) | N | | | |
| description | TEXT | N | | | 问题描述 |
| type | VARCHAR(30) | N | | IDX | PAYMENT / ACCOUNT / NETWORK / OTHER；经验检索匹配键 |
| status | VARCHAR(20) | N | OPEN | IDX | OPEN / PROCESSING / RESOLVED / CLOSED |
| priority | VARCHAR(10) | N | MEDIUM | | LOW / MEDIUM / HIGH / CRITICAL |
| created_by | BIGINT | N | | FK→user | 提单人 |
| owner_id | BIGINT | Y | | FK→user / IDX | 负责人，分配后填 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |
| updated_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### task

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| ticket_id | BIGINT | N | | FK→ticket / IDX | |
| title | VARCHAR(200) | N | | | |
| content | TEXT | Y | | | 处理说明，Agent 创建时由计划生成 |
| assignee_id | BIGINT | Y | | FK→user / IDX | 处理人 |
| status | VARCHAR(20) | N | TODO | | TODO / IN_PROGRESS / DONE / CANCELLED |
| priority | VARCHAR(10) | N | MEDIUM | | 同 ticket.priority |
| source | VARCHAR(10) | N | MANUAL | | MANUAL / AGENT / SYSTEM；任务中心区分来源 |
| created_by | BIGINT | Y | | FK→user | 人工=操作者；Agent=确认执行的用户 |
| created_by_run_id | VARCHAR(64) | Y | | IDX | 逻辑引用 agent_run；source=AGENT 时必填 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |
| updated_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### notification

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| receiver_id | BIGINT | N | | FK→user / IDX | 接收人 |
| ticket_id | BIGINT | N | | FK→ticket / IDX | v1 通知均挂工单上下文 |
| channel | VARCHAR(10) | N | MOCK | | WECOM / MOCK |
| title | VARCHAR(200) | N | | | |
| content | TEXT | N | | | |
| status | VARCHAR(10) | N | PENDING | | PENDING / SENT / FAILED |
| fail_reason | VARCHAR(500) | Y | | | 发送失败原因 |
| sent_at | DATETIME | Y | | | |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |

### 10.3 agent_db（Python 独占，5 张，零物理外键）

#### agent_run

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| run_id | VARCHAR(64) | N | | PK | FastAPI 生成，如 RUN-20260929-0001 |
| user_id | BIGINT | N | | IDX | 逻辑引用 business_db.user |
| ticket_id | BIGINT | N | | IDX | 逻辑引用 business_db.ticket |
| instruction | VARCHAR(1000) | N | | | 用户指令原文 |
| model | VARCHAR(50) | N | | | 如 deepseek-chat |
| status | VARCHAR(20) | N | RUNNING | IDX | RUNNING / WAITING_CONFIRM / SUCCESS / FAILED / CANCELLED / EXPIRED |
| human_action | VARCHAR(10) | N | NONE | | NONE / CONFIRM / MODIFY / CANCEL；Human Intervention Rate 来源 |
| plan_json | JSON | Y | | | {initial, current, revisions}——初始计划+当前计划+少量修改记录 |
| error_message | VARCHAR(500) | Y | | | FAILED/EXPIRED 原因 |
| started_at | DATETIME | N | CURRENT_TIMESTAMP | | |
| finished_at | DATETIME | Y | | | |
| total_latency_ms | INT | Y | | | 终态写入 |
| prompt_tokens | INT | Y | | | 终态汇总 |
| completion_tokens | INT | Y | | | |
| updated_at | DATETIME | N | CURRENT_TIMESTAMP | | 状态变化即更新，排查轮询问题 |

#### agent_tool_log

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| run_id | VARCHAR(64) | N | | UQ(run_id, seq) | 逻辑引用 agent_run |
| seq | INT | N | | UQ(run_id, seq) | 同 run 内调用序号，兼防重复写入 |
| tool_name | VARCHAR(50) | N | | | query_ticket / create_task / notify_owner 等 |
| tool_args | JSON | N | | | 调用参数 |
| tool_result | JSON | Y | | | 结果摘要，超长截断 |
| status | VARCHAR(10) | N | | | SUCCESS / FAILED / DENIED（403 被拒，Invalid Action Rate 数据源） |
| duration_ms | INT | Y | | | |
| error_message | VARCHAR(500) | Y | | | |
| called_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### agent_node_log

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| run_id | VARCHAR(64) | N | | UQ(run_id, seq) | |
| seq | INT | N | | UQ(run_id, seq) | 节点顺序号，Trace 瀑布图排序 |
| node_name | VARCHAR(50) | N | | | agent / tools / plan / final |
| input_summary | JSON | Y | | | State 摘要 |
| output_summary | JSON | Y | | | 节点产出摘要 |
| status | VARCHAR(10) | N | | | SUCCESS / FAILED |
| duration_ms | INT | Y | | | |
| error_message | VARCHAR(500) | Y | | | |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### evaluation_result

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| case_id | VARCHAR(50) | N | | IDX | 对应 cases.json 案例编号 |
| run_id | VARCHAR(64) | N | | UQ | 一次回放一条结果，重评覆盖 |
| tool_selection_ok | TINYINT | N | | | 1 对 0 错 |
| tool_args_ok | TINYINT | N | | | |
| task_success | TINYINT | N | | | |
| invalid_action | TINYINT | N | 0 | | 1 = 出现越权/错误动作 |
| llm_judge_score | DECIMAL(4,2) | Y | | | 0~10，NULL=未启用 |
| judge_comment | VARCHAR(500) | Y | | | Judge 评语 |
| passed | TINYINT(1) | N | | | 综合判定 |
| detail_json | JSON | Y | | | 预期 vs 实际逐项对比 |
| evaluated_at | DATETIME | N | CURRENT_TIMESTAMP | | |

#### experience

| 字段 | 类型 | 空 | 默认 | 约束/索引 | 说明 |
|---|---|---|---|---|---|
| id | BIGINT | N | 自增 | PK | |
| content | TEXT | N | | | 经验文本 |
| match_tags | JSON | N | | | {"ticket_type":"PAYMENT","priority":"HIGH"}；检索时动态比对 |
| source_run_id | VARCHAR(64) | Y | | | 逻辑引用提炼来源 Run；NULL=人工录入 |
| enabled | TINYINT(1) | N | 1 | | 坏经验可下线 |
| hit_count | INT | N | 0 | | 被召回次数 |
| created_at | DATETIME | N | CURRENT_TIMESTAMP | | |
| updated_at | DATETIME | N | CURRENT_TIMESTAMP | | |

### 10.4 设计取舍记录

1. user 不加 email/phone：通知映射已有 wecom_userid，无其他消费方
2. agent_run 主键用 run_id 字符串：全链路（HTTP header、task、日志表）标识统一
3. DENIED 由 Python 记录：Spring Security 403 后 FastAPI Tool 执行器从 HTTP 响应得知并落日志，Java 无感知，边界不破
4. agent_run 加 updated_at：被前端轮询，状态更新时间排查必需
5. summary 类 JSON 字段存摘要不存全量：完整 State 在 Redis checkpoint，落库只留可读摘要

---

## 11. 开发阶段计划

| 阶段 | 内容 | 验收 |
|---|---|---|
| P0 骨架 | Vue / Spring Boot / FastAPI / MySQL / Redis 全部启动，互相 Ping | 三端连通 |
| P1 业务底座 | 用户、角色、JWT、RBAC、工单 CRUD、任务 CRUD；前端登录 / 工作台 / 工单管理 | 三角色权限范围不同，RBAC 拦截生效 |
| P2 只读 Agent | LangChain + ChatDeepSeek；query_ticket / query_task / query_owner 只读 Tool；跑通 Agent → Tool → Java API → MySQL；开始记录 agent_run / agent_tool_log | 自然语言查工单，多轮 Tool 循环，日志有数据 |
| P3 LangGraph | State / Node / Conditional Edge / Agent Loop / Redis Checkpoint / Interrupt / Resume；写操作 Tool；跑通生成 Plan → WAITING_CONFIRM → 确认 → Resume → create_task → update_ticket → SUCCESS | 全链路可演示 |
| P4 可观测 | 完善 agent_node_log；Trace 页面（Node / Tool / 耗时 / 状态 / Token / Error） | 一次 Run 完整回放 |
| P5 企微 + 工程完善 | 企微 Mock / Real、权限预检、幂等、异常处理、Evaluation Fixture | MVP 清单勾完 |
| P6 Evaluation | 30~50 Case Dataset、自动回放、指标计算、LLM Judge | 指标报表可产出 |
| P7 Evolution | Experience Extraction / Store / Retrieval 闭环跑通 | 相似工单召回经验 |

二期：RAG、Embedding、Rerank、Query Rewrite、SSE、Docker、更完整 Evaluation 平台。

---

## 12. 明确不做（第一阶段）

Nacos、RabbitMQ、Kafka、Kubernetes、复杂微服务、多 Agent、Harness、Fine-tuning、自动代码进化、复杂工作流引擎。不为简历技术栈丰富而堆框架。

---

## 13. 待定事项

| 事项 | 决策时点 |
|---|---|
| MyBatis vs MyBatis-Plus | Java 实现阶段开工前 |
| 权限码全集（种子数据） | 建表 SQL 轮一起敲定 |
| 种子数据清单（3 角色、测试账号） | 建表 SQL 轮 |
| langgraph-checkpoint-redis 社区包 vs 自写 saver | P3 开工时 |
| modified_plan 在 Command(resume=...) 中的结构 | P3 开工时 |
| Redis Key TTL 策略（checkpoint / 幂等） | P3 开工时 |
| UI 组件选型 | 前端开发时由 Skill 辅助 |
