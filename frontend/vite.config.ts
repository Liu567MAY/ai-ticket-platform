import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // 周期 0 探活：浏览器只同源访问 5173，跨域一律由 dev 代理解决（Java 零 CORS 配置）
      // 路径不做 rewrite：Java 端点即 GET /internal/health
      '/internal': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
