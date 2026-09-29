---
name: AI 智能工单协同平台
description: 安灯看板式的工单处理线——Agent 每步亮一盏灯，需要人判断时拉灯呼叫
colors:
  workshop-bg: "#F3F4F2"
  panel: "#FFFFFF"
  panel-tint: "#FAFBFA"
  hairline: "#E2E4E1"
  hairline-strong: "#CDD1CD"
  ink: "#1F2328"
  ink-secondary: "#5A6167"
  ink-tertiary: "#6B7178"
  lamp-green: "#1F7A4D"
  green-wash: "#E8F2ED"
  lamp-amber: "#B7791F"
  amber-deep: "#8F5F12"
  amber-wash: "#FAF3E4"
  lamp-red: "#C13A2B"
  red-wash: "#FAEDEB"
  lamp-orange: "#C2610E"
  orange-deep: "#A34E08"
  orange-wash: "#FCF3E7"
  orange-line: "#EBD3AE"
  status-gray: "#5A6472"
  gray-wash: "#F0F2F4"
  steel-blue: "#24518F"
  steel-blue-hover: "#1D4376"
  steel-blue-wash: "#F0F4F9"
  steel-blue-line: "#B9CCE4"
  console-dark: "#23272B"
  scrim: "rgba(20,26,34,.4)"
typography:
  headline:
    fontFamily: "'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    fontSize: "19px"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.01em"
  title:
    fontFamily: "'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.6
  section:
    fontFamily: "'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    fontSize: "13.5px"
    fontWeight: 600
    lineHeight: 1.6
  body:
    fontFamily: "'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    fontSize: "12px"
    fontWeight: 600
    letterSpacing: "0.04em"
  mono:
    fontFamily: "Consolas,'Courier New',monospace"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.9
rounded:
  tag: "3px"
  badge: "4px"
  chrome: "5px"
  control: "6px"
  panel: "8px"
  overlay: "10px"
  pill: "99px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
components:
  button-primary:
    backgroundColor: "{colors.steel-blue}"
    textColor: "#FFFFFF"
    typography: "600 13.5px 'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    rounded: "{rounded.control}"
    padding: "0 22px"
    height: "36px"
  button-primary-hover:
    backgroundColor: "{colors.steel-blue-hover}"
  button-primary-disabled:
    backgroundColor: "#E7EAEE"
    textColor: "#5F676F"
  button-warn:
    backgroundColor: "{colors.lamp-orange}"
    textColor: "#FFFFFF"
    typography: "600 13.5px 'Segoe UI','Microsoft YaHei','PingFang SC',sans-serif"
    rounded: "{rounded.control}"
    padding: "0 20px"
    height: "38px"
  button-warn-hover:
    backgroundColor: "{colors.orange-deep}"
  button-ghost:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.ink-secondary}"
    rounded: "{rounded.control}"
    padding: "0 16px"
    height: "36px"
  status-pill-green:
    backgroundColor: "{colors.green-wash}"
    textColor: "{colors.lamp-green}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "3px 10px"
  status-pill-blue:
    backgroundColor: "{colors.steel-blue-wash}"
    textColor: "{colors.steel-blue}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "3px 10px"
  status-pill-orange:
    backgroundColor: "{colors.orange-wash}"
    textColor: "{colors.orange-deep}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "3px 10px"
  status-pill-red:
    backgroundColor: "{colors.red-wash}"
    textColor: "{colors.lamp-red}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "3px 10px"
  status-pill-gray:
    backgroundColor: "{colors.gray-wash}"
    textColor: "{colors.status-gray}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "3px 10px"
  panel:
    backgroundColor: "{colors.panel}"
    rounded: "{rounded.panel}"
  input-text:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "0 12px"
    height: "38px"
  tag-neutral:
    backgroundColor: "{colors.panel-tint}"
    textColor: "{colors.ink-secondary}"
    rounded: "{rounded.tag}"
    padding: "0 6px"
  count-badge:
    backgroundColor: "{colors.steel-blue-wash}"
    textColor: "{colors.steel-blue}"
    typography: "600 12px"
    rounded: "{rounded.pill}"
    padding: "1px 8px"
---

# Design System: AI 智能工单协同平台

## Overview

**Creative North Star: "安灯看板"**

这套界面是一条处理线上的安灯板（Toyota andon）：Agent 是产线上的机器，每走一步亮一盏灯；需要人工判断时拉灯呼叫（琥珀），处理人拍板后机器继续（绿灯逐一点亮）。整个系统的视觉纪律都从这个隐喻推导——状态永远可见、语义色只说状态、其余一切保持车间的冷静底色。正式感来自纪律而不是装饰：网格、发丝线、等宽数据、零拟物零霓虹。

