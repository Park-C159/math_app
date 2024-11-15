<script setup lang="ts">

import {ref, getCurrentInstance, onMounted} from "vue";
import {Search, UserFilled, ArrowDown} from '@element-plus/icons-vue'
import dayjs from "dayjs";

// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况

const props = defineProps<{ courseName: string }>();
const input = ref<string>('');

const discussions = ref<any[]>([])

const getDiscussContent = async () => {
  try {
    const response = await proxy?.$http.get('/get_discussions', {
      params: {
        course_name: props.courseName,
        page: 1,
        per_page: 5,
      }
    });

    // 确保返回的数据存在且非空
    if (response?.data?.discussions && response.data.discussions.length > 0) {
      discussions.value.push(...response.data.discussions);  // 使用 push 追加数组内容
      console.log(discussions);
    }

    console.log(discussions.value);
  } catch (error) {
    console.error('Error fetching discussions:', error);
  }
}


onMounted(() => {
  getDiscussContent();
});
</script>

<template>
  <div class="discuss-container">
    <div class="discuss-header">
      <div class="discuss-header-left">
        <el-input
            v-model="input"
            style="max-width: 300px; text-align: left"
            placeholder="请输入需要搜索的关键字"
            class="input-with-select"
        >
          <template #append>
            <el-button :icon="Search"/>
          </template>
        </el-input>
        <el-button class="new_discussion-btn" color="rgb(173, 145, 255)" plain>发起讨论</el-button>


      </div>
      <div class="filter">
        <el-dropdown>
          <span class="el-dropdown-link">
            全部帖子
            <el-icon class="el-icon--right">
              <arrow-down/>
            </el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item>我发布的</el-dropdown-item>
              <el-dropdown-item>老师参与</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        <el-dropdown>
          <span class="el-dropdown-link">
            所有时间
            <el-icon class="el-icon--right">
              <arrow-down/>
            </el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item>最近一周</el-dropdown-item>
              <el-dropdown-item>最近一月</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    <div class="discuss-content">
      <div class="discussion" v-for="(discussion, index ) in discussions" :key="index">
        <div class="discussion-left">
          <div class="discussion-avatar">
            <el-avatar :icon="UserFilled"/>
          </div>
          <div class="discussion-main">
            <div class="user">{{ discussion.author }}&nbsp;&nbsp;<span
                style="font-size: small">{{ dayjs(discussion.created_at).format('YYYY-MM-DD') }}</span></div>
            <div class="text">{{ discussion.content }}</div>
            <div class="reply" v-if="discussion.first_reply.reply_time">
              <div class="reply-avatar">
                <el-avatar size="small" :icon="UserFilled"/>
              </div>
              <div class="reply-main">
                <div class="user">{{ discussion.first_reply.replier }}&nbsp;&nbsp;<span
                    style="font-size: small">{{ dayjs(discussion.first_reply.reply_time).format('YYYY-MM-DD') }}</span>
                </div>
                {{ discussion.first_reply.reply_content }}

              </div>
            </div>
          </div>
        </div>
        <div class="reply-btn">回复</div>
      </div>
    </div>

  </div>
</template>

<style scoped>
.discuss-header{
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.discuss-header-left{
  display: flex;
}

.el-dropdown-link {
  cursor: pointer;
  color: rgb(173, 145, 255);
  display: flex;
  align-items: center;
  line-height: 32px;
  margin-left: 2rem;
}
.new_discussion-btn {
  margin-left: 15px;
}

.discussion-left {
  display: flex;
}

.reply-btn {
  font-size: small;
  cursor: pointer;
}

.discussion {
  padding: 1rem;
  display: flex;
  box-shadow: 0px 0px 10px 0px rgba(0, 0, 0, 0.85);
  background: #444;
  margin-top: 1rem;
  border-radius: 1rem;
  justify-content: space-between;
}

.discussion-main {
  margin-left: 0.5rem;
}

.reply {
  display: flex;
  margin-top: 0.5rem;
}

.reply-main {
  margin-left: 0.5rem;
  font-size: small;
}

.user {
  color: #ddd;
}
</style>