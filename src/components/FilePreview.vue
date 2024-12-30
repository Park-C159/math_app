<!-- FilePreview.vue -->
<template>
  <div class="file-preview-container" v-if="files.length > 0">
    <div class="preview-section" v-if="images.length > 0">
      <div class="preview-title">图片预览</div>
      <div class="preview-grid">
        <div v-for="(image, index) in images"
             :key="index"
             class="preview-item"
             @click="openPreview(image)">
          <img :src="image.url"
               :alt="image.name || `预览图片 ${index + 1}`"
               class="preview-image"/>
        </div>
      </div>
    </div>

    <div class="preview-section" v-if="pdfs.length > 0">
      <div class="preview-title">PDF文件</div>
      <div class="pdf-list">
        <div v-for="(pdf, index) in pdfs" :key="index" class="pdf-item">
          <div class="pdf-icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
              <path fill="#ff4d4f"
                    d="M20 2H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-8.5 7.5c0 .83-.67 1.5-1.5 1.5H9v2H7.5V7H10c.83 0 1.5.67 1.5 1.5v1zm5 2c0 .83-.67 1.5-1.5 1.5h-2.5V7H15c.83 0 1.5.67 1.5 1.5v3zm4-3H19v1h1.5V11H19v2h-1.5V7h3v1.5zM9 9.5h1v-1H9v1zM4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm10 5.5h1v-3h-1v3z"/>
            </svg>
          </div>
          <a :href="pdf.url" target="_blank" class="pdf-name" :title="pdf.name">{{ pdf.name }}</a>
        </div>
      </div>
    </div>

    <!-- 图片预览模态框 -->
    <div class="image-preview-modal" v-if="showPreview" @click="closePreview">
      <div class="modal-content">
        <img :src="currentImage?.url"
             :alt="currentImage?.name"
             class="preview-full-image"
             @click.stop/>
        <button class="close-button" @click="closePreview">&times;</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {onMounted, onUnmounted, ref, watch} from 'vue';

interface FilePreview {
  url: string;
  name: string;
  type: 'image' | 'pdf';
}

const props = defineProps<{
  content: string
}>();

const files = ref<FilePreview[]>([]);
const images = ref<FilePreview[]>([]);
const pdfs = ref<FilePreview[]>([]);

// 预览相关的状态
const showPreview = ref(false);
const currentImage = ref<FilePreview | null>(null);

// 打开预览
const openPreview = (image: FilePreview) => {
  currentImage.value = image;
  showPreview.value = true;
  // 禁止背景滚动
  document.body.style.overflow = 'hidden';
};

// 关闭预览
const closePreview = () => {
  showPreview.value = false;
  currentImage.value = null;
  // 恢复背景滚动
  document.body.style.overflow = 'auto';
};

// 从markdown内容中提取文件信息
const extractFiles = (content: string) => {
  const fileList: FilePreview[] = [];

  // 提取图片
  const imageRegex = /!\[(.*?)\]\((.*?)\)/g;
  const imageMatches = [...content.matchAll(imageRegex)];
  imageMatches.forEach(match => {
    const name = match[1] || '';
    const url = match[2] || '';
    if (url) {
      fileList.push({url, name, type: 'image'});
    }
  });

  // 提取PDF
  const pdfRegex = /\[PDF文件-(.*?)\]\((.*?)\)/g;
  const pdfMatches = [...content.matchAll(pdfRegex)];
  pdfMatches.forEach(match => {
    const name = match[1] || '';
    const url = match[2] || '';
    if (url) {
      fileList.push({url, name, type: 'pdf'});
    }
  });

  return fileList;
};

// 监听内容变化
watch(() => props.content, (newContent) => {
  files.value = extractFiles(newContent);
  images.value = files.value.filter(file => file.type === 'image');
  pdfs.value = files.value.filter(file => file.type === 'pdf');
}, {immediate: true});

// 添加键盘事件监听，支持ESC关闭预览
onMounted(() => {
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && showPreview.value) {
      closePreview();
    }
  });
});

onUnmounted(() => {
  window.removeEventListener('keydown', (e) => {
    if (e.key === 'Escape' && showPreview.value) {
      closePreview();
    }
  });
});
</script>

<style scoped>
.file-preview-container {
  margin-top: 12px;
  border-top: 1px solid #e4e7ed;
  padding-top: 12px;
}

.preview-section {
  margin-bottom: 16px;
}

.preview-section:last-child {
  margin-bottom: 0;
}

.preview-title {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.preview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 8px;
}

.preview-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: 4px;
  overflow: hidden;
  border: 1px solid #e4e7ed;
  cursor: pointer;
  transition: transform 0.2s;
}

.preview-item:hover {
  transform: scale(1.05);
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.pdf-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.pdf-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
  background-color: #fafafa;
}

.pdf-icon {
  flex-shrink: 0;
}

.pdf-name {
  color: #409eff;
  text-decoration: none;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pdf-name:hover {
  color: #66b1ff;
  text-decoration: underline;
}

/* 图片预览模态框样式 */
.image-preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  position: relative;
  max-width: 90%;
  max-height: 90%;
}

.preview-full-image {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
}

.close-button {
  position: absolute;
  top: -40px;
  right: -40px;
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  color: white;
  font-size: 30px;
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
}

.close-button:hover {
  color: #ddd;
}
</style>