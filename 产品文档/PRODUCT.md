# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

正式前端：Vue 3 + Vite + Vue Router + Pinia + Axios（PRD 已定，尚未开工）。
设计阶段交付物：静态 HTML 交互图（此前按工单场景做过一版三栏原型；业务场景已收敛为学分置换审核，交互图内容需按新场景重做，视觉世界与三栏布局骨架沿用）。

## Users

- TEACHER / REVIEWER（政教处 / 教务审核老师）——审核工作台主用户：复核 AI 审核结果、确认/修改/退回、最终审批
- STUDENT（学生）——提交学分置换申请与材料、查看审核状态与待补清单、接收企业微信通知
- ADMIN（管理员）——用户管理、规则知识库管理、查看 Agent Run / Trace / Evaluation

## Product Purpose

学分置换 AI 审核协同平台：学生提交置换申请与证明材料，AI Agent 依据审核规则知识库（RAG）逐条审核材料（数量/类型/内容/字段完整性），输出结构化问题清单与审核结论；老师复核 AI 判断（确认/修改/退回）并做最终审批；Agent 按确认后的结论推进业务流程（状态机、补件任务、企业微信通知）。成功 = 老师从"逐份翻材料初审"变为"复核 AI 结论 + 拍板"，且每一步可回放、可评估。

## Positioning

"AI 负责逐条对照规则的判断，人负责把关判断本身，Agent 负责判断之后的确定性流程执行"：规则驱动逐条审核（禁止一次读完直接下结论）、材料缺失不猜测（NEED_SUPPLEMENT/BLOCKED）、审核结果结构化落业务库、人工修改即终审但最终审批独立成节点、双状态机（Run 生命周期 / 申请业务状态）分离。同类"AI 审核工具"无法直接复制的是这套 LangGraph Interrupt/Resume + 结构化审核 + 可观测评估自进化的完整工程闭环。

## Operating Context

学校内部审批系统，桌面浏览器为主，中文界面；老师复核以天为周期（checkpoint TTL 按 7 天设计）；一期无 SSE（轮询）；通知走企业微信（开发期 Mock）。

## Capabilities and Constraints

- 一期页面：登录、审核任务工作台（三栏：申请目录树 / 申请详情 / AI 审核结果面板）、申请提交、任务中心、Agent 运行记录
- AI 审核结果面板：审核结论、Rule 逐条结果（PASS/FAIL/无法审核）、问题清单、缺失材料 + 老师操作（确认/修改/退回；审批阶段：同意学分置换）
- 文件能力边界（正式）：数量、类型、文本内容、字段完整性、Rules 对照；不宣称印章真伪识别（OCR/Vision 二期）
- 角色：STUDENT / TEACHER / ADMIN；Agent 继承触发用户权限
- 双状态机：Run（RUNNING/WAITING_HUMAN_REVIEW/SUCCESS/FAILED/CANCELLED/EXPIRED）与申请（SUBMITTED/AUDITING/NEED_SUPPLEMENT/WAIT_TEACHER_APPROVAL/APPROVED/REJECTED）禁止混用
- 知识库：Markdown Rules + Metadata + 本地 BGE Embedding + Chroma，先 Metadata Filter 再向量检索
- 一期不做：印章真伪识别、Rerank、SSE、Docker、知识库管理 UI、经验向量检索

## Brand Commitments

视觉世界已确认：「安灯看板」（Toyota andon 隐喻）——语义三色灯（运转绿 #1F7A4D / 呼叫琥珀 #B7791F / 故障红 #C13A2B）+ 主操作深钢蓝 #24518F，正式、克制、不花里胡哨；详见 DESIGN.md。状态灯语义在新场景直接映射 PASS / FAIL / 待审核 / 呼叫复核。

## Evidence on Hand

- PRD v0.2（当前基准）：20260929/学分置换AI审核协同平台-PRD-v0.2.md
- PRD v0.1（工单场景，已作废留档）：20260929/AI智能工单协同平台-PRD-v0.1.md
- 旧场景静态交互图（布局/视觉参考，内容待重做）：ui-mockup/index.html（评审截图在 ui-mockup/review/）
- 设计系统：DESIGN.md + design.json（同目录）

## Product Principles

1. 规则先行：AI 的每个判断必须能追溯到一条知识库规则（rule_code + evidence）
2. 材料不足不猜测：缺材料 = NEED_SUPPLEMENT/BLOCKED，不是 FAIL
3. 判断归 AI、把关归人、执行归流程：修改即终审，但最终行政审批独立成节点
4. 全程留痕：逐规则审核链可回放，人工修改是最高质量反馈
5. 克制：界面服务于审核主线，不堆砌

## Accessibility & Inclusion

无既有要求；桌面端 Web 常规可访问性按基础标准执行。
