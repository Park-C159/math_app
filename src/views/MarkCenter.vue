<script setup lang="ts">
import { getCurrentInstance, onMounted, ref } from "vue";
import { useRoute } from "vue-router";

const route = useRoute();
const instance = getCurrentInstance();
const proxy = instance?.proxy;

interface QuestionScore {
  question_id: number;
  question_text: string;
  user_score: number;
}

interface UserScore {
  question_score: QuestionScore[];
  total_score: number;
  user_id: string;
  user_name: string;
}

const userScore = ref<UserScore[]>([]);

const getExamMark = () => {
  proxy?.$http.get("download_users_mark", {
    params: {
      exam_id: route.query.exam_id
    }
  }).then((res:any) => {
    let response = res.data;
    if (response.code === 200) {
      userScore.value = response.data;
    }
  });
};

onMounted(() => {
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
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = 'user_scores.csv';
  link.click();
};
</script>

<template>
  <el-button class="btn" @click="downloadCSV">下载CSV</el-button>
  <div class="table">
    <table>
      <thead>
      <tr>
        <th>用户名</th>
        <th>学号</th>
        <th v-for="question in userScore[0]?.question_score" :key="question.question_id">
          {{ question.question_text }}
        </th>
        <th>总分</th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="(user, index) in userScore" :key="index">
        <td>{{ user.user_name }}</td>
        <td>{{ user.user_id }}</td>
        <td v-for="(question, i) in user.question_score" :key="i">
          {{ question.user_score }}
        </td>
        <td>{{ user.total_score }}</td>
      </tr>
      </tbody>
    </table>

  </div>
</template>

<style scoped>
.btn{
  float: right;
  margin:1rem;
}
.table{
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
