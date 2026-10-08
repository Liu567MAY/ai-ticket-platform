package com.aiticket.health;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 周期 0 健康检查：GET /internal/health。
 *
 * <p>内部经连接池真实执行 SELECT 1 验证 business_db 连通性（走完整 JDBC 链路，
 * 而非仅检查进程存活）。
 *
 * <p>路径挂在 /internal 下，不属于 /api 前端空间（见 docs/specs/api/00-api-boundary.md）。
 * 响应契约见 docs/specs/2026-10-03/backend-java/00-cycle0-plan.md §5：
 * 成功 200 {"code":0,"message":"ok"}；失败 503 {"code":1,"message":"mysql unavailable"}。
 */
@RestController
public class HealthController {

    private static final Logger log = LoggerFactory.getLogger(HealthController.class);

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/internal/health")
    public ResponseEntity<HealthResponse> health() {
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return ResponseEntity.ok(new HealthResponse(0, "ok"));
        } catch (DataAccessException e) {
            // 只向调用方暴露固定文案；异常细节进日志便于排查
            log.warn("MySQL 健康检查失败: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(new HealthResponse(1, "mysql unavailable"));
        }
    }
}
