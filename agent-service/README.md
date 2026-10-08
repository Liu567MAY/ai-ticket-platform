# agent-service — 学分置换 AI 审核协同平台 Agent 服务

FastAPI + LangChain/LangGraph Agent 服务（agent_db 与 Agent 运行数据的管理者）。

## 技术栈

- Python 3.11 · FastAPI · Uvicorn
- Redis（Checkpoint / 运行时状态，周期 0 仅验证连通）
- 周期 0 依赖仅：fastapi / uvicorn / redis（LangChain 等后续周期引入）

## 环境变量（启动必需，缺失即启动失败）

| 变量 | 说明 |
|---|---|
| `REDIS_URL` | Redis 连接串，格式 `redis://[:password@]host:port/db` |

模板见 `.env.example`。本机开发 Redis 若启用 requirepass，形如 `redis://:密码@127.0.0.1:6379/0`（口令勿入仓库）。

## 启动

```bash
python -m venv venv
venv/Scripts/pip install -r requirements.txt   # Windows；Linux/macOS 为 venv/bin/
export REDIS_URL='redis://:***@127.0.0.1:6379/0'
venv/Scripts/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

端口：**8000**。

## 健康检查（周期 0 统一契约）

`GET /internal/health` —— 内部真实执行 Redis `PING`：

- 成功：HTTP 200 `{"code":0,"message":"ok"}`
- Redis 不可用：HTTP 503 `{"code":1,"message":"redis unavailable"}`（与 backend-java 契约一致；总体验收时统一，原"恒 200"方案已废弃）

本服务为内部服务：仅接受 Spring Boot 转发，不暴露公网，前端不直接访问。后续周期扩展 `/runs/*`（Agent 管理）与 Tool 执行器（契约见 `docs/specs/api/`）。

## 自测

```bash
curl -i http://127.0.0.1:8000/internal/health
```

周期 0 详细方案与实测记录：`docs/specs/2026-10-03/agent/`。

> 本 README 由设计总控窗口于周期 0 总体验收时代补（原窗口遗漏交付）。
