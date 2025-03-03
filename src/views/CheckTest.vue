<script setup lang="ts">
import MathTextRenderer from "@/components/MathTextRenderer.vue";

import {useRoute} from "vue-router";
import {getCurrentInstance, inject, onMounted, ref} from "vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Delete, Download, Plus, ZoomIn} from '@element-plus/icons-vue'
import type {UploadFile} from 'element-plus'

const route = useRoute()
const instance = getCurrentInstance()
const proxy = instance?.proxy

interface QuestionOption {
  id: number;
  option_label: string;
  option_text: string;
}

interface QuestionFlow {
  id: number;
  step_label: number;
  step_text: string;
  is_hidden: boolean;
}

interface Question {
  id: number;
  question_text: string;
  score: number;
  type: 'choice' | 'blank' | 'proof' | 'flow';  // 根据题目类型调整
  created_at: string; // 日期类型为 string，符合 ISO 格式
  options: QuestionOption[]; // 选项数组
  flows: QuestionFlow[]; // 流程数组
  user_answer: UserAnswer;
  correct_answer: string | string[];
  user_answer_flow: string[];
  file_list: any[];
}

interface UserInfo {
  extra: string;         // 额外信息，可以为空字符串
  id: number;            // 用户ID
  phone_number: string;  // 用户的手机号
  role: string; // 用户角色，可以是 'admin' 或 'user'
  user_id: string;       // 用户唯一标识符
  username: string;      // 用户名
}

interface UserAnswer {
  user_id: number;
  question_id: number;
  is_correct: boolean;
  score: number;
  user_answer: string;
  created_at: string;
}

const UserInfo = ref<UserInfo>();
const Questions = ref<Question[]>([]);
const ExamTitle = ref<string>(String(route.query.exam_name))
const dialogImageUrl = ref('')
const dialogVisible = ref(false)
const disabled = ref(false)
const baseURL = inject<string>('baseURL')
const userList = ref<UserInfo[]>([]);
const userIndex = ref(0)
const currentUser = ref<UserInfo>(userList.value[userIndex.value]);
const loading = ref(false)

const isDrawing = ref(false);    // 是否正在绘制
const lastX = ref(0);            // 上次鼠标位置 X
const lastY = ref(0);            // 上次鼠标位置 Y
const currentFile = ref<any>(null);   // 当前选中的文件

// 统一的字符串格式化和解析函数
const formatAndParseAnswer = (answer: string) => {
  if (answer) {
    try {
      const formattedAnswer = answer.replace(/'/g, '"')
      return JSON.parse(formattedAnswer)
    } catch (error) {
      console.error('JSON 解析错误:', error)
      return []
    }
  } else {
    return []
  }
}

const getQuestions = (user_id: number) => {
  proxy?.$http.get("/user_answers", {
    params: {
      user_id: user_id,
      exam_id: route.query.exam_id,
    }
  }).then((res: any) => {
    let response = res.data

    if (response.code === 200) {
      let question: Question[] = []

      response.data.forEach((data: Question) => {
        let fileList = null
        let userAnswerFlow = null
        let correctAnswer: string | string[] = data.correct_answer

        if (data.user_answer) {
          data.user_answer.user_id = user_id
          if (data.type === 'proof') {
            // 格式化并解析正确答案和用户答案
            correctAnswer = formatAndParseAnswer(correctAnswer as string) // correct_answer可能是string或string[]
            let formatUserAnswer = data.user_answer.user_answer
            fileList = formatAndParseAnswer(formatUserAnswer) // 解析用户答案
          } else {
            if (data.type === 'flow') {
              let formatUserAnswer = data.user_answer.user_answer
              userAnswerFlow = formatAndParseAnswer(formatUserAnswer) // 解析流式问题的用户答案
            }
          }
        } else {
          if (data.type === 'proof') {
            correctAnswer = formatAndParseAnswer(correctAnswer as string) // correct_answer可能是string或string[]
          }

          fileList = []
          userAnswerFlow = []
          data.user_answer = {
            user_id: user_id,
            question_id: data.id,
            is_correct: false,
            score: 0,
            user_answer: '',
            created_at: '',
          }
        }

        // 将处理后的数据推送到问题数组中
        // if (data.type === 'proof') {
          question.push({
            id: data.id,
            question_text: data.question_text,
            score: data.score,
            type: data.type,
            created_at: data.created_at,
            options: data.options,
            flows: data.flows,
            user_answer: data.user_answer,
            correct_answer: correctAnswer,
            user_answer_flow: userAnswerFlow,
            file_list: fileList
          })
        // }
      })

      // 更新到状态管理或其他地方
      Questions.value = question
    }
  })
  setTimeout(() => {
    loading.value = false
  }, 500)

}

// 设置 canvas 背景和绘图工具
const setupCanvas = () => {
  const canvas = document.querySelector('canvas')!;
  const ctx = canvas.getContext('2d')!;
  const img = new Image();
  img.src = dialogImageUrl.value;

  // 设置跨域请求为 'anonymous'
  img.crossOrigin = 'anonymous';

  img.onload = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height); // 清空画布
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height); // 绘制图片到画布
  };

  ctx.strokeStyle = 'red'

  // 监听鼠标事件进行绘制
  canvas.onmousedown = (e) => {
    isDrawing.value = true;
    lastX.value = e.offsetX;
    lastY.value = e.offsetY;
  };

  canvas.onmousemove = (e) => {
    if (isDrawing.value) {
      ctx.beginPath();
      ctx.moveTo(lastX.value, lastY.value);
      ctx.lineTo(e.offsetX, e.offsetY);
      ctx.stroke();
      lastX.value = e.offsetX;
      lastY.value = e.offsetY;
    }
  };

  canvas.onmouseup = () => {
    isDrawing.value = false;
  };

  canvas.onmouseleave = () => {
    isDrawing.value = false;
  };
};

