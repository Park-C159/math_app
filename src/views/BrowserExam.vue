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
const TotalScore = ref(0)

// 统一的字符串格式化和解析函数
const formatAndParseAnswer = (answer: string) => {
  try {
    const formattedAnswer = answer.replace(/'/g, '"')
    return JSON.parse(formattedAnswer)
  } catch (error) {
    console.error('JSON 解析错误:', error)
    return null
  }
}

const getQuestions = () => {
  proxy?.$http.get("/user_answers", {
    params: {
      user_id: UserInfo.value?.id,
      exam_id: route.query.exam_id,
    }
  }).then((res) => {
    let response = res.data

    if (response.code === 200) {
      let totalScore = 0
      let question: Question[] = []

      response.data.map((data: Question) => {
        let fileList = null
        let userAnswerFlow = null
        let correctAnswer: string | string[] = data.correct_answer

        if(data.user_answer){
          if (data.type === 'proof') {
            // 格式化并解析正确答案和用户答案
            correctAnswer = formatAndParseAnswer(correctAnswer as string) // correct_answer可能是string或string[]
            let formatUserAnswer = data.user_answer.user_answer
            fileList = formatAndParseAnswer(formatUserAnswer) // 解析用户答案
          } else if (data.type === 'flow') {
            let formatUserAnswer = data.user_answer.user_answer
            userAnswerFlow = formatAndParseAnswer(formatUserAnswer) // 解析流式问题的用户答案
          }

        }else{
          if (data.type === 'proof') {
            correctAnswer = formatAndParseAnswer(correctAnswer as string) // correct_answer可能是string或string[]
          }

          fileList = []
          userAnswerFlow = []
          data.user_answer = {
            user_id: UserInfo.value?.id as number,
            question_id: data.id,
            is_correct: false,
            score: 0,
            user_answer: '',
            created_at: '',
          }
        }

        totalScore += data.user_answer.score
        // 将处理后的数据推送到问题数组中
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
      })

      // 更新到状态管理或其他地方
      Questions.value = question
      TotalScore.value = totalScore
    }

  })


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
const handlePictureCardPreview = (file: UploadFile) => {
  dialogImageUrl.value = file.url!
  dialogVisible.value = true
}


onMounted(() => {
  let userInfo = localStorage.getItem('userInfo')
  if (userInfo) {
    let parseUserInfo = JSON.parse(userInfo) as UserInfo
    UserInfo.value = parseUserInfo;

  }
  getQuestions()
})


</script>

<template>
  <div id="container" class="container">
    <div class="info">
      <h1 class="exam-title">{{ ExamTitle }}</h1>
      <h2 style="text-align: right">总分：<span style="color: red">{{TotalScore}}</span>分</h2>
    </div>

    <div class="questions">
      <div class="question" v-for="(question, index) in Questions" :key="index">
        <!--        题目 -->
        <div class="question-title">
          <span v-if="question.type === 'choice'" class="question-type">选择题</span>
          <span v-if="question.type === 'blank'" class="question-type">填空题</span>
          <span v-if="question.type === 'proof'" class="question-type">解答题</span>
          <span v-if="question.type === 'flow'" class="question-type">流程题</span>
          ：
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
                <img class="el-upload-list__item-thumbnail" :src="file.url" alt=""/>
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
            <img w-full :src="dialogImageUrl" alt="Preview Image"/>
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
          <span>{{question.user_answer.score}}/{{question.score}}</span>
        </div>
      </div>
    </div>
    <!--    <TestComponent />-->
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
.proof-answer{
  display: flex;
  flex-direction: row;

  justify-content: space-around;
}
.proof-answer>div{
  width: 45%;
}
</style>