# 周期 0 · Frontend — 任务拆解与范围

- 日期：2026-10-03
- 负责窗口：Frontend
- 交付目录：`frontend/`（本目录由本窗口新建）
- 上游依据：用户周期 0 任务书；`docs/specs/api/00-api-boundary.md`（浏览器唯一入口 = Spring Boot `/api/*`，本周期仅用 `/internal/health` 做探活联通）

## 1. 周期目标

1. frontend/ 工程可独立启动（`npm run dev`）。
2. 经 Axios 联通 Java health（`GET /internal/health`），页面渲染响应。
3. 周期 Spec 固化于本目录。

## 2. 范围内 / 禁止项

**范围内**：Vite + Vue3 + TS 工程；Vue Router / Pinia / Axios 安装并最小接线；dev 代理；一个联通证明页；`.env.example`；Node 版本约束声明。

**明确禁止**：业务页面、登录、路由守卫、UI 组件库、正式 API 封装（拦截器/统一错误处理层）；修改 `frontend/` 与本 Spec 目录之外的任何文件；git 操作。

## 3. 环境事实（开工前实测）

| 项 | 实测结果 | 对本周期的影响 |
|---|---|---|
| Node | v24.20.0（无 nvm），npm 11.19.0 | 非严格 20 LTS；engines 以 `>=20` 声明最低基线（Vite 7 官方支持 `^20.19.0 \|\| >=22.12.0`，24.x 在支持范围）。如需严格 20 需装 nvm-windows，本周期不改系统环境 |
| Java 后端 | `backend-java/target/backend-java-0.0.1-SNAPSHOT.jar` 已构建；8080 未监听 | 联通验证需临时拉起 jar（仅运行，不改任何 Java 文件），自测后停止 |
| health 契约 | 成功 `200 {"code":0,"message":"ok"}`；MySQL 不可用 `503 {"code":1,"message":"mysql unavailable"}`（HealthController 实测源码确认） | 联通页按 code/message + HTTP 状态双轨渲染 |
| MySQL | 3306 监听中；`business_user` 口令仅存本机环境变量，本会话不可得 | 注入占位口令启动 jar → health 如实返回 503（接口设计内合法失败分支），可完整验证"失败显错误"；成功分支复验步骤见 03 |

## 4. 任务拆解

| # | 任务 | 产出 |
|---|---|---|
| T1 | Vite 脚手架创建 Vue3 + TS 工程，安装 vue-router@4 / pinia / axios | `frontend/` 完整工程 + `package.json` |
| T2 | dev 代理 `/internal` → `http://localhost:8080` | `vite.config.ts` |
| T3 | 联通证明页：加载即调 `GET /internal/health`，渲染 code/message 或错误；带手动重测按钮 | `src/views/HealthCheckView.vue` 等（见 01） |
| T4 | `.env.example`（无必需变量，写明说明） | `frontend/.env.example` |
| T5 | Node 20 LTS 基线声明 | `package.json` engines |
| T6 | 本 Spec 五册 | 本目录 |
| T7 | 自测（dev 日志 / 双路 curl / 浏览器实测）并回填 04 | `04-selftest-record.md` |

## 5. 与上游 Spec 的关系

- 代理转发使浏览器侧请求全部同源（5173 → 8080 由 dev server 完成），本周期不要求 Java 配 CORS，符合"跨域一律代理解决"约定。
- `/internal/health` 是 Java 探活端点，不属于 `/api` 前端空间；前端联通页仅在周期 0 使用它，正式业务 API 封装层留待后续周期按 API Spec 建立。
