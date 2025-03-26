<script setup lang="ts">
import {getCurrentInstance, onMounted, ref} from "vue";
import {useRoute} from "vue-router";
import MathTextRenderer from "@/components/MathTextRenderer.vue";
import ChoicechartComponent from "@/components/echarts/ChoicechartComponent.vue";
import FenbuchartComponent from "@/components/echarts/FenbuchartComponet.vue";
import XiangxianComponent from "@/components/echarts/XiangxianComponent.vue";

const route = useRoute();
const instance = getCurrentInstance();
const proxy = instance?.proxy;

interface QuestionScore {
  question_id: number;
  question_text: string;
  user_score: number;
  question_type: string;
  user_answer_value: string;
}

interface QuestionScoreSummary {
  question_id: number;
  question_text: string;
  question_type: string;
  user_scores: number[];
  user_answers: string[];
}

interface QuestionStatistics {
  average_score: number;
  coefficient_of_variation: number;
  iqr: number;
  kurtosis: number;
  median_score: number;
  mode_score: number;
  q1: number;
  q3: number;
  question_id: number;
  question_text: string;
  range: number;
  skewness: number;
  standard_deviation: number;
  variance: number;
}

interface TotalScoreStatistics {
  average_total_score: number;
  coefficient_of_variation: number;
  iqr_total_score: number;
  kurtosis_total_score: number;
  median_total_score: number;
  mode_total_score: number;
  q1_total_score: number;
  q3_total_score: number;
  range_total_score: number;
  skewness_total_score: number;
  standard_deviation_total_score: number;
  variance_total_score: number;
}

interface UserScore {
  question_score: QuestionScore[];
  total_score: number;
  user_id: string;
  user_name: string;
}

interface Student {
  id: number;
  username: string;
  user_id: string;
  phone_number: string;
  gender: number;
  role: string;
  extra: string;
}

interface AIReport {
  user_name: string;
  exam_name: string;
  course_name: string;
  total_score: number;
  max_score: number;
  score_percentage: number;
  analysis_report: string;
}

const userScore = ref<UserScore[]>([]);
const examId = ref<number>(0);
const courseId = ref<number>(0);
const exams = ref<any[]>([]);
const examName = ref<string>("");
const questionStatistics = ref<QuestionStatistics[]>([]);
const totalScoreStatistics = ref<TotalScoreStatistics | null>(null);
const questionScoreSummary = ref<QuestionScoreSummary[]>([]);
const totalScores = ref<number[]>([]);
const selectedStudent = ref<UserScore | null>(null);
const aiReport = ref<AIReport | null>(null);
const isGeneratingReport = ref<boolean>(false);
const showReportModal = ref<boolean>(false);
const students = ref<Student[]>([]);
const loadingStudents = ref<boolean>(false);

const getExamMark = () => {
  proxy?.$http.get("download_users_mark", {
    params: {
      exam_id: examId.value
    }
  }).then((res: any) => {
    let response = res.data;
    if (response.code === 200) {
      userScore.value = response.data.user_scores;
      questionStatistics.value = response.data.question_statistics;
      totalScoreStatistics.value = response.data.total_statistics;

      // 处理 questionScoresSummary
      const questionMap = new Map<number, {
        question_id: number;
        question_text: string;
        question_type: string;
        user_scores: number[];
        user_answers: string[];
      }>();
      userScore.value.forEach((user) => {
        user.question_score.forEach((score) => {
          if (!questionMap.has(score.question_id)) {
            questionMap.set(score.question_id, {
              question_id: score.question_id,
              question_text: score.question_text,
              question_type: score.question_type,
              user_scores: [],
              user_answers: []
            });
          }

          questionMap.get(score.question_id)?.user_scores.push(score.user_score);
          questionMap.get(score.question_id)?.user_answers.push(score.user_answer_value);
        });
        totalScores.value.push(user.total_score)
      });
      // 将 Map 转换为数组
      questionScoreSummary.value = Array.from(questionMap.values());
    }
  });
};

