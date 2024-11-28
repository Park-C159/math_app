<script setup lang="ts">
import {useRoute, useRouter} from 'vue-router';  // 获取路由参数
import {ref, onMounted, getCurrentInstance} from 'vue';   // Vue的响应式和生命周期
import axios from 'axios';  // 用于HTTP请求
import {marked} from 'marked';
import MathTextRenderer from "@/components/MathTextRenderer.vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Delete, Plus, ZoomIn} from "@element-plus/icons-vue";  // 用于解析Markdown内容

interface Option {
  option_id: number;
  option_label: string;
  option_text: string;
}

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

interface Step {
  step_id: number;
  step_text: string;
  is_hidden: boolean;
}

interface UserWithAnswer {
  user_id: number;
  question_id: number;
  is_correct: boolean;
  score: number;
  user_answer: string;
  created_at: string;
}

interface Question {
  id: number;
  question_text: string;
  score: -1;
  type: 'choice' | 'blank' | 'proof' | 'flow';  // 根据题目类型调整
  created_at: string; // 日期类型为 string，符合 ISO 格式
  options: QuestionOption[]; // 选项数组
  flows: QuestionFlow[]; // 流程数组
  user_answer: UserWithAnswer;
  correct_answer: string | string[];
  user_answer_flow: string[];
  file_list: any[];
}

interface UserInfoInterface {
  extra: string;         // 额外信息，可以为空字符串
  id: number;            // 用户ID
  phone_number: string;  // 用户的手机号
  role: string; // 用户角色，可以是 'admin' 或 'user'
  user_id: string;       // 用户唯一标识符
  username: string;      // 用户名
}


// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况
// 获取路由实例
const route = useRoute();
const router = useRouter();

// 响应式变量来存储课程信息和视频URL
const markdownContent = ref<string | Promise<string>>('');
const courseData = ref({
  chapter_title: '',
  content: '',
  course_name: '',
  section_title: '',
  planned_hours: 0,
  video_link: ''
});

interface UserAnswer {
  user_id: number;
  question_id: number;
  user_answer: string;
}

const videoUrl = ref<string>('');
const UserAnswerString = ref<string>(`course-${route.query.course_id}`);
const UserInfo = ref<UserInfoInterface>();

// 获取后端内容
const getContent = async () => {
  try {
    const courseName = route.query.class_name as string;
    const courseId = route.query.course_id as string;

    if (courseId) {
      const response = await proxy?.$http.get(`/course_content`, {
        params: {course_name: courseName, course_id: courseId}
      });

      const course = response?.data[0];
      courseData.value = {
        chapter_title: course.chapter_title,
        content: course.content,
        course_name: course.course_name,
        section_title: course.section_title,
        planned_hours: course.planned_hours,
        video_link: course.video_link,
      };
      markdownContent.value = marked(course.content);
    }
  } catch (error) {
    console.error('Error fetching course content:', error);
  }
};

// 获取视频的 URL 或视频 Blob
const getVideo = async () => {
  try {
    const response = await proxy?.$http.get('/get_video', {
      params: {video_name: "sym_" + route.query.course_id},
      responseType: 'blob'
    });

    const blob = new Blob([response?.data], {type: 'video/mp4'});
    videoUrl.value = URL.createObjectURL(blob);
  } catch (error) {
    console.error('Error fetching video:', error);
  }
};

// 响应式变量来存储题目和用户答案
const Questions = ref<Question[]>([]);
const userAnswer = ref<any[]>([]);
const correctResults = ref<Array<boolean | null>>([]); // 存储每道题的正确/错误状态

