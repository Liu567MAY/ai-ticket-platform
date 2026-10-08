# 周期 0 · Frontend — 自测记录与结果

自测时间：2026-10-03（周期 0 当日）
自测人：Frontend 窗口

## 1. 环境与进程

| 进程 | 启动方式 | 结果 | 收尾 |
|---|---|---|---|
| Java（联调用） | `java -jar backend-java/target/backend-java-0.0.1-SNAPSHOT.jar`，按其 application-example.yml 约定注入 `DB_URL` / `DB_USERNAME`，`DB_PASSWORD` 为**占位口令**（真实口令本会话不可得，未猜未改任何 Java/DB 内容） | 启动成功，8080 监听 | 自测后停止，端口 8080 已释放 |
| Vite dev server | `npm run dev` | `VITE v8.3.2 ready in 5847 ms`，Local: http://localhost:5173/ | 自测后停止（含残留 node 子进程清理），端口 5173 已释放 |

**dev server 启动日志（关键行）**：

```
> frontend@0.0.0 dev
> vite

  VITE v8.3.2  ready in 5847 ms
  ➜  Local:   http://localhost:5173/
01:50:11 [vite] (client) [optimizer] bundling dependencies...
```

Java 停止后的代理错误日志（对应 502 形态，行为符合预期）：

```
[vite] http proxy error: /internal/health
AggregateError [ECONNREFUSED]
```

## 2. L1 / L2 curl 输出

**L1 直连 Java**（`curl http://localhost:8080/internal/health`）：

```
{"code":1,"message":"mysql unavailable"}
HTTP_STATUS:503
```

**L2 经 Vite 代理**（`curl http://localhost:5173/internal/health`，dev server 运行中）：

```
{"code":1,"message":"mysql unavailable"}
HTTP_STATUS:503
```

L2 = L1（响应体与状态码完全一致）→ 代理转发配置验证通过。

## 3. L3 浏览器实测（自动化驱动，1280×720）

| 形态 | 操作 | 页面渲染结果 | 结论 |
|---|---|---|---|
| 检测中 | 打开首页 | 标题 / 说明 / "重新检测"按钮（disabled）+ "检测中…" | ✅ |
| Java 可达但 DB 凭据无效（503） | 页面加载自动请求 | **联通失败**卡片：HTTP 状态 503、message=mysql unavailable、错误说明"服务返回 HTTP 503（请求已到达 Java）"、原始 JSON `{"code":1,"message":"mysql unavailable"}` | ✅ 真实 Java 结构化响应经代理→Axios→渲染全链路走通 |
| Java 不可达（502） | 停 Java 后点"重新检测" | **联通失败**卡片：HTTP 状态 502、错误说明"代理层错误：Vite 代理无法连接 Java（检查 8080 是否启动）" | ✅（文案经自测修正，见 §5） |

截图留档：会话产物目录（`call_8eea94d…png` 为 503 形态、`call_3885924…png` 为 502 形态）。

## 4. 构建与类型检查

```
npm run build
> vue-tsc -b && vite build
✓ 94 modules transformed.
dist/index.html 0.51 kB │ dist/assets/index-*.css 1.23 kB │ dist/assets/index-*.js 142.65 kB (gzip 54.00 kB)
✓ built in 309ms
```

`vue-tsc -b` 无类型错误；生产构建成功。

## 5. 自测发现并修复

- **502 文案缺陷**：Java 不可达时 Vite 代理返回 502，原文案"服务返回 HTTP 502（请求已到达 Java）"误导（实际只到代理）。已修正为按状态区分：502/504 → "代理层错误：Vite 代理无法连接 Java"；其余非 2xx → "服务返回 HTTP xxx（请求已到达 Java）"；无响应 → "网络错误（请求未到达 Vite 代理）"。修正后经 HMR 实测生效。

## 6. 结论与遗留

**结论：本周期验收目标达成。**
- 工程可独立启动：✅（npm install / npm run dev 实测）
- Axios 联通 Java health：✅（失败分支为真实 Java 响应，证明请求穿透 5173 代理 → 8080 Java → JSON → 页面渲染全链路；502/网络错误分支亦验证）
- 五项任务（工程 / 代理 / 联通页 / .env.example / engines）全部交付；禁止项无违反；git 零操作；frontend/ 与本 Spec 目录之外零文件改动。

**遗留 / 待复验**：
1. **成功分支（`200 {"code":0,"message":"ok"}`）待 DB 口令就绪后复验**，步骤见 03 §4（注入真实 `DB_PASSWORD` 启动 jar → curl 8080 应 200 → 打开 5173 页面应显示"联通成功 code 0 message ok"）。代码路径已实现，风险低。
2. **Node 版本偏差**：本机 v24.20.0（无 nvm），engines 声明 `>=20`。Vite 8 官方支持范围含 24.x，实测无碍；如需严格 20 LTS 需另行安装 nvm-windows（不改系统环境属用户决策）。
3. **npm 源备注**：默认 registry.npmjs.org 本机网络下连续 ECONNRESET，本次以 `--registry=https://registry.npmmirror.com` 命令行参数完成安装（未改任何全局/项目 npm 配置）；后续周期安装依赖如遇同样问题可复用该参数。