// 获取所有考试
const getExams = async () => {
  courseId.value = Number(route.query.courseId);
  if (!courseId.value) return;

  try {
    const res = await proxy?.$http.get("exams_list", {
      params: {
        course_id: courseId.value
      }
    });

    if (res?.data?.code === 200 && res.data.data.length > 0) {
      exams.value = res.data.data;
      // 默认选择最新的考试
      examId.value = exams.value[0].id;
      examName.value = exams.value[0].name;

      // 获取考试的学生列表
      getStudentList();
      // 获取考试的成绩分析
      getExamMark();
    }
  } catch (error) {
    console.error("获取考试列表失败:", error);
  }
};

// 获取课程的学生列表
const getStudentList = async () => {
  loadingStudents.value = true;
  try {
    const res = await proxy?.$http.get("course_user_list", {
      params: {
        course_id: courseId.value
      }
    });

    if (res?.data?.code === 200) {
      students.value = res.data.data;
    }
  } catch (error) {
    console.error("获取学生列表失败:", error);
  } finally {
    loadingStudents.value = false;
  }
};

// 选择考试
const selectExam = (exam: any) => {
  examId.value = exam.id;
  examName.value = exam.name;
  getExamMark();
};

onMounted(async () => {
  await getExams();
});

// 将数据转换为CSV格式
const convertToCSV = (data: UserScore[]): string => {
  const headers = ['用户名', '学号', ...data[0]?.question_score.map(q => q.question_text), '总分'];
  const rows = data.map(user => {
    const scores = user.question_score.map(q => q.user_score);
    return [
      user.user_name,
      user.user_id,
      ...scores,
      user.total_score
    ].join(',');
  });

  return [headers.join(','), ...rows].join('\n');
};

// 下载CSV文件
const downloadCSV = () => {
  const csvContent = convertToCSV(userScore.value);
  const blob = new Blob([csvContent], {type: 'text/csv;charset=utf-8;'});
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${examName.value}_成绩.csv`;
  link.click();
};

// 生成AI分析报告
const generateAIReport = (student: Student) => {
  selectedStudent.value = {
    user_id: student.id.toString(),
    user_name: student.username,
    question_score: [],
    total_score: 0
  };
  isGeneratingReport.value = true;
  showReportModal.value = true;

  proxy?.$http.get("generate_score_analysis", {
    params: {
      user_id: student.id,
      exam_id: examId.value
    }
  }).then((res: any) => {
    let response = res.data;
    if (response.code === 200) {
      aiReport.value = response.data;
    } else {
      // 处理错误
      proxy?.$message.error(response.message || "生成报告失败");
    }
    isGeneratingReport.value = false;
  }).catch((error: any) => {
    proxy?.$message.error("生成报告请求失败: " + error.message);
    isGeneratingReport.value = false;
  });
};

// 关闭报告模态框
const closeReportModal = () => {
  showReportModal.value = false;
  aiReport.value = null;
  selectedStudent.value = null;
};

// 导出AI报告为PDF
// 渲染Markdown为HTML
const renderMarkdown = (text: string) => {
  if (!text) return '';

  // 简单的Markdown渲染
  return text
    // 处理标题
    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
    .replace(/^### (.*$)/gm, '<h3>$1</h3>')
    .replace(/^#### (.*$)/gm, '<h4>$1</h4>')
    .replace(/^##### (.*$)/gm, '<h5>$1</h5>')

    // 处理粗体和斜体
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')

    // 处理列表
    .replace(/^\s*\*(.*)/gm, '<li>$1</li>')
    .replace(/^\s*\d+\.(.*)/gm, '<li>$1</li>')

    // 处理换行
    .replace(/\n/g, '<br />');
};

const exportReportAsPDF = () => {
  if (!aiReport.value) return;

  // 这里可以使用如html2pdf等库将报告导出为PDF
  // 为简化实现，此处仅创建一个文本文件下载
  const reportText = `
学生成绩分析报告
学生: ${aiReport.value.user_name}
考试: ${aiReport.value.exam_name}
课程: ${aiReport.value.course_name}
分数: ${aiReport.value.total_score}/${aiReport.value.max_score} (${aiReport.value.score_percentage.toFixed(2)}%)

${aiReport.value.analysis_report}
  `;

  const blob = new Blob([reportText], {type: 'text/plain;charset=utf-8;'});
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${aiReport.value.user_name}_${examName.value}_成绩分析报告.txt`;
  link.click();
};
</script>

