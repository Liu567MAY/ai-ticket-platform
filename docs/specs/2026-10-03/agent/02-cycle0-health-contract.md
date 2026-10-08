# 周期 0 Spec 二 — 健康检查契约（GET /internal/health）

状态：已实施
日期：2026-10-03

---

## 1. 端点定义

- 路径：`GET /internal/health`
- 定位：FastAPI 内部探活端点（运维 / Java AgentClient 探测服务与 Redis 可达性），不属于 Spec 04 的 `/internal/tools/*` 业务工具空间，也不给 Vue 前端使用。
- 认证：无。内网探活，周期 0 不接鉴权；后续如需与内网访问策略对齐再评估（TBD 记录于 §6）。

## 2. 响应契约

| 场景 | HTTP 状态码 | 响应体 |
|---|---|---|
| Redis PING 成功 | 200 | `{"code":0,"message":"ok"}` |
| Redis PING 失败（连接失败 / 超时 / 认证失败等任何异常） | 200 | `{"code":1,"message":"redis unavailable"}` |

- 成功响应体**严格只有** `code`、`message` 两个字段：由 Pydantic `response_model`（`HealthResponse`）强约束，序列化不会带出多余字段。
- 失败响应体与成功同构（同两字段），`code=1` 表达不可用。

**决策 D-04（HTTP 状态码恒为 200）**：任务的契约面是响应体（`code` 字段表达语义），故失败时不返回 503。调用方以 `code` 字段判定健康状态。若后续 Java 探活 / 容器编排依赖非 200 判失败，属联调契约变更，走周期报告提出。

## 3. Redis 探测设计

- 客户端：`redis.asyncio.Redis.from_url(REDIS_URL, socket_connect_timeout=2.0, socket_timeout=2.0)`（redis 8.1.0 内置 asyncio，无额外依赖）。
- 探测动作：`await redis.ping()`。
- 异常处理：探活路由内捕获全部异常统一归为 `redis unavailable`——探活接口自身不允许因 Redis 故障变成 500（探活失败本身就是有效输出）。
- 超时：连接 2s + 命令 2s（决策 D-02），保证探活快速失败。

## 4. 生命周期（lifespan）

- 启动：创建 Redis 客户端，挂 `app.state.redis`。**惰性连接**：启动阶段不主动 PING，Redis 不可用**不阻止服务启动**，可用性由 `/internal/health` 运行时探测表达（与 00 §5 验收标准第 6 条对应）。
- 关闭：`await app.state.redis.aclose()` 释放连接。
- `REDIS_URL` 缺失时在 `config.py` 导入期 fail-fast（决策 D-01），服务不会半启动。

## 5. 契约示例

成功（Redis 8.10.1 @ 127.0.0.1:6379，带密码连接）：

```
GET /internal/health
HTTP/1.1 200 OK
content-type: application/json

{"code":0,"message":"ok"}
```

失败（REDIS_URL 指向不可达端口）：

```
GET /internal/health
HTTP/1.1 200 OK
content-type: application/json

{"code":1,"message":"redis unavailable"}
```

## 6. TBD

- health 是否需要纳入内网鉴权 / 是否额外暴露进程信息（版本、uptime）
- 失败 message 是否需要区分细分原因（auth 失败 vs 网络不可达）
