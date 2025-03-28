<script setup lang="ts">
import dayjs from "dayjs";
import {ElMessage} from 'element-plus'
import FilePreview from './discussion/FilePreview.vue';
import DiscussHeader from "./discussion/DiscussHeader.vue";
import EditorButtons from "./discussion/EditorButtons.vue";
import {ref, getCurrentInstance, onMounted, watch} from "vue";
import ContentRenderer from './discussion/ContentRenderer.vue';
import CustomPagination from "./discussion/CustomPagination.vue";
import AvatarWithRole from "@/components/AvatarWithRole.vue";
import CommentActions from "@/components/CommentActions.vue";

const instance = getCurrentInstance();
const proxy = instance?.proxy;
const props = defineProps<{ courseName: string }>();
const input = ref<string>(""); // 搜索框文本
const discussions = ref<any[]>([]); // 存储某条课程的所有主评论
const showEditor = ref<boolean>(false);  // 控制主评论编辑框显示与否
const discussionContent = ref<string>("");  // 主评论编辑框内容
const replyContent = ref<{ [key: number]: string }>({});  // 存储每个讨论的回复内容
const activeReplyIndex = ref<number | null>(null);  // 控制哪个讨论显示回复编辑器
const targetType = ref<string | null>(null);// 存储当前回复的回复类型
const targetId = ref<number | null>(null); //记录回复评论的对象ID
const currentPage = ref<number>(1);       // 当前页码
const totalReplies = ref<number>(0);      // 总评论数
const perPage = ref<number>(5);           // 每页显示的评论数
const timeFilter = ref('all'); // 保存当前的时间筛选条件
const authorFilter = ref('all'); // 保存当前的人物筛选条件

// 主评论插入emoji
const insertMainEmoji = (emoji: any) => {
  discussionContent.value += emoji
}

// 回复插入emoji
const insertReplyEmoji = (emoji: any, index: number) => {
  if (!replyContent.value[index]) {
    replyContent.value[index] = ''
  }
  replyContent.value[index] += emoji
}

// 处理主评论上传文件
const handleMainUploadSuccess = (content: string) => {
  discussionContent.value += content
}

// 处理回复上传文件
const handleReplyUploadSuccess = (content: string, index: number) => {
  if (!replyContent.value[index]) {
    replyContent.value[index] = ''
  }
  replyContent.value[index] += content
}

// 获取当前用户信息
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


// 获取讨论区主评论内容
const getDiscussContent = async (page = 1) => {
  try {
    // 1. 先清空当前显示内容
    discussions.value = [];

    let userId = '';
    const userInfo = getUserInfo();
    if (userInfo && userInfo.id) {
      userId = userInfo.id;
    } else {
      ElMessage.error('请先登录');
    }

    const response = await proxy?.$http.get("/get_main_discussions", {
      params: {
        course_name: props.courseName,
        page: page,
        per_page: perPage.value,
        search: input.value,
        time_filter: timeFilter.value,
        author_filter: authorFilter.value,
        user_id: userId,
        type: 'course'
      },
    });

    // 2. 检查是否有数据返回
    if (response?.data?.discussions && response.data.discussions.length > 0) {
      discussions.value = response.data.discussions.map((discussion: any) => ({
        ...discussion,
        showReplies: false
      }));
      totalReplies.value = response.data.total || 0;
      currentPage.value = page;
    } else {
      // 3. 如果没有数据，显示空状态
      ElMessage.info('未找到相关讨论');
    }
  } catch (error) {
    ElMessage.error('获取评论失败')
  }
};


