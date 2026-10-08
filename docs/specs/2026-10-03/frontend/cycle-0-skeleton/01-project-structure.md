# 周期 0 · Frontend — 工程结构与依赖

## 1. 目录结构（本周期交付后）

```
frontend/
├── index.html                  # Vite 入口 HTML（lang=zh-CN，标题=学分置换 AI 审核协同平台 · 周期 0 联通验证）
├── package.json                # scripts / engines(node >=20)
├── vite.config.ts              # vue 插件 + dev 代理（见 02）
├── tsconfig.json / tsconfig.app.json / tsconfig.node.json
├── .env.example                # 环境变量模板（本周期无必需变量，见 §4）
├── .gitignore                  # 脚手架默认（node_modules / dist 等）
├── README.md                   # 工程自述（启动方式 / 代理 / Spec 链接）
├── public/
│   └── favicon.svg
└── src/
    ├── main.ts                 # createApp → use(pinia) → use(router) → mount
    ├── App.vue                 # 仅 <RouterView />，无业务布局
    ├── style.css               # 极简全局样式（系统字体栈）
    ├── router/
    │   └── index.ts            # 单路由：/ → HealthCheckView；无守卫
    ├── views/
    │   └── HealthCheckView.vue # 联通证明页（唯一页面）
    └── vite-env.d.ts
```

脚手架默认的 `components/HelloWorld.vue`、`assets/vue.svg` 等演示资产随创建即删除，保持骨架干净。

## 2. 依赖清单

| 包 | 类型 | 版本策略 | 用途 |
|---|---|---|---|
| vue | dependencies | 脚手架默认（^3.x） | 框架 |
| vue-router | dependencies | ^4.x | 最小接线：单路由注册（禁止守卫，后续周期才需要） |
| pinia | dependencies | ^3.x | 最小接线：`app.use(createPinia())`；本周期不建任何 store |
| axios | dependencies | ^1.x | 联通页直接 `import axios` 调用；**不建**任何封装/拦截器 |
| vite / @vitejs/plugin-vue / typescript / vue-tsc | devDependencies | 脚手架默认 | 构建 / 类型 |

安装命令：脚手架生成后 `npm install` + `npm install vue-router@4 pinia axios`。

## 3. package.json 约定

```jsonc
{
  "engines": { "node": ">=20" }   // 任务要求 Node 20 LTS 基线；本机实测 24.20.0，见 00 §3
}
```

scripts 保持脚手架默认：`dev`（vite）、`build`（vue-tsc -b && vite build，含类型检查）、`preview`。脚手架无独立 type-check 脚本，类型检查内置于 build。

## 4. .env.example

本周期**无必需环境变量**。文件内容以注释说明：

- Vite 环境变量必须以 `VITE_` 前缀才会暴露给客户端代码；
- 当前联通页使用相对路径 `/internal/health`，经 dev 代理转发，因此**无需配置后端地址**；
- 后续周期如引入（例如构建期 API base），在此文件追加示例，绝不提交真实密钥。

## 5. 设计边界说明

- 不引入 UI 组件库、CSS 框架、状态管理封装、请求封装——正式 UI 与封装属后续周期，按 DESIGN.md 与 API Spec 另行设计。
- 联通页是"工程联通证明"，非业务 UI：允许出现 HTTP 状态码 / JSON 报文等技术信息，周期结束不迁移、不复用为业务页面基础。