落地形态是冷调浅灰的"车间光"地面（#F3F4F2）上浮着白色面板，全部分隔靠 1px 发丝线（#E2E4E1）而非阴影；近黑墨色文字（#1F2328）分三级递减。语义灯家族（工单线：运转绿 / 呼叫琥珀 / 故障红；审核线新增：动作橙 / 复核灰 / 执行蓝灯）只出现在状态位上；主操作是唯一的彩色交互色——深钢蓝（#24518F）。字体全部使用中文系统字栈（Segoe UI → 微软雅黑 → 苹方），无任何外部依赖，离线可开；机器事实（ID、时间戳、耗时、参数、tokens）一律 Consolas 等宽。

老师审核工作台（第二个已建 surface）把这套纪律带进审核场景，并立起两条新法则。其一是行动语义「橙色=等我操作」：材料缺口、待老师复核这类"轮到你拍板"的状态一律点亮橙色，主按钮随业务状态出现——老师 5 秒内能回答"我该点哪个按钮"。其二是主工作面零终端元素：第一层业务事实（谁申请的、交了什么）与第二层 AI 判断（逐规则结论、问题清单）留在主面，第三层技术执行（Run/Node/Tool/Token）全部收进 440px 执行详情抽屉——一键可得，但不打扰。

**Key Characteristics:**
- 状态灯是 8px 小圆灯（品牌标内 5–7px），不是发光球；灯永远与状态文字同行出现，并带 aria-label。
- 安灯条永远可见（工单台）：整单 Agent 进度是面板顶部一条四段灯条，不是埋在内容里的徽标。
- 动效纪律是「每屏至多一个运动信号」：进行中 = 1.1s 硬闪烁（颜色跟随执行者——审核台蓝灯 = AI 正在跑，工单台绿灯 = 流程推进）；琥珀呼吸光环只属于工单线的呼叫灯，审核台无使用位（待复核态用常亮橙灯）。
- 「橙色=等我操作」：橙灯 / 橙药丸 / 橙横幅 / 橙色主按钮这个家族只说一件事——轮到老师拍板；蓝 = AI 进行中，灰空心 = 学生侧等待，绿/红 = 终态。
- 主工作面零终端元素：技术执行信息（Run/Node/Tool/Token、耗时、JSON 参数）只从「查看执行详情」抽屉进入；旧深色 runlog 条不回流新主界面。
- 等宽字体只说机器的话：Run/Ticket 编号、时刻、毫秒耗时、JSON 参数、token 计数，以及规则证据摘录（机器采样的原文）。
- 零渐变按钮、零投影按钮、零外部字体/图标库；图标为 1.7–2px 描边的线性 SVG（12–17px）。
- keyframes 只服务灯信号；过渡（0.15–0.2s）只服务空间层级（树/规则行 chevron 旋转、抽屉滑入、遮罩淡入），其余状态变化瞬时完成，全部尊重 prefers-reduced-motion。

## Colors

车间底色 + 发丝线 + 三级墨色构成全部"非语义"色；语义灯家族与一个钢蓝交互色是仅有的彩色。每个彩色都绑定一个明确语义，不承担装饰。

### Primary
- **深钢蓝 / 执行蓝**（#24518F）：全系统唯一的交互色。主按钮（确认审核、同意置换、登录、发送）、链接与"查看执行详情"、顶栏激活导航、树/列表选中态（配洗蓝底与蓝发丝边）、全局焦点环（2px 描边）。悬停加深为 #1D4376。它只说"这里可以操作/已被选中"；唯一被批准的状态兼任是审核线的"蓝灯 = AI 进行中"——AI 替你跑着，本身就是行动的前置状态。

### Secondary（语义灯家族——安灯语言）
- **运转绿**（#1F7A4D）：一切"运转/成功/已完成"——列表行首灯、安灯段、计划步骤灯、时间线完成节点、通过状态、绿结论横幅（洗绿底 #E8F2ED）。工作信号用 1.1s 硬闪烁（opacity 1 → 0.35）；在审核线上它同时是终态"通过"。
- **呼叫琥珀**（#B7791F）+ **琥珀深字**（#8F5F12，浅底上的文字用色）：工单线的"等待人工"语言——待确认灯、呼叫脉冲（1.6s 光晕呼吸）、琥珀横幅（洗琥珀底 #FAF3E4）、高优先级文字、Trace 表 WAITING_CONFIRM 行。审核台无琥珀使用位——待老师复核用常亮橙灯表达。同一屏最多一处呼吸。
- **故障红**（#C13A2B）：故障与危险最低限使用——FAILED 状态灯与文字、严重优先级文字、驳回状态与红结论横幅（洗红底 #FAEDEB，审核台启用：已驳回药丸、红横幅、驳回 ghost 悬停底）、通知未读小点、"取消"悬停变红。
- **动作橙**（#C2610E 族，审核线新增）：灯与主按钮 #C2610E、橙底上的深字 #A34E08、橙洗底 #FCF3E7、橙描边 #EBD3AE。语义「需补材料 / 等待学生侧回流」，行动语义「橙色=等我操作」——待老师复核/待最终审批药丸、橙结论横幅、补充清单盒、缺失材料行、GATE/中断类型标、确认退回补材料的橙色主按钮（hover #A34E08）。
- **复核灰**（#5A6472 + 洗灰底 #F0F2F4，审核线新增）：AI 低置信度转交人工的"需人工复核"规则态、待补材料药丸与树组、灰结论横幅、抽屉 AUDIT 类型标；空心灯（1.5px 强发丝圈）在审核线读作"学生侧等待"。