// 获取某条主评论的所有子评论并进行展示
const loadReplies = async (discussionId: number, index: number) => {
  try {
    let userId = '';
    const userInfo = getUserInfo();
    if (userInfo && userInfo.id) {
      userId = userInfo.id;
    } else {
      ElMessage.error('获取评论失败');
    }

    // 如果已经加载过回复，则切换显示状态
    if (discussions.value[index].replies) {
      discussions.value[index].showReplies = !discussions.value[index].showReplies;
      return;
    }

    // 发送请求获取该讨论的所有子评论
    const response = await proxy?.$http.get("/get_detailed_discussions", {
      params: {
        discussion_id: discussionId,
        user_id: userId
      },
    });

    if (response?.data?.replies) {
      // 展开该讨论的回复并更新数据
      discussions.value[index].replies = response.data.replies;
      discussions.value[index].showReplies = true; // 标记该讨论已展开回复
    }
  } catch (error) {
    ElMessage.error('获取评论失败');
  }
};

const deleteComment = async (commentId: number, commentType: string) => {
  try {
    const response = await proxy?.$http.post('/comments/delete', {
      comment_type: commentType,
      comment_id: commentId
    });

    const data = response.data;

    if (data.status === 'success') {
      ElMessage.success('评论删除成功');
      getDiscussContent()
    } else {
      ElMessage.error(data.message || '删除失败');
    }
  } catch (error) {
    console.error('删除评论失败:', error);
    ElMessage.error('删除评论失败，请稍后重试');
  }
}

// 对主评论或者子评论进行点赞或取消点赞
const likeComment = async (id: number, type: string) => {
  const user = getUserInfo();
  if (!user) {
    ElMessage.error('请先登录');
    return;
  }

  try {
    const response = await proxy?.$http.post("/update_like", {
      id: id,
      type: type,
      user_id: user.id,
    });

    if (
        response?.data?.message === "Like added successfully" ||
        response?.data?.message === "Like removed successfully"
    ) {
      const newLikeCount = response.data.like;
      const isLiked = response.data.liked; // 后端返回是否已点赞的状态

      if (type === "discussion") {
        const discussionIndex = discussions.value.findIndex((d) => d.id === id);
        if (discussionIndex !== -1) {
          discussions.value[discussionIndex].like = newLikeCount;
          discussions.value[discussionIndex].isLiked = isLiked;
        }
      } else if (type === "reply") {
        discussions.value.forEach((discussion) => {
          if (discussion.replies) {
            const replyIndex = discussion.replies.findIndex(
                (reply: any) => reply.id === id
            );
            if (replyIndex !== -1) {
              discussion.replies[replyIndex].like = newLikeCount;
              discussion.replies[replyIndex].isLiked = isLiked;
            }
          }
        });
      }
    }
  } catch (error) {
    ElMessage.error('点赞/取消点赞失败');
  }
};


// 用户发布新评论
const handleCreateDiscussion = () => {
  const userInfo = getUserInfo();

  if (userInfo) {
    showEditor.value = true;
  } else {
    ElMessage.error('请先登录');
  }
};

// 处理回复按钮点击事件
const handleReplyClick = (discussionIndex: number, target_type: string, target_id: number) => {
  // 如果当前点击的是同一个回复，则取消
  if (activeReplyIndex.value === discussionIndex) {
    activeReplyIndex.value = null;
    targetType.value = null;
    targetId.value = null;
    return;
  }

  // 设置当前活跃的回复索引和目标ID
  activeReplyIndex.value = discussionIndex;
  targetType.value = target_type;
  targetId.value = target_id;
};


// 用户提交讨论
const submitDiscussion = async () => {
  const user = getUserInfo();
  const content = discussionContent.value.trim();

  if (user && content) {
    try {
      const response = await proxy?.$http.post("/submit_discussion", {
        user_id: user.id,
        course_name: props.courseName,
        content: content,
        type: 'course'
      });

      if (response?.data?.message === "讨论创建成功") {
        discussions.value.unshift(response.data.discussion);
        showEditor.value = false;
        discussionContent.value = "";  // 清空内容
        totalReplies.value += 1; // 增加总评论数
      } else {
        ElMessage.error('提交失败');
      }
    } catch (error) {
      console.error("Error submitting discussion:", error);
      ElMessage.error('提交失败');
    }
  } else {
    ElMessage.error('提交内容不能为空');
  }
};

