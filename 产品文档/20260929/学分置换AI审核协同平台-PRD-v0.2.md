# 学分置换 AI 审核协同平台 PRD

## 文档信息

| 项 | 内容 |
|---|---|
| 版本 | v0.2 |
| 日期 | 2026-09-29 |
| 状态 | 业务场景正式收敛后重写；架构与机制沿用 v0.1 已拍板决策 |
| 取代 | v0.1《AI 智能工单协同平台 PRD》（工单场景，留档作废） |
| 范围 | 项目定位、技术栈、架构职责、核心决策、审核设计、知识库、关键机制、数据库原则、开发计划 |

---

## 1. 项目定位

模拟真实学校学分置换审批业务：**学生提交学分置换申请与材料，AI Agent 依据审核规则知识库自动逐条审核，老师只复核 AI 审核结果并做最终人工审批**。

核心能力清单：

1. 学生提交学分置换申请和材料
2. AI 根据审核规则知识库自动审查（RAG）
3. 审核文件数量 / 类型 / 内容 / 字段完整性
4. 输出结构化问题清单
5. 输出审核结论
6. 老师人工复核（确认 / 修改 / 退回）
7. 老师最终批准 / 退回补充
8. Agent 根据审核结果自动推进后续业务流程
9. 企业微信通知学生
10. Agent 可观测 / Evaluation / Experience 自进化

**项目不是**：聊天机器人、Harness、通用工单系统。

一句话定位：**AI 负责逐条对照规则的判断，老师负责把关判断本身，Agent 负责判断之后的确定性流程执行**——判断与推进在同一个 LangGraph 图内以不同 Node 共存。

主要体现：Java 后端 + Python AI Agent + RAG 审核 + Human-in-the-loop + Agent Tool Calling + Agent 工程化。

规模约束：保持"实习生可独立完成并深入讲清楚"。

## 2. 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Vue 3、Vite、Vue Router、Pinia、Axios；UI 不预设组件库 |
| Java 后端 | Spring Boot 3、Spring Security、JWT、MyBatis / MyBatis-Plus（待定）、MySQL、Redis |
| Python Agent | FastAPI、LangChain、LangGraph、langchain-deepseek（ChatDeepSeek） |
| 知识库 | Markdown Rules + Metadata + **本地 BGE Embedding** + **Chroma** + LangChain Retriever（不新增独立向量库服务） |
| 外部能力 | 企业微信 API |
| 工程化 | Docker 后期加入 |

agent-service 内新增目录：`knowledge-base/`（Markdown 规则文件）与 Chroma 持久化目录。

## 3. 根目录结构（不变）

```
ai-ticket-platform/
├── frontend/            # Vue3 + Vite
├── backend-java/        # Spring Boot
├── agent-service/       # FastAPI + LangChain + LangGraph + knowledge-base
├── docs/
├── deploy/
├── .gitignore
└── README.md
```

## 4. 系统职责

- **Vue3**：登录、审核任务工作台（申请目录树 / 申请详情 / AI 审核结果面板）、申请提交、任务中心、Agent 运行记录（Trace）
- **Spring Boot**：用户、角色、权限、申请、材料、审核记录、补件、审批、状态机、文件存储、企业微信通知、对 FastAPI 的调用、权限校验
- **FastAPI**：Agent API、LangChain、LangGraph、审核 State、Tool Calling、RAG 检索、Interrupt / Resume、Checkpoint、Agent Trace、Evaluation、Experience

核心原则（不变）：Agent 不直接操作业务数据表，一切业务操作经 `Tool → HTTP → Spring Boot → Spring Security → Service → MySQL`。

## 5. 数据访问边界（原则不变，实体更新）

| 数据 | 归属 |
|---|---|
| 业务数据：user / role / permission / application / material / audit_record / supplement_record / approval_record / notification | **Java 独占**（business_db） |
| Agent 运行数据：agent_run / agent_tool_log / agent_node_log / evaluation_result / experience | **Python 独占**（agent_db） |
| 审核规则知识库（Markdown 文件 + Chroma 向量） | **Python 侧文件资产**，不入 MySQL；规则内容是业务知识，但承载形态为文件与向量库 |

