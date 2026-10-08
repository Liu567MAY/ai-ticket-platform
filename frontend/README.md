# frontend — 学分置换 AI 审核协同平台

Vue 3 + TypeScript + Vite。浏览器唯一入口；所有业务请求只访问 Spring Boot。

## 启动

```bash
npm install
npm run dev    # http://localhost:5173
```

要求 Node >= 20（见 package.json engines）。

## Dev 代理

`vite.config.ts` 中配置：`/internal` → `http://localhost:8080`。跨域一律由 dev 代理解决，Java 侧零 CORS 配置。

周期 0 页面：打开首页即探活 `GET /internal/health`（需 Java 已在 8080 启动，启动方式见 `backend-java/src/main/resources/application-example.yml`）。

## 周期 Spec

`docs/specs/2026-10-03/frontend/cycle-0-skeleton/`