### Neutral
- **车间光地面**（#F3F4F2）：全局背景；登录页叠加一层极淡的垂直渐变（#F6F7F6 → #EDEFEA，唯一渐变）。
- **面板白**（#FFFFFF）/ **面板浅灰**（#FAFBFA）：面板底与次级表面（悬停行与悬停树行、表头、展开的规则详情、抽屉说明条）。
- **发丝线**（#E2E4E1）/ **强发丝线**（#CDD1CD）：全部 1px 分隔线；强线用于输入框/幽灵按钮描边、空心灯圈、时间线竖轨。
- **墨三级**：正文近黑墨 #1F2328、次要 #5A6167、三级与占位符 #6B7178。无纯黑，也不再有更浅的可读文字色。
- **控制台深灰**（#23272B）：机器之声表面——ADMIN「Agent 运行记录」页的深色 runlog 底、工单台品牌灯组嵌块、评审工具与演示 toast；老师主工作面不再出现（审核台品牌嵌块改用洗蓝铬件）。
- **遮罩墨纱**（rgba(20,26,34,.4)，预览模态 .45）：执行详情抽屉与材料预览的全屏底纱，把浮层从页面上"摘下来"。

（落地备注：审核工作台以近孪生中性值落地——地面 #F5F6F8、发丝线 #E4E7EB、次级底 #F8F9FB、强线 #D3D8DE、洗蓝 #EEF3FA、蓝线 #C6D6EA、洗绿 #E9F3EE。两套中性值的统一待裁决，token 层暂以工单台值为准；新增 token（橙/灰/红洗底/遮罩）以审核台实测值为准。）

### Named Rules
**语义灯不入装饰法则。** 绿/琥珀/红/橙/灰/蓝（灯）只允许出现在状态位：灯、状态药丸、状态横幅、状态文字、类型标、日志结果色。凡不表达运行状态的场合一律回到车间灰系。

**钢蓝唯一话事权。** #24518F 是系统里唯一的交互色，垄断"可点击/已选中/焦点"三种含义；唯一被批准的状态兼任是审核线"蓝灯 = AI 进行中"。其他任何色相不得承担交互暗示，语义灯也不得做成按钮。

**「橙色=等我操作」法则。** 橙灯亮起的地方就是轮到老师拍板的地方：待老师复核/需补材料状态、橙结论横幅、确认退回补材料的橙色主按钮。蓝 = AI 进行中，灰空心 = 学生侧等待，绿/红 = 终态——按钮颜色跟着行动语义走：前进类动作（确认/同意）永远钢蓝，退回类动作（退回补材料）用橙。

**墨分三级。** 文字只用 #1F2328 / #5A6167 / #6B7178 三级，靠层级不靠颜色花样；更浅的灰只允许出现在禁用态（#5F676F / #70777E）。

## Typography

**Display/Headline Font:** 中文系统字栈（Segoe UI → Microsoft YaHei → PingFang SC → sans-serif）
**Body Font:** 同一字栈；正文 14px 起步
**Label/Mono Font:** Consolas（回退 Courier New）——只用于机器数据与机器采样的原文

**Character:** 没有展示字型，也没有海报式层级——全系统最大字号 19px（登录标题），两个工作台的页面题都是 18px，品牌名 15px，面板题 14px。工业纪律感来自小字号、600 封顶的字重和等宽数据的严谨排布，而不是字号对比。

