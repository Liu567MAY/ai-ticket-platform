# 周期 0 Spec 总览 — 项目骨架与基础环境

状态：已实施
日期：2026-10-03
负责窗口：AI Agent 开发窗口（agent-service/）
范围目录：`agent-service/` + 本 Spec 目录（`docs/specs/2026-10-03/agent/`）

---

## 1. 周期目标

工程可独立启动 + 连通 Redis + 提供 health 接口。为后续周期的 FastAPI / LangGraph 开发提供可运行的最小骨架。

## 2. 周期边界（任务约束，逐条落实）

| 约束 | 落实情况 |
|---|---|
| 只允许 fastapi、uvicorn、redis 三个依赖 | `requirements.txt` 仅列三项（精确版本），传递依赖不显式声明 |
| 禁止实现 Agent / LangChain / LangGraph / RAG / Tool / Checkpoint / DeepSeek | 工程内无任何相关 import / 目录占位 |
| 禁止连接 MySQL、禁止建表 | 工程内无 MySQL 连接；agent_db 不动 |
| 禁止改 agent-service/ 与本 Spec 目录之外的文件 | 未改 README、docs/specs/api、deploy 等 |
| 禁止 git 操作 | 未执行任何 git 命令 |
| Redis 连接不写死 | `REDIS_URL` 必须由环境变量注入，代码零默认值，缺失即启动失败（见 01） |

## 3. 任务拆解

| # | 任务 | 结果文件 |
|---|---|---|
| 1 | Python 3.11 环境 + venv | `agent-service/venv/`（Python 3.11.16，见 01 §2） |
| 2 | FastAPI 骨架 | `agent-service/app/`（见 01 §3） |
| 3 | Redis 连接 + 环境变量契约 | `app/config.py` + `.env.example`（见 01 §4） |
| 4 | GET /internal/health | `app/api/internal.py`（契约见 02） |
| 5 | 自测（三分支） | 计划与记录见 03 |

## 4. 与既有 Spec 的关系（冲突检查结论）

- Spec 04 将 Tool API 空间定义为 `/internal/tools/*`；本周期新增 `/internal/health` 为独立运维探活端点，不在 `/internal/tools/*` 空间内，不冲突。Tool API 本周期不实现。
- Spec 00 将 Agent 管理接口空间定义为 `/runs/*`；本周期不实现。
- 端口 8000、`REDIS_URL`、health 契约为周期 0 新定内容，既有 Spec 无相关约束（Spec 00 §7 的 TBD 项不涉及）。

## 5. 验收标准（自测对照）

1. venv 基于 Python 3.11，`pip install -r requirements.txt` 可复现安装。
2. 不注入 `REDIS_URL` 时启动失败，报错信息明确指引 `.env.example`。
3. 注入合法 `REDIS_URL` 后服务在 8000 端口启动。
4. `GET /internal/health` 在 Redis 可用时返回 `{"code":0,"message":"ok"}`（严格两字段）。
5. `GET /internal/health` 在 Redis 不可用时返回 `{"code":1,"message":"redis unavailable"}`。
6. Redis 不可用不影响服务启动，仅影响 health 的 code 语义（见 02 §4）。

## 6. 本周期明确不做

- `/runs/*`、`/internal/tools/*` 及任何业务端点
- 任何数据库连接（MySQL / agent_db）
- LangChain / LangGraph / Embedding / Checkpointer 相关包与代码
- 测试框架（pytest 等，后续周期随需求引入）
- Docker / 部署配置
