package com.aiticket;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 学分置换 AI 审核协同平台 —— Spring Boot 业务后端启动类。
 *
 * <p>本服务是整个系统的业务唯一权威层：用户权限、业务状态、业务事务均由本服务裁决；
 * Agent 服务（FastAPI）对业务数据的任何读写必须经 /internal/tools/* 回到本服务。
 *
 * <p>当前进度：周期 0（项目骨架与基础环境）——仅工程骨架、business_db 数据源连通、
 * /internal/health 健康检查；无 JWT / Security / Entity / Mapper / 业务接口。
 */
@SpringBootApplication
public class AiTicketApplication {

    public static void main(String[] args) {
        SpringApplication.run(AiTicketApplication.class, args);
    }
}