### Hierarchy
- **Headline**（600，19px 仅登录卡 / 页面题 18px，行高 1.4）：登录卡标题与工作台页面标题（"王五 - 学分置换申请"）；顶栏品牌名 15px/600。
- **Title**（600，14px，行高 1.6）：面板题与抽屉题（"审核任务""AI 审核结果""Agent 执行详情"）。
- **Section**（600，13.5px，行高 1.6）：右栏节头（"问题清单""规则明细""老师操作"）与预览卡标题；节内计数用 12px/500 三级墨缀于节头之后。
- **Body**（400，13–14px，行高 1.6；叙述性长文 13.5px / 行高 1.75；次级文字 12.5px）：申请说明、规则详情值、抽屉 run-meta、树搜索框、内联编辑框；列表行标题 13px/600。
- **Label**（600，12–12.5px，分组标签带 0.04em 字距，下限 12px）：字段标签 12.5px、区块小标与表头 12px、状态药丸 12px/600；旧工单图的 11px 通用签为遗留值，不再新增。
- **Mono**（Consolas，11–12px，日志块行高 1.9）：Ticket/Run 编号、时刻与耗时、JSON 参数、tokens 计数、日志行、规则代码与问题序号；证据摘录 12px 落在白底引用块（1px 发丝边、4px 圆角）。

### Named Rules
**系统字栈铁律。** 只用操作系统自带中文字体，禁止引入任何 Webfont 或字体文件——这套界面必须离线双开即用。

**等宽只说机器的话。** Consolas 专属机器事实（编号、时刻、耗时、参数、tokens）与机器采样的原文证据（规则证据摘录）；人写的句子（申请说明、状态名、审核结论）一律回到系统字栈。

**600 封顶、19px 封顶。** 字重最高 600，字号最高 19px，标签下限 12px；需要更强层级时靠墨色与位置，不靠加粗放大。

## Layout

桌面优先（≥1280）。工作台是固定三栏骨架：左栏导航（工单台工单列表 264px / 审核台文件夹树 280px）、中栏详情弹性 minmax(0,1fr)、右栏结果与操作（工单台 Copilot 384px / 审核台 AI 审核结果 420px），栏距 12px，页面内边距 14px 16px（审核台底部 24px），高度锁定为视口减 56px 顶栏。三栏都是白面板纵向 flex，内容区独立滚动——页面本身不滚，密度由面板内部消化。

顶栏 56px 常驻（sticky）：灯组品牌标 + 主导航（13px，激活态洗蓝底）+ 用户区（28px 钢蓝圆头像 + 姓名/角色两行，左侧 1px 竖线分隔）。Trace / 运行记录页为单列阅读流，最大宽 1280px 居中。二级入口浮在网格之外：执行详情抽屉 440px 固定右侧滑入（z 41 + 全屏遮罩 z 40），材料预览模态 620px 居中（z 50）。

间距节奏围绕 4 / 8 / 12 / 16 / 20px：模块间距 12px，面板头 12px 16px，列表/树行 5px 8px 起步，面板内文 14px 16px 起步。控件高度成阶梯：28px（浮层关闭钮、头像）→ 30px（小按钮、列表筛选）→ 32px（搜索框、图标钮）→ 36px（标准操作钮）→ 38px（主操作钮、Copilot 输入行）→ 40px（登录表单/主按钮）。

响应式：≤1100px 工单台退两栏（侧栏缩至 220px，Copilot 换行下移）、审核台退单列堆叠（树面板限高 340px）；≤820px 全部纵向堆叠、主导航隐藏、审核台元数据网格退 2 列；≤480px 顶栏用户名收起。评审导航另有 ≤600px 的自身收缩（隐藏标签与演示水印）。

## Elevation & Depth

这是一套平面向发丝线借深度的系统：所有分隔靠 1px 线和面板浅灰完成，常规阴影只有一个——极淡的环境影 `0 1px 2px rgba(16,24,32,.05)`，用于面板本身和"被选中"的页签（让白页签从浅灰底上浮起一毫米）。不存在硬偏移投影、不存在悬停浮起。深度的例外都是信号或浮层：琥珀呼叫灯的 4px 光晕（工单线语义脉冲）、输入聚焦的 3px 洗蓝光环，以及真正离开页面的浮层——抽屉与预览卡用浮层影 `0 6px 20px rgba(16,24,32,.12)` 配全屏遮罩墨纱 rgba(20,26,34,.4)（预览 .45）与页面断开。浮层层级阶梯：遮罩/抽屉 z40/41，预览 z50，演示 toast z60。

### Shadow Vocabulary
- **环境影**（`box-shadow: 0 1px 2px rgba(16,24,32,.05)`）：面板常态 + 选中页签；全系统唯一的常规阴影。
- **焦点光环**（`box-shadow: 0 0 0 3px rgba(36,81,143,.1)`）：输入框聚焦时伴随边框转蓝出现。
- **浮层影**（`box-shadow: 0 6px 20px rgba(16,24,32,.12)`）：执行详情抽屉与材料预览卡——真正离开页面的浮层专用。
- **呼叫光晕**（keyframes 内 `0 0 0 4px rgba(183,121,31,.12)`）：只属于工单线琥珀呼叫灯的呼吸脉冲；审核台无使用位。
- **全局焦点环**（`outline: 2px solid #24518F; outline-offset: 2px`）：所有可交互元素的 :focus-visible 保障。
- 页面底部深灰胶囊浮层（`0 4px 14px rgba(16,24,32,.25)`）属于评审导航（非产品 UI），不是产品阴影词汇。