物理隔离：同 MySQL 实例 + business_db / agent_db 两 schema + 两独立账号（business_user / agent_user）。

## 6. 已拍板核心决策（v0.2 全量）

沿用 v0.1 仍然成立的：方案 A 代理（`/agent/*` 查询 Java 只转发）、run_id 由 FastAPI 生成、JWT 原样穿透 + FastAPI 不解析权限、权限码下发过滤 Tool、Spring Security 兜底、`X-Agent-Run-Id` 审计头、异步 Run + 前端轮询、Redis 职责四件套、双 schema 双账号、评估案例文件化、企微 Mock 降级、Experience 一期结构化标签匹配、MyBatis 选型待定。

v0.2 新拍板：

1. **修改即终审**：老师在 HUMAN_REVIEW 修改 AI 审核结果后，更新对应 Rule Result → 重新 Aggregate → **不再二次 Interrupt**，直接按修改后的最终结果进入业务分支；**最终学分置换审批保留为独立人工节点**（AI 审核复核 ≠ 最终行政审批）。
2. **双状态机分离，禁止混用**：
   - Agent Run Status：RUNNING / WAITING_HUMAN_REVIEW / SUCCESS / FAILED / CANCELLED / EXPIRED
   - Application Status：SUBMITTED / AUDITING / NEED_SUPPLEMENT / WAIT_TEACHER_APPROVAL / APPROVED / REJECTED
3. **submit_audit_result Tool**：Agent 完成 Aggregate 后、Interrupt 前，经此 Tool 将正式审核结果写入业务库；老师复核读取业务库正式数据，不读 Redis 临时 State。
4. **Checkpoint TTL 约 7 天**：人工复核以天为周期；审核报告等业务事实已持久化 MySQL，checkpoint 过期不丢正式审核结果，EXPIRED 后可重开 Run 只做流程推进或重审。
5. **RAG 一期轻量方案**：Markdown Rules + Metadata + 本地 BGE Embedding + Chroma + LangChain Retriever；检索先 Metadata Filter 再向量检索。
6. **文件审核能力边界（正式）**：文件数量、文件类型、文本内容、字段完整性、Rules 对照。**不宣称真实印章真伪识别**；扫描件 / OCR / Vision 后续扩展。盖章项一期 = 文本线索 + confidence 标注 + 老师复核兜底。
7. **application_id 为跨 Run 业务连续性标识**：同一申请多次 Run（初审 / 补件重审），补件重审新建 run_id、关联同一 application_id；Trace 按 application_id 串接。

## 7. 角色与权限

| 角色 | 职责 |
|---|---|
| STUDENT | 发起申请、上传材料、查看审核状态与待补材料、接收企微通知 |
| TEACHER / REVIEWER | 查看待审核申请、查看 AI 审核结果与问题清单、修改/确认审核结果、退回补材料、最终批准 |
| ADMIN | 用户管理、规则知识库管理、查看 Agent Run / Trace / Evaluation、系统配置 |

Agent 不是角色，始终继承当前触发用户的权限（学生触发的审核 Run 用学生 JWT 只读；老师确认后的 Resume 用老师 JWT 执行推进）。

## 8. 规则驱动审核设计

审核禁止"LLM 一次读完全部材料直接输出通过/不通过"，采用**规则驱动 + 逐条审核**：

规则示例：R01 文件数量 / R02 文件类型 / R03 实习证明内容 / R04 申请表内容 / R05 盖章签字完整性。

每条规则产出结构化结果：

```json
{
  "rule_code": "R03",
  "status": "FAIL",
  "file": "实习证明.pdf",
  "problem": "缺少实习时间",
  "evidence": "...",
  "confidence": 0.92
}
```

材料缺失时**不允许 LLM 猜测**：结果为 NEED_SUPPLEMENT 或 BLOCKED（如 R03：无法审核，缺少实习证明）。

最终审核结果必须结构化：`outcome`（PASS / FAIL / NEED_SUPPLEMENT / HUMAN_REVIEW）、`issues[]`、`passed_rules`、`failed_rules`、`missing_materials`、`summary`、`model_raw`（可选）。老师页面直接按结构化字段渲染。