const formatAndParseAnswer = (answer: string) => {
  try {
    const formattedAnswer = answer.replace(/'/g, '"')
    return JSON.parse(formattedAnswer)
  } catch (error) {
    console.error('JSON 解析错误:', error)
    return null
  }
}

// 获取题目
const getQuestions = () => {
  proxy?.$http.get("/user_answers", {
    params: {
      user_id: UserInfo.value?.id,
      course_id: route.query.course_id,
    }
  }).then((res) => {
    let response = res.data

    if (response.code === 200) {
      let question: Question[] = []

      response.data.forEach((data: Question) => {
        let fileList = null
        let userAnswerFlow = null
        let correctAnswer: string | string[] = data.correct_answer

        if (data.user_answer) {
          data.user_answer.user_id = UserInfo.value?.id as number
          if (data.type === 'proof') {
            // 格式化并解析正确答案和用户答案
            correctAnswer = formatAndParseAnswer(correctAnswer as string) // correct_answer可能是string或string[]
            let formatUserAnswer = data.user_answer.user_answer
            fileList = formatAndParseAnswer(formatUserAnswer) // 解析用户答案
          } else {
            if (data.type === 'flow') {
              let formatUserAnswer = data.user_answer.user_answer
              if (formatUserAnswer === '') {
                formatUserAnswer = '[]'
              }
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
            user_id: UserInfo.value?.id as number,
            question_id: data.id,
            is_correct: false,
            score: -1,
            user_answer: '',
            created_at: '',
          }
        }

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
    }
  })

}


const submitAnswer = () => {
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
const postExam = () => {
  let userAnswers: UserAnswer[] = []
  Questions.value.map(question => {
    let userAnswer: string = question.user_answer.user_answer;
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
    exam_id: route.query.course_id,
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

// 获取题目
// const getQuestions = async () => {
//   try {
//     let userInfo = JSON.parse(localStorage.getItem('userInfo'));
//     const response = await proxy?.$http.get('/get_questions', {
//       params: {
//         course_id: route.query.course_id,
//         user_id: userInfo.id,
//       }
//     });
//     if (response?.data) {
//       questions.value = response.data;
//       userAnswer.value = response.data.map((question: Question) => {
//         // 初始化答案，填入已存在的 user_answer 或空字符串
//         if (question.question_type === 'flow') {
//           return question.steps?.map((_, i) => question?.user_answer?.[i] || '') || [];
//         } else {
//           return question?.user_answer || '';
//         }
//       });
//     }
//   } catch (error) {
//     console.error('Error fetching questions:', error);
//   }
// };


// 提交并校准答案
// const submitAnswer = () => {
//   let user_answer:any[] = []
//   let userInfo = JSON.parse(localStorage.getItem('userInfo'));
//
//   Questions.value.forEach((question, index) => {
//     const userAns = userAnswer.value[index];
//     const correctAns = question.correct_answer;
//
//     if (question.question_type === 'choice') {
//       // 校准选择题答案
//       question.check = (userAns === correctAns);
//       correctResults.value[index] = (userAns === correctAns);
//     } else if (question.question_type === 'blank') {
//       // 校准填空题答案
//       const userBlanks = userAns.split(',').map((ans: string) => ans.trim());
//       const correctBlanks = correctAns.split(',').map((ans: string) => ans.trim());
//       question.check = (JSON.stringify(userBlanks) === JSON.stringify(correctBlanks));
//       correctResults.value[index] = (JSON.stringify(userBlanks) === JSON.stringify(correctBlanks));
//     } else if (question.question_type === 'flow') {
//       let is_correct = true;
//       for (let i = 0; i < question.steps.length; i++) {
//         if (question.steps[i].is_hidden) {
//           if(question.steps[i].step_text !== userAns[i]) {
//             is_correct = false;
//             break;
//           }
//         }
//       }
//       question.check = is_correct
//       correctResults.value[index] = is_correct;
//     } else if (question.question_type === 'proof'){
//       question.check = null
//       correctResults.value[index] = null;
//
//     }
//
//
//     user_answer.push({
//       user_id: userInfo.id,
//       question_id: question.id,
//       user_answer: userAns,
//       is_correct: question.check,
//     });
//
//   });
//   proxy?.$http.put('/answered_questions', {
//     user_answer:  JSON.stringify(user_answer),
//   }).then(res=>{
//     getQuestions()
//     // console.log(res);
//
//   })
//   // 显示结果（在控制台打印结果数组）
//   const correctCount = correctResults.value.filter(result => result).length;
//   alert(`正确答案数量：${correctCount}/${questions.value.length}`);
// };

const scoreView = () => {
  router.push({
    path: '/score',
    query: {
      class_name: route.query.class_name,
      course_id: route.query.course_id
    }
  });
}
// const updateAnswer = () => {
//   Questions.value.map(question => {
//     if (question.type === 'flow') {
//       question.user_answer = JSON.stringify(question.user_answer_flow)
//     }
//   })
//   localStorage.setItem(UserAnswerString.value, JSON.stringify(Questions.value));
// }

// 在页面加载时获取内容和题目
onMounted(() => {
  let userInfo = localStorage.getItem('userInfo')
  if (userInfo) {
    let parseUserInfo = JSON.parse(userInfo) as UserInfoInterface
    UserInfo.value = parseUserInfo;
  }
  getContent();
  getVideo();
  getQuestions();
});
</script>

<template>
  <main class="main-container">
    <div class="main-body">
      <h1>{{ courseData.chapter_title }}</h1>
      <h2>{{ courseData.section_title }}</h2>
      <div class="course-content">
        <h2 style="margin-bottom: 20px">课程重点</h2>
        <div class="markdown_content" v-html="markdownContent"></div>
        <div style="height: 20px"></div>
      </div>
      <video v-if="!videoUrl" :src="videoUrl" controls class="video">
        Your browser does not support the video tag.
      </video>
      <div style="height: 20px"></div>
    </div>

    <div class="test">
      <h2>课后练习（公式请用工具箱中的latex生成器）</h2>

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
                v-model="question.user_answer.user_answer"
                placeholder="请在此输入答案，用“,”分隔多个答案"
            />
          </div>

          <!--  证明题  -->
          <!--          <div v-else-if="question.type === 'proof'">-->
          <!--            <el-upload-->
          <!--                v-model:file-list="question.file_list"-->
          <!--                list-type="picture-card"-->
          <!--            >-->
          <!--              <el-icon>-->
          <!--                <Plus/>-->
          <!--              </el-icon>-->
          <!--              <template #file="{ file }">-->
          <!--                <div>-->
          <!--                  <img class="el-upload-list__item-thumbnail" :src="file.url" alt=""/>-->
          <!--                  <span class="el-upload-list__item-actions">-->
          <!--                    <span-->
          <!--                        class="el-upload-list__item-preview"-->
          <!--                        @click="handlePictureCardPreview(file)"-->
          <!--                    >-->
          <!--                      <el-icon><zoom-in/></el-icon>-->
          <!--                    </span>-->
          <!--                  </span>-->
          <!--                </div>-->
          <!--              </template>-->
          <!--            </el-upload>-->
          <!--            <el-dialog v-model="dialogVisible">-->
          <!--              <img class="full-image" :src="dialogImageUrl" alt="Preview Image"/>-->
          <!--            </el-dialog>-->
          <!--          </div>-->

          <!--        正确答案-->
          <div class="correct-answer"
               v-if="question.user_answer.score >=0"
          >
            <span>标准答案：</span>
            <div class=" proof-answer
          " v-if="question.type === 'proof'">
              <div v-for="(imgUrl, imgIndex) in question.correct_answer" :key="imgIndex">
                <img :src="imgUrl" alt="标准答案" style="width: 100%">
              </div>
            </div>
            <span v-else>{{ question.correct_answer }}</span>

          </div>

          <div class="score"
               v-if="question.user_answer.score >=0"
          >
            <span>得分：</span>
            <span>{{ question.user_answer.score }}/{{ question.score }}</span>
          </div>
        </div>
      </div>


      <el-button class="submit-btn" color="rgb(173, 145, 255)" @click="submitAnswer" plain>提交</el-button>
      <el-button class="submit-btn" color="rgb(173, 145, 255)" @click="scoreView">成绩概览</el-button>
    </div>
  </main>
</template>

<style scoped>
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
  margin-left: 0!important;
}

.flow-block {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.flow-item {
  width: 50%;
  background-color: antiquewhite;
  border-radius: 1rem;
  padding: 1rem;
  color: #1c1c2c;
  text-align: center;
}

.blank input {
  width: 100%;
}

.submit-btn {
  margin-top: 20px;
  width: 100%;
}

.problems {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 1rem;
  box-shadow: 0px 0px 10px 0px rgba(0, 0, 0, 0.85);
}

.question > span {
  font-weight: 600;
}

.video {
  width: 100%;
  height: 400px;
  background-color: #333;
}

.main-container {
  max-width: 1000px;
  margin: 0 auto;
}

.main-container h1 {
  text-align: center;
}

.course-content {
  padding: 20px;
}

.test {
  padding: 20px;
}

.markdown_content {
  line-height: 1.6;
  font-size: 16px;
}
</style>
