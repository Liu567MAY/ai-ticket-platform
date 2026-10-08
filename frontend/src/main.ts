import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from './App.vue'
import router from './router'

// 周期 0：仅完成 Router / Pinia 最小接线；不建业务 store、页面、守卫（属后续周期）
createApp(App).use(createPinia()).use(router).mount('#app')
