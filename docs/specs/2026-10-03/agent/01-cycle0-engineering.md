# 周期 0 Spec 一 — 工程结构 / 环境变量 / 启动方式

状态：已实施
日期：2026-10-03

---

## 1. 目录结构

```
agent-service/
├── app/
│   ├── __init__.py            # 包标识（空）
│   ├── main.py                # FastAPI 实例、lifespan（Redis 客户端生命周期）、入口
│   ├── config.py              # 环境变量读取与校验（fail-fast）
│   └── api/
│       ├── __init__.py        # 包标识（空）
│       └── internal.py        # /internal/* 路由（本周期仅 health）
├── requirements.txt           # 仅 fastapi / uvicorn / redis（精确版本）
├── .env.example               # REDIS_URL 模板（不含真实密码）
├── .gitignore                 # venv/ / .env / __pycache__
└── venv/                      # Python 3.11 虚拟环境（不入库）
```

分层说明：`config.py` 只读环境变量；`api/` 只放路由；`main.py` 负责装配。为后续周期的 `/runs/*`（Agent 管理）与 `/internal/tools/*`（Tool 执行器）预留了 `api/` 包扩展位，本周期不加空占位文件。

## 2. Python 环境构建过程（实际执行）

| 步骤 | 命令 | 结果 |
|---|---|---|
| 安装 Python 3.11 | `uv python install 3.11` | CPython 3.11.16（本机原无 3.11，仅 3.12.10） |
| 创建标准 venv | `<3.11 python.exe> -m venv venv` | `agent-service/venv`，pip 24.0 |
| 安装依赖 | `python -m pip install fastapi uvicorn redis` | 见 §5 版本清单 |

说明：uv 仅用于安装解释器本体；venv 用标准库 `venv` 模块创建，与后续 CI / 其他成员复现方式一致。

## 3. 环境变量契约

| 变量 | 必填 | 语义 |
|---|---|---|
| `REDIS_URL` | 是 | Redis 连接 URL，格式 `redis://[:password@]host:port/db` |

**决策 D-01（fail-fast，无默认值）**：代码不提供任何默认 Redis 地址。`config.py` 在模块加载时校验 `REDIS_URL`，缺失立即 `RuntimeError`（中文提示指回 `.env.example`）。理由：任务明确"禁止写死"；无默认值让"环境未配置"在启动瞬间暴露，而不是在第一次探活时以 `code=1` 的假象掩盖。

**决策 D-02（超时常量）**：探活超时不走环境变量，作为代码常量（`REDIS_HEALTH_TIMEOUT_SECONDS = 2.0`，连接与命令各 2s）。health 是内部探活接口，必须快速失败；该值不具环境差异性，不做成配置。

**决策 D-03（.env.example 不含真实凭据）**：本机开发 Redis 实际启用了 `requirepass`（密码见本机 `redis-dev.conf`，不写入仓库）。`.env.example` 只给无密码形式 `redis://127.0.0.1:6379/0` 并注释带密码格式；本地实际使用时自行补密码段。`.env` 已列入 `.gitignore`，不入库。

## 4. 启动方式

前置（一次性）：

```bash
cd agent-service
python -m pip install -r requirements.txt   # 在 venv 内
```

启动（Redis 连接必须先注入环境）：

```bash
# Git Bash / Linux
export REDIS_URL="redis://:password@127.0.0.1:6379/0"
uvicorn app.main:app --host 0.0.0.0 --port 8000

# 等价入口（内部 uvicorn.run，host=0.0.0.0, port=8000）
python -m app.main

# Windows PowerShell
$env:REDIS_URL="redis://:password@127.0.0.1:6379/0"; uvicorn app.main:app --host 0.0.0.0 --port 8000
```

- 端口 8000 为周期任务指定；`--host 0.0.0.0` 面向内网联调（FastAPI 属内网服务，Spec 00）。
- 不使用 `uvicorn --env-file`：该参数依赖 python-dotenv，超出本周期三项依赖约束；环境注入以 shell / IDE 方式进行。

## 5. 依赖版本（2026-10-03 安装所得，requirements.txt 已固化）

| 包 | 版本 | 说明 |
|---|---|---|
| fastapi | 0.142.2 | Web 框架（传递依赖 pydantic 2.13.5 / starlette 1.7.0 等，不显式声明） |
| uvicorn | 0.54.0 | ASGI 服务器（不装 [standard] extras，避免引入额外包） |
| redis | 8.1.0 | redis-py（含 asyncio 客户端，health 使用 `redis.asyncio`） |

requirements.txt 采用精确 pin（`==`），保证可复现。
