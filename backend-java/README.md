# backend-java — 学分置换 AI 审核协同平台业务后端

Spring Boot 3 业务后端（业务数据唯一权威：business_db）。

## 技术栈

- Java 17 · Spring Boot 3.5.x · Maven
- MySQL（business_db，双库边界见 `deploy/sql/`）
- 周期 0 依赖仅：spring-boot-starter-web / spring-boot-starter-jdbc / mysql-connector-j

## 环境变量（启动必需，无默认值，缺失即启动失败）

| 变量 | 说明 |
|---|---|
| `DB_URL` | JDBC 连接串，库必须为 business_db，例：`jdbc:mysql://127.0.0.1:3306/business_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true` |
| `DB_USERNAME` | 业务库账号（推荐 `business_user`，授权仅 business_db.*） |
| `DB_PASSWORD` | 口令（只走环境变量，禁止写死） |

取值示例见 `src/main/resources/application-example.yml`。

## 启动

```bash
mvn clean package
export DB_URL='...' DB_USERNAME=business_user DB_PASSWORD='...'
java -jar target/backend-java-0.0.1-SNAPSHOT.jar
```

端口：**8080**。

## 健康检查（周期 0 统一契约）

`GET /internal/health` —— 内部真实执行 `SELECT 1`：

- 成功：HTTP 200 `{"code":0,"message":"ok"}`
- MySQL 不可用：HTTP 503 `{"code":1,"message":"mysql unavailable"}`（快速失败，连接超时 5s）

`/internal/*` 为内网接口，不暴露公网。业务 API 走 `/api/*`（契约见 `docs/specs/api/`）。

## 自测

```bash
curl -i http://127.0.0.1:8080/internal/health
```

周期 0 详细方案与实测记录：`docs/specs/2026-10-03/backend-java/`。

> 本 README 由设计总控窗口于周期 0 总体验收时代补（原窗口遗漏交付）。