### Named Rules
**平面向发丝线借深度法则。** 常规面板不做抬升，hover 不加投影；需要分区时画 1px 线或换次级底，需要强调选中时才允许环境影出现。投影只升级一次：浮层（抽屉/预览）配浮层影 + 遮罩墨纱。

## Shapes

圆角是一个收得很紧的七级阶梯：微型签 3px（类型签、水印骨架、Trace 类型标）→ 小徽标 4px（文件图标砖、抽屉 NODE/TOOL/AUDIT/GATE 类型标、证据引用块、"老师已修改"标）→ 小型铬件 5px（导航项、小按钮、树行、抽屉关闭钮、分段选择）→ 控件 6px（按钮、输入框、安灯条、规则卡、结论横幅——即 `--radius`）→ 面板 8px → 独立浮层 10px（登录卡、材料预览卡）→ 胶囊 99px（状态药丸、计数徽标、演示水印/toast）。灯是正圆（8px；品牌标内 5–7px；空心灯为 1.5px 强发丝线圈）。

边框语言高度统一：白面板一律 1px 发丝边 + 8px 圆角 + 环境影；可点击的"白底描边"控件（输入框、幽灵按钮、筛选器）用更深的强发丝线，悬停时描边加深或转蓝。列表型内容（规则卡、问题清单、文件列表、抽屉 wf 行）是 1px 发丝边框内的行堆叠——行间 1px 分隔、悬停转次级底、无独立圆角；缺失材料行以虚线橙描边 + 橙洗底宣告缺口。安灯条四段之间是上下留 8px 的 1px 内嵌竖线；处理记录时间线是一条 1px 竖轨串起空心/实心灯节点。没有斜切、没有双层边框、没有玻璃拟态。

## Components

### Buttons
- **Shape:** 控件圆角（6px；小按钮 5px），无渐变无投影。
- **Primary（确认审核结果 / 同意学分置换 / 登录 / 发送）:** 深钢蓝底（#24518F）白字，600 字重，高 36px（审核台主操作 38px、登录主按钮 40px 全宽），内边距 0 22px；hover 加深 #1D4376；禁用态灰底 #E7EAEE / 灰字 #5F676F / not-allowed。主操作按钮永远在操作区右对齐（margin-left:auto 的位置纪律）。
- **Warn（确认并退回补材料）:** 动作橙底（#C2610E）白字，600，38px 高，内边距 0 20px；hover 加深 #A34E08。只用于"等我操作"的退回类动作，与钢蓝主按钮随业务状态二选一出现——按钮颜色就是行动语义。
- **Ghost（修改审核结果 / 修改计划）:** 白底 1px 强发丝描边，次要墨色文字，高 36px；hover 文字转浓、描边加深、底转次级灰；禁用态透明底灰字。30px 小号 ghost（5px 圆角）用于确认判断/取消。
- **Danger ghost（驳回）:** 白底强发丝描边 + 故障红文字，hover 描边转红 + 洗红底——破坏性动作的第二形态（最终审批阶段与"取消"并存）。
- **Small（确认判断 / 修改判断 / 保存并重新汇总）:** 30px 高、5px 圆角、12.5px/600、内边距 0 14px；primary 蓝底白字，ghost 描边。
- **Quiet text（取消）:** 无边框纯文字（13px 三级墨），hover 转故障红。
- **图标钮 / 发送钮 / 关闭钮:** 28–38px 方形（浮层关闭钮 28px、5px 圆角），6px 圆角；悬停底转次级灰；发送钮为钢蓝底白色线性纸飞机图标。
- 全部按钮继承全局 :focus-visible 2px 钢蓝描边。

### 状态灯（签名组件）
- 8px 正圆，两套已建语法共享同一灯形：
  - **工单线四态**：实心绿 = 运转/成功，实心琥珀 = 等待人工（唯一呼吸），实心红 = 故障，空心（1.5px 强发丝圈）= 未开始/已取消。
  - **审核线六态**：实心蓝 = AI 进行中（本线唯一闪烁），实心橙 = 等我操作（待老师复核/待最终审批），实心绿/红 = 终态（通过/驳回），实心灰 = 需人工复核（低置信度转交），空心 = 学生侧等待（待补材料）。
