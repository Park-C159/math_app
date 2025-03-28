<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'

interface Props {
  src: string | ArrayBuffer // pdf 地址
  width?: string | number // 预览容器宽度
  height?: string | number // 预览容器高度
  pageScale?: number | 'page-actual' | 'page-width' | 'page-height' | 'page-fit' | 'auto' // 页面默认缩放规则
  theme?: 'dark' | 'light' // 预览主题
  fileName?: string // 覆盖 pdf 文件名
}

const props = withDefaults(defineProps<Props>(), {
  src: '',
  width: '100%',
  height: '100%',
  pageScale: 'page-width',
  theme: 'light',
  fileName: ''
})

const emit = defineEmits(['loaded'])

// 状态变量
const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')
const objectUrl = ref<string | null>(null)

// 计算容器样式
const viewerWidth = computed(() => {
  if (typeof props.width === 'number') {
    return `${props.width}px`
  } else {
    return props.width
  }
})

const viewerHeight = computed(() => {
  if (typeof props.height === 'number') {
    return `${props.height}px`
  } else {
    return props.height
  }
})

// 从URL中获取文件名
const getFileNameFromUrl = (url: string): string => {
  try {
    const parts = url.split('/')
    const fileName = parts[parts.length - 1]
    // 解码URL编码的文件名
    return decodeURIComponent(fileName)
  } catch (e) {
    return props.fileName || 'document.pdf'
  }
}

// 加载PDF
const loadPdf = async () => {
  if (!props.src) {
    error.value = true
    errorMessage.value = '未提供PDF源'
    loading.value = false
    return
  }

  loading.value = true
  error.value = false

  try {
    if (typeof props.src === 'string') {
      // 1. 直接使用URL (简单但可能有CORS问题)
      await checkPdfExists(props.src)
      emit('loaded', {
        url: props.src,
        fileName: props.fileName || getFileNameFromUrl(props.src)
      })
      loading.value = false
    } else if (props.src instanceof ArrayBuffer) {
      // 2. 使用ArrayBuffer创建Object URL
      if (objectUrl.value) {
        URL.revokeObjectURL(objectUrl.value)
      }
      const blob = new Blob([props.src], { type: 'application/pdf' })
      objectUrl.value = URL.createObjectURL(blob)
      emit('loaded', {
        url: objectUrl.value,
        fileName: props.fileName || 'document.pdf'
      })
      loading.value = false
    }
  } catch (err) {
    console.error('PDF加载失败:', err)
    loading.value = false
    error.value = true
    errorMessage.value = err instanceof Error ? err.message : '加载PDF文件失败'
  }
}

// 检查PDF是否存在并可以访问
const checkPdfExists = async (url: string): Promise<void> => {
  try {
    const response = await fetch(url, { method: 'HEAD' })
    if (!response.ok) {
      throw new Error(`无法访问PDF文件 (状态码: ${response.status})`)
    }
  } catch (err) {
    console.warn('URL检查失败，可能是CORS限制，尝试直接加载:', err)
    // 不抛出错误，让浏览器尝试直接加载
  }
}

// 监听src变化重新加载PDF
watch(() => props.src, (newSrc) => {
  if (newSrc) {
    loadPdf()
  }
})

// 组件卸载时清理资源
onMounted(() => {
  if (props.src) {
    loadPdf()
  }
})

// 组件销毁时清理Object URL
const cleanupObjectUrl = () => {
  if (objectUrl.value) {
    URL.revokeObjectURL(objectUrl.value)
    objectUrl.value = null
  }
}
</script>

<template>
  <div
    class="pdf-viewer-container"
    :class="[`theme-${theme}`]"
    :style="`width: ${viewerWidth}; height: ${viewerHeight};`"
  >
    <!-- 加载中状态 -->
    <div v-if="loading" class="pdf-loading">
      <div class="loading-spinner"></div>
      <div class="loading-text">加载PDF中...</div>
    </div>

    <!-- 错误状态 -->
    <div v-if="error" class="pdf-error">
      <div class="error-icon">❌</div>
      <div class="error-text">{{ errorMessage }}</div>
      <div class="error-recovery">
        <a :href="src" target="_blank" class="download-link">尝试直接下载</a>
      </div>
    </div>

    <!-- PDF嵌入 - 使用object标签加载PDF -->
    <object
      v-if="!loading && !error && (typeof src === 'string' || objectUrl)"
      class="pdf-object"
      :data="objectUrl || src"
      type="application/pdf"
      :style="`width: 100%; height: 100%; border: none;`"
    >
      <div class="fallback-message">
        <p>您的浏览器无法显示PDF，<a :href="objectUrl || src" target="_blank">点击下载</a></p>
      </div>
    </object>
  </div>
</template>

<style scoped>
.pdf-viewer-container {
  position: relative;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  overflow: hidden;
  background-color: #f5f5f5;
}

.pdf-loading {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.8);
  z-index: 10;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #1677ff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.loading-text {
  margin-top: 10px;
  font-size: 14px;
}

.pdf-error {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 10;
}

.error-icon {
  font-size: 40px;
  margin-bottom: 10px;
}

.error-text {
  font-size: 14px;
  color: #f56c6c;
  margin-bottom: 16px;
  text-align: center;
}

.error-recovery {
  margin-top: 16px;
}

.download-link {
  color: #1677ff;
  text-decoration: none;
}

.download-link:hover {
  text-decoration: underline;
}

.pdf-object {
  display: block;
  width: 100%;
  height: 100%;
}

.fallback-message {
  width: 100%;
  text-align: center;
  padding: 20px;
}

.theme-dark {
  background-color: #333;
  color: #f0f0f0;
  border-color: #444;
}

.theme-light {
  background-color: #f5f5f5;
  color: #333;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>