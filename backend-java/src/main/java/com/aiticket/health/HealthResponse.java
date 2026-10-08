package com.aiticket.health;

/**
 * 健康检查响应体。
 *
 * <p>使用 record 固定两个字段及其序列化顺序（code 在前、message 在后），
 * 保证成功报文逐字节为 {"code":0,"message":"ok"}。
 *
 * @param code    0=健康，1=MySQL 不可用
 * @param message ok / mysql unavailable
 */
public record HealthResponse(int code, String message) {
}