const handlePictureCardPreview = async (file: UploadFile) => {
  dialogImageUrl.value = file.url!
  currentFile.value = file
  dialogVisible.value = true
  setTimeout(() => {
    setupCanvas()
  }, 500)
}

// 保存绘制的内容
const saveDrawing = () => {
  const canvas = document.querySelector('canvas')!;
  const dataUrl = canvas.toDataURL('image/png'); // 获取绘制后的图片数据
  uploadToBackend(dataUrl); // 上传到后端
  dialogVisible.value = false; // 关闭对话框
};

// 清除绘制内容
const clearDrawing = () => {
  const canvas = document.querySelector('canvas')!;
  const ctx = canvas.getContext('2d')!;
  ctx.clearRect(0, 0, canvas.width, canvas.height); // 清除内容
  setupCanvas(); // 重新加载背景图片
};

// 将绘制后的图片上传到后端
const uploadToBackend = (imageData: string) => {
  // console.log(currentFile.value.name, '上传图片:', imageData);
  // 假设你会通过 Axios 上传图片
  proxy?.$http.put('/upload', {
    image_name: currentFile.value.name,
    image: imageData
  }).then((res: any) => {
    let response = res.data;
    if (response.code === 200) {
      ElMessage({
        type: 'success',
        message: response.msg
      })
    } else {
      ElMessage({
        type: "warning",
        message: response.msg
      })
    }
  }).catch((err: any) => {
    console.error(err)
    ElMessage({
      type: 'error',
      message: "服务器开小差了，请联系管理员！"
    })
  })
};

const getUserList = async () => {
  let course_id = route.query.course_id
  await proxy?.$http.get("course_user_list", {
    params: {
      course_id: course_id,
    }
  }).then(res => {
    let response = res.data
    if (response.code === 200) {
      userList.value = response.data
      currentUser.value = response.data[0]
    }
  })

}

const submitCheck = () => {
  let user_id: number;
  if (currentUser.value) {
    user_id = currentUser.value.id
  } else {
    return
  }
  let userAnswers: UserAnswer[] = []
  Questions.value.forEach(question => {
    userAnswers.push(question.user_answer)
  })
  proxy?.$http.put("/user_answers", {
    exam_id: route.query.exam_id,
    user_answers: userAnswers,
    user_id: user_id
  }).then(res => {
    let response = res.data
    if (response.code === 200) {
      ElMessage({
        type: 'success',
        message: response.msg
      })
    } else {
      ElMessage({
        type: 'error',
        message: response.msg,
      })
    }
  }).catch(err => {

    ElMessage({
      type: 'error',
      message: err.message,
    })
    console.error(err)
  })
  // console.log("submitCheck", Questions.value[0].user_answer.score)
}

