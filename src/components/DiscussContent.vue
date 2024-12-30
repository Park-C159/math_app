<script setup lang="ts">
import {ref, getCurrentInstance, onMounted, watch} from "vue";
import {Search, UserFilled, ArrowDown, Star} from "@element-plus/icons-vue";
import dayjs from "dayjs";
import {ElMessage} from 'element-plus'
import FilePreview from './FilePreview.vue';
import ContentRenderer from './ContentRenderer.vue';

// 获取 Vue 实例
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
const jumpToPage = ref<number | null>(null); // 跳转页码输入
const timeFilter = ref('all'); // 保存当前的时间筛选条件
const authorFilter = ref('all'); // 保存当前的人物筛选条件
const emojiList = ["😀", "😁", "😂", "🤣", "😃", "😄", "😅", "😆", "😉", "😊", "😋", "😎", "😍", "😘", "🥰", "😗", "😙", "😚", "☺", "🙂", "🤗", "🤩", "🤔", "🤨", "😐", "😑", "😶", "🙄", "😏", "😣", "😥", "😮", "🤐", "😯", "😪", "😫", "🥱", "😴", "😌", "😛", "😜", "😝", "🤤", "😒", "😓", "😔", "😕", "🙃", "🤑", "😲", "☹", "🙁", "😖", "😞", "😟", "😤", "😢", "😭", "😦", "😧", "😨", "😩", "🤯", "😬", "😰", "😱", "🥵", "🥶", "😳", "🤪", "😵", "🥴", "😠", "😡", "🤬", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "😇", "🥺", "🤠", "🤡", "🤥", "🤫", "🤭", "🧐", "🤓", "😈", "👿", "👹", "👺", "💀", "☠", "👻", "👽", "👾", "🤖", " 💩", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🐱‍👤", "🐱‍🏍", "🐱‍💻", "🐱‍🐉", "🐱‍👓", "🐱‍🚀", "🙈", " 🙉", "🙊", "🐵", "🐶", "🐺", "🐱", "🦁", "🐯", "🦒", "🦊", "🦝", "🐮", "🐷", "🐗", "🐭", "🐹", "🐰", "🐻", "🐨", "🐼", "🐸", "🦓", "🐴", "🦄", "🐔", "🐲", "🐽", "🐾", "🐒", "🦍", "🦧", "🦮", "🐕‍🦺", "🐩", "🐕", "🐈", "🐅", "🐆", "🐎", "🦌", "🦏", "🦛", "🐂", "🐃", "🐄", "🐖", "🐏", "🐑", "🐐", "🐪", "🐫", "🦙", "🦘", "🦥", "🦨", "🦡", "🐘", "🐁", "🐀", "🦔", "🐇", "🐿", "🦎", "🐊", "🐢", "🐍", "🐉", "🦕", "🦖", "🦦", "🦈", "🐬", "🐳", "🐋", "🐟", "🐠", "🐡", "🦐", "🦑", "🐙", "🦞", "🦀", "🐚", "🦆", "🐓", "🦃", "🦅", "🕊", "🦢", "🦜", "🦩", "🦚", "🦉", "🐦", "🐧", "🐥", "🐤", "🐣", "🦇", "🦋", "🐌", "🐛", "🦟", "🦗", "🐜", "🐝", "🐞", "🦂", "🕷", "🕸", "🦠", "🧞‍♀️", "🧞‍♂️", "🗣", "👤", "👥", "👁", "👀", "🦴", "🦷", "👅", "👄", "🧠", "🦾", "🦿", "👣", "🤺", "⛷", "🤼‍♂️", "🤼‍♀️", "👯‍♂️", "👯‍♀️", "💑", "👩‍❤️‍👩", "👨‍❤️‍👨", "💏", "👩‍❤️‍💋‍👩", "👨‍❤️‍💋‍👨", "👪", "👨‍👩‍👦", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧", "👨‍👨‍👦", " 👨‍👨‍👧", "👨‍👨‍👧‍👦", "👨‍👨‍👦‍👦", "👨‍👨‍👧‍👧", "👩‍👩‍👦", "👩‍👩‍👧", "👩‍👩‍👧‍👦", "👩‍👩‍👦‍👦", "👩‍👩‍👧‍👧", "👩‍👦", "👩‍👧", "👩‍👧‍👦", "👩‍👦‍👦", "👩‍👧‍👧", "👨‍👦", "👨‍👧", "👨‍👧‍👦", "👨‍👦‍👦", "👨‍👧‍👧", "👭", "👩🏻‍🤝‍👩🏻", "👩🏼‍🤝‍👩🏻", "👩🏼‍🤝‍👩🏼", "👩🏽‍🤝‍👩🏻", "👩🏽‍🤝‍👩🏼", "👩🏽‍🤝‍👩🏽", "👩🏾‍🤝‍👩🏻", "👩🏾‍🤝‍👩🏼", "👩🏾‍🤝‍👩🏽", "👩🏾‍🤝‍👩🏾", "👩🏿‍🤝‍👩🏻", "👩🏿‍🤝‍👩🏼", "👩🏿‍🤝‍👩🏽", "👩🏿‍🤝‍👩🏾", "👩🏿‍🤝‍👩🏿", "👫", "👩🏻‍🤝‍🧑🏻", "👩🏻‍🤝‍🧑🏼", "👩🏻‍🤝‍🧑🏽", "👩🏻‍🤝‍🧑🏾", "👩🏻‍🤝‍🧑🏿", "👩🏼‍🤝‍🧑🏻", "👩🏼‍🤝‍🧑🏼", "👩🏼‍🤝‍🧑🏽", "👩🏼‍🤝‍🧑🏾", "👩🏼‍🤝‍🧑🏿", "👩🏽‍🤝‍🧑🏻", "👩🏽‍🤝‍🧑🏼", "👩🏽‍🤝‍🧑🏽", "👩🏽‍🤝‍🧑🏾", "👩🏽‍🤝‍🧑🏿", "👩🏾‍🤝‍🧑🏻", "👩🏾‍🤝‍🧑🏼", "👩🏾‍🤝‍🧑🏽", "👩🏾‍🤝‍🧑🏾", "👩🏾‍🤝‍🧑🏿", "👩🏿‍🤝‍🧑🏻", "👩🏿‍🤝‍🧑🏼", "👩🏿‍🤝‍🧑🏽", "👩🏿‍🤝‍🧑🏾", "👩🏿‍🤝‍🧑🏿", "👬", "👨🏻‍🤝‍👨🏻", "👨🏼‍🤝‍👨🏻", "👨🏼‍🤝‍👨🏼", "👨🏽‍🤝‍👨🏻", "👨🏽‍🤝‍👨🏼", "👨🏽‍🤝‍👨🏽", "👨🏾‍🤝‍👨🏻", "👨🏾‍🤝‍👨🏼", "👨🏾‍🤝‍👨🏽", "👨🏾‍🤝‍👨🏾", "👨🏿‍🤝‍👨🏻", "👨🏿‍🤝‍👨🏼", "👨🏿‍🤝‍👨🏽", "👨🏿‍🤝‍👨🏾", "👨🏿‍🤝‍👨🏿"]
const FILE_SIZE_LIMIT = 20 // 10MB
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/bmp']
const ALLOWED_PDF_TYPE = 'application/pdf'