## 9. 知识库与 RAG

```
knowledge-base/
├── rules/
│   ├── credit-replacement/
│   │   ├── file-count.md
│   │   ├── file-type.md
│   │   ├── internship-proof.md
│   │   ├── application-form.md
│   │   └── approval-requirement.md
│   └── index.md
└── policies/
    └── credit-replacement-policy.md
```

入库：Markdown → Chunk → Metadata（scene / rule_code / rule_type / document_type）→ BGE Embedding → Chroma → Retriever。
检索：识别场景与材料类型 → **Metadata Filter 先行**（scene = credit_replacement, document_type = internship_proof）→ 向量检索 → 交 Agent 对照审核。
定位：RAG 是**审核规则获取层**，不回答学生问题。一期不做复杂 Pipeline，Rerank 缓入。

## 10. LangChain / LangGraph 职责

**LangChain**：ChatDeepSeek、Prompt、Structured Output（单规则结果 + 汇总 JSON）、Tool、Tool Calling、Retriever、Embedding、Chroma。

**LangGraph**：State、Node、Conditional Edge、Agent Loop（逐规则检索-审核循环）、Interrupt、Resume、Checkpoint、Human-in-the-loop。

```
START → Load Application → Load Materials → 识别材料类型
      → Retrieve Rules（按规则循环）→ Audit Rule ×N → Aggregate
      → submit_audit_result（落业务库）
      → Interrupt → WAITING_HUMAN_REVIEW
老师操作后 Resume：
  确认/修改（修改→更新 Rule Result→重新 Aggregate，不再二次 Interrupt）
  ├─ 不通过/退回 → Generate Supplement（清单+任务）→ update_application_status(NEED_SUPPLEMENT) → notify_student → END
  └─ 通过 → update_application_status(WAIT_TEACHER_APPROVAL) → create_teacher_review_task → END
最终审批（独立人工节点，新 Resume）：
  老师批准/驳回 → approve_credit_replacement → 写审批记录 → notify_student → END
```

## 11. Human-in-the-loop

老师可以：查看 AI 问题清单、逐条查看 Rule 结果、修改 AI 判断、确认结果、退回补材料、最终批准。

人工行为记录枚举：**CONFIRM / MODIFY / REJECT / APPROVE / RETURN_FOR_SUPPLEMENT**（记录于 run 与审核记录，双写）。

## 12. Tool 清单

- 查询类：query_application、query_student、query_materials、query_credit_rule_context（query_course 二期待定，v1 课程信息以申请填报为准）
- 落库类：**submit_audit_result**
- 业务执行类：create_supplement_task、update_application_status、create_teacher_review_task、approve_credit_replacement、notify_student

所有业务 Tool 链路：FastAPI → 携带原用户 JWT + X-Agent-Run-Id → Spring Boot → Spring Security → Service → MySQL。

## 13. 双状态机

**Agent Run**：RUNNING / WAITING_HUMAN_REVIEW / SUCCESS / FAILED / CANCELLED / EXPIRED —— 只描述 Run 生命周期。
**Application**：SUBMITTED / AUDITING / NEED_SUPPLEMENT / WAIT_TEACHER_APPROVAL / APPROVED / REJECTED —— 业务事实，归 Java。
前端轮询 Run 状态 + 申请状态两个读数，两套状态机禁止混用。

## 14. 关键机制（沿用并适配）

- **JWT 链**：Vue → Spring Boot → FastAPI → Tool → Spring Boot，原样穿透；FastAPI 内网服务不解析 JWT。
- **双层权限**：按当前用户权限码过滤可用 Tool + Spring Security 兜底。
- **异步 Run**：创建即返回 run_id，前端一期轮询，二期 SSE。
- **幂等**：`agent:idempotent:{run_id}:{action}`，覆盖 resume / 状态更新 / 建任务 / 通知。
- **企微**：Java 实际调用；三种通知——材料不足请补充 / 已完成材料审核等待老师审批 / 申请已通过；开发期 Mock。

## 15. 可观测 / Evaluation / Evolution