<template>
  <div class="table">
    <!-- 考试选择 -->
    <div class="exam-selector">
      <h2>考试列表</h2>
      <div class="exam-buttons">
        <button
          v-for="exam in exams"
          :key="exam.id"
          :class="['exam-btn', examId === exam.id ? 'active' : '']"
          @click="selectExam(exam)">
          {{ exam.name }}
        </button>
      </div>
    </div>

    <!-- 添加学生列表和生成报告按钮 -->
    <div class="students-section">
      <h2>学生列表</h2>
      <div v-if="loadingStudents" class="loading-students">
        正在加载学生列表...
      </div>
      <div v-else-if="students.length === 0" class="no-students">
        暂无学生数据
      </div>
      <div v-else class="student-table">
        <table>
          <thead>
            <tr>
              <th>姓名</th>
              <th>学号</th>
              <th>性别</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="student in students" :key="student.id">
              <td>{{ student.username }}</td>
              <td>{{ student.user_id }}</td>
              <td>{{ student.gender === 1 ? '男' : '女' }}</td>
              <td>
                <button class="report-btn" @click="generateAIReport(student)">生成AI分析报告</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <h2 style="margin: 20px">总分：</h2>
    <div class="total">
      <div v-if="totalScores.length>0" class="total-fenbu">
        <FenbuchartComponent
            title="成绩分布散点图"
            type="scatter-line"
            :seriesData="totalScores"
        />
      </div>
      <div class="export-container">
        <button class="export-btn" @click="downloadCSV">导出成绩CSV</button>
      </div>
    </div>


    <h2 style="margin: 20px">客观题：</h2>
    <table v-if="(userScore[0]?.question_score || []).filter(q => q.question_type === 'choice').length > 0">
      <thead>
      <tr>
        <th v-for="question in (userScore[0]?.question_score || []).filter(q => q.question_type === 'choice')"
            :key="question.question_id">
          <MathTextRenderer :raw-text="question.question_text"/>
        </th>

      </tr>
      </thead>
      <tbody>
      <tr>
        <td v-for="answer in (questionScoreSummary || []).filter(s => s.question_type==='choice')"
            style="height: 200px;">
          <ChoicechartComponent
              :seriesData="answer.user_answers"
          />
        </td>
      </tr>
      </tbody>
    </table>
    <div v-else class="no-data">暂无客观题数据</div>

    <h2 style="margin: 20px">主观题：</h2>

    <div v-if="questionScoreSummary.length>0 && (questionScoreSummary || []).filter(s => s.question_type!=='choice').length > 0" class="total-fenbu">
      <XiangxianComponent
          title="主观题分布情况"
          :seriesData="questionScoreSummary"
      />
    </div>
    <div v-else class="no-data">暂无主观题数据</div>

    <div v-for="qs in (questionScoreSummary || []).filter(s => s.question_type!=='choice')" :key="qs.question_id">
      <MathTextRenderer :raw-text="qs.question_text"/>
      <div class="total-fenbu">
        <FenbuchartComponent
            title="成绩分布散点图"
            type="scatter"
            :seriesData="qs.user_scores"
        />
      </div>
    </div>

    <!-- AI报告模态框 -->
    <div v-if="showReportModal" class="report-modal">
      <div class="report-modal-content">
        <div class="report-modal-header">
          <h3>学生成绩分析报告</h3>
          <button class="close-btn" @click="closeReportModal">×</button>
        </div>
        <div class="report-modal-body">
          <div v-if="isGeneratingReport" class="loading">
            <p>正在生成报告，请稍候...</p>
          </div>
          <div v-else-if="aiReport" class="report-container">
            <div class="report-header">
              <h4>{{ aiReport.user_name }} - {{ aiReport.exam_name }}</h4>
              <p>课程: {{ aiReport.course_name }}</p>
              <p>分数: {{ aiReport.total_score }}/{{ aiReport.max_score }} ({{ aiReport.score_percentage.toFixed(2) }}%)</p>
            </div>
            <div class="report-content markdown-content" v-html="renderMarkdown(aiReport.analysis_report)"></div>
            <div class="report-actions">
              <button class="export-report-btn" @click="exportReportAsPDF">导出报告</button>
            </div>
          </div>
          <div v-else class="error-message">
            <p>无法生成报告，请重试。</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.total{
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.total-fenbu{
  width: 100%;
  height: 50vh;
}
.fenbu{
  width: 45%;
  height: 50vh;
}
.btn {
  float: right;
  margin: 1rem;
}

.table {
  padding: 1rem;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 8px;
  text-align: center;
  border: 1px solid #ddd;
}

th {
  font-weight: bold;
}

/* 考试选择器样式 */
.exam-selector {
  margin-bottom: 20px;
}

.exam-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.exam-btn {
  padding: 8px 15px;
  background-color: #f0f0f0;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.exam-btn:hover {
  background-color: #e0e0e0;
}

.exam-btn.active {
  background-color: #1890ff;
  color: white;
  border-color: #1890ff;
}

/* 学生列表样式 */
.students-section {
  margin-bottom: 20px;
}

.student-table {
  margin-bottom: 20px;
  max-height: 300px;
  overflow-y: auto;
}

.loading-students, .no-students, .no-data {
  padding: 20px;
  text-align: center;
  color: #999;
  border: 1px solid #eee;
  border-radius: 4px;
  margin-bottom: 20px;
}

.report-btn {
  background-color: #1890ff;
  color: white;
  border: none;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
}

.report-btn:hover {
  background-color: #40a9ff;
}

.export-btn {
  background-color: #52c41a;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 4px;
  cursor: pointer;
}

.export-container {
  margin-left: 20px;
}

/* 模态框样式 */
.report-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.report-modal-content {
  background-color: white;
  color: #333;
  width: 80%;
  max-width: 800px;
  max-height: 90vh;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
}

.report-modal-header {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #f8f8f8;
  color: #333;
}

.report-modal-body {
  padding: 20px;
  overflow-y: auto;
  flex-grow: 1;
  background-color: white;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #999;
}

.report-container {
  display: flex;
  flex-direction: column;
}

.report-header {
  margin-bottom: 20px;
  color: #333;
}

.report-content {
  margin-bottom: 20px;
  line-height: 1.6;
  color: #333;
}

/* Markdown 样式 */
.markdown-content h1,
.markdown-content h2,
.markdown-content h3,
.markdown-content h4,
.markdown-content h5 {
  color: #333;
  margin-top: 16px;
  margin-bottom: 8px;
}

.markdown-content h1 {
  font-size: 24px;
  border-bottom: 1px solid #eee;
  padding-bottom: 8px;
}

.markdown-content h2 {
  font-size: 20px;
  border-bottom: 1px solid #eee;
  padding-bottom: 6px;
}

.markdown-content h3 {
  font-size: 18px;
}

.markdown-content h4 {
  font-size: 16px;
}

.markdown-content h5 {
  font-size: 14px;
}

.markdown-content li {
  margin-left: 24px;
  list-style-type: disc;
  margin-bottom: 4px;
}

.markdown-content strong {
  font-weight: bold;
}

.markdown-content em {
  font-style: italic;
}

.report-actions {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.export-report-btn {
  background-color: #722ed1;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 4px;
  cursor: pointer;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
}

.error-message {
  color: #f5222d;
  text-align: center;
}
</style>