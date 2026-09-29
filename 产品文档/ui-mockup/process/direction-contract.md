# Surface brief — 静态 UI 交互图（登录 / 工单工作台 / Agent 运行记录）

## Scope & Mode

单一自包含静态 HTML（docs/ui-mockup/index.html），三屏页内切换 + Copilot 四状态切换器。设计评审用原型，不含真实数据与后端。Mode: Operate。

## Audience & Job

OPERATOR（工单处理人员）在工作位上处理工单；任务是扫读工单状态、查看 AI 分析、确认/修改/取消 Agent 执行计划；ADMIN 事后回放 Run Trace。

## Direction & Memorable Moment

安灯看板（用户在方向轮直接指定，种子 f22b912d，执行按用户要求"正式、不花里胡哨"）。记忆点：WAITING_CONFIRM 时琥珀安灯呼吸呼叫，确认执行后绿灯逐一点亮。

## Constraints

桌面优先（≥1280）；中文系统字栈，无外部字体/依赖（离线可开）；语义三色灯（绿=运转、琥珀=呼叫、红=故障）+ 主操作深钢蓝；无 emoji 图标，SVG 线性图标；演示数据需标注。

## Direction contract

THESIS: 工单处理线上的安灯板——Agent 是产线上的机器，每一步亮一盏灯；需要人工判断时拉灯呼叫，处理人拍板后机器继续。拒绝类别默认的"白卡片+蓝按钮后管台"排布：整单 Agent 状态是一条永远可见的安灯条，不是埋在面板里的徽标。

OWN-WORLD: 冷调浅灰车间光地面（#F3F4F2），白色面板加发丝边（#E2E4E1），近黑墨（#1F2328）；语义三色灯：运转绿 #1F7A4D、呼叫琥珀 #B7791F、故障红 #C13A2B；主操作深钢蓝 #24518F。中文系统字（Segoe UI / 微软雅黑），元数据 Consolas 等宽。状态灯是小圆灯不是发光球；全页仅琥珀灯允许一处呼吸脉动。

STORY: 处理人扫一眼安灯条就知道 Agent 走到哪一步；琥珀灯亮 = 等我拍板；确认执行后绿灯依次点亮；Trace 页回放每一次亮灯记录。

FIRST VIEWPORT: 顶栏（灯条品牌标 + 导航 + 用户）之下，工作台三栏：左 264px 工单列表（登记簿式行，行首状态灯），中栏当前工单详情（状态/负责人/优先级/描述/处理记录时间线），右 384px Agent Copilot——顶部四枚状态切换签（分析中/待确认/执行中/已完成，签上带小灯），其下为对应状态面板（快捷操作四宫格、AI 分析、执行计划步骤灯行、操作按钮组、流转记录 mono 日志、底部自然语言输入框）。确认执行按钮在计划正下方右对齐，钢蓝主按钮。

FORM: 安灯看板——接地方向列表第 1 位，用户指定覆盖脚本指定方向（种子 f22b912d）。署名交互 = 安灯呼叫与确认后的点亮序列；状态切换器即分镜机制。正式感来自纪律：网格、发丝线、等宽数据、零拟物零霓虹。

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.