const updateUser = (direction: string) => {
  if (direction === 'left') {
    if (userIndex.value > 0) {
      loading.value = true
      userIndex.value--
      currentUser.value = userList.value[userIndex.value]
      submitCheck()
      getQuestions(currentUser.value.id)
    } else {
      ElMessage({
        type: 'warning',
        message: "没有更多的学生了！"
      })
    }

  } else {
    if (userIndex.value < userList.value.length - 1) {
      loading.value = true
      userIndex.value++
      currentUser.value = userList.value[userIndex.value]
      submitCheck()
      getQuestions(currentUser.value.id)

    } else {
      ElMessage({
        type: 'warning',
        message: "没有更多学生了！请点击完成阅卷结束阅卷。"
      })
    }
  }
}

const finishCheck = () => {
  ElMessageBox.confirm(
      "是否完成阅卷？",
      "提示",
      {
        confirmButtonText: "是",
        cancelButtonText: "否",
        type: "warning",
      }
  ).then(() => {
    proxy?.$http.put("/exams", {
      exam_id: route.query.exam_id,
    }).then(res => {
      let response = res.data
      if (response.code === 200) {
        ElMessage({
          type: 'success',
          message: response.msg
        })
        setTimeout(() => {
          window.close()
        }, 3000)
      } else {
        ElMessage({
          type: 'warning',
          message: response.msg
        })
      }
    }).catch(err => {
      console.error(err)
      ElMessage({
        type: 'error',
        message: "系统错误，请联系管理员！",
      })
    })
  }).catch(() => {
    ElMessage({
      type: 'info',
      message: "未完成阅卷！"
    })
  })
}

onMounted(async () => {
  let userInfo = localStorage.getItem('userInfo')
  if (userInfo) {
    let parseUserInfo = JSON.parse(userInfo) as UserInfo
    UserInfo.value = parseUserInfo;

  }
  await getUserList();
  if (currentUser.value) {
    getQuestions(currentUser.value.id)
  }
})


</script>

