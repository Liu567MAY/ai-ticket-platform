import { createRouter, createWebHistory } from 'vue-router'
import HealthCheckView from '../views/HealthCheckView.vue'

// 周期 0：仅一条联通证明路由；业务路由与导航守卫属后续周期
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'health-check', component: HealthCheckView },
  ],
})

export default router
