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

const userScore = ref<UserScore[]>([]);
const examId = ref<number>(0)
const questionStatistics = ref<QuestionStatistics[]>([])
const totalScoreStatistics = ref<TotalScoreStatistics | null>(null)
const questionScoreSummary = ref<QuestionScoreSummary[]>([])
const totalScores = ref<number[]>([])

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
      console.log(questionScoreSummary.value);
    }
  });
};

const getExamID = async () => {
  await proxy?.$http.get("get_exam_id", {
    params: {
      course_id: route.query.courseId
    }
  }).then((res: any) => {
    let response = res.data;
    if (response.code === 200) {
      examId.value = response.data.exam_id;
    }
  });
};

onMounted(async () => {
  await getExamID()
  getExamMark();
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
  link.download = 'user_scores.csv';
  link.click();
};
</script>

<template>
  <div class="table">
    <h2 style="margin: 20px">总分：</h2>
    <div class="total">
      <div v-if="totalScores.length>0" class="total-fenbu">
        <FenbuchartComponent
            title="成绩分布散点图"
            type="scatter-line"
            :seriesData="totalScores"
        />
      </div>

    </div>


    <h2 style="margin: 20px">客观题：</h2>
    <table>
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
    <h2 style="margin: 20px">主观题：</h2>

    <div v-if="questionScoreSummary.length>0" class="total-fenbu">
      <XiangxianComponent
          title="主观题分布情况"
          :seriesData="questionScoreSummary"
      />

    </div>

    <div v-for="qs in (questionScoreSummary || []).filter(s => s.question_type!=='choice')">
      <MathTextRenderer :raw-text="qs.question_text"/>
      <div class="total-fenbu">
        <FenbuchartComponent
            title="成绩分布散点图"
            type="scatter"
            :seriesData="qs.user_scores"
        />
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
</style>
