<script setup lang="ts">
import {ref, getCurrentInstance, onMounted, nextTick} from "vue";
import {Search, UserFilled, ArrowDown, Star} from "@element-plus/icons-vue";
import dayjs from "dayjs";

// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;

const props = defineProps<{ courseName: string }>();
const input = ref<string>("");
const discussions = ref<any[]>([]);
const showEditor = ref<boolean>(false);  // 控制编辑框显示与否
const discussionContent = ref<string>("");  // 编辑框内容
const currentPage = ref<number>(1);       // 当前页码
const totalReplies = ref<number>(0);      // 总评论数
const perPage = ref<number>(5);           // 每页显示的评论数

// 获取讨论内容
const getDiscussContent = async (page: number = 1) => {
  try {
    const response = await proxy?.$http.get("/get_discussions", {
      params: {
        course_name: props.courseName,
        page: page,
        per_page: perPage.value,
      },
    });

    if (response?.data?.discussions && response.data.discussions.length > 0) {
      discussions.value = response.data.discussions; // 替换数据
      totalReplies.value = response.data.total || 0; // 更新总评论数
    }
  } catch (error) {
    console.error("Error fetching discussions:", error);
  }
};

// 获取当前用户信息并打印
const getUserInfo = () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}"); // 获取并解析用户信息

    if (userInfo && userInfo.username) {
      return userInfo;
    } else {
      console.log("No user information found."); // 提示用户信息未找到
      return null;
    }
  } catch (error) {
    console.error("Error parsing user info from localStorage:", error);
    return null;
  }
};

// 创建讨论的函数，包含获取用户信息的步骤
const handleCreateDiscussion = () => {
  const userInfo = getUserInfo();

  if (userInfo) {
    console.log(`User ${userInfo.username} is creating a discussion...`);
    showEditor.value = true;  // 显示编辑框
  } else {
    console.warn("Cannot create a discussion without valid user information.");
    alert("请先登录！");
  }
};

// 点赞功能
const likeDiscussion = async (index: number) => {
  try {
    const discussion = discussions.value[index];
    discussion.like += 1; // 前端更新 like 字段
    await proxy?.$http.post("/update_like", {
      discussion_id: discussion.id,
      like: discussion.like,
    });
  } catch (error) {
    console.error("Error liking discussion:", error);
  }
};

// 提交讨论
const submitDiscussion = async () => {
  const user = getUserInfo();
  const content = discussionContent.value.trim();

  if (user && content) {
    try {
      const response = await proxy?.$http.post("/submit_discussion", {
        user_id: user.id,
        course_name: props.courseName,
        content: content
      });

      if (response?.data?.message === "讨论创建成功") {
        discussions.value.unshift(response.data.discussion);  // 添加到前端
        showEditor.value = false;
        discussionContent.value = "";  // 清空内容
      } else {
        alert("提交失败！");
      }
    } catch (error) {
      console.error("Error submitting discussion:", error);
      alert("提交讨论时发生错误！");
    }
  } else {
    alert("讨论内容不能为空！");
  }
};

// 分页变更时触发
const handlePageChange = (page: number) => {
  currentPage.value = page;
  getDiscussContent(page);
};

onMounted(() => {
  getDiscussContent(currentPage.value);
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
        <el-button
            class="new_discussion-btn"
            color="rgb(173, 145, 255)"
            plain
            @click="handleCreateDiscussion"
        >
          发起讨论
        </el-button>
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

    <!-- 编辑框（发言框） -->
    <div v-if="showEditor" class="editor-container">
      <el-input
          v-model="discussionContent"
          type="textarea"
          placeholder="请输入讨论内容..."
          rows="4"
          style="margin-bottom: 10px"
      />
      <el-button type="primary" @click="submitDiscussion">提交</el-button>
      <el-button @click="showEditor = false">取消</el-button>
    </div>

    <div class="discuss-content">
      <div class="discussion" v-for="(discussion, index) in discussions" :key="index">
        <div class="discussion-left">
          <div class="discussion-avatar">
            <el-avatar :icon="UserFilled"/>
          </div>
          <div class="discussion-main">
            <div class="user">
              {{ discussion.author_name }}
              &nbsp;&nbsp;<span style="font-size: small">{{ dayjs(discussion.created_at).format("YYYY-MM-DD") }}</span>
            </div>
            <div class="text">{{ discussion.content }}</div>

            <!-- 遍历所有子评论（回复） -->
            <div class="reply" v-for="(reply, replyIndex) in discussion.replies" :key="replyIndex">
              <div class="reply-avatar">
                <el-avatar size="small" :icon="UserFilled"/>
              </div>
              <div class="reply-main">
                <div class="user">
                  {{ reply.replier_name }}
                  &nbsp;&nbsp;<span style="font-size: small">{{ dayjs(reply.reply_time).format("YYYY-MM-DD") }}</span>
                </div>
                {{ reply.reply_content }}
              </div>
            </div>
          </div>
        </div>
        <div class="discussion-actions">
          <el-button class="like-btn" type="text" size="small" icon="Star" @click="likeDiscussion(index)">
            <span>{{ discussion.like }}</span>
          </el-button>
          <div class="reply-btn">回复</div>
        </div>
      </div>
    </div>

    <!-- 底部分页导航 -->
    <el-pagination
        v-if="totalReplies > 0"
        :current-page="currentPage"
        :page-size="perPage"
        :total="totalReplies"
        @current-change="handlePageChange"
        layout="prev, pager, next, jumper"
        background
        class="pagination-center">
    </el-pagination>

  </div>
</template>

<style scoped>
.discuss-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.discuss-header-left {
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

.discussion-actions {
  display: flex;
  align-items: center;
}

.like-btn {
  margin-right: 10px;
  cursor: pointer;
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
  margin-top: 10px;
}

.reply-main {
  padding-left: 10px;
}

.editor-container {
  margin-bottom: 15px;
}

.editor-container .el-input__inner {
  border-radius: 1rem;
}

.editor-container .el-button {
  margin-top: 10px;
}

.pagination-center {
  text-align: center;
  margin-top: 20px;
}

.pagination-center .el-pager,
.pagination-center .el-pagination__button,
.pagination-center .el-pagination__prev,
.pagination-center .el-pagination__next {
  display: inline-block;
  text-align: center;
}

.pagination-center .el-pagination {
  display: inline-flex;
  justify-content: center;
  align-items: center;
}
</style>
