<template>
  <el-dialog
    v-model="dialogVisible"
    title="话题管理"
    width="80%"
    :before-close="handleClose"
  >
    <div class="topic-manager">
      <!-- 添加新话题按钮 -->
      <div class="action-bar">
        <el-button type="primary" @click="handleAddTopic">
          添加新话题
        </el-button>
      </div>

      <!-- 话题列表 -->
      <el-table :data="topics" style="width: 100%">
        <el-table-column prop="tag" label="话题名称" />
        <el-table-column prop="content" label="话题内容" show-overflow-tooltip />
        <el-table-column label="有效期" width="300">
          <template #default="scope">
            {{ formatDate(scope.row.start_time) }} 至 {{ formatDate(scope.row.end_time) }}
          </template>
        </el-table-column>
        <el-table-column label="PDF附件" width="120">
          <template #default="scope">
            <el-tag v-if="scope.row.pdf_url" type="success">已上传</el-tag>
            <el-tag v-else type="info">无附件</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button type="primary" link @click="handleEditTopic(scope.row)">
              编辑
            </el-button>
            <el-button type="danger" link @click="handleDeleteTopic(scope.row.id)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 添加/编辑话题对话框 -->
    <el-dialog
      v-model="topicDialogVisible"
      :title="isEditing ? '编辑话题' : '添加话题'"
      width="50%"
    >
      <el-form :model="topicForm" label-width="100px">
        <el-form-item label="话题名称">
          <el-input v-model="topicForm.tag" />
        </el-form-item>
        <el-form-item label="话题内容">
          <el-input
            v-model="topicForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入话题内容..."
          />
        </el-form-item>
        <el-form-item label="PDF附件">
          <div class="pdf-upload-container">
            <FileUpload @upload-success="handlePdfUpload" />
            <div v-if="topicForm.pdf_url" class="pdf-preview">
              <span class="pdf-name">已上传: {{ getPdfFileName(topicForm.pdf_url) }}</span>
              <el-button type="danger" size="small" @click="removePdf">删除</el-button>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="开始时间">
          <el-date-picker
            v-model="topicForm.start_time"
            type="datetime"
            placeholder="选择开始时间"
          />
        </el-form-item>
        <el-form-item label="结束时间">
          <el-date-picker
            v-model="topicForm.end_time"
            type="datetime"
            placeholder="选择结束时间"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="topicDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmitTopic">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, getCurrentInstance } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'
import FileUpload from './FileUploader.vue'

interface Tag {
  id: number
  tag: string
  content: string
  pdf_url: string | null
  course_id: number
  user_id: number
  start_time: string
  end_time: string
  created_at: string
  updated_at: string
}

const instance = getCurrentInstance()
const proxy = instance?.proxy

const props = defineProps<{
  courseName: string
}>()

const emit = defineEmits<{
  (e: 'update'): void
}>()

const dialogVisible = ref(false)
const topicDialogVisible = ref(false)
const topics = ref<Tag[]>([])
const isEditing = ref(false)
const currentTopicId = ref<number | null>(null)
const courseName = ref('数理逻辑')

const topicForm = ref({
  tag: '',
  content: '',
  start_time: '',
  end_time: '',
  pdf_url: ''
})

// 处理PDF上传成功
const handlePdfUpload = (content: string) => {
  // 从Markdown链接格式 [PDF文件-filename.pdf](http://127.0.0.1:5000/api/path/to/file.pdf) 中提取URL
  const match = content.match(/\[PDF文件-.*?\]\((.*?)\)/)
  if (match && match[1]) {
    topicForm.value.pdf_url = match[1]
  }
}

// 从PDF URL中提取文件名
const getPdfFileName = (url: string) => {
  if (!url) return ''
  // 从URL中提取文件名
  const parts = url.split('/')
  return parts[parts.length - 1]
}

// 删除已上传的PDF
const removePdf = () => {
  topicForm.value.pdf_url = ''
  ElMessage.success('已删除PDF附件')
}

const getUserInfo = () => {
  try {
    const info = JSON.parse(localStorage.getItem('userInfo') || '{}')
    return info
  } catch (error) {
    console.error('获取用户信息失败:', error)
    return null
  }
}

