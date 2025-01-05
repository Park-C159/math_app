<template>
  <!-- 首部，包括搜索框、发布按钮、筛选功能 -->
  <DiscussHeader
      v-model:input="input"
      buttonText="参与讨论"
      @search="handleSearch"
      @create-discussion="handleCreateDiscussion"
      @time-filter-change="handleTimeFilterClick"
      @author-filter-change="handleAuthorFilterClick"
  />
  <!-- 编辑框（发言框） -->
  <div v-if="showEditor" class="editor-container">
    <FilePreview :content="discussionContent"/>
    <el-input v-model="discussionContent" type="textarea" placeholder="请输入讨论内容..." rows="4"
              style="margin-bottom: 10px; border: none"/>
    <EditorButtons
        @emoji-select="insertMainEmoji"
        @file-upload="handleMainUploadSuccess"
        @submit="submitDiscussion"
        @cancel="() => { showEditor = false; discussionContent = ''; }"
    />
  </div>
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
            <div>
              {{ tag.name }}
            </div>
            <div style="color: gray; font-size: 0.9em;">
              {{ dayjs(tag.start_time).format("YYYY-MM-DD") }} - {{ dayjs(tag.end_time).format("YYYY-MM-DD") }}
            </div>
          </el-tag>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="main-content" v-if="currentContent">

      <div class="top-panel">
        <AvatarWithRole :Role="currentContent.userRole" :userName="currentContent.userName"/>
        <div class="topic-main" style="width: 100%">
            <span class="user-name">
              {{ currentContent.userName }}
            </span>
          <span class="create-time">
              {{ dayjs(currentContent.startTime).format("YYYY-MM-DD") }}
            </span>
          <div>
            <ContentRenderer :content="currentContent.description+'[PDF文件-附件]('+currentContent.pdfUrl+')'"/>
          </div>
        </div>
      </div>

      <div class="bottom-panel">
        <div v-for="comment in currentContent.comments"
             :key="comment.id"
             class="comment-item">
          <div class="comment">
            <AvatarWithRole :Role="comment.userRole" :userName="comment.userName"/>
            <div class="comment-main" style="width: 100%; margin-left: 10px;">
            <span class="user-name">
              {{ comment.userName }}
            </span>
              <span class="create-time">
              {{ dayjs(comment.time).format("YYYY-MM-DD") }}
            </span>
              <div>
                <ContentRenderer :content="comment.content"/>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {ref, reactive, getCurrentInstance} from 'vue'
import {ArrowLeft, ArrowRight, UserFilled} from '@element-plus/icons-vue'
import 'mavon-editor/dist/css/index.css'
import ContentRenderer from "@/components/discussion/ContentRenderer.vue"
import dayjs from "dayjs";
import AvatarWithRole from "@/components/AvatarWithRole.vue";
import FilePreview from "@/components/discussion/FilePreview.vue";
import EditorButtons from "@/components/discussion/EditorButtons.vue";
import {ElMessage} from "element-plus";
import DiscussHeader from "@/components/discussion/DiscussHeader.vue";

interface Comment {
  id: number
  content: string
  time: string
  userName: string
  userRole: string
}

interface TagContent {
  id: number
  description: string
  pdfUrl: string
  userName: string
  userRole: string
  startTime: string | null
  endTime: string | null
  comments: Comment[]
}

interface Tag {
  id: number
  name: string
  start_time: string | null
  end_time: string | null
}

const instance = getCurrentInstance()
const proxy = instance?.proxy
const props = defineProps<{ courseName: string }>()
const isCollapsed = ref(true)
const selectedTagId = ref<number | null>(null)
const tags = ref<Tag[]>([])
const tagContents = reactive<Record<number, TagContent>>({})
const currentContent = ref<TagContent | null>(null)
const showEditor = ref<boolean>(false);  // 控制主评论编辑框显示与否
const discussionContent = ref<string>("");  // 主评论编辑框内容
const discussions = ref<any[]>([]);
const totalReplies = ref<number>(0);
const input = ref<string>(""); // 搜索框文本
const timeFilter = ref('all'); // 保存当前的时间筛选条件
const authorFilter = ref('all'); // 保存当前的人物筛选条件

const insertMainEmoji = (emoji: any) => {
  discussionContent.value += emoji
}

const handleMainUploadSuccess = (content: string) => {
  discussionContent.value += content
}

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

const handleSearch = () => {
  selectTag(tags.value[0])
};

const handleCreateDiscussion = () => {
  const userInfo = getUserInfo();

  if (userInfo) {
    showEditor.value = true;
  } else {
    ElMessage.error('请先登录');
  }
};