<template>
  <div id="container" class="container">
    <div class="info">
      <h1 class="exam-title">{{ ExamTitle }}</h1>
    </div>
    <div class="exam">
      <div class="arrow" @click="updateUser('left')">
        <el-icon>
          <ArrowLeftBold/>
        </el-icon>
      </div>
      <div class="questions" v-if="!loading">
        <div class="question" v-for="(question, index) in Questions" :key="index">
          <!--        题目 -->
          <div class="question-title">
            <span v-if="question.type === 'choice'" class="question-type">选择题</span>
            <span v-if="question.type === 'blank'" class="question-type">填空题</span>
            <span v-if="question.type === 'proof'" class="question-type">解答题</span>
            <span v-if="question.type === 'flow'" class="question-type">流程题</span>
            ：<span>（{{ question.score }}分）</span>
            111
            <MathTextRenderer :raw-text="question.question_text"/>
          </div>

          <!--        选择题选项 -->
          <div v-if="question.type === 'choice'">
            <ul>
              <li v-for="(option, optionIndex) in question.options" :key="optionIndex">
                <input
                    type="radio"
                    :name="'mcq_' + index"
                    :value="option.option_label"
                    v-model="question.user_answer.user_answer"
                />
                {{ option.option_label }}.
                <MathTextRenderer :raw-text="option.option_text"/>
              </li>
            </ul>
          </div>

          <!-- 流程题流程 -->
          <div v-else-if="question.type==='flow'">
            <ul>
              <li v-for="(step, stepIndex) in question.flows" :key="stepIndex" class="flow-block">
                <div class="flow-item">
                  <span v-if="!step.is_hidden"><MathTextRenderer :raw-text="step.step_text"/></span>
                  <el-input
                      v-else
                      type="textarea"
                      placeholder="请补全流程"
                      rows="2"
                      disabled
                      v-model="question.user_answer_flow[stepIndex]"
                  ></el-input>
                </div>
                <div v-if="stepIndex < question.flows.length - 1" class="arrow">
                  &darr;
                </div>
              </li>
            </ul>
          </div>

          <!-- 填空题  -->
          <div v-else-if="question.type==='blank'" class="blank-block">
            <input
                disabled
                v-model="question.user_answer.user_answer"
                placeholder="请在此输入答案，用“,”分隔多个答案"
            />
          </div>

          <!--  证明题  -->
          <div v-else-if="question.type === 'proof'">
            <el-upload
                v-model:file-list="question.file_list"
                list-type="picture-card"
            >
              <el-icon>
                <Plus/>
              </el-icon>
              <template #file="{ file }">
                <div>
                  <img class="el-upload-list__item-thumbnail" :src="file.url" alt="未作答"/>
                  <span class="el-upload-list__item-actions">
                    <span
                        class="el-upload-list__item-preview"
                        @click="handlePictureCardPreview(file)"
                    >
                      <el-icon><zoom-in/></el-icon>
                    </span>
                  </span>
                </div>
              </template>
            </el-upload>
            <el-dialog v-model="dialogVisible">
              <div>
                <canvas ref="canvas" width="500" height="500" style="border: 1px solid #ccc;"></canvas>
              </div>
              <div>
                <el-button @click="saveDrawing">保存</el-button>
                <el-button @click="clearDrawing">清除笔迹</el-button>
              </div>
            </el-dialog>
          </div>

          <!--        正确答案-->
          <div class="correct-answer">
            <span>标准答案：</span>
            <div class="proof-answer" v-if="question.type === 'proof'">
              <div v-for="(imgUrl, imgIndex) in question.correct_answer" :key="imgIndex">
                <img :src="imgUrl" alt="标准答案" style="width: 100%">
              </div>
            </div>
            <span v-else>{{ question.correct_answer }}</span>

          </div>

          <div class="score">
            <span>得分：</span>
            <el-input
                placeholder="请输入得分，可以有小数"
                v-model="question.user_answer.score"
                @blur=""
            >
            </el-input>
          </div>
        </div>
      </div>
      <div v-else>
        <el-icon>
          <Loading/>
        </el-icon>
      </div>

      <div class="arrow" @click="updateUser('right')">
        <el-icon>
          <ArrowRightBold/>
        </el-icon>
      </div>
    </div>
    <div class="btns">
      <el-button class="submit-btn" type="success" plain @click="submitCheck">保存</el-button>
    </div>
    <div class="btns">
      <el-button class="submit-btn" type="warning" plain @click="finishCheck">完成阅卷</el-button>
    </div>
  </div>
</template>

<style scoped>
#container {
  max-width: 1000px;
  margin: 0 auto
}

.exam {
  display: flex;
  justify-content: center;
  align-items: center;
}

.exam > .arrow {
  cursor: pointer;
  height: 100px;
  width: 100px;
  line-height: 100px;
  font-size: 50px;
  border-radius: 5%;
}

.exam > .arrow:hover {
  background-color: #aaa;
}

.info {
  padding: 5% 2%;
}

.info > .exam-title {
  text-align: center;
}

.question {
  padding: 5%;
  border-radius: 10px;
  border: 1px solid #ccc;
}

.flow-block {
  margin-bottom: 1rem;
}

.flow-item {
  margin-bottom: 0.5rem;
}

.arrow {
  text-align: center;
  margin-bottom: 0.5rem;
}

.flow-item {
  width: 50%;
  background-color: antiquewhite;
  border-radius: 1rem;
  padding: 1rem;
  color: #1c1c2c;
  text-align: center;
}

.flow-block {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.blank-block {
  margin-top: 0.5rem;
}

.blank-block input {
  width: 100%;
}

.submit-btn {
  width: 100%;

}

.proof-answer {
  display: flex;
  flex-direction: row;

  justify-content: space-around;
}

.proof-answer > div {
  width: 45%;
}

.btns {
  width: 100%;
  margin-top: 1rem;
}

.el-pagination {
  display: flex;
  justify-content: space-between;
}

.el-pager {
  width: 100%;
}
</style>