const fetchTopics = async () => {
  try {
    console.log('开始获取话题列表,课程名称:', props.courseName)
    const response = await proxy?.$http.get('tags', {
      params: {
        course_name: props.courseName
      }
    })
    console.log('获取话题列表响应:', response)
    topics.value = response.data
    console.log('获取话题列表成功:', topics.value)
  } catch (error) {
    console.error('获取话题列表失败:', error)
  }
}

// 格式化日期
const formatDate = (date: string) => {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '未设置'
}

// 处理添加话题
const handleAddTopic = () => {
  isEditing.value = false
  currentTopicId.value = null
  topicForm.value = {
    tag: '',
    content: '',
    start_time: '',
    end_time: '',
    pdf_url: ''
  }
  topicDialogVisible.value = true
}

// 处理编辑话题
const handleEditTopic = (topic: Tag) => {
  isEditing.value = true
  currentTopicId.value = topic.id
  topicForm.value = {
    tag: topic.tag,
    content: topic.content,
    start_time: topic.start_time,
    end_time: topic.end_time,
    pdf_url: topic.pdf_url || ''
  }
  topicDialogVisible.value = true
}

// 处理删除话题
const handleDeleteTopic = async (topicId: number) => {
  try {
    console.log('开始删除话题,话题ID:', topicId)
    const response = await proxy?.$http.get('tags/delete', {
      params: {
        topic_id: topicId
      }
    })
    console.log('删除话题响应:', response)
    await fetchTopics()
    ElMessage.success('话题删除成功')

    // 删除成功后触发update事件
    emit('update')
  } catch (error) {
    console.error('删除话题失败:', error)
    ElMessage.error('删除话题失败')
  }
}

// 处理提交话题
const handleSubmitTopic = async () => {
  try {
    console.log('开始提交话题:', topicForm.value)
    const userInfo = getUserInfo()
    if (!userInfo || !userInfo.id) {
      ElMessage.error('请先登录')
      return
    }

    // 格式化日期
    const startTime = topicForm.value.start_time ? dayjs(topicForm.value.start_time).format('YYYY-MM-DD HH:mm:ss') : null
    const endTime = topicForm.value.end_time ? dayjs(topicForm.value.end_time).format('YYYY-MM-DD HH:mm:ss') : null

    // 准备请求数据
    let requestData;
    let apiEndpoint;

    if (isEditing.value && currentTopicId.value) {
      // 编辑现有话题
      apiEndpoint = 'tags/update';
      requestData = {
        topic_id: currentTopicId.value,
        tag: topicForm.value.tag,
        content: topicForm.value.content,
        start_time: startTime,
        end_time: endTime,
        pdf_url: topicForm.value.pdf_url
      };
      console.log('更新话题请求数据:', requestData);
    } else {
      // 创建新话题
      apiEndpoint = 'tags/create';
      requestData = {
        tag: topicForm.value.tag,
        content: topicForm.value.content,
        start_time: startTime,
        end_time: endTime,
        course_name: props.courseName,
        user_id: userInfo.id,
        pdf_url: topicForm.value.pdf_url
      };
      console.log('创建话题请求数据:', requestData);
    }

    const response = await proxy?.$http.get(apiEndpoint, {
      params: requestData
    });

    console.log('提交话题响应:', response);
    ElMessage.success(isEditing.value ? '话题更新成功' : '话题创建成功');
    topicDialogVisible.value = false;
    topicForm.value = {
      tag: '',
      content: '',
      start_time: '',
      end_time: '',
      pdf_url: ''
    };

    // 刷新话题列表
    await fetchTopics();

    // 确保在编辑或创建话题成功后触发 update 事件
    emit('update');

  } catch (error) {
    console.error('提交话题失败:', error);
    ElMessage.error('提交话题失败: ' + (error.response?.data?.error || error.message));
  }
}

// 处理关闭对话框
const handleClose = () => {
  dialogVisible.value = false
}

// 暴露方法给父组件
defineExpose({
  show: () => {
    dialogVisible.value = true
    fetchTopics()
  }
})

onMounted(() => {
  fetchTopics()
})
</script>

<style scoped>
.topic-manager {
  padding: 20px;
}

.action-bar {
  margin-bottom: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.pdf-upload-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.pdf-preview {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
  padding: 8px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.pdf-name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #409eff;
}
</style>