- 动效纪律「每屏至多一个运动信号」：`blink`（1.1s ease-in-out，opacity 1 → 0.35，"正在跑"）与 `call`（1.6s 琥珀光晕呼吸，工单线专属）之外零 keyframes。
- 灯不单独说话：永远与状态文字同行（间距 5–9px），并带 role="img" + aria-label。
- 品牌标 = 三绿一空的灯组徽记；容器铬件随 surface：工单台为深灰嵌块（#23272B，5px 圆角），审核台为洗蓝底 + 蓝发丝边嵌块（6px 圆角）。

### 安灯条（签名组件，工单台）
- 面板头下方一条四段横条：次级灰底、1px 发丝边、6px 圆角；每段 = 灯 + 12px 步骤名，段间 1px 内嵌竖线（上下缩进 8px）。
- 段状态：done = 绿灯 + 绿字；hot = 琥珀灯（唯一呼吸）+ 琥珀深字加粗；未到 = 空心灯 + 次级墨色。
- 灯序由 JS 状态机驱动（分析中 / 待确认 / 执行中 / 已完成），与右侧四状态签联动——确认执行后绿灯逐一点亮即在此发生。

### 文件夹树（签名组件，审核台）
- 左栏导航：搜索框（32px 高、1px 强发丝边、12.5px，线性放大镜图标）+ 两层树：**流程节点为一级分组**（待AI审核 → 待老师复核 → 待补材料 → 待最终审批 → 已通过 → 已驳回，按业务流转序固定排列；灯 + 组名 + 右对齐行内计数）→ 学生叶子（灯 + 姓名 + 右侧 mono 日期辅助信息）。日期不作为分组维度——树回答的是"哪些申请现在需要我处理"，不是"哪天提交的"。
- 行语法：13px、5px 圆角、5px 8px 内边距，缩进阶梯 0 / 34px；叶子日期为 12px 等宽三级墨右对齐；chevron 为 14px 线性箭头，展开旋转 90°（0.15s）——旋转即层级状态；hover 转次级灰；选中 = 洗蓝底 + 钢蓝字 + 600。
- 树由状态机数据驱动：申请状态变更后自动归组重渲染，树永远反映当前流程节点分布，组名右侧常挂 12px 三级墨计数。

### 规则结果卡片（签名组件，审核台）
- 收起态一行：规则代码（mono 12px 三级墨，定宽）+ 规则名（13px）+ 灯态文字（12px/600 同族色）+ chevron；9px 12px 内边距，行间 1px 发丝线，外框 1px 发丝边 6px 圆角；hover 转次级灰。
- 展开详情 = 52px 标签列网格（审核结果 / 问题 / 依据 / 规则要求 / 证据 / 置信度 / 修改说明），次级灰底承托、顶部 1px 分隔；证据摘录用 mono 12px 白底引用块（1px 发丝边、4px 圆角）——机器采样的原文以等宽呈现；老师改过的判断挂"老师已修改"橙标（#A34E08 字 + 橙洗底 + 橙描边，4px 圆角）。
- 内联编辑 = 修改判断展开蓝发丝边编辑盒：四态分段选择（5px 圆角小签，选中洗蓝底钢蓝字）+ 修改说明 textarea（占位文案"修改说明（将记入审核记录，作为经验提取的依据）"）+ 保存并重新汇总 / 取消；保存即重算结论横幅与问题清单——"修改即重新 Aggregate"的 UI 化。
- 每张卡详情底部常驻 30px 小按钮对：确认判断（ghost）/ 修改判断（primary 蓝），旁注 12px 三级墨"修改后将重新汇总审核结论"。

### 问题清单（审核台）
- 1px 发丝边 6px 圆角行堆叠：mono 12px 故障红序号 + 13px 问题描述（缺失材料与 FAIL 问题去重合并编号）。
- 空态 = 次级灰底"未发现问题"——零问题也要占一格，让"没有问题"本身可见。

### 结论横幅（审核台）
- 四语义色调：橙（需要补充材料）/ 红（审核不通过）/ 绿（审核通过）/ 灰（需人工复核）——洗色底 + 灯 + 14px/600 主句 + 12px 副句；6px 圆角，11px 13px 内边距，灯与首行对齐（margin-top 6px）。
- 副句色彩纪律：终态（绿/红）横幅副文回次级墨，橙/灰横幅副文随主色——终态的消息本身足够重，不需要满幅染色。

