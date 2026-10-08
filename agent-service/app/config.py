"""环境变量配置。

周期 0 只有 Redis 连接配置。
决策 D-01（fail-fast，无默认值）：代码不提供任何默认 Redis 地址，
REDIS_URL 必须由环境注入（参考 .env.example），缺失时启动即失败，
让"环境未配置"在启动瞬间暴露，而不是被 health 的 code=1 掩盖。
"""

import os

REDIS_URL: str = os.environ.get("REDIS_URL", "")

if not REDIS_URL:
    raise RuntimeError(
        "缺少环境变量 REDIS_URL（Redis 连接地址，代码不写死默认值）。"
        "请参考 agent-service/.env.example 配置后再启动。"
    )

# 决策 D-02：探活超时（秒）为代码常量而非环境变量——health 是内部探活接口，
# 必须快速失败，该值不具环境差异性
REDIS_HEALTH_TIMEOUT_SECONDS: float = 2.0

# from_url 额外参数：连接超时与命令超时各 2s，health 客户端与后续周期共用同一参数基准
REDIS_CLIENT_KWARGS: dict = {
    "socket_connect_timeout": REDIS_HEALTH_TIMEOUT_SECONDS,
    "socket_timeout": REDIS_HEALTH_TIMEOUT_SECONDS,
}