- **Trace = 审核链**：Load Application → Retrieve R01 → Audit R01 → … → Aggregate → WAITING_HUMAN_REVIEW → Teacher Confirm → Notify → SUCCESS。三表结构不变（agent_run / agent_tool_log / agent_node_log），节点语义更新。
- **Evaluation 指标（审核版）**：Rule Selection Accuracy、Audit Accuracy（逐 Rule 判定正确率）、Issue Extraction Accuracy、Missing Material Accuracy、Tool Selection / Argument Accuracy、Human Intervention Rate（老师修改率）、Invalid Action Rate、Task Success Rate；LLM Judge 仅辅助（总结质量 / 描述清晰度 / 报告完整性）。业务确定性指标优先。案例文件化 + seed/fixture 重放机制不变。
- **Experience**：数据源 = AI 原始结论 vs 老师修改后的结论、老师改的 Rule、老师补充的问题描述、Evaluation 结果。例：AI 判 R03 PASS，老师改 FAIL（实习时间无明确起止日期）→ 经验"审核实习时间需确认明确起止日期，不能只出现模糊月份"。一期检索用结构化标签（document_type / rule_code / issue_type），不做向量经验检索。

## 16. 前端页面（一期）

1. 登录页
2. **审核任务工作台**（TEACHER 主界面）：左侧申请目录树（日期 → 类型/状态 → 学生）｜中间申请详情（学生信息、申请信息、材料列表与预览）｜右侧 AI 审核结果（审核结论、Rule 逐条结果、问题清单、缺失材料 + 确认/修改/退回操作；审批阶段出现"同意学分置换"）
3. 申请提交页（STUDENT）：填申请 + 传材料 + 查看状态与待补清单
4. 任务中心 / Agent 运行记录（ADMIN 视角 Trace）

视觉方向沿用已确认的「安灯看板」世界（状态灯语义直接映射 PASS / FAIL / 待审核 / 呼叫复核），布局三栏骨架沿用，内容按审核场景重做——排在数据库设计之后。

## 17. 开发阶段

| 阶段 | 内容 |
|---|---|
| P0 骨架 | 三服务 + MySQL + Redis 启动互 Ping；Python 侧加 Chroma / BGE 依赖与 knowledge-base 目录 |
| P1 业务底座 | 用户 / 角色 / JWT / RBAC；申请 CRUD；材料上传与存储；通知记录；前端登录 / 提交 / 工作台骨架 |
| P2 审核 Agent 闭环（只读到落库） | 规则 Markdown 入库脚本；Metadata Filter + 向量检索；逐规则审核循环；结构化输出；submit_audit_result 落库；agent_run / agent_tool_log 记录 |
| P3 LangGraph 完整化 | Interrupt / Resume；执行分支（补件任务 / 状态推进 / 待办）；Redis Checkpoint（7 天 TTL）；幂等；双状态机落表 |
| P4 可观测 | agent_node_log 完善；Trace 页面（审核链回放） |
| P5 企微 + 工程完善 | Mock / Real 企微、权限预检、幂等、异常处理、Evaluation Fixture |
| P6 Evaluation | 审核版指标数据集（30~50 案例）、自动回放、LLM Judge |
| P7 Evolution | Experience Extraction / Store / Retrieval（结构化标签）闭环 |

二期：OCR / Vision 盖章核验、Rerank、SSE、Docker、知识库管理 UI、经验向量检索。

## 18. 明确不做（一期）

Nacos、RabbitMQ、Kafka、K8s、复杂微服务、多 Agent 实例（审核与推进同图不同 Node）、Harness、Fine-tuning、真实印章真伪识别、复杂工作流引擎、经验向量检索。

## 19. 待定事项

| 事项 | 决策时点 |
|---|---|
| MyBatis vs MyBatis-Plus | Java 实现阶段前 |
| 权限码全集 + 种子数据 | 建表 SQL 轮 |
| langgraph-checkpoint-redis 包 vs 自写 saver | P3 |
| modified result 在 Command(resume=...) 的结构 | P3 |
| 课程参照表（query_course）是否需要 | 数据库概念设计确认时 |
| BGE 具体型号（bge-small-zh / bge-m3） | P2 开工前 |