interface UploadFile {
  raw: File;
  name: string;
  type: string;
  size: number;
}

interface UploadRequestOptions {
  file: File;
  onProgress?: (progressEvent: { percent: number }) => void;
  onSuccess?: (response: any) => void;
  onError?: (error: any) => void;
}

const insertMainEmoji = (emoji: any) => {
  discussionContent.value += emoji
}

const insertReplyEmoji = (emoji: any, index: number) => {
  if (!replyContent.value[index]) {
    replyContent.value[index] = ''
  }
  replyContent.value[index] += emoji
}


const beforeUpload = (file: File) => {
  const isAllowedType = [...ALLOWED_IMAGE_TYPES, ALLOWED_PDF_TYPE].includes(file.type)
  const isLt10M = file.size / 1024 / 1024 < FILE_SIZE_LIMIT

  if (!isAllowedType) {
    ElMessage({
      type: 'error',
      message: '只能上传图片或PDF文件！'
    })
    return false
  }

  if (!isLt10M) {
    ElMessage({
      type: 'error',
      message: `文件大小不能超过 ${FILE_SIZE_LIMIT}MB!`
    })
    return false
  }

  return true
}

const loading = ref(false)
const uploadProgress = ref(0)

// 获取文件显示格式
const getFileDisplayFormat = (fileType: string) => {
  if (ALLOWED_IMAGE_TYPES.includes(fileType)) {
    return 'image'
  } else if (fileType === ALLOWED_PDF_TYPE) {
    return 'pdf'
  }
  return null
}

// 生成插入内容
const generateInsertContent = (url: string, fileType: string, fileName: string) => {
  const displayFormat = getFileDisplayFormat(fileType)

  if (displayFormat === 'image') {
    return `![图片](${url})`
  } else if (displayFormat === 'pdf') {
    return `[PDF文件-${fileName}](${url})`
  }
  return ''
}

