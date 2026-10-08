# 周期 0 Spec 三 — 自测计划与记录

状态：自测计划已定；执行记录见 §3（2026-10-03 补录）
日期：2026-10-03

---

## 1. 自测范围

覆盖 00 §5 验收标准全部 6 条，其中 3 条为启动/环境分支，2 条为 health 运行时分支，1 条为依赖复现。

## 2. 自测计划（用例）

| # | 用例 | 前置 | 步骤 | 预期 |
|---|---|---|---|---|
| T1 | Redis 基线连通 | 本机 Redis（127.0.0.1:6379，requirepass 启用） | venv 内直连 PING 脚本 | `PING -> True` |
| T2 | 依赖复现安装 | 干净 venv | `pip install -r requirements.txt` | 安装成功，版本与 §5 清单一致 |
| T3 | REDIS_URL 缺失 fail-fast | 启动时不注入 REDIS_URL | `python -m app.main` | 启动即失败，报错含 `.env.example` 指引，无半启动 |
| T4 | 正常启动 | `export REDIS_URL=<合法带密码 URL>` | `uvicorn app.main:app --host 0.0.0.0 --port 8000` | 启动日志 `Uvicorn running on http://0.0.0.0:8000` |
| T5 | health 成功分支 | T4 服务存活 | `curl -s http://127.0.0.1:8000/internal/health` | `{"code":0,"message":"ok"}`，仅两字段 |
| T6 | health 失败分支 | 以不可达 REDIS_URL（127.0.0.1:6399）重启服务 | 同 T5 | `{"code":1,"message":"redis unavailable"}`，服务仍存活 |
| T7 | 惰性连接验证 | 同 T6 | 观察 T6 启动日志 | 服务不因 Redis 不可达而启动失败 |

判定：T1–T7 全部符合预期即通过；任一失败则记录现象与根因，修复后重跑。

## 3. 自测记录（实际执行，2026-10-03）

### T1 Redis 基线连通 — ✅ 通过

环境事实：本机 Redis 服务 `D:\devtools\redis-8.10.1\redis-server.exe`（redis-dev.conf，`bind 127.0.0.1`，`requirepass` 启用），版本 8.10.1。
首次无密码直连返回 `redis.exceptions.AuthenticationError`（据此确认 requirepass），带密码重连：

```
PING -> True
redis_version -> 8.10.1
```

### T2 依赖复现安装 — ✅ 通过

requirements.txt（fastapi==0.142.2 / uvicorn==0.54.0 / redis==8.1.0）在 venv 内安装成功，`pip list` 与 01 §5 清单一致（pydantic 2.13.5 / starlette 1.7.0 为传递依赖）。

### T3 REDIS_URL 缺失 fail-fast — ✅ 通过

过程备注：初次执行误用 `env -u REDIS_URL python …` 包裹，在本机 Git Bash（MSYS）下 `env -u` 启动 Windows exe 会静默失败（无输出、exit 0），属工具链怪癖，与工程无关；确认 shell 环境本就无 REDIS_URL 后直接执行，结论如下。

未注入 REDIS_URL 执行 `python -m app.main`，启动即失败（无半启动、无端口占用，退出码 1）：

```
RuntimeError: 缺少环境变量 REDIS_URL（Redis 连接地址，代码不写死默认值）。
请参考 agent-service/.env.example 配置后再启动。
```

### T4 正常启动 — ✅ 通过

`export REDIS_URL="redis://:***@127.0.0.1:6379/0"` 后启动（密码脱敏记录）：

```
INFO:     Started server process [xxxx]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

启动阶段无 Redis 连接动作（惰性连接，D-01/02/03 落实）。

### T5 health 成功分支 — ✅ 通过

```
$ curl -s http://127.0.0.1:8000/internal/health
{"code":0,"message":"ok"}
```

响应体仅 `code`、`message` 两字段，与 02 §2 契约一致。

### T6 health 失败分支 — ✅ 通过

以 `REDIS_URL="redis://127.0.0.1:6399/0"`（不可达端口）重启后：

```
$ curl -s http://127.0.0.1:8000/internal/health
{"code":1,"message":"redis unavailable"}
```

### T7 惰性连接验证 — ✅ 通过

T6 的服务在 Redis 不可达情况下正常启动并持续服务 `/internal/health`，启动日志无异常、无退出（对应 02 §4：Redis 不可用不阻止服务启动）。

## 4. 自测结论

T1–T7 全部通过，00 §5 验收标准 6 条全部满足。周期 0 完成，具备进入后续周期的工程基座。
