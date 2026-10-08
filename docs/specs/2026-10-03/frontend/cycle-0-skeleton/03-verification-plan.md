# 周期 0 · Frontend — 联通验证方案与自测计划

## 1. 验证矩阵（由内向外三层）

| 层 | 手段 | 验证点 | 预期 |
|---|---|---|---|
| L1 直连 | `curl http://localhost:8080/internal/health` | Java 服务本身存活、契约正确 | `{"code":…,"message":…}`（200 或 503，取决于 DB 凭据） |
| L2 代理 | `curl http://localhost:5173/internal/health`（dev server 运行中） | Vite 代理转发链路 | 与 L1 同响应体、同状态码 |
| L3 页面 | 浏览器打开 `http://localhost:5173/` | Axios 调用 + 双轨渲染 | 成功形态显 code/message；失败形态显错误（HTTP 状态 + message 或网络错误文案） |

L2 = L1 即证明代理正确；L3 在 L2 基础上证明 Axios 与渲染正确。

## 2. 联通页渲染规格（T3 验收细节）

- 页面加载即发起 `GET /internal/health`（相对路径，走代理）。
- 三态渲染：
  - 请求中：显示"检测中…"；
  - HTTP 2xx：显示 `code` 与 `message`（来自响应 JSON），标注"联通成功"；
  - HTTP 非 2xx / 网络错误：显示实际 HTTP 状态码 + 响应内 `message`（有则显），无响应体（如连接拒绝）时显示网络错误描述，标注"联通失败"。
- 提供"重新检测"按钮便于重复自测。
- 展示原始 JSON 报文（等宽字体），便于与 L1/L2 curl 输出人工比对。

## 3. 自测执行计划

1. 启动 Java：注入占位 DB 口令后台拉起 jar（不改 Java 文件；自测结束后停止进程）。
2. 启动 dev：`npm run dev` 后台运行，记录启动日志。
3. 依次执行 L1 / L2 curl，记录输出。
4. 浏览器（自动化驱动）打开 5173，截图记录 L3 成功/失败两种形态的实际渲染。
5. `npm run build` + `vue-tsc` 类型检查通过，证明工程可构建。
6. 结果回填 `04-selftest-record.md`。

## 4. 已知缺口与复验路径

- 本会话无法获得 `DB_PASSWORD` → L1/L2/L3 只能实测 **503 失败分支**（真实 Java 响应，非模拟）。
- 成功分支复验步骤（DB 凭据就绪后，任何人可执行）：
  1. 按本册 §2 启动方式注入真实口令启动 jar；
  2. `curl http://localhost:8080/internal/health` 应返回 `200 {"code":0,"message":"ok"}`；
  3. 打开 5173 页面应显示"联通成功 + code 0 + message ok"。
- 该缺口不影响本周期验收目标"工程可独立启动 + Axios 联通 Java health（失败分支即真实联通证明：请求到达 Java 并返回结构化响应）"。