### 执行详情抽屉（签名组件，审核台）
- 440px 右侧滑入（0.2s ease-out），全屏遮罩墨纱 rgba(20,26,34,.4)（0.18s 淡入，点击即关）；白底 + 左缘 1px 发丝边 + 浮层影；头 14px/600 + 28px 关闭钮（5px 圆角，hover 次级灰）。
- 头部下方第一件东西是自我降级说明："技术执行详情 · 管理员 / 开发排查视角，老师日常审核无需关注"（12px 三级墨，次级灰底 5px 圆角条）——技术信息进抽屉的第一句话就是"你可以不看"。
- 内容：run-meta 等宽两列格（Run ID / 模型 / 状态 / 开始时间 / 总耗时 / Tokens，12.5px，次级灰底 6px 圆角）+ wf 行（mono 12px 序号 + NODE/TOOL/AUDIT/GATE 类型标 + 13px/600 节点名 + mono 明细（超长省略）+ 灯（完成绿 / 运行中蓝闪）+ mono 耗时，行高最小 36px）。
- 类型标语法（4px 圆角、12px/600）：NODE 灰 / TOOL 洗蓝 / AUDIT 复核灰 / GATE 动作橙——执行器、工具、审核判断、人工闸门四类一目了然。
- 页脚指向："完整 Trace 与 Token 明细见「Agent 运行记录」页面（ADMIN 视角）"——抽屉是老师侧的技术终点，不做深度浏览。

### 材料行（审核台）
- 白底行 9px 13px 内边距 + 悬停次级灰：30×34 洗蓝文件图标砖（4px 圆角，线性 PDF 图标）+ 13px/600 文件名 + 12px 三级墨副行（类型 · 大小 · 上传时间）+ 右侧灯态审核文字（12px：通过绿 / 存在问题红 / 待AI审核空心）。
- 缺失材料行：虚线橙描边 + 橙洗底 + 8px 橙点 + 橙字文件名 + "未上传 · 需补充"——缺口永远和材料同列同构，不另起一节。
- 整行可点开材料预览浮层。

### 状态切换签（Copilot Tabs，工单台）
- 四枚等宽签（分析中/待确认/执行中/已完成），各带一枚小灯；未选中为透明底次级墨字，hover 底转次级灰；选中态白底 + 1px 强发丝边 + 环境影 + 600 字重（浮起一毫米的那一种）。

### Pills / Tags
- **状态药丸（审核线）:** 胶囊（99px），洗色底 + 同族深字（12px/600）+ 内嵌灯：蓝 = 待AI审核、橙 = 待老师复核/待最终审批、绿 = 已通过、红 = 已驳回、灰 = 待补材料（配空心灯）。
- **状态签（工单线）:** 胶囊洗色底 + 同族深字，内嵌一枚灯；绿签 = #E8F2ED/#1F7A4D，琥珀/红同构。
- **类型签：** 3px 微圆角，次级灰底 + 1px 发丝边 + 次级墨字（11px，遗留）。
- **计数徽标：** 洗蓝底钢蓝字胶囊（1px 8px）挂在面板题旁。
- **类型标（Trace / 抽屉 wf）：** Trace 页 3px/11px（NODE 灰 / TOOL 洗蓝 / HUMAN 洗琥珀，边 #E8CE9E）；抽屉 wf 类型标为其 12px/4px 延伸（NODE 灰 / TOOL 洗蓝 / AUDIT 复核灰 / GATE 动作橙），0.05em 级字距感由 600 字重承担。

### Cards / Containers（面板）
- 白底（#FFFFFF）、1px 发丝边、8px 圆角、环境影；面板头 12px 16px + 底部 1px 分隔线，标题 14px/600。
- 面板体独立滚动；内嵌信息块用次级灰底（AI 分析框、规则展开详情、抽屉说明条）或 1px 描边卡（执行计划、结果框、补充清单盒——补充清单盒用橙描边 + 橙洗底宣告退回）。
- 工单/申请元数据是密排网格（工单台 3 列、审核台 4 列 8 格，1px 线分割、单元格次级灰底）——"登记簿"式的信息排布；审核台另设"更多信息"折叠（12.5px 蓝色链接钮 + 虚线描边折叠盒）。

### Inputs / Fields
- 白底、1px 强发丝描边、6px 圆角、高 32–40px；占位符三级墨。
- 聚焦：描边转钢蓝 + 3px 洗蓝光环（`0 0 0 3px rgba(36,81,143,.1)`）；登录输入框内嵌 15px 线性图标（1.7px 描边）；审核台内联编辑 textarea（12.5px）聚焦仅描边转蓝（无光环），树搜索框为 32px 紧凑变体。
- Copilot 输入行 = 输入框 + 38px 钢蓝发送钮，永远钉在面板底部；自然语言是辅助入口，提示文案随执行状态改写。

### Navigation
- 顶栏主导航：13px 次级墨，6px 14px 内边距，5px 圆角；hover 底转次级灰；激活态洗蓝底 + 钢蓝字 + 600。
- 用户区左侧 1px 竖线分隔，28px 钢蓝圆形字首头像 + 姓名（13px/600）/角色（12px 三级墨）两行。
- 评审导航（页面底部深灰胶囊、三屏切换 + aria-pressed）是评审工具，样式不得回流到产品 UI。

