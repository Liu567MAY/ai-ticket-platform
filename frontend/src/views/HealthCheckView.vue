<script setup lang="ts">
import { onMounted, ref } from 'vue'
import axios from 'axios'

// 周期 0 联通证明页（非业务 UI）：加载即探活 GET /internal/health，
// 直接调用 axios，不建任何请求封装层（正式封装属后续周期，按 API Spec 另行设计）。

type Phase = 'loading' | 'success' | 'error'

const phase = ref<Phase>('loading')
const httpStatus = ref<number | null>(null)
const code = ref<number | null>(null)
const message = ref('')
const rawJson = ref('')
const errorText = ref('')

async function check(): Promise<void> {
  phase.value = 'loading'
  httpStatus.value = null
  code.value = null
  message.value = ''
  rawJson.value = ''
  errorText.value = ''
  try {
    const res = await axios.get('/internal/health')
    phase.value = 'success'
    httpStatus.value = res.status
    const data = res.data as { code?: number; message?: string }
    code.value = data?.code ?? null
    message.value = data?.message ?? ''
    rawJson.value = JSON.stringify(res.data)
  } catch (err: unknown) {
    phase.value = 'error'
    if (axios.isAxiosError(err)) {
      httpStatus.value = err.response?.status ?? null
      const data = err.response?.data as { code?: number; message?: string } | undefined
      code.value = data?.code ?? null
      message.value = data?.message ?? ''
      rawJson.value = err.response ? JSON.stringify(err.response.data) : ''
      errorText.value = err.response
        ? err.response.status === 502 || err.response.status === 504
          ? `代理层错误：Vite 代理无法连接 Java（检查 8080 是否启动）`
          : `服务返回 HTTP ${err.response.status}（请求已到达 Java）`
        : `网络错误：${err.message}（请求未到达 Vite 代理，检查 5173 dev server）`
    } else {
      errorText.value = `未知错误：${String(err)}`
    }
  }
}

onMounted(check)
</script>

<template>
  <main class="health-page">
    <h1>周期 0 · 前端 ↔ Java 联通证明页</h1>
    <p class="desc">
      <code>GET /internal/health</code>，经 Vite 代理转发至 <code>http://localhost:8080</code>（探活页，非业务 UI）
    </p>

    <div class="actions">
      <button type="button" :disabled="phase === 'loading'" @click="check">重新检测</button>
    </div>

    <section v-if="phase === 'loading'" class="panel" aria-live="polite">检测中…</section>

    <section v-else-if="phase === 'success'" class="panel success" aria-live="polite">
      <p class="verdict">联通成功</p>
      <dl>
        <dt>HTTP 状态</dt>
        <dd>{{ httpStatus }}</dd>
        <dt>code</dt>
        <dd>{{ code }}</dd>
        <dt>message</dt>
        <dd>{{ message }}</dd>
      </dl>
      <pre class="raw">{{ rawJson }}</pre>
    </section>

    <section v-else class="panel error" aria-live="polite">
      <p class="verdict">联通失败</p>
      <dl>
        <template v-if="httpStatus !== null">
          <dt>HTTP 状态</dt>
          <dd>{{ httpStatus }}</dd>
        </template>
        <template v-if="message">
          <dt>message</dt>
          <dd>{{ message }}</dd>
        </template>
        <dt>错误说明</dt>
        <dd>{{ errorText }}</dd>
      </dl>
      <pre v-if="rawJson" class="raw">{{ rawJson }}</pre>
    </section>
  </main>
</template>

<style scoped>
.health-page {
  max-width: 640px;
  margin: 48px auto;
  padding: 0 16px;
}

h1 {
  font-size: 19px;
  font-weight: 600;
}

.desc {
  color: #5a6167;
  font-size: 13px;
}

.desc code,
.raw {
  font-family: Consolas, 'Courier New', monospace;
}

.actions {
  margin: 16px 0;
}

button {
  padding: 6px 16px;
  border: 1px solid #cdd1cd;
  border-radius: 6px;
  background: #fff;
  cursor: pointer;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.panel {
  padding: 16px;
  border: 1px solid #e2e4e1;
  border-radius: 8px;
  background: #fff;
}

.panel.success {
  border-color: #1f7a4d;
  background: #e8f2ed;
}

.panel.error {
  border-color: #c13a2b;
  background: #faedeb;
}

.verdict {
  margin: 0 0 12px;
  font-weight: 600;
}

dl {
  display: grid;
  grid-template-columns: 96px 1fr;
  gap: 4px 12px;
  margin: 0 0 12px;
  font-size: 14px;
}

dt {
  color: #5a6167;
}

dd {
  margin: 0;
}

.raw {
  margin: 0;
  padding: 8px;
  border-radius: 4px;
  background: #f0f2f4;
  font-size: 13px;
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