// 新增：提交回复
const submitReply = async (discussionId: number, index: number) => {
  const user = getUserInfo();
  const content = replyContent.value[index]?.trim();

  if (user && content) {
    try {
      // 发送回复请求
      const response = await proxy?.$http.post("/submit_reply", {
        user_id: user.id,
        parent_id: discussionId,
        content: content,
        target_type: targetType.value,
        target_id: targetId.value
      });

      if (response?.data?.message === "回复创建成功") {
        // 检查是否已经加载过回复
        const isRepliesLoaded = discussions.value[index].replies !== undefined;

        // 构建新回复对象，确保包含完整信息
        const newReply = {
          ...response.data.reply,
          reply_type: targetType.value || 'discussion',
          target_name: targetType.value ?
              discussions.value[index].replies?.find((r: any) => r.id === targetId.value)?.replier_name
              || discussions.value[index].author_name
              : null
        };

        // 如果没有加载过回复，则重新获取全部回复
        if (!isRepliesLoaded) {
          const repliesResponse = await proxy?.$http.get("/get_detailed_discussions", {
            params: {discussion_id: discussionId}
          });

          if (repliesResponse?.data?.replies) {
            discussions.value[index].replies = repliesResponse.data.replies;
          }
        } else {
          // 如果已经加载过回复，直接追加新回复
          discussions.value[index].replies.push(newReply);
        }

        // 更新回复计数和显示状态
        discussions.value[index].replies_count += 1;
        discussions.value[index].showReplies = true;

        // 重置回复编辑器
        activeReplyIndex.value = null;
        replyContent.value[index] = "";
        targetType.value = null;
        targetId.value = null;
      } else {
        ElMessage.error('提交失败');
      }
    } catch (error) {
      console.error("Error submitting reply:", error);
      ElMessage.error('提交失败');
    }
  } else {
    ElMessage.error('提交内容不能为空');
  }
};

// 评论区分页显示切换
const handlePageChange = (page: number) => {
  getDiscussContent(page);
};

// 搜索功能
const handleSearch = () => {
  getDiscussContent(1);
};

// 处理时间筛选按钮点击事件
const handleTimeFilterClick = (filter: string) => {
  timeFilter.value = filter;
  getDiscussContent(1);
};

// 处理人物筛选按钮点击事件
const handleAuthorFilterClick = (filter: string) => {
  authorFilter.value = filter;
  getDiscussContent(1);
};

// 监听搜索框输入内容
watch(input, (newInput) => {
  if (newInput.trim() !== "") {
    getDiscussContent(currentPage.value);
  } else {
    getDiscussContent(1);
  }
});

onMounted(() => {
  getDiscussContent(currentPage.value);
});
</script>

