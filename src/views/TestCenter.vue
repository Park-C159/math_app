<script setup lang="ts">
import MathTextRenderer from "@/components/MathTextRenderer.vue";

import {useRoute} from "vue-router";
import {getCurrentInstance, inject, onBeforeUnmount, onMounted, ref} from "vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Delete, Download, Plus, ZoomIn} from '@element-plus/icons-vue'
import type {UploadFile} from 'element-plus'
import dayjs from 'dayjs'
import duration from 'dayjs/plugin/duration'

const route = useRoute()
const instance = getCurrentInstance()
const proxy = instance?.proxy
dayjs.extend(duration)

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
  user_answer: string;
  user_answer_flow: string[];
  file_list: string[];
}

interface UserInfoInterface {
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
  user_answer: string;
}

const UserInfo = ref<UserInfoInterface>();
const UserAnswerString = ref<string>(`exams-${route.query.exam_id}`);
const Questions = ref<Question[]>([]);
const EndTime = ref<string>(String(route.query.end_time))
const ExamTitle = ref<string>(String(route.query.exam_name))
const dialogImageUrl = ref('')
const dialogVisible = ref(false)
const disabled = ref(false)
const baseURL = inject<string>('baseURL')

let timer: number | null = null;
const TimeLeft = ref<number>(10000)
const TimeLeftString = ref<string>('00:00:00')

const getQuestions = () => {
  if (localStorage.getItem('isLogin') === 'true' && !localStorage.getItem(UserAnswerString.value)) {
    proxy?.$http.get("/exams", {
      params: {
        exam_id: route.query.exam_id
      }
    }).then((res) => {
      let response = res.data
      if (response.code === 200) {
        response.data.map((data: Question) => {
          if (data.type === 'flow') {
            data.user_answer_flow = Array(data.flows.length).fill('');
          }
        })
        Questions.value = response.data
        localStorage.setItem(UserAnswerString.value, JSON.stringify(Questions.value))
      } else {
        ElMessage({
          message: response.msg,
          type: 'error',
        })
      }
    })
  } else {
    let questions = localStorage.getItem(UserAnswerString.value)
    if (questions) {
      Questions.value = JSON.parse(questions)
    } else {
      ElMessage({
        message: "考试尚未发布！",
        type: 'warning',
      })
    }
  }
  console.log(Questions.value);

}

const updateAnswer = () => {
  Questions.value.map(question => {
    if (question.type === 'flow') {
      question.user_answer = JSON.stringify(question.user_answer_flow)
    }
  })
  localStorage.setItem(UserAnswerString.value, JSON.stringify(Questions.value));
}

// 图片上传
const handleUploadSuccess = (response: any, file: UploadFile, fileList: string[]) => {
  if (response.code === 200) {
    file.url = baseURL + response.data
    file.name = response.data
    ElMessage({
      message: response.msg,
      type: 'success',
    })
    updateAnswer()
  }
}
const customUpload = (option: any) => {
  const formData = new FormData();
  formData.append("file", option.file);

  proxy?.$http.post('upload', formData, {
    headers: {
      "Content-Type": "multipart/form-data"
    }
  }).then((res) => {
    option.onSuccess(res.data, option.file);
  })
}
const handleRemove = (file: UploadFile, file_list: any[]) => {
  proxy?.$http.delete("/upload", {
    params: {
      file_name: file.name
    }
  }).then((res => {
    if (res.data.code === 200) {

      const index = file_list.findIndex((f) => {
        f.name === file.name
        return f.name === file.name
      }); // 查找文件名对应的索引
      console.log(index);
      if (index !== -1) {
        file_list.splice(index, 1); // 删除该文件
      }
      updateAnswer()

      ElMessage({
        message: res.data.msg,
        type: 'success',
      })
    }
  }))
}
const handlePictureCardPreview = (file: UploadFile) => {
  dialogImageUrl.value = file.url!
  dialogVisible.value = true
}

const postExam = () => {
  let userAnswers: UserAnswer[] = []
  Questions.value.map(question => {
    let userAnswer: string = question.user_answer;
    if (question.type === 'proof') {
      userAnswer = JSON.stringify(question.file_list)
    }
    let userId: number = UserInfo.value?.id || 0
    userAnswers.push({
      // user_id: UserInfo.value.id,
      user_id: userId,
      question_id: question.id,
      user_answer: JSON.stringify(userAnswer)
    })
  })
  proxy?.$http.post("/user_answers", {
    exam_id: route.query.exam_id,
    user_answer: userAnswers
  }).then((res) => {
    let response = res.data
    if (response.code === 200) {
      ElMessage({
        type: 'success',
        message: '提交成功',
      })
    } else {
      ElMessage({
        type: 'warning',
        message: response.msg,
      })
    }
    setTimeout(() => {
      window.close();
    }, 3000)
  }).catch(err => {
    ElMessage({
      type: "error",
      message: "提交失败，请联系管理员！"
    })
    console.error(err)
  })

}
const submitExam = () => {
  ElMessageBox.confirm(
      '是否确认提交？提交之后不可重复提交！',
      '提示',
      {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'warning',
      }
  ).then(() => {
    postExam()
  }).catch(() => {
    ElMessage({
      type: 'info',
      message: '取消提交',
    })
  })
}


