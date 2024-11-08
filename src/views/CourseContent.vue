<script setup lang="ts">
import {useRoute, useRouter} from 'vue-router';  // 获取路由参数
import {ref, onMounted, getCurrentInstance} from 'vue';   // Vue的响应式和生命周期
import axios from 'axios';  // 用于HTTP请求
import {marked} from 'marked';
import MathTextRenderer from "@/components/MathTextRenderer.vue";  // 用于解析Markdown内容

interface Option {
  option_id: number;
  option_label: string;
  option_text: string;
}

interface Step {
  step_id: number;
  step_text: string;
  is_hidden: boolean;
}

interface Question {
  question_type: 'choice' | 'blank' | 'flow' | 'proof';
  question_text: string;
  correct_answer: string;
  options?: Option[];  // 仅选择题有 options
  steps?: Step[];      // 仅流程题有 steps
  check?: boolean | null;
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
const videoUrl = ref<string>('');

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
const questions = ref<any[]>([]);
const userAnswer = ref<any[]>([]);
const correctResults = ref<Array<boolean | null>>([]); // 存储每道题的正确/错误状态

// 获取题目
// 获取题目
const getQuestions = async () => {
  try {
    let userInfo = JSON.parse(localStorage.getItem('userInfo'));
    const response = await proxy?.$http.get('/get_questions', {
      params: {
        course_id: route.query.course_id,
        user_id: userInfo.id,
      }
    });
    if (response?.data) {
      questions.value = response.data;
      userAnswer.value = response.data.map((question: Question) => {
        // 初始化答案，填入已存在的 user_answer 或空字符串
        if (question.question_type === 'flow') {
          return question.steps?.map((_, i) => question?.user_answer?.[i] || '') || [];
        } else {
          return question?.user_answer || '';
        }
      });
    }
  } catch (error) {
    console.error('Error fetching questions:', error);
  }
};


// 提交并校准答案
const submitAnswer = () => {
  let user_answer:any[] = []
  let userInfo = JSON.parse(localStorage.getItem('userInfo'));

  questions.value.forEach((question, index) => {
    const userAns = userAnswer.value[index];
    const correctAns = question.correct_answer;

    if (question.question_type === 'choice') {
      // 校准选择题答案
      question.check = (userAns === correctAns);
      correctResults.value[index] = (userAns === correctAns);
    } else if (question.question_type === 'blank') {
      // 校准填空题答案
      const userBlanks = userAns.split(',').map((ans: string) => ans.trim());
      const correctBlanks = correctAns.split(',').map((ans: string) => ans.trim());
      question.check = (JSON.stringify(userBlanks) === JSON.stringify(correctBlanks));
      correctResults.value[index] = (JSON.stringify(userBlanks) === JSON.stringify(correctBlanks));
    } else if (question.question_type === 'flow') {
      let is_correct = true;
      for (let i = 0; i < question.steps.length; i++) {
        if (question.steps[i].is_hidden) {
          if(question.steps[i].step_text !== userAns[i]) {
            is_correct = false;
            break;
          }
        }
      }
      question.check = is_correct
      correctResults.value[index] = is_correct;
    } else if (question.question_type === 'proof'){
      question.check = null
      correctResults.value[index] = null;

    }


    user_answer.push({
      user_id: userInfo.id,
      question_id: question.id,
      user_answer: userAns,
      is_correct: question.check,
    });

  });
  proxy?.$http.put('/answered_questions', {
    user_answer:  JSON.stringify(user_answer),
  }).then(res=>{
    getQuestions()
    // console.log(res);

  })
  // 显示结果（在控制台打印结果数组）
  const correctCount = correctResults.value.filter(result => result).length;
  alert(`正确答案数量：${correctCount}/${questions.value.length}`);
};

const scoreView = ()=>{
  router.push({
    path: '/score',
    query: {
      class_name: route.query.class_name,
      course_id: route.query.course_id
    }
  });
}

// 在页面加载时获取内容和题目
onMounted(() => {
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

      <div class="problems" v-for="(question, index) in questions" :key="index">
        <div class="question">
          <div style="margin-bottom: 0.5rem">
            <span v-if="question.question_type === 'choice'">选择题：</span>
            <span v-if="question.question_type === 'blank'">填空题：</span>
            <span v-if="question.question_type === 'proof'">证明题：</span>
            <span v-if="question.question_type === 'flow'">流程题：</span>
            <MathTextRenderer :raw-text="question.question_text" />
          </div>
<!--         填空题 -->
          <div v-if="question.question_type === 'blank'" class="blank">
            <input :disabled="question.answered" v-model="userAnswer[index]" placeholder="请在此输入答案，用“,”分隔多个答案"/>
          </div>
<!--          选择题-->
          <ul v-if="question.question_type === 'choice'">
            <li v-for="option in question.options" :key="option.option_id">
              <input :disabled="question.answered" type="radio" :name="'mcq_' + index" :value="option.option_label" v-model="userAnswer[index]" />
              {{ option.option_label }}. <MathTextRenderer :raw-text="option.option_text" />
            </li>
          </ul>

          <ul v-if="question.question_type === 'flow'">
            <li v-for="(step, i) in question.steps" :key="step.step_id" class="flow-block">
              <div class="flow-item">
                <span v-if="!step.is_hidden"><MathTextRenderer :raw-text="step.step_text" /></span>
                <el-input
                    :disabled="question.answered"
                    v-else
                    type="textarea"
                    placeholder="请补全流程"
                    v-model="userAnswer[index][i]"
                    rows="2"
                ></el-input>
              </div>
              <div v-if="i < question.steps.length - 1" class="arrow">
                &darr;
              </div>
            </li>
          </ul>
        </div>
        <div style="text-align: right;" v-if="question.answered && question.is_correct">
          <el-icon style="color: green; font-size: 2rem">
            <Check/>
          </el-icon>
          正确
        </div>
        <div style="text-align: right" v-else-if="!question.answered"></div>
        <div style="text-align: right" v-else>
          <el-icon style="color: red; font-size: 2rem">
            <Close/>
          </el-icon>
          错误
        </div>

        <div v-if="question.answered">
          正确答案：{{ question.correct_answer }}
        </div>

      </div>
      <el-button class="submit-btn" color="rgb(173, 145, 255)" @click="submitAnswer" plain>提交</el-button>
      <el-button class="submit-btn" color="rgb(173, 145, 255)" @click="scoreView">成绩概览</el-button>
    </div>
  </main>
</template>

<style scoped>

.flow-block{
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.flow-item{
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

.question>span {
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
