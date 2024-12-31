<template>
  <div class="flex h-screen">
    <!-- Left Sidebar -->
    <div :class="['transition-all duration-300 bg-gray-100 border-r',
      isCollapsed ? 'w-12' : 'w-64']">
      <div class="sidebar-header">
        <span v-show="!isCollapsed">话题标签</span>
        <el-button type="text" @click="toggleSidebar">
          <el-icon>
            <ArrowLeft v-if="!isCollapsed"/>
            <ArrowRight v-if="isCollapsed"/>
          </el-icon>
        </el-button>
      </div>
      <div class="sidebar-content">
        <div v-show="!isCollapsed" class="tags">
          <el-tag
              v-for="tag in tags"
              :key="tag"
              class="cursor-pointer"
              @click="selectTag(tag)">
            {{ tag }}
          </el-tag>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Left Panel (Text and PDF) -->
      <div class="left-panel">
        <!-- Text Display Area -->
        <div class="text-display">
          请同学们阅读下面的PDF文件并写出自己的心得。
        </div>
        <div>
          <PDFViewer
              page-scale="page-fit"
              :width="800"
              :height="700"
              theme="dark"
              :src="PDFSrc"
              @loaded="onLoaded"/>
        </div>
      </div>

      <!-- Right Panel (Comments) -->
      <div class="right-panel">
        <div class="comments">
          <div v-for="comment in comments" :key="comment.id" class="comment-item">
            <div class="font-bold">{{ comment.user }}</div>
            <div class="text-gray-600">{{ comment.content }}</div>
            <div class="text-sm text-gray-400">{{ comment.time }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {ref} from 'vue'
import {ArrowLeft, ArrowRight} from '@element-plus/icons-vue'
import PDFViewer from './PDFViewer.vue'

const isCollapsed = ref(false)
const tags = ref(['标签1', '标签2', '标签3'])
const PDFSrc = ref('https://cdn.jsdelivr.net/gh/themusecatcher/resources@0.0.3/Markdown.pdf')

function onLoaded (pdfApp: any) {
  console.log('loaded app:', pdfApp)
}

const comments = ref([
  {
    id: 1,
    user: '张三',
    content: '这份课件内容很详细，对我理解知识点很有帮助。',
    time: '2024-01-01 10:30'
  },
  {
    id: 2,
    user: '李四',
    content: '我觉得第三章节的案例分析特别精彩。',
    time: '2024-01-01 11:15'
  },
  {
    id: 3,
    user: '王五',
    content: '希望能多一些实践练习的内容。',
    time: '2024-01-01 14:20'
  }
])

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

const selectTag = (tag: string) => {
  // 处理标签选择逻辑
}
</script>

<style scoped>
/* Main container layout */
.flex {
  display: flex;
}

.h-screen {
  height: 100vh;
}

/* Left Sidebar Styles */
.sidebar-header {
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e5e7eb;
}

.sidebar-content {
  height: calc(100% - 4rem);
  overflow-y: auto;
}

.tags {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

/* Main Content Area */
.main-content {
  display: flex;
  flex: 1;
  color: black;
}

/* Left Panel (Text and PDF) */
.left-panel {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
}

.text-display {
  overflow-y: auto;
  border-bottom: 1px solid #e5e7eb;
}

.content {
  background-color: white;
  border-radius: 0.375rem;
  padding: 1rem;
  height: 100%;
}

/* PDF Iframe */
.pdf-frame {
  width: 100%;
  height: 100%;
}

/* Right Panel (Comments) */
.right-panel {
  width: 50%;
  padding: 1rem;
  overflow-y: auto;
}

.comments {
  background-color: white;
  border-radius: 0.375rem;
  padding: 1rem;
  height: 100%;
}

.comment-item {
  margin-bottom: 1rem;
  padding: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.375rem;
}

.comment-item .font-bold {
  margin-bottom: 0.25rem;
}

/* Sidebar Collapse Animation */
.transition-all {
  transition: all 0.3s ease;
}
</style>