const startCountDown = () => {
  let endTime = new Date(EndTime.value).getTime()
  let now = new Date().getTime()
  const timeLeft = endTime - now
  if (timeLeft <= 0) {
    if (timer !== null) {
      clearInterval(timer)
      timer = null
      TimeLeft.value = 0
    }
    postExam()
  } else {
    TimeLeft.value = timeLeft / 1000
  }
  timer = setInterval(() => {
    if (TimeLeft.value > 0) {
      TimeLeft.value--;
      TimeLeftString.value = updateTime(TimeLeft.value)
      console.log(TimeLeftString.value)
    } else {
      if (timer !== null) {
        clearInterval(timer)
        timer = null
        TimeLeft.value = 0
      }
      postExam();  // 倒计时结束后执行操作
    }
  }, 1000)
}
const updateTime = (timeLeft: number) => {
  const durationFormatted = dayjs.duration(timeLeft, 'seconds')
  const formattedTime:string = `${String(durationFormatted.hours()).padStart(2, '0')}:${String(durationFormatted.minutes()).padStart(2, '0')}:${String(durationFormatted.seconds()).padStart(2, '0')}`;

  return formattedTime
}


onMounted(() => {
  let userInfo = localStorage.getItem('userInfo')
  if (userInfo) {
    let parseUserInfo = JSON.parse(userInfo) as UserInfoInterface
    UserInfo.value = parseUserInfo;
  }
  startCountDown()
  getQuestions()
})
// 在组件卸载时清除定时器
onBeforeUnmount(() => {
  if (timer) {
    clearInterval(timer);
  }
});

</script>

<template>
  <div id="container" class="container">
    <div class="time-left">{{TimeLeftString}}</div>
    <div class="info">
      <h1 class="exam-title">{{ ExamTitle }}</h1>
      <p>*请在规定时间内完成作答</p>
    </div>
    <div class="questions">
      <div class="question" v-for="(question, index) in Questions" :key="index">
        <!--        题目 -->
        <div class="question-title">
          <span v-if="question.type === 'choice'" class="question-type">选择题</span>
          <span v-if="question.type === 'blank'" class="question-type">填空题</span>
          <span v-if="question.type === 'proof'" class="question-type">解答题</span>
          <span v-if="question.type === 'flow'" class="question-type">流程题</span>
          ：<span>（{{ question.score }}分）</span>
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
                  v-model="question.user_answer"
                  @change="updateAnswer"
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
                    v-model="question.user_answer_flow[stepIndex]"
                    @change="updateAnswer"
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
              v-model="question.user_answer"
              placeholder="请在此输入答案，用“,”分隔多个答案"
              @change="updateAnswer"
          />
        </div>

        <!--  证明题  -->
        <div v-else-if="question.type === 'proof'">
          <el-upload
              v-model:file-list="question.file_list"
              list-type="picture-card"
              :on-success="handleUploadSuccess"
              :http-request="customUpload"
          >
            <el-icon>
              <Plus/>
            </el-icon>
            <template #file="{ file }">
              <div>
                <img class="el-upload-list__item-thumbnail" :src="file.url" alt=""/>
                <span class="el-upload-list__item-actions">
                    <span
                        class="el-upload-list__item-preview"
                        @click="handlePictureCardPreview(file)"
                    >
                      <el-icon><zoom-in/></el-icon>
                    </span>
                    <span
                        v-if="!disabled"
                        class="el-upload-list__item-delete"
                        @click="handleRemove(file, question.file_list)"
                    >
                      <el-icon><Delete/></el-icon>
                    </span>
                  </span>
              </div>
            </template>
          </el-upload>
          <el-dialog v-model="dialogVisible">
            <img w-full :src="dialogImageUrl" alt="Preview Image"/>
          </el-dialog>
        </div>
      </div>
    </div>
    <div class="btn">
      <el-button class="submit-btn" @click="submitExam">提交</el-button>
    </div>
  </div>
</template>

<style scoped>
#container {
  max-width: 1000px;
  margin: 0 auto
}

.info {
  padding: 5% 2%;
}

.info > .exam-title {
  text-align: center;
}

.question {
  margin: 2rem;
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
.time-left{
  position: fixed;
  top: 5%;         /* 距离视口顶部 10px */
  right: 5%;       /* 距离视口右侧 10px */
  z-index: 1000;     /* 确保它位于其他元素之上 */
  background-color: mistyrose;
  font-size: 2rem;
  text-align: center;
  padding: 0.5rem;
  border-radius: 0.5rem;
  color: #000;
  font-weight: bold;
}
</style>