const customUpload = async (options: UploadRequestOptions, index?: number) => {
  const file = options.file
  loading.value = true
  uploadProgress.value = 0

  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('file_type', options.file.type === ALLOWED_PDF_TYPE ? 'pdf' : 'image')

    const response: any = await proxy?.$http.post("/upload", formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.code === 200) {
      const insertContent = generateInsertContent(
          response.data.data,
          file.type,
          file.name
      )

      // 插入内容到编辑器
      if (index === undefined) {
        discussionContent.value = (discussionContent.value || '') + insertContent
      } else {
        replyContent.value[index] = (replyContent.value[index] || '') + insertContent
      }

      ElMessage({
        type: 'success',
        message: '文件上传成功'
      })

      options.onSuccess?.(response)
    } else {
      throw new Error(response.data.msg || '上传失败')
    }
  } catch (error) {
    console.error('上传错误:', error)
    ElMessage({
      type: 'error',
      message: error instanceof Error ? error.message : '服务器错误，请联系管理员'
    })
    options.onError?.(error)
  } finally {
    loading.value = false
    uploadProgress.value = 0
  }
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
const getDiscussContent = async (page: number = 1) => {
  try {
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

    if (response?.data?.discussions && response.data.discussions.length > 0) {
      discussions.value = response.data.discussions.map((discussion: any) => ({
        ...discussion,
        showReplies: false
      }));
      totalReplies.value = response.data.total || 0;
      currentPage.value = page;
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
const likeDoR = async (id: number, type: string) => {
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
    console.log(`User ${userInfo.username} is creating a discussion...`);
    showEditor.value = true;
  } else {
    console.warn("Cannot create a discussion without valid user information.");
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
        discussions.value.unshift(response.data.discussion);  // 添加到前端
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


// 跳转到指定评论区页面
const jumpToSpecificPage = () => {
  const totalPages = Math.ceil(totalReplies.value / perPage.value);
  if (jumpToPage.value && jumpToPage.value > 0 && jumpToPage.value <= totalPages) {
    getDiscussContent(jumpToPage.value);
    jumpToPage.value = null;
  } else {
    ElMessage.error('请输入有效页码');
  }
};


// 搜索功能
const handleSearch = () => {
  currentPage.value = 1;
  getDiscussContent();
};


// 处理时间筛选按钮点击事件
const handleTimeFilterClick = (filter: string) => {
  timeFilter.value = filter; // 更新时间筛选条件
  getDiscussContent(1); // 重新获取第一页数据
};


// 处理人物筛选按钮点击事件
const handleAuthorFilterClick = (filter: string) => {
  authorFilter.value = filter; // 更新时间筛选条件
  getDiscussContent(1); // 重新获取第一页数据
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
    <div class="discuss-header">
      <div class="discuss-header-left">
        <el-input
            v-model="input"
            style="max-width: 300px; text-align: left"
            placeholder="请输入需要搜索的关键字"
            class="input-with-select"
            @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button :icon="Search" @click="handleSearch"/>
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
              <ArrowDown/>
            </el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleAuthorFilterClick('created_by_me')">我发布的</el-dropdown-item>
              <el-dropdown-item @click="handleAuthorFilterClick('teacher_involved')">老师参与</el-dropdown-item>
              <el-dropdown-item @click="handleAuthorFilterClick('all')">恢复默认</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        <el-dropdown>
          <span class="el-dropdown-link">
            所有时间
            <el-icon class="el-icon--right">
              <ArrowDown/>
            </el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleTimeFilterClick('last_week')">最近一周</el-dropdown-item>
              <el-dropdown-item @click="handleTimeFilterClick('last_month')">最近一月</el-dropdown-item>
              <el-dropdown-item @click="handleTimeFilterClick('all')">恢复默认</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 编辑框（发言框） -->
    <div v-if="showEditor" class="editor-container">
      <FilePreview :content="discussionContent"/>
      <el-input v-model="discussionContent" type="textarea" placeholder="请输入讨论内容..." rows="4"
                style="margin-bottom: 10px; border: none"/>
      <div class="editor-buttons-left">
        <el-popover placement="bottom" :width="300" trigger="click">
          <template #reference>
            <el-button icon="Plus"/>
          </template>
          <div class="emoji-container">
            <span v-for="emoji in emojiList" :key="emoji" class="emoji-item" @click="insertMainEmoji(emoji)">{{
                emoji
              }}</span>
          </div>
        </el-popover>

        <el-upload
            class="upload-demo"
            :http-request="(options:any) => customUpload(options)"
            :auto-upload="true"
            :show-file-list="false"
            :before-upload="beforeUpload"
            accept=".jpg,.jpeg,.png,.gif,.webp,.pdf"
        >
          <template #trigger>
            <el-button :loading="loading" icon="Upload" plain>
              {{ loading ? `上传中 ${uploadProgress}%` : '上传' }}
            </el-button>
          </template>
        </el-upload>
      </div>
      <div class="editor-buttons-right">
        <el-button class="new_discussion-btn" plain icon="Promotion" @click="submitDiscussion"/>
        <el-button @click="showEditor = false;discussionContent=''" icon="Close"/>
      </div>
    </div>

    <!-- 评论区显示区 -->
    <div class="discuss-content">
      <div class="discussion" v-for="(discussion, index) in discussions" :key="index">
        <div class="discussion-left">
          <div class="discussion-avatar">
            <el-avatar :icon="UserFilled"/>
          </div>
          <div class="discussion-main">
            <div class="user">
              {{ discussion.author_name }}
              &nbsp;&nbsp;<span style="font-size: small">
              {{ dayjs(discussion.created_at).format("YYYY-MM-DD") }}
            </span>
            </div>
            <!-- 修改后的帖子内容展示 -->
            <div class="text">
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
                  <div class="reply-user-info">
                    <div class="discussion-avatar">
                      <el-avatar :icon="UserFilled"/>
                    </div>
                    <div class="reply-user font-bold text-base">
                      {{ reply.replier_name }}
                    </div>
                    <div class="reply-time text-gray-500 text-sm">
                      {{ dayjs(reply.reply_time).format("YYYY-MM-DD") }}
                    </div>
                  </div>
                  <div class="reply-actions">
                    <el-button class="like-btn" type="text" :icon="reply.isLiked ? 'StarFilled' : 'Star'"
                               @click="likeDoR(reply.id, 'reply')">
                      <span>{{ reply.like }}</span>
                    </el-button>
                    <el-button class="reply-btn" style="background: transparent; margin-left: 0" icon="EditPen"
                               @click="handleReplyClick(index, 'reply', reply.id)"/>
                  </div>
                </div>
                <div class="reply-content mt-2">
                <span v-if="reply.reply_type === 'reply'" style="color: blue">
                  @{{ reply.target_name }}
                </span>
                  <ContentRenderer :content="reply.reply_content"/>
                </div>
              </div>
            </div>

            <div v-if="activeReplyIndex === index" class="reply-editor-container">
              <el-input v-model="replyContent[index]" type="textarea" placeholder="请输入回复内容..." rows="3"
                        style="margin-top: 10px; margin-bottom: 10px"/>
              <div class="editor-buttons-left">
                <el-popover placement="bottom" :width="300" trigger="click">
                  <template #reference>
                    <el-button icon="Plus"/>
                  </template>
                  <div class="emoji-container">
                  <span v-for="emoji in emojiList" :key="emoji" class="emoji-item"
                        @click="insertReplyEmoji(emoji, index)">{{ emoji }}</span>
                  </div>
                </el-popover>

                <el-upload class="upload-demo" :http-request="(options:any) => customUpload(options, index)"
                           :auto-upload="true" :show-file-list="false" :before-upload="beforeUpload"
                           accept=".jpg,.jpeg,.png,.gif,.webp,.pdf">
                  <template #trigger>
                    <el-button :loading="loading" icon="Upload" plain>
                      {{ loading ? `上传中 ${uploadProgress}%` : '上传' }}
                    </el-button>
                  </template>
                </el-upload>
              </div>
              <div class="editor-buttons-right">
                <el-button plain @click="submitReply(discussion.id, index)" icon="Promotion"/>
                <el-button @click="activeReplyIndex = null" icon="Close"/>
              </div>
            </div>
          </div>
        </div>
        <div class="discussion-actions">
          <el-button class="like-btn" type="text" :icon="discussion.isLiked ? 'StarFilled' : 'Star'"
                     @click="likeDoR(discussion.id, 'discussion')">
            <span>{{ discussion.like }}</span>
          </el-button>
          <el-button class="reply-btn" style="background: transparent; margin-left: 0" icon="EditPen"
                     @click="handleReplyClick(index, 'discussion', discussion.id)"/>
        </div>
      </div>
    </div>

    <!-- 讨论区分页展示切换按钮 -->
    <div class="pagination-container">
      <div class="pagination-wrapper">
        <!-- 切换 -->
        <el-pagination
            :current-page="currentPage"
            :page-size="perPage"
            :total="totalReplies"
            layout="prev, pager, next"
            @current-change="handlePageChange"
            class="custom-pagination"
        ></el-pagination>
        <!-- 跳转 -->
        <div class="jump-to-page">
          <el-input
              v-model="jumpToPage"
              type="number"
              placeholder="跳转页码"
              size="small"
              class="jump-input"
          ></el-input>
          <el-button
              type="primary"
              size="small"
              @click="jumpToSpecificPage"
              class="jump-button"
          >
            跳转
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.discuss-container {
  width: 100%;
}

.discuss-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.discuss-header-left {
  display: flex;
  align-items: center;
}

.discuss-header-left > * {
  margin-right: 10px;
}

.discuss-content {
  background-color: rgba(30, 30, 30, 0.7);
  padding: 1rem;
  border-radius: 8px;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.discuss-content .discussion {
  display: flex;
  align-items: flex-start;
}

.discuss-content .discussion-left {
  display: flex;
  width: 100%;
}

.discuss-content .discussion-avatar {
  flex-shrink: 0; /* Prevents avatar from shrinking */
  margin-right: 10px; /* Add some space between avatar and main content */
}

.discuss-content .discussion-main {
  flex-grow: 1; /* Allows the main content to expand and fill available space */
  min-width: 0; /* Prevents text overflow issues in flex containers */
  width: 100%; /* Ensures full width within the flex container */
}

.discussion {
  padding: 1rem;
  display: flex;
  box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.85);
  background: #444;
  margin-top: 1rem;
  border-radius: 1rem;
  justify-content: space-between;
}

.discussion-left {
  display: flex;
}

.discussion-main {
  margin-left: 0.5rem;
}

.discussion-actions {
  display: flex;
}

.like-btn {
  margin-right: 10px;
  cursor: pointer;
  color: white;
}

.reply-btn {
  border: none;
  background: transparent;
  margin-left: 0;
  color: white;
}

.reply-container {
  border-radius: 10px;
  padding: 4px 4px 4px 17px;
  border: 1px solid gray;
  transition: background-color 0.3s ease;
  margin-bottom: 7px;
}

.reply-user-info {
  display: flex;
}

.reply-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
}

.reply-actions {
  display: flex;
  align-items: center;
}

.reply-content {
  width: 92%;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.pagination-wrapper {
  display: flex;
  align-items: center;
  background-color: rgba(50, 50, 50, 0.5);
  padding: 15px 25px;
  border-radius: 12px;
  backdrop-filter: blur(15px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.custom-pagination {
  margin-right: 30px;
}

.jump-to-page {
  display: flex;
  align-items: center;
}

.jump-input {
  width: 120px;
  margin-right: 15px;
}

.jump-button {
  background-color: rgba(95, 95, 95, 0.7);
  border-color: transparent;
  color: #fff;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.jump-button:hover {
  background-color: rgba(110, 110, 110, 0.8);
  transform: scale(1.05);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

.custom-pagination :deep(.el-pager li) {
  background-color: rgba(70, 70, 70, 0.5);
  backdrop-filter: blur(10px);
  margin: 0 5px;
  border-radius: 6px;
  transition: all 0.3s ease;
  color: white !important;
}

.custom-pagination :deep(.el-pager li:hover) {
  background-color: rgba(90, 90, 90, 0.7);
  transform: scale(1.1);
}

.replies-toggle-btn {
  color: #888;
  text-decoration: none;
  padding: 0;
  background: none;
  border: none;
  font-size: 0.9em;
}

.filter {
  display: flex;
  gap: 20px;
}

/* 主容器样式 */
.reply-editor-container,
.editor-container {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
  background: white;
}


/* 按钮容器布局 */
.editor-buttons-left {
  display: flex;
  gap: 8px;
  margin: 8px 0;
}

.editor-buttons-right {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 8px;
}

/* 表情选择器样式 */
.emoji-container {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 8px;
  padding: 8px;
  max-height: 200px; /* 设置最大高度 */
  overflow-y: auto; /* 添加垂直滚动条 */
}

/* 自定义滚动条样式 */
.emoji-container::-webkit-scrollbar {
  width: 6px;
}

.emoji-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.emoji-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.emoji-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.emoji-item {
  cursor: pointer;
  text-align: center;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.emoji-item:hover {
  background-color: #f5f7fa;
}

/* 按钮行容器 */
.editor-container .buttons-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}
</style>