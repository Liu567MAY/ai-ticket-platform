# Java 后端周期 0 — 项目骨架与基础环境（方案）

状态：已执行（测试结果见 [01-cycle0-test-report.md](01-cycle0-test-report.md)）
日期：2026-10-03
负责人：Java 后端开发窗口

---

## 1. 周期目标与禁止项

**目标**：backend-java/ 工程可独立启动 + 连通本机 MySQL business_db + 提供 `GET /internal/health` 健康检查接口。

**本周期明确禁止**（任务约束，全文有效）：

- 不做 JWT / Spring Security / 任何鉴权逻辑
- 不建 Entity / Mapper / 业务 Controller / MyBatis
- 不创建业务表、不改 deploy/sql
- 只连接 business_db，禁止连接 agent_db 或其他库
- 只允许写 backend-java/ 与 docs/specs/2026-10-03/backend-java/
- 不做 git 操作

## 2. 环境基线（自测时实测值）

| 项 | 值 |
|---|---|
| JDK | Temurin 17.0.20.1 |
| Maven | 3.9.16（~/.m2/settings.xml 已配 Aliyun 镜像） |
| MySQL | 8.0.44，监听 127.0.0.1:3306 |
| 业务库账号 | business_user@localhost，授权仅 `business_db.*`（与双库边界一致） |
| 端口 | 8080（应用），自测前确认空闲 |

## 3. 工程结构

```
backend-java/
├── pom.xml
└── src/main/
    ├── java/com/aiticket/
    │   ├── AiTicketApplication.java        # 启动类
    │   └── health/
    │       ├── HealthController.java       # GET /internal/health
    │       └── HealthResponse.java         # 健康检查响应体（record，固定字段顺序）
    └── resources/
        ├── application.yml                 # 端口 + 数据源占位符（无任何明文口令）
        └── application-example.yml         # 环境变量注入示例模板（勿作运行配置）
```

**选型与理由**：

| 项 | 选择 | 理由 |
|---|---|---|
| 框架 | Spring Boot 3.5.x（3 系最新补丁） | 任务指定 Spring Boot 3 + Java 17 |
| 依赖 | spring-boot-starter-web、spring-boot-starter-jdbc、mysql-connector-j(runtime) | health 只需 JdbcTemplate 执行 SELECT 1；不引 MyBatis（无 Mapper 需求，留给后续周期） |
| 不引 | Actuator / Security / MyBatis-Plus | 任务禁止或无必要；健康检查为自研轻量接口，契约完全由本周期 Spec 定义 |

**包名** `com.aiticket`：取自仓库名 ai-ticket-platform。

## 4. 环境变量契约

`application.yml` 中数据源三项使用**纯占位符**（无默认值），环境变量缺失时启动即报错（fail-fast），任何口令不落仓库文件：

| 环境变量 | 含义 | 示例值（见 application-example.yml） |
|---|---|---|
| `DB_URL` | 完整 JDBC URL，库名固定 business_db | `jdbc:mysql://127.0.0.1:3306/business_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true` |
| `DB_USERNAME` | 业务库账号 | `business_user` |
| `DB_PASSWORD` | 业务库口令 | 仅存本机环境变量，不写入任何文件 |

JDBC 参数说明：`characterEncoding=UTF-8`（Connector/J 8 规范写法，映射服务端 utf8mb4）；`serverTimezone=Asia/Shanghai`；`useSSL=false + allowPublicKeyRetrieval=true`（本机开发，caching_sha2_password 非 SSL 连接所需）。

**启动方式**（Windows / Git Bash）：

```bash
export DB_URL='jdbc:mysql://127.0.0.1:3306/business_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true'
export DB_USERNAME=business_user
export DB_PASSWORD='<本机口令>'
mvn -f backend-java/pom.xml clean package
java -jar backend-java/target/backend-java-0.0.1-SNAPSHOT.jar
```

## 5. 健康检查契约

`GET /internal/health`

- 行为：内部经 JdbcTemplate 执行 `SELECT 1`（走 HikariCP 连接池，即真实链路验证）
- 成功：HTTP 200，响应体**严格两个字段** `{"code":0,"message":"ok"}`
- 失败（SELECT 1 抛出 DataAccessException）：HTTP 503，响应体严格两个字段 `{"code":1,"message":"mysql unavailable"}`

**路径空间说明**：`/internal/*` 不属于 `/api` 前端空间（与 docs/specs/api/00-api-boundary.md 的分类原则一致）；本接口服务于开发期环境验证，非前端 API、非 Tool API。

**周期 0 自定决策**（待全局 HTTP 规范定稿时对齐，见 Spec 00 §7 TBD）：

1. 失败时 HTTP 状态码取 503（Service Unavailable，健康检查语义惯例）；成功 200。业务体 code 仅 0/1。
2. HikariCP `connection-timeout=5s`：健康检查需快速失败（默认 30s 对健康检查过长；本地业务查询也不应超过该上限）。
3. 响应体字段顺序固定为 code → message（用 record 组件声明序保证，不用 Map.of——其迭代顺序不确定）。
4. 失败日志记 warn 级别（含异常摘要），便于排查但不对响应体泄露任何细节。

## 6. 自测计划

| # | 用例 | 操作 | 预期 |
|---|---|---|---|
| T1 | 构建 | `mvn clean package` | BUILD SUCCESS |
| T2 | 正常启动 | 三环境变量注入后 `java -jar`，连接真实 business_db | 日志出现 Tomcat 8080、Hikari 池名、Started 行 |
| T3 | health 成功路径 | `curl http://127.0.0.1:8080/internal/health` | HTTP 200，报文逐字节等于 `{"code":0,"message":"ok"}` |
| T4 | health 失败路径 | 同 jar 另起实例（--server.port=8081），DB_URL 指向未监听端口 127.0.0.1:3399（模拟 MySQL 不可达，不触碰真实 MySQL 服务、不连接任何其他库） | HTTP 503，报文逐字节等于 `{"code":1,"message":"mysql unavailable"}` |
| T5 | 口令外置复核 | 检查仓库内 backend-java 全部文件 | 无任何明文口令；application.yml 无默认值占位符 |

T4 说明：指向关闭端口不会与任何 MySQL 建立连接（TCP 直接被拒），仅用于验证失败分支，不违反"禁止连接 business_db 之外库"约束。
