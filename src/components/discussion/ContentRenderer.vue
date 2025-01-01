<template>
  <div class="content-renderer">
    <template v-for="(item, index) in parsedContent" :key="index">
      <img v-if="item.type === 'image'"
           :src="item.url"
           :alt="item.alt"
           class="content-image"
           @click="handleImageClick(item.url)"/>

      <div v-else-if="item.type === 'pdf'" class="pdf-preview">
        <div class="pdf-header">
          <span class="pdf-icon">
            <el-icon><Document/></el-icon>
          </span>
          <a :href="item.url"
             target="_blank"
             class="pdf-link"
             :title="item.name">
            {{ item.name }}
          </a>
        </div>

        <!-- PDFViewer 仅在点击预览时显示 -->
        <div v-if="pdfStates[index] && pdfStates[index].rendered">
          <PDFViewer
              page-scale="page-fit"
              :width="800"
              :height="700"
              theme="dark"
              :src="item.url"/>
        </div>

        <template v-if="pdfStates[index]">
          <div v-if="pdfStates[index].loading" class="pdf-loading">
            <el-icon class="is-loading">
              <Loading/>
            </el-icon>
            加载中...
          </div>
        </template>

        <!-- 显示点击预览或关闭按钮 -->
        <el-button v-if="!pdfStates[index]?.rendered"
                   type="primary"
                   link
                   @click="initPdfState(index)">
          点击预览 PDF
        </el-button>

        <!-- 显示隐藏PDF按钮 -->
        <el-button v-else
                   type="danger"
                   link
                   @click="togglePdfViewer(index)">
          隐藏 PDF
        </el-button>
      </div>

      <span v-else>{{ item.text }}</span>
    </template>

    <!-- 图片预览弹窗 -->
    <el-dialog
        v-model="imagePreviewVisible"
        :append-to-body="true"
        width="80%"
        align-center>
      <img :src="currentPreviewImage" style="width: 100%; height: auto;" alt=""/>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import {ref, computed} from 'vue';
import VuePdfApp from "vue3-pdf-app";
import {Document, Loading} from '@element-plus/icons-vue';
import PDFViewer from "@/components/PDFViewer.vue";

const props = defineProps<{
  content: string
}>();

interface ContentItem {
  type: 'text' | 'image' | 'pdf';
  text?: string;
  url?: string;
  alt?: string;
  name?: string;
}

interface PdfState {
  loading: boolean;
  error: boolean;
  rendered: boolean;
}

const imagePreviewVisible = ref(false);
const currentPreviewImage = ref('');
const pdfStates = ref<Record<number, PdfState>>({});

const parsedContent = computed(() => {
  const items: ContentItem[] = [];
  const content = props.content || '';
  let lastIndex = 0;

  // 正则表达式匹配图片和PDF链接
  const regex = /!\[(.*?)\]\((.*?)\)|\[PDF文件-(.*?)\]\((.*?)\)/g;
  let match;

  while ((match = regex.exec(content)) !== null) {
    // 添加匹配前的文本
    if (match.index > lastIndex) {
      items.push({
        type: 'text',
        text: content.slice(lastIndex, match.index)
      });
    }

    // 判断是图片还是PDF
    if (match[0].startsWith('![')) {
      items.push({
        type: 'image',
        alt: match[1],
        url: match[2]
      });
    } else {
      items.push({
        type: 'pdf',
        name: match[3],
        url: match[4]
      });
    }

    lastIndex = match.index + match[0].length;
  }

  // 添加剩余文本
  if (lastIndex < content.length) {
    items.push({
      type: 'text',
      text: content.slice(lastIndex)
    });
  }

  return items;
});

const handleImageClick = (url: string) => {
  currentPreviewImage.value = url;
  imagePreviewVisible.value = true;
};

const initPdfState = (index: number) => {
  pdfStates.value[index] = {
    loading: true,
    error: false,
    rendered: false
  };
  // 模拟加载完成
  setTimeout(() => {
    pdfStates.value[index].loading = false;
    pdfStates.value[index].rendered = true;
  }, 1500); // 延迟 1.5 秒模拟加载
};

const togglePdfViewer = (index: number) => {
  // 隐藏 PDF 时将 rendered 设置为 false
  if (pdfStates.value[index]) {
    pdfStates.value[index].rendered = false;
  }
};
</script>

<style scoped>
.content-renderer {
  word-break: break-word;
}

.content-image {
  max-width: 200px;
  max-height: 200px;
  margin: 8px;
  cursor: pointer;
  border-radius: 4px;
  transition: transform 0.2s;
}

.content-image:hover {
  transform: scale(1.05);
}

.pdf-preview {
  margin: 8px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 12px;
}

.pdf-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.pdf-icon {
  color: #ff4d4f;
  margin-right: 8px;
}

.pdf-link {
  color: #409eff;
  text-decoration: none;
  word-break: break-all;
}

.pdf-link:hover {
  text-decoration: underline;
}

.pdf-viewer {
  margin-top: 12px;
  max-height: 500px;
  overflow-y: auto;
}

.pdf-loading,
.pdf-error {
  text-align: center;
  padding: 20px;
  color: #909399;
}

.pdf-error {
  color: #f56c6c;
}

.is-loading {
  animation: rotating 2s linear infinite;
}

@keyframes rotating {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
