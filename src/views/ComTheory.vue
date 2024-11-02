<script setup lang="ts">
import CourseStruct from "@/components/CourseStruct.vue";
import DiscussContent from "@/components/DiscussContent.vue";
import {ref, getCurrentInstance} from 'vue';
import {UserFilled, Calendar, Location, Document, Setting} from '@element-plus/icons-vue';


// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况

const isExpanded = ref(false);
let ContentID = ref(1);

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
      params:{
        book_name: "sym"
      },
      responseType: 'blob'  // 确保响应类型为 blob，表示二进制数据
    });

    // 创建 Blob 对象
    const blob = new Blob([response?.data], { type: 'application/pdf' });
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

</script>

<template>
  <el-container class="main-container">
    <el-header class="class-header">
      <div class="title">数理逻辑</div>
      <div class="info">
        <div class="teacher pd">
          <el-icon>
            <UserFilled/>
          </el-icon>
          <span class="info-title">任课教师：</span>
          &nbsp;&nbsp;王拥军
        </div>
        <div class="time pd">
          <el-icon>
            <Calendar/>
          </el-icon>
          <span class="info-title">开课时间：</span>&nbsp;&nbsp;2024-09-01 00:00:00 至 2024-12-12 23:59:59
        </div>
      </div>
      <!-- 折叠/展开文本 -->
      <div class="details" :class="{ expanded: isExpanded }" @click="toggleExpand">
        <p>
          本课程的核心概念是可计算性，围绕可计算性主要讲授两部分内容：计算模型和计算复杂性。前者强调计算的上限，后者关注现实可计算。
        </p>
        <p>
          计算模型是指用于描述计算过程的抽象数学模型，它可以帮助理解计算的本质、计算能力的限制以及计算问题的可解性。
        </p>
        <p>课程全部内容分为六章，其中前三章属于可计算部分，涉及递归函数论和图灵机两个计算模型，计划大约24学时；后三章是计算复杂性部分，涉及不可判定性、复杂性理论和NP完全，计划大约21学时；还有3学时介绍课程大作业。</p>
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
          <CourseStruct courseName="可计算性与计算复杂性"/>
        </div>
        <div v-else-if="ContentID === 2">
          <DiscussContent courseName="可计算性与计算复杂性" />
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

  </el-container>
</template>

<style scoped>
.main-container {
  padding: 2rem;
}
.download-btn{
  margin-top: 1rem;
}
.el-aside{
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