<template>
  <div class="discuss-container">
    <!-- 首部，包括搜索框、发布按钮、筛选功能 -->
    <DiscussHeader
        v-model:input="input"
        buttonText="发起讨论"
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

    <!-- 评论区显示区 -->
    <div class="discuss-content">
      <div class="discussion" v-for="(discussion, index) in discussions" :key="index">
        <div class="user-info">
          <AvatarWithRole :Role="discussion.author_role" :userName="discussion.author_name"/>
          <div class="discussion-main">
            <span class="user-name">
              {{ discussion.author_name }}
            </span>
            <span class="create-time">
              {{ dayjs(discussion.created_at).format("YYYY-MM-DD") }}
            </span>
            <div>
              <ContentRenderer :content="discussion.content"/>
            </div>

            <div v-if="discussion.replies_count > 0" class="view-replies-button">
              <el-button type="text" class="replies-toggle-btn" @click="loadReplies(discussion.id, index)">
                {{
                  discussion.showReplies ? `隐藏 ${discussion.replies_count} 条回复` : `查看 ${discussion.replies_count} 条回复`
                }}
              </el-button>
            </div>

            <div v-if="discussion.showReplies" class="replies">
              <div v-for="(reply, replyIndex) in discussion.replies" :key="replyIndex"
                   class="reply-container border rounded-md p-3 mb-2 bg-gray-50">
                <div class="reply-header flex justify-between items-center">
                  <div class="user-info">
                    <AvatarWithRole :Role="reply.replier_role" :userName="reply.replier_name"/>
                    <div class="discussion-main">
                      <span class="user-name">
                        {{ reply.replier_name }}
                      </span>
                      <span class="create-time">
                        {{ dayjs(reply.reply_time).format("YYYY-MM-DD") }}
                      </span>
                      <div class="content">
                        <span v-if="reply.reply_type === 'reply'" style="color: #00a8ff; margin-right: 10px;">
                          @{{ reply.target_name }}
                        </span>
                        <ContentRenderer :content="reply.reply_content"/>
                      </div>
                    </div>
                  </div>
                  <comment-actions
                      :id="reply.id"
                      type="reply"
                      :isOwnComment="getUserInfo().username==reply.replier_name"
                      :is-liked="reply.isLiked"
                      :like-count="reply.like"
                      :index="index"
                      :showReplyButton=true
                      @like="likeComment"
                      @reply="handleReplyClick"
                      @delete="deleteComment"
                  />
                </div>

              </div>
            </div>

            <div v-if="activeReplyIndex === index" class="reply-editor-container">
              <el-input v-model="replyContent[index]" type="textarea" placeholder="请输入回复内容..." rows="3"
                        style="margin-top: 10px; margin-bottom: 10px"/>
              <EditorButtons
                  @emoji-select="(emoji) => insertReplyEmoji(emoji, index)"
                  @file-upload="(content) => handleReplyUploadSuccess(content, index)"
                  @submit="() => submitReply(discussion.id, index)"
                  @cancel="() => {activeReplyIndex = null; replyContent = ''}"
              />
            </div>
          </div>
        </div>
        <comment-actions
            :id="discussion.id"
            type="discussion"
            :isOwnComment="getUserInfo().username==discussion.author_name"
            :is-liked="discussion.isLiked"
            :like-count="discussion.like"
            :index="index"
            :showReplyButton=true
            @like="likeComment"
            @reply="handleReplyClick"
            @delete="deleteComment"
        />
      </div>
    </div>

    <!-- 讨论区分页展示切换按钮 -->
    <CustomPagination
        v-model:current-page="currentPage"
        :per-page="perPage"
        :total-items="totalReplies"
        @page-change="handlePageChange"
    />
  </div>
</template>

<style scoped>
.discuss-content {
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 1rem;
  backdrop-filter: blur(10px);
}

.content {
  display: flex;
}

.discuss-content .discussion-main {
  width: 100%;
}

.user-name {
  font-size: large;
}

.create-time {
  font-size: smaller;
  margin-left: 0.5rem;
  color: gray;
}

.discussion {
  padding: 1rem;
  display: flex;
  box-shadow: 0 0 10px 0 rgba(255, 255, 255, 0.2);
  background: rgba(0, 0, 0, 0.2);
  margin-top: 1rem;
  border-radius: 1rem;
}

.discussion-main {
  margin-left: 0.5rem;
}

.reply-container {
  border-radius: 1rem;
  padding: 1rem;
  border: 1px solid gray;
  transition: background-color 0.3s ease;
  margin-bottom: 7px;
}

.user-info {
  width: 100%;
  display: flex;
}

.reply-header {
  display: flex;
  margin-bottom: 5px;
}

.reply-editor-container,
.editor-container {
  border: 1px solid #e4e7ed;
  border-radius: 1rem;
  padding: 16px;
  margin-bottom: 20px;
  background: white;
}
</style>