// 处理时间筛选按钮点击事件
const handleTimeFilterClick = (filter: string) => {
  timeFilter.value = filter;
  selectTag(tags.value[0])
};

// 处理人物筛选按钮点击事件
const handleAuthorFilterClick = (filter: string) => {
  authorFilter.value = filter;
  selectTag(tags.value[0])
};

const getUserInfo = () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}");

    if (userInfo && userInfo.username) {
      return userInfo;
    } else {
      ElMessage.error('未获取到用户信息');
      return null;
    }
  } catch (error) {
    ElMessage.error('获取用户信息失败');
    return null;
  }
};

const submitDiscussion = async () => {
  const user = getUserInfo();
  const content = discussionContent.value.trim();

  if (user && content) {
    try {
      // 创建普通 JavaScript 对象，避免发送响应式对象
      const requestData = {
        user_id: Number(user.id), // 确保 ID 是数字类型
        topic_id: Number(selectedTagId.value), // 获取响应式引用的值并转换为数字
        content: content
      };

      const response = await proxy?.$http.post("/submit_topic_discussion", requestData);

      if (response?.data?.message === "评论提交成功") {
        // 构造新的普通 JavaScript 对象
        ElMessage.success('评论提交成功');
        await fetchTagContent(selectedTagId.value!);
        discussionContent.value = '';
        showEditor.value = false;
      } else {
        ElMessage.error(response?.data?.message || '提交失败');
      }
    } catch (error) {
      console.error("Error submitting discussion:", error);
      ElMessage.error('提交失败');
    }
  } else {
    ElMessage.error(content ? '请先登录' : '提交内容不能为空');
  }
};

const fetchTags = async () => {
  try {
    const response: any = await proxy?.$http.get('/tags', {
      params: {course_name: props.courseName}
    })

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

    const contentData: TagContent = {
      id: response.data.id,
      description: response.data.description,
      pdfUrl: response.data.pdfUrl,
      userName: response.data.userName,
      userRole: response.data.userRole,
      startTime: response.data.startTime,
      endTime: response.data.endTime,
      comments: response.data.comments
    }

    // 更新数据
    tagContents[tagId] = contentData
    currentContent.value = contentData
  } catch (error) {
    console.error(`Error fetching content for tag ${tagId}:`, error)
  }
}

const selectTag = async (tag: Tag) => {
  selectedTagId.value = tag.id
  if (!tagContents[tag.id]) {
    await fetchTagContent(tag.id)
  } else {
    // 确保currentContent指向tagContents中的数据
    currentContent.value = tagContents[tag.id]
  }
}

fetchTags()
</script>

<style scoped>
.flex {
  display: flex;
}

.h-screen {
  height: 100vh;
}

.tags-container {
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-radius: 1rem;
  transition: all 0.3s ease;
  width: 250px;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.1);
}

.tags-container.collapsed {
  background: transparent;
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
  color: white;
}

.sidebar-content {
  transition: opacity 0.3s ease;
  opacity: 1;
}

.user-name {
  font-size: large;
}

.create-time {
  font-size: smaller;
  margin-left: 0.5rem;
  color: gray;
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
  color: white;
  white-space: normal !important;
  height: auto !important;
  padding: 8px 12px !important;
  margin-bottom: 8px;
  word-break: break-word;
  line-height: 1.4;
  background-color: rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.tag-button:hover {
  transform: scale(1.01);
  box-shadow: 0 4px 12px rgba(255, 255, 255, 0.6);
}

.tag-button.active {
  background-color: rgba(255, 255, 255, 1);
  border-color: white;
  color: black;
}


.main-content {
  display: table-column;
  flex: 1;
  color: black;
}

.top-panel {
  display: flex;
  background: white;
  width: 100%;
  gap: 1rem;
  margin: 1rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 1rem;
  color: white;
  backdrop-filter: blur(10px);
}

.bottom-panel {
  background: white;
  width: 100%;
  gap: 1rem;
  margin: 1rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 1rem;
  color: white;
  backdrop-filter: blur(10px);
}

.comment {
  display: flex;
  width: 100%;
}

.comment-item {
  padding: 1rem;
  display: flex;
  box-shadow: 0 0 10px 0 rgba(255, 255, 255, 0.2);
  background: rgba(0, 0, 0, 0.2);
  margin-top: 1rem;
  border-radius: 1rem;
}

.editor-container {
  border: 1px solid #e4e7ed;
  border-radius: 1rem;
  padding: 16px;
  margin-bottom: 20px;
  background: white;
}
</style>
