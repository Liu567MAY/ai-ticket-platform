# Java 后端周期 0 — 自测记录与结果

状态：已完成（2026-10-03）
关联方案：[00-cycle0-plan.md](00-cycle0-plan.md)

---

## 1. 测试环境

| 项 | 值 |
|---|---|
| JDK | Temurin 17.0.20.1 |
| Maven | 3.9.16（Aliyun 镜像） |
| MySQL | 8.0.44 @ 127.0.0.1:3306 |
| 账号 | business_user@localhost（授权仅 business_db.*，实测 GRANTS 确认） |
| 被测构件 | backend-java/target/backend-java-0.0.1-SNAPSHOT.jar |

## 2. 用例结果

| # | 用例 | 结果 | 证据摘要 |
|---|---|---|---|
| T1 | Maven 构建 | ✅ 通过 | `BUILD SUCCESS`，Total time 01:15 min |
| T2 | 正常启动 | ✅ 通过 | 启动日志关键行见 §3 |
| T3 | health 成功路径 | ✅ 通过 | `curl http://127.0.0.1:8080/internal/health` → HTTP 200，报文逐字节 `{"code":0,"message":"ok"}`，Content-Type: application/json |
| T4 | health 失败路径 | ✅ 通过 | 同 jar 另起实例（--server.port=8081），DB_URL 指向未监听的 127.0.0.1:3399 → HTTP 503，报文逐字节 `{"code":1,"message":"mysql unavailable"}`；请求发出约 1.1s 快速失败，日志出现 `WARN ... HealthController : MySQL 健康检查失败: Failed to obtain JDBC Connection` |
| T5 | 口令外置复核 | ✅ 通过 | 对 backend-java/ 全部 .yml/.xml/.java 扫描 `123456` 无命中；application.yml 数据源三项为纯占位符 `${DB_URL}` / `${DB_USERNAME}` / `${DB_PASSWORD}`，无默认值 |

T4 说明：目标端口未监听，TCP 握手即被拒绝，未与任何 MySQL 实例建立连接，不涉及 business_db 之外的库。

## 3. 启动日志关键行（T2，实例 1）

```text
:: Spring Boot ::               (v3.5.16)
INFO ... AiTicketApplication : Starting AiTicketApplication v0.0.1-SNAPSHOT using Java 17.0.20.1 with PID 17880
INFO ... TomcatWebServer  : Tomcat initialized with port 8080 (http)
INFO ... TomcatWebServer  : Tomcat started on port 8080 (http) with context path '/'
INFO ... AiTicketApplication : Started AiTicketApplication in 2.445 seconds (process running for 2.898)
INFO ... HikariDataSource : business-db-pool - Starting...
INFO ... HikariPool       : business-db-pool - Added connection com.mysql.cj.jdbc.ConnectionImpl@24bf4a07
INFO ... HikariDataSource : business-db-pool - Start completed.
```

（Hikari 三行出现在首次 health 请求时——连接池按需初始化，属 Spring Boot + Hikari 默认行为。）

## 4. health 响应报文（实测原文）

成功（实例 1，连真实 business_db）：

```
HTTP/1.1 200
Content-Type: application/json

{"code":0,"message":"ok"}
```

失败（实例 2，DB 不可达模拟）：

```
HTTP/1.1 503

{"code":1,"message":"mysql unavailable"}
```

## 5. 结论

周期 0 全部用例通过：工程可独立构建、启动；经环境变量注入连通 business_db（真实 SELECT 1 链路验证）；健康检查成功/失败两条路径报文均严格为约定两字段；无任何明文口令落仓库。满足本周期验收标准。
