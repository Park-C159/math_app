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
        user_id: userId
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
  console.log(discussionIndex, target_type, target_id);
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
        content: content
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
          <AvatarWithRole :replierRole="discussion.author_role"/>
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
                    <AvatarWithRole :replierRole="reply.replier_role"/>
                    <div class="discussion-main">
                      <span class="user-name">
                        {{ reply.replier_name }}
                      </span>
                      <span class="create-time">
                        {{ dayjs(reply.reply_time).format("YYYY-MM-DD") }}
                      </span>
                      <div>
                        <span v-if="reply.reply_type === 'reply'" style="color: #00a8ff">
                          @{{ reply.target_name }}
                        </span>
                        <ContentRenderer :content="reply.reply_content"/>
                      </div>
                    </div>
                  </div>
                  <div class="comment-actions">
                    <el-button class="like-btn" type="text" @click="likeComment(reply.id, 'reply')">
                      <template v-if="reply.isLiked">
                        <svg x="1735831356929" class="icon" viewBox="0 0 1024 1024" version="1.1"
                             xmlns="http://www.w3.org/2000/svg" p-id="6725" width="20" height="20">
                          <path
                              d="M64 483.04V872c0 37.216 30.144 67.36 67.36 67.36H192V416.32l-60.64-0.64A67.36 67.36 0 0 0 64 483.04zM857.28 344.992l-267.808 1.696c12.576-44.256 18.944-83.584 18.944-118.208 0-78.56-68.832-155.488-137.568-145.504-60.608 8.8-67.264 61.184-67.264 126.816v59.264c0 76.064-63.84 140.864-137.856 148L256 416.96v522.4h527.552a102.72 102.72 0 0 0 100.928-83.584l73.728-388.96a102.72 102.72 0 0 0-100.928-121.824z"
                              p-id="6726" fill="#bfbfbf"></path>
                        </svg>
                      </template>
                      <template v-else>
                        <svg x="1735831311461" class="icon" viewBox="0 0 1024 1024" version="1.1"
                             xmlns="http://www.w3.org/2000/svg" p-id="6321" width="20" height="20">
                          <path
                              d="M190.193225 471.411583c14.446014 0 26.139334-11.718903 26.139334-26.13831 0-14.44499-11.69332-26.164916-26.139334-26.164916-0.271176 0-0.490164 0.149403-0.73678 0.149403l-62.496379 0.146333c-1.425466-0.195451-2.90005-0.295735-4.373611-0.295735-19.677155 0-35.621289 16.141632-35.621289 36.114522L86.622358 888.550075c0 19.949354 15.96767 35.597753 35.670407 35.597753 1.916653 0 3.808746 0.292666 5.649674 0l61.022819 0.022513c0.099261 0 0.148379 0.048095 0.24764 0.048095 0.097214 0 0.146333-0.048095 0.24457-0.048095l0.73678 0 0-0.148379c13.413498-0.540306 24.174586-11.422144 24.174586-24.960485 0-13.55983-10.760065-24.441669-24.174586-24.981974l0-0.393973-50.949392 0 1.450025-402.275993L190.193225 471.409536z"
                              fill="#bfbfbf" p-id="6322"></path>
                          <path
                              d="M926.52241 433.948343c-19.283182-31.445176-47.339168-44.172035-81.289398-45.546336-1.77032-0.246617-3.536546-0.39295-5.380544-0.39295l-205.447139-0.688685c13.462616-39.059598 22.698978-85.58933 22.698978-129.317251 0-28.349675-3.193739-55.962569-9.041934-82.542948l-0.490164 0.049119c-10.638291-46.578852-51.736315-81.31498-100.966553-81.31498-57.264215 0-95.466282 48.15065-95.466282 106.126063 0 3.241834-0.294712 6.387477 0 9.532097-2.996241 108.386546-91.240027 195.548698-196.23636 207.513194l0 54.881958-0.785899 222.227314 0 229.744521 10.709923 0 500.025271 0.222057 8.746198-0.243547c19.35686 0.049119 30.239721-4.817726 47.803749-16.116049 16.682961-10.761088 29.236881-25.50079 37.490869-42.156122 2.260483-3.341095 4.028757-7.075139 5.106298-11.20111l77.018118-344.324116c1.056052-4.053316 1.348718-8.181333 1.056052-12.160971C943.643346 476.446249 938.781618 453.944769 926.52241 433.948343zM893.82573 486.837924l-82.983993 367.783411-0.099261-0.049119c-2.555196 6.141884-6.879688 11.596106-12.872169 15.427364-4.177136 2.727111-8.773827 4.351098-13.414521 4.964058-1.49812-0.195451-3.046383 0-4.620227 0l-477.028511-0.540306-0.171915-407.408897c89.323375-40.266076 154.841577-79.670527 188.596356-173.661202 0.072655 0.024559 0.124843 0.049119 0.195451 0.072655 2.99931-9.137101 6.313799-20.73423 8.697079-33.164331 5.551436-29.185716 5.258771-58.123792 5.258771-58.123792-4.937452-37.98001 25.940812-52.965306 44.364417-52.965306 25.304316 0.860601 50.263777 33.656541 50.263777 52.326762 0 0 5.600555 27.563776 5.649674 57.190537 0.048095 37.366026-4.6673 56.847729-4.6673 56.847729l-0.466628 0c-5.872754 30.879288-16.214287 60.138682-30.464849 86.964654l0.36839 0.342808c-2.358721 4.815679-3.709485 10.220782-3.709485 15.943111 0 19.922748 19.088754 21.742187 38.765909 21.742187l238.761895 0.270153c0 0 14.666024 0.465604 14.690584 0.465604l0 0.100284c12.132318-0.638543 24.221658 5.207605 31.100322 16.409738 5.504364 9.016351 6.437619 19.6045 3.486404 28.988218L893.82573 486.837924z"
                              fill="#bfbfbf" p-id="6323"></path>
                          <path
                              d="M264.827039 924.31872c0.319272 0.024559 0.441045 0.024559 0.295735-0.024559 0.243547-0.048095 0.367367-0.074701-0.295735-0.074701s-0.539282 0.026606-0.271176 0.074701C264.43409 924.343279 264.532327 924.343279 264.827039 924.31872z"
                              fill="#bfbfbf" p-id="6324"></path>
                        </svg>
                      </template>
                      <span style="margin-left: 7px">{{ reply.like }}</span>
                    </el-button>
                    <el-button
                        class="reply-btn"
                        @click="handleReplyClick(index, 'reply', reply.id)">
                      <svg x="1735831070372" class="icon" viewBox="0 0 1024 1024" version="1.1"
                           xmlns="http://www.w3.org/2000/svg" p-id="5090" width="20" height="20">
                        <path
                            d="M298.666667 128C183.893333 128 85.333333 215.125333 85.333333 329.130667v237.738666C85.333333 680.874667 183.893333 768 298.666667 768a42.666667 42.666667 0 1 0 0-85.333333c-73.728 0-128-54.784-128-115.797334V329.130667C170.666667 268.117333 224.938667 213.333333 298.666667 213.333333h426.666666c73.728 0 128 54.784 128 115.797334v237.738666C853.333333 627.882667 799.061333 682.666667 725.333333 682.666667a42.666667 42.666667 0 0 0-42.666666 42.666666v96.213334l-142.122667-127.914667A42.666667 42.666667 0 0 0 512 682.666667h-42.666667a42.666667 42.666667 0 1 0 0 85.333333h26.282667l129.962667 116.949333C680.533333 934.4 768 895.402667 768 821.546667v-57.6c95.488-18.432 170.666667-97.536 170.666667-197.12v-237.653334C938.666667 215.082667 840.106667 128 725.333333 128H298.666667zM256 341.333333a42.666667 42.666667 0 0 1 42.666667-42.666666h426.666666a42.666667 42.666667 0 1 1 0 85.333333H298.666667a42.666667 42.666667 0 0 1-42.666667-42.666667z m42.666667 128a42.666667 42.666667 0 1 0 0 85.333334h256a42.666667 42.666667 0 1 0 0-85.333334H298.666667z"
                            fill="#bfbfbf" p-id="5091"></path>
                      </svg>
                    </el-button>
                  </div>
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
        <div class="comment-actions">
          <el-button class="like-btn" type="text" @click="likeComment(discussion.id, 'discussion')">
            <template v-if="discussion.isLiked">
              <svg x="1735831356929" class="icon" viewBox="0 0 1024 1024" version="1.1"
                   xmlns="http://www.w3.org/2000/svg" p-id="6725" width="20" height="20">
                <path
                    d="M64 483.04V872c0 37.216 30.144 67.36 67.36 67.36H192V416.32l-60.64-0.64A67.36 67.36 0 0 0 64 483.04zM857.28 344.992l-267.808 1.696c12.576-44.256 18.944-83.584 18.944-118.208 0-78.56-68.832-155.488-137.568-145.504-60.608 8.8-67.264 61.184-67.264 126.816v59.264c0 76.064-63.84 140.864-137.856 148L256 416.96v522.4h527.552a102.72 102.72 0 0 0 100.928-83.584l73.728-388.96a102.72 102.72 0 0 0-100.928-121.824z"
                    p-id="6726" fill="#bfbfbf"></path>
              </svg>
            </template>
            <template v-else>
              <svg x="1735831311461" class="icon" viewBox="0 0 1024 1024" version="1.1"
                   xmlns="http://www.w3.org/2000/svg" p-id="6321" width="20" height="20">
                <path
                    d="M190.193225 471.411583c14.446014 0 26.139334-11.718903 26.139334-26.13831 0-14.44499-11.69332-26.164916-26.139334-26.164916-0.271176 0-0.490164 0.149403-0.73678 0.149403l-62.496379 0.146333c-1.425466-0.195451-2.90005-0.295735-4.373611-0.295735-19.677155 0-35.621289 16.141632-35.621289 36.114522L86.622358 888.550075c0 19.949354 15.96767 35.597753 35.670407 35.597753 1.916653 0 3.808746 0.292666 5.649674 0l61.022819 0.022513c0.099261 0 0.148379 0.048095 0.24764 0.048095 0.097214 0 0.146333-0.048095 0.24457-0.048095l0.73678 0 0-0.148379c13.413498-0.540306 24.174586-11.422144 24.174586-24.960485 0-13.55983-10.760065-24.441669-24.174586-24.981974l0-0.393973-50.949392 0 1.450025-402.275993L190.193225 471.409536z"
                    fill="#bfbfbf" p-id="6322"></path>
                <path
                    d="M926.52241 433.948343c-19.283182-31.445176-47.339168-44.172035-81.289398-45.546336-1.77032-0.246617-3.536546-0.39295-5.380544-0.39295l-205.447139-0.688685c13.462616-39.059598 22.698978-85.58933 22.698978-129.317251 0-28.349675-3.193739-55.962569-9.041934-82.542948l-0.490164 0.049119c-10.638291-46.578852-51.736315-81.31498-100.966553-81.31498-57.264215 0-95.466282 48.15065-95.466282 106.126063 0 3.241834-0.294712 6.387477 0 9.532097-2.996241 108.386546-91.240027 195.548698-196.23636 207.513194l0 54.881958-0.785899 222.227314 0 229.744521 10.709923 0 500.025271 0.222057 8.746198-0.243547c19.35686 0.049119 30.239721-4.817726 47.803749-16.116049 16.682961-10.761088 29.236881-25.50079 37.490869-42.156122 2.260483-3.341095 4.028757-7.075139 5.106298-11.20111l77.018118-344.324116c1.056052-4.053316 1.348718-8.181333 1.056052-12.160971C943.643346 476.446249 938.781618 453.944769 926.52241 433.948343zM893.82573 486.837924l-82.983993 367.783411-0.099261-0.049119c-2.555196 6.141884-6.879688 11.596106-12.872169 15.427364-4.177136 2.727111-8.773827 4.351098-13.414521 4.964058-1.49812-0.195451-3.046383 0-4.620227 0l-477.028511-0.540306-0.171915-407.408897c89.323375-40.266076 154.841577-79.670527 188.596356-173.661202 0.072655 0.024559 0.124843 0.049119 0.195451 0.072655 2.99931-9.137101 6.313799-20.73423 8.697079-33.164331 5.551436-29.185716 5.258771-58.123792 5.258771-58.123792-4.937452-37.98001 25.940812-52.965306 44.364417-52.965306 25.304316 0.860601 50.263777 33.656541 50.263777 52.326762 0 0 5.600555 27.563776 5.649674 57.190537 0.048095 37.366026-4.6673 56.847729-4.6673 56.847729l-0.466628 0c-5.872754 30.879288-16.214287 60.138682-30.464849 86.964654l0.36839 0.342808c-2.358721 4.815679-3.709485 10.220782-3.709485 15.943111 0 19.922748 19.088754 21.742187 38.765909 21.742187l238.761895 0.270153c0 0 14.666024 0.465604 14.690584 0.465604l0 0.100284c12.132318-0.638543 24.221658 5.207605 31.100322 16.409738 5.504364 9.016351 6.437619 19.6045 3.486404 28.988218L893.82573 486.837924z"
                    fill="#bfbfbf" p-id="6323"></path>
                <path
                    d="M264.827039 924.31872c0.319272 0.024559 0.441045 0.024559 0.295735-0.024559 0.243547-0.048095 0.367367-0.074701-0.295735-0.074701s-0.539282 0.026606-0.271176 0.074701C264.43409 924.343279 264.532327 924.343279 264.827039 924.31872z"
                    fill="#bfbfbf" p-id="6324"></path>
              </svg>
            </template>
            <span style="margin-left: 7px">{{ discussion.like }}</span>
          </el-button>
          <el-button
              class="reply-btn"
              @click="handleReplyClick(index, 'discussion', discussion.id)">
            <svg x="1735831070372" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg"
                 p-id="5090" width="20" height="20">
              <path
                  d="M298.666667 128C183.893333 128 85.333333 215.125333 85.333333 329.130667v237.738666C85.333333 680.874667 183.893333 768 298.666667 768a42.666667 42.666667 0 1 0 0-85.333333c-73.728 0-128-54.784-128-115.797334V329.130667C170.666667 268.117333 224.938667 213.333333 298.666667 213.333333h426.666666c73.728 0 128 54.784 128 115.797334v237.738666C853.333333 627.882667 799.061333 682.666667 725.333333 682.666667a42.666667 42.666667 0 0 0-42.666666 42.666666v96.213334l-142.122667-127.914667A42.666667 42.666667 0 0 0 512 682.666667h-42.666667a42.666667 42.666667 0 1 0 0 85.333333h26.282667l129.962667 116.949333C680.533333 934.4 768 895.402667 768 821.546667v-57.6c95.488-18.432 170.666667-97.536 170.666667-197.12v-237.653334C938.666667 215.082667 840.106667 128 725.333333 128H298.666667zM256 341.333333a42.666667 42.666667 0 0 1 42.666667-42.666666h426.666666a42.666667 42.666667 0 1 1 0 85.333333H298.666667a42.666667 42.666667 0 0 1-42.666667-42.666667z m42.666667 128a42.666667 42.666667 0 1 0 0 85.333334h256a42.666667 42.666667 0 1 0 0-85.333334H298.666667z"
                  fill="#bfbfbf" p-id="5091"></path>
            </svg>
          </el-button>
        </div>
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

.discuss-content .discussion-avatar {
  margin-right: 10px;
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

.like-btn {
  margin-right: 10px;
  cursor: pointer;
  color: white;
}

.comment-actions .reply-btn {
  border: none;
  background: transparent;
  color: white;
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

.comment-actions {
  display: flex;
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