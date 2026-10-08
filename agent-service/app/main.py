"""agent-service 入口。

周期 0（项目骨架与基础环境）：FastAPI 骨架 + Redis 连接 + /internal/health。
Agent / LangChain / LangGraph / RAG / Tool / Checkpoint / DeepSeek 属后续周期，本工程不含。
"""

from contextlib import asynccontextmanager

import redis.asyncio as aioredis
from fastapi import FastAPI

from app.api.internal import router as internal_router
from app.config import REDIS_CLIENT_KWARGS, REDIS_URL


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期：创建 Redis 客户端（惰性连接，启动不 PING），关闭时释放。

    Redis 不可用不阻止服务启动，可用性由 /internal/health 运行时探测表达（周期 0 Spec 02 §4）。
    """
    app.state.redis = aioredis.from_url(REDIS_URL, **REDIS_CLIENT_KWARGS)
    yield
    await app.state.redis.aclose()


app = FastAPI(title="agent-service", version="0.1.0", lifespan=lifespan)
app.include_router(internal_router)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