### 表格与瀑布行（Trace / ADMIN）
- 运行记录表：表头 12px/600 三级墨 + 次级灰底；行 10px 14px、1px 底线；hover 次级灰、选中洗蓝底；ID/耗时/tokens 全部 Consolas。
- 状态列复用状态灯语法（SUCCESS 绿 / WAITING_CONFIRM 琥珀呼吸 / FAILED 红 / CANCELLED 空心）。
- Trace 瀑布行：等宽序号 + 缩进 + 类型标 + 名称 + 等宽详情（超长省略）+ 灯 + 右对齐等宽耗时，行高最小 38px；抽屉 wf 行是其轻量变体。

### Mono 流转日志（runlog，ADMIN 侧）
- 深灰控制台块（#23272B，6px 圆角，10px 13px），Consolas 12px / 行高 1.9。
- 行内四色语法：时刻 #9AA1A8、普通叙述 #B9C0C6、成功结果 #6FBF8E（`→ SUCCESS · 342ms`）、呼叫事件 #E4B45C。这是机器之声的唯一出口，人话不进来。
- 作用域铁律：runlog 只属于 ADMIN「Agent 运行记录」页与评审工具；老师主工作面永久禁止——技术执行信息一律入执行详情抽屉。

### 材料预览浮层（占位组件，演示资产）
- 620px 模态卡（10px 圆角、浮层影、遮罩 rgba(20,26,34,.45)）：预览体洗灰底上摆一张 460px 白"纸"（4px 圆角），文档内容以 #EEF0F2 骨架条占位。
- 印章占位 = 86px 圆章（2.5px 描边 #D9877C、55% 透明度）+ 故障红"单位公章"字样——#D9877C 是占位章的局部色，仅存在于这个演示组件，永不进入系统色板与真实组件。

## Do's and Don'ts

### Do:
- **Do** 用状态灯表达一切运行状态：8px 圆灯 + 语义色 + 同行文字 + aria-label；拿不准状态语义时回看两套语法（工单线：绿运转 / 琥珀呼叫 / 红故障 / 空心未动；审核线：蓝 = AI 进行中、橙 = 等我操作、灰 = 需人工复核、空心 = 学生侧等待、绿/红 = 终态）。
- **Do** 让整单 Agent 进度以安灯条形式常驻工单台面板顶部——状态永远可见，不要埋进内容里。
- **Do** 记住行动语义「橙色=等我操作」：需要老师拍板的动作（确认并退回补材料）用橙色主按钮 #C2610E（hover #A34E08）；确认/同意类前进动作永远钢蓝 #24518F。
- **Do** 把技术执行信息（Run/Node/Tool/Token、耗时、JSON 参数）收进 440px 执行详情抽屉，主界面入口只用 12px 钢蓝"查看执行详情"链接钮；抽屉第一行放自我降级说明。
- **Do** 机器事实（编号、时刻、耗时、参数、tokens、证据摘录）一律 Consolas 等宽（11–12px），人工叙述用系统字栈。
- **Do** 分隔靠 1px 发丝线与次级灰底；交互与选中只用深钢蓝（#24518F，hover #1D4376），焦点给足 2px 描边。
- **Do** 控件高度走 28/30/32/36/38/40px 阶梯，间距走 4/8/12/16/20px 节奏。
- **Do** 为所有动效保留 prefers-reduced-motion 降级（灯停闪、光晕停呼吸、抽屉瞬时到位）。
- **Do** 显式标注演示数据（演示账号、"静态交互图 · 演示数据"水印），原型与真实系统不混淆。

### Don't:
- **Don't** 把语义灯（绿/琥珀/红/橙/灰/蓝）用于纯装饰或非状态场景；语义灯不做成按钮，彩色不进非语义区域。
- **Don't** 给同一屏第二个运动信号——每屏至多一处闪烁或呼吸；审核台不使用琥珀呼吸光环（待复核 = 常亮橙灯）；绿/红灯不带光。
- **Don't** 在老师主工作面放终端元素：深色 runlog、NODE/TOOL/AUDIT/GATE 标签、token 计数只存在于执行详情抽屉与 ADMIN 运行记录页。
- **Don't** 引入外部字体、图标库或 emoji 图标；图标只用 12–17px、1.7–2px 描边的内联线性 SVG。
- **Don't** 超过 19px 字号或 600 字重，标签不低于 12px；不要海报式大标题层级。
- **Don't** 用硬偏移投影或 hover 抬升表达可点；深度只来自发丝线、次级灰和选中态的极淡环境影——投影只属于抽屉/预览浮层。
- **Don't** 把印章赭 #D9877C 用在材料预览占位组件之外——它是演示占位章的局部色，不是系统色。
- **Don't** 复用评审导航的深灰胶囊浮层样式——那是评审工具的铬件，不是产品语言。
