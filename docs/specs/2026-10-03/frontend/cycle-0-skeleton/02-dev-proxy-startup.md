# 周期 0 · Frontend — Dev 代理与启动方式

## 1. 代理配置（vite.config.ts）

```ts
server: {
  proxy: {
    '/internal': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
}
```

要点：

- **不做 rewrite**：浏览器请求 `/internal/health`，Java 端点即 `@GetMapping("/internal/health")`，路径原样对齐。
- `changeOrigin: true`：把请求头 Host 改写为 target，避免本地 Spring 对 Host 的潜在校验问题。
- 仅在 dev server 生效；构建产物如需后端地址由后续周期按部署形态决定（Nginx 反代或同源部署）。
- 跨域策略：浏览器全程只对 5173 同源请求，**Java 侧无需任何 CORS 配置**（本周期禁止向 Java 提 CORS 要求）。
- `/internal` 不属于 `/api` 前端空间（见 `docs/specs/api/00-api-boundary.md`），仅周期 0 探活使用；后续周期正式代理范围以 API Spec 为准。

## 2. 启动方式

### 前端

```bash
cd frontend
npm install          # 首次
npm run dev          # 默认 http://localhost:5173
```

### Java（联调时由 Java 窗口 / 使用者按其约定启动）

Java 侧启动约定（摘自 `backend-java/src/main/resources/application-example.yml`，本窗口不改 Java 任何文件）：

```bash
export DB_URL='jdbc:mysql://127.0.0.1:3306/business_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true'
export DB_USERNAME=business_user
export DB_PASSWORD='<你的口令>'
java -jar backend-java/target/backend-java-0.0.1-SNAPSHOT.jar
```

- health 真实执行 `SELECT 1`：DB 凭据有效 → `200 {"code":0,"message":"ok"}`；DB 不可用 → `503 {"code":1,"message":"mysql unavailable"}`。
- 本周期自测时口令不可得，注入占位口令拉起 jar：应用正常启动、health 如实返回 503（属于接口设计内合法失败分支，足以验证前端链路；见 03）。

## 3. 端口约定

| 端口 | 服务 |
|---|---|
| 5173 | Vite dev server（浏览器唯一入口） |
| 8080 | Spring Boot（本周期仅 /internal/health） |
