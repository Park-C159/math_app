<script setup lang="ts">
import CourseStruct from "@/components/CourseStruct.vue";
import DiscussContent from "@/components/DiscussContent.vue";
import {ref, getCurrentInstance, onMounted, watch} from 'vue';
import {UserFilled, Calendar, Location, Document, Setting} from '@element-plus/icons-vue';
import {useRoute, useRouter} from "vue-router";


// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况
const route = useRoute()
const router = useRouter()

const CourseId = ref(route.query.courseId)
const isExpanded = ref(false);
let ContentID = ref(1);
const CourseInfo = ref({
  id: '',
  name: '',
  teacher: '',
  start_time: '',
  end_time: '',
  intro: ''
});

const getCourseInfo = () => {
  proxy?.$http.get('/course_management', {
    params: {
      name: route.query.courseName
    }
  }).then((res) => {
    CourseInfo.value = {
      id: res.data.id,
      name: res.data.name,
      teacher: res.data.teacher,
      start_time: res.data.start_time,
      end_time: res.data.end_time,
      intro: res.data.intro
    };
  }).catch((err) => {
    console.error(err);
  })
}

// 切换展开/收起
const toggleExpand = () => {
  isExpanded.value = !isExpanded.value;
};

const handleSelect = (key: string, keyPath: string[]) => {
  ContentID.value = parseInt(key);
}

const downloadBook = async () => {
  try {
    const response = await proxy?.$http.get('/download_book', {
      params: {
        book_name: "sym"
      },
      responseType: 'blob'  // 确保响应类型为 blob，表示二进制数据
    });

    // 创建 Blob 对象
    const blob = new Blob([response?.data], {type: 'application/pdf'});
    const url = window.URL.createObjectURL(blob);

    // 创建一个链接用于下载文件
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', '数理逻辑.pdf');  // 设置下载的文件名
    document.body.appendChild(link);
    link.click();

    // 移除链接
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);  // 释放URL对象
  } catch (error) {
    console.error('Error downloading the file:', error);
  }
};

const testCenter = () => {
  router.push(`/test_list?course_id=${CourseId.value}`); // 获取头部需要更改
}

onMounted(() => {
  getCourseInfo();
})

// 监听路由变化
watch(() => route.query.courseId, (newCourseId) => {
  CourseId.value = newCourseId
  getCourseInfo()  // 路由参数变化时重新调用获取课程信息的函数
})
</script>

<template>
  <el-container class="main-container">
    <el-header class="class-header">
      <div class="title">{{ CourseInfo.name }}</div>
      <div class="info">
        <div class="teacher pd">
          <el-icon>
            <UserFilled/>
          </el-icon>
          <span class="info-title">任课教师：</span>
          &nbsp;&nbsp;{{ CourseInfo.teacher }}
        </div>
        <div class="time pd">
          <el-icon>
            <Calendar/>
          </el-icon>
          <span class="info-title">开课时间：</span>&nbsp;&nbsp;{{ CourseInfo.start_time }} 至 {{ CourseInfo.end_time }}
        </div>
      </div>
      <!-- 折叠/展开文本 -->
      <div class="details" :class="{ expanded: isExpanded }" @click="toggleExpand">
        <p>
          {{ CourseInfo.intro }}
        </p>
      </div>
    </el-header>

    <el-container class="app-container">
      <el-aside width="150px">
        <el-menu
            style="border-right: none;"
            background-color="#1d1e28"
            text-color="#fff"
            active-text-color="rgb(173, 145, 255)"
            class="el-menu-vertical-demo"
            default-active="1"
            @select="handleSelect"
        >
          <el-menu-item index="1">
            <el-icon>
              <Notebook/>
            </el-icon>
            <span>学习内容</span>
          </el-menu-item>
          <el-menu-item index="2">
            <el-icon>
              <ChatRound/>
            </el-icon>
            <span>讨论区</span>
          </el-menu-item>
          <el-menu-item index="3">
            <el-icon>
              <Bell/>
            </el-icon>
            <span>公告</span>
          </el-menu-item>
          <el-menu-item index="4">
            <el-icon>
              <Medal/>
            </el-icon>
            <span>成绩</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <!-- 根据 ContentID 动态渲染内容 -->
        <div v-if="ContentID === 1">
          <CourseStruct courseName="数理逻辑"/>
        </div>
        <div v-else-if="ContentID === 2">
          <DiscussContent courseName="数理逻辑"/>
        </div>
        <div v-else-if="ContentID === 3">
          <p>公告内容</p>
        </div>
        <div v-else-if="ContentID === 4">
          <p>成绩内容</p>
        </div>
      </el-main>
    </el-container>
    <el-button class="download-btn" color="rgb(173, 145, 255)" @click="downloadBook" plain>下载中心</el-button>
    <el-button class="download-btn" color="rgb(173, 145, 255)" @click="testCenter" plain>考试中心</el-button>

  </el-container>
</template>

<style scoped>
.main-container {
  padding: 2rem;
}

.download-btn {
  margin-top: 1rem;
  margin-left: 0 !important;
}

.el-aside {
  background-color: #1d1e28;
}

.class-header {
  background-color: #1c1c2c;
  padding: 2rem;
  border-radius: 2rem;
  box-shadow: 0px 0px 20px 0px rgba(0, 0, 0, 0.25);
  height: auto;
}

.details p {
  text-indent: 2em; /* 首行缩进两字符 */
  margin: 0;
}

.details {
  max-height: 1.2rem; /* 设置默认可见高度，约为一行的高度 */
  padding-right: calc(2rem + 10px);
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1; /* 设置最多显示两行 */
  position: relative;
  line-height: 1.2rem;
  font-size: 0.8rem;
  color: #ccc;
}

.details.expanded {
  -webkit-line-clamp: unset;
  max-height: 100rem;
}

.details::after {
  cursor: pointer;
  content: "展开";
  position: absolute;
  bottom: 0;
  right: 0;
  color: #fff;
  padding-left: 10px;
}

.expanded::after {
  content: "收起";
}

.title {
  font-size: 2rem;
  font-weight: bold;
  line-height: 2.5rem;
}

.info {
  margin-top: 1rem;
  margin-bottom: 0.5rem;
  display: flex;
}

.pd {
  margin-right: 2rem;
  display: flex;
  align-items: center;
}

.app-container {
  margin-top: 20px;
  background-color: #1c1c2c;
  box-shadow: 0px 0px 20px 0px rgba(0, 0, 0, 0.25);
  border-radius: 0.5rem;
}

@media (max-width: 680px) {
  .info {
    display: flex;
    flex-direction: column;
  }

  .info-title {
    display: none;
  }
}
</style>
