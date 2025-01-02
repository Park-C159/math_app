<template>
  <div class="flex h-screen">
    <!-- Left Sidebar -->
    <div class="tags-container" :class="{ 'collapsed': isCollapsed }">
      <div class="sidebar-header">
        <span v-show="!isCollapsed" class="title-text">话题标签</span>
        <el-button type="text" @click="toggleSidebar">
          <el-icon>
            <ArrowLeft v-if="!isCollapsed"/>
            <ArrowRight v-if="isCollapsed"/>
          </el-icon>
        </el-button>
      </div>
      <div class="sidebar-content" v-show="!isCollapsed">
        <div class="tags">
          <el-tag
              v-for="tag in tags"
              :key="tag.id"
              class="tag-button"
              :class="{ 'active': selectedTagId === tag.id }"
              @click="selectTag(tag)">
            {{ tag.name }}
          </el-tag>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="main-content" v-if="currentContent">
      <div class="top-panel">
        <content-renderer :content="currentContent.description+'[PDF文件-附件]('+currentContent.pdfUrl+')'"/>
      </div>

      <div class="bottom-panel">
        <div v-for="comment in currentContent.comments"
             :key="comment.id"
             class="comment-item">
          <div class="content-head">
            <el-avatar :icon="UserFilled"/>
            <div class="font-bold">{{ comment.user }}</div>
            <div class="text-sm text-gray-400">{{ comment.time }}</div>
          </div>
          <ContentRenderer :content="comment.content"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {ref, reactive, getCurrentInstance} from 'vue'
import {ArrowLeft, ArrowRight, UserFilled} from '@element-plus/icons-vue'
import 'mavon-editor/dist/css/index.css'
import ContentRenderer from "@/components/discussion/ContentRenderer.vue";

interface Comment {
  id: number
  user: string
  content: string
  time: string
}

interface TagContent {
  description: string
  pdfUrl: string
  comments: Comment[]
}

interface Tag {
  id: number
  name: string
}

const instance = getCurrentInstance();
const proxy = instance?.proxy;
const isCollapsed = ref(true)
const selectedTagId = ref<number | null>(null)
const tags = ref<Tag[]>([])
const tagContents = reactive<Record<number, TagContent>>({})
const currentContent = ref<TagContent | null>(null)

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

const fetchTags = async () => {
  try {
    const response: any = await proxy?.$http.get('/tags')
    tags.value = response.data
    if (tags.value.length > 0) {
      await selectTag(tags.value[0])
    }
  } catch (error) {
    console.error('Error fetching tags:', error)
  }
}

const fetchTagContent = async (tagId: number) => {
  try {
    const response: any = await proxy?.$http.get(`/topics/${tagId}`)
    tagContents[tagId] = response.data[tagId]
    currentContent.value = tagContents[tagId]
  } catch (error: any) {
    console.error(`Error fetching content for tag ${tagId}:`, error)
  }
}

const selectTag = async (tag: Tag) => {
  selectedTagId.value = tag.id
  if (!tagContents[tag.id]) {
    await fetchTagContent(tag.id)
  } else {
    currentContent.value = tagContents[tag.id]
  }
}

fetchTags()
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
.tags-container {
  border: 2px solid white;
  border-radius: 0.375rem;
  background: white;
  transition: all 0.3s ease;
  width: 300px;
  overflow: hidden;
  z-index: 2;
}

.tags-container.collapsed {
  background: transparent;
  border-color: transparent;
  width: 50px;
}


.sidebar-header {
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e5e7eb;
  white-space: nowrap;
}

.title-text {
  transition: opacity 0.2s ease;
  color: black;
}

.sidebar-content {
  transition: opacity 0.3s ease;
  opacity: 1;
}

.tags {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  white-space: nowrap;
}

.tag-button {
  width: 100%;
  text-align: left;
  white-space: normal !important;
  height: auto !important;
  padding: 8px 12px !important;
  margin-bottom: 8px;
  word-break: break-word;
  line-height: 1.4;
}

.tag-button.active {
  background-color: #e6f7ff;
  border-color: #1890ff;
  color: #1890ff;
}


/* Main Content Area */
.main-content {
  display: table-column;
  flex: 1;
  color: black;
}

.bottom-panel,
.top-panel {
  background: white;
  width: 100%;
  gap: 1rem;
  padding: 1rem;
  border: 2px solid white;
  border-radius: 0.375rem;
  margin: 1rem;
}

.content-head {
  display: flex;
  direction: ltr;
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
</style>
