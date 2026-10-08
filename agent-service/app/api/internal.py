"""/internal/* 内部接口（探活等，内网使用，不暴露公网、不给 Vue 前端）。

周期 0 仅提供 /internal/health；
后续周期按 Spec 00 / 03 / 04 扩展 /runs/*（Agent 管理）与 Tool 执行器相关端点。
"""

from fastapi import APIRouter, Request
from pydantic import BaseModel

router = APIRouter(tags=["internal"])


class HealthResponse(BaseModel):
    """health 响应体：严格只有 code / message 两个字段。"""

    code: int
    message: str


@router.get("/internal/health", response_model=HealthResponse)
async def health(request: Request) -> HealthResponse:
    """探活：内部执行一次 Redis PING。

    HTTP 状态码恒为 200，成功与否由响应体 code 字段表达（决策 D-04，见周期 0 Spec 02）。
    """
    try:
        await request.app.state.redis.ping()
    except Exception:  # 连接失败/超时/认证失败等统一归为不可用：探活接口自身不因 Redis 故障变 500
        return HealthResponse(code=1, message="redis unavailable")
    return HealthResponse(code=0, message="ok")
