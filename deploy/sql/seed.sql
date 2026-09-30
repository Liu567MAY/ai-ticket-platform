-- ============================================================
-- seed.sql — business_db 初始化数据（首次部署执行一次，勿重复执行）
-- 执行前提：business_db.sql 已执行
-- 测试密码统一为 123456（BCrypt 密文，$2a$10，已验证可被
-- Spring Security BCryptPasswordEncoder.matches 正确匹配）
-- ============================================================

USE business_db;

-- ------------------------------------------------------------
-- 角色（role 1:N user）
-- ------------------------------------------------------------
INSERT INTO role (id, role_code, role_name) VALUES
(1, 'STUDENT', '学生'),
(2, 'TEACHER', '政教处/教务审核老师'),
(3, 'ADMIN',   '系统管理员');

-- ------------------------------------------------------------
-- 权限码全集（14 项）
-- STUDENT：申请与材料；TEACHER：复核与终审；ADMIN：系统与 Agent 治理
-- ------------------------------------------------------------
INSERT INTO permission (id, perm_code, perm_name) VALUES
( 1, 'application:submit',      '提交学分置换申请'),
( 2, 'application:read:own',    '查看本人申请'),
( 3, 'material:upload',         '上传/补交材料'),
( 4, 'application:read:all',    '查看全部申请'),
( 5, 'review:confirm',          '复核确认 AI 审核结果'),
( 6, 'review:modify',           '修改 AI 审核结果'),
( 7, 'review:return',           '退回补材料'),
( 8, 'approval:decide',         '最终审批（同意/驳回）'),
( 9, 'system:user:manage',      '用户管理'),
(10, 'system:config:manage',    '系统配置管理'),
(11, 'kb:manage',               '审核规则知识库管理'),
(12, 'agent:run:read',          '查看 Agent 运行记录与 Trace'),
(13, 'agent:evaluation:read',   '查看评估结果'),
(14, 'agent:experience:manage', '经验库管理');

-- ------------------------------------------------------------
-- 角色-权限关联
-- ------------------------------------------------------------
INSERT INTO role_permission (role_id, permission_id) VALUES
-- STUDENT：提交 / 看自己 / 传材料
(1, 1), (1, 2), (1, 3),
-- TEACHER：看全部 / 复核确认 / 修改 / 退回 / 终审
(2, 4), (2, 5), (2, 6), (2, 7), (2, 8),
-- ADMIN：用户 / 配置 / 知识库 / Run / 评估 / 经验
(3, 9), (3, 10), (3, 11), (3, 12), (3, 13), (3, 14);

-- ------------------------------------------------------------
-- 测试账号（密码均为 123456，BCrypt 密文）
-- wecom_userid 留 NULL：开发期通知走 Mock
-- ------------------------------------------------------------
-- 管理员
INSERT INTO user (id, role_id, username, password, real_name, student_no, college, major, class_name, wecom_userid, status) VALUES
(1, 3, 'admin',    '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '系统管理员', NULL,      NULL,     NULL,             NULL,      NULL, 1);
-- 审核老师
INSERT INTO user (id, role_id, username, password, real_name, student_no, college, major, class_name, wecom_userid, status) VALUES
(2, 2, 'T0001',    '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '周老师',     NULL,      NULL,     NULL,             NULL,      NULL, 1),
(3, 2, 'T0002',    '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '陈老师',     NULL,      NULL,     NULL,             NULL,      NULL, 1);
-- 学生
INSERT INTO user (id, role_id, username, password, real_name, student_no, college, major, class_name, wecom_userid, status) VALUES
(4, 1, 'S2022001', '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '张三', 'S2022001', '信息学院', '计算机科学与技术', '计科2201', NULL, 1),
(5, 1, 'S2022002', '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '李四', 'S2022002', '信息学院', '软件工程',         '软工2201', NULL, 1),
(6, 1, 'S2022003', '$2a$10$L85AnGHMmSK1eYPiU8XhdOQNPKQIbVzuCQXEoCUC15oGY41wDWd6y', '王五', 'S2022003', '信息学院', '软件工程',         '软工2202', NULL, 1);
