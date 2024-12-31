<script setup lang="ts">
import {ref} from 'vue'
import {ElMessage} from 'element-plus'
import type {UploadRequestOptions} from 'element-plus'
import {getCurrentInstance} from 'vue'

const instance = getCurrentInstance()
const proxy = instance?.proxy

const props = defineProps<{
  // 是否显示上传进度
  showProgress?: boolean
}>()

const emit = defineEmits<{
  'upload-success': [content: string]
}>()

// 常量定义
const FILE_SIZE_LIMIT = 20 // 20MB
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/bmp']
const ALLOWED_PDF_TYPE = 'application/pdf'

// 状态管理
const loading = ref(false)
const uploadProgress = ref(0)

// 文件类型检查
const beforeUpload = (file: File) => {
  const isAllowedType = [...ALLOWED_IMAGE_TYPES, ALLOWED_PDF_TYPE].includes(file.type)
  const isLt20M = file.size / 1024 / 1024 < FILE_SIZE_LIMIT

  if (!isAllowedType) {
    ElMessage({
      type: 'error',
      message: '只能上传图片或PDF文件！'
    })
    return false
  }

  if (!isLt20M) {
    ElMessage({
      type: 'error',
      message: `文件大小不能超过 ${FILE_SIZE_LIMIT}MB!`
    })
    return false
  }

  return true
}

// 获取文件显示格式
const getFileDisplayFormat = (fileType: string) => {
  if (ALLOWED_IMAGE_TYPES.includes(fileType)) {
    return 'image'
  } else if (fileType === ALLOWED_PDF_TYPE) {
    return 'pdf'
  }
  return null
}

// 生成插入内容
const generateInsertContent = (url: string, fileType: string, fileName: string) => {
  const displayFormat = getFileDisplayFormat(fileType)

  if (displayFormat === 'image') {
    return `![图片-${fileName}](http://127.0.0.1:5000/api${url})`
  } else if (displayFormat === 'pdf') {
    return `[PDF文件-${fileName}](http://127.0.0.1:5000/api${url})`
  }
  return ''
}

// 自定义上传方法
const customUpload = async (options: UploadRequestOptions) => {
  const file = options.file
  loading.value = true
  uploadProgress.value = 0

  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('file_type', file.type === ALLOWED_PDF_TYPE ? 'pdf' : 'image')

    const response: any = await proxy?.$http.post("/upload", formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.code === 200) {
      const insertContent = generateInsertContent(
          response.data.data,
          file.type,
          file.name
      )

      emit('upload-success', insertContent)

      ElMessage({
        type: 'success',
        message: '文件上传成功'
      })

      options.onSuccess?.(response)
    } else {
      throw new Error(response.data.msg || '上传失败')
    }
  } catch (error: any) {
    console.error('上传错误:', error)
    ElMessage({
      type: 'error',
      message: error instanceof Error ? error.message : '服务器错误，请联系管理员'
    })
    options.onError?.(error)
  } finally {
    loading.value = false
    uploadProgress.value = 0
  }
}
</script>

<template>
  <el-upload
      class="upload-demo"
      :http-request="customUpload"
      :auto-upload="true"
      :show-file-list="false"
      :before-upload="beforeUpload"
      accept=".jpg,.jpeg,.png,.gif,.webp,.pdf"
  >
    <template #trigger>
      <el-button :loading="loading" icon="Upload" plain>
        <template v-if="showProgress && loading">
          上传中 {{ uploadProgress }}%
        </template>
        <template v-else>
          上传
        </template>
      </el-button>
    </template>
  </el-upload>
</template>

<style scoped>
.upload-demo {
  display: inline-block;
}
</style>