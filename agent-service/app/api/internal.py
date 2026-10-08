"""/internal/* 内部接口（探活等，内网使用，不暴露公网、不给 Vue 前端）。

周期 0 仅提供 /internal/health；
后续周期按 Spec 00 / 03 / 04 扩展 /runs/*（Agent 管理）与 Tool 执行器相关端点。
"""

from fastapi import APIRouter, Request, Response
from pydantic import BaseModel

router = APIRouter(tags=["internal"])


class HealthResponse(BaseModel):
    """health 响应体：严格只有 code / message 两个字段。"""

    code: int
    message: str


@router.get("/internal/health", response_model=HealthResponse)
async def health(request: Request, response: Response) -> HealthResponse:
    """探活：内部执行一次 Redis PING。

    健康检查契约（周期 0 总体验收统一）：成功 HTTP 200 + {"code":0,...}；
    依赖不可用 HTTP 503 + {"code":1,...}，与 backend-java /internal/health 完全一致。
    """
    try:
        await request.app.state.redis.ping()
    except Exception:  # 连接失败/超时/认证失败等统一归为不可用：探活接口自身不因 Redis 故障变 500
        response.status_code = 503
        return HealthResponse(code=1, message="redis unavailable")
    return HealthResponse(code=0, message="ok")
