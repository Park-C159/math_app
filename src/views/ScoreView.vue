<template>
  <div class="container">
    <h1>课程答题情况</h1>

    <div v-if="loading" class="loading">加载中...</div>

    <div v-else>
      <!-- 课程内容 -->
      <div v-for="(question, index) in data" :key="question.question_id" class="question-container">
        <h2>题目 {{ index+1 }}</h2>
        <strong>题目:</strong><MathTextRenderer :raw-text="question.question_text" />
        <p><strong>正确答案:</strong> {{ question.correct_answer }}</p>

        <!-- 选项（如果有） -->
        <ul v-if="question.options.length > 0" class="options">
          <li v-for="option in question.options" :key="option.option_id">
            {{ option.option_label }}. {{ option.option_text }}
          </li>
        </ul>

        <!-- 答题情况 -->
        <div class="answers">
          <h3>答题情况:</h3>
          <div style="width: 100%; height: 300px; display: flex;">
            <PieChartComponent
                title="用户答题情况"
                :seriesData="question.pieStatic"
            />
            <PieChartComponent
                title="用户答案分布请"
                type="bar"
                :xData="question.answerDistribution.xData"
                :yData="question.answerDistribution.yData"
            />

          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import TestEchartComponent from "@/components/echarts/TestEchartComponent.vue";
import PieChartComponent from "@/components/echarts/PieChartComponent.vue";
import MathTextRenderer from "@/components/MathTextRenderer.vue";

export default {
  name:"ScoreView",
  data(){
    return {
      data:[],
    }
  },
  components: {
    TestEchartComponent,
    PieChartComponent,
    MathTextRenderer
  },
  methods:{
    getCourseAnswer() {
      this.$http.get("/get_course_answers", {
        params: { course_id: this.$route.query.course_id },
      }).then(res => {
        this.data = res.data;
        this.data.map(data => {
          // 初始化一个对象，用来统计各种用户答案的数量
          let answerStats = {};

          // 遍历每个答案
          for (let answer of data.answers) {
            const userAnswer = answer.user_answer; // 获取用户的答案
            if (!answerStats[userAnswer]) {
              // 如果答案还未被记录，初始化为0
              answerStats[userAnswer] = 0;
            }
            // 累加该答案的数量
            answerStats[userAnswer]++;
          }

          let userAnswerJson = Object.keys(answerStats).map(key => ({
            name: key, // 用户答案的具体值
            value: answerStats[key], // 该答案的出现次数
          }));

          // 将统计结果从对象转化为数组
          data.answerDistribution = this.processDataForBarChart(userAnswerJson);
          console.log(data.answerDistribution);

          // 如果需要饼图统计，也可以直接使用上面的结构
          let correctCount = userAnswerJson.find(d => d.name === "正确")?.value || 0;
          let incorrectCount = data.answers.length - correctCount;

          data.pieStatic = [
            { name: "正确", value: correctCount },
            { name: "错误", value: incorrectCount },
          ];
        });
      });
    },
    processDataForBarChart(data) {
      const xData = data.map(item => item.name);
      const yData = data.map(item => item.value);
      return { xData: xData, yData: yData };
    },

  },
  mounted() {
    this.getCourseAnswer();
  }
};
</script>

<style scoped>
.container {
  background-color: white;
  color: black;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.loading {
  text-align: center;
  font-size: 1.5rem;
  color: #333;
}

.question-container {
  margin-bottom: 20px;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 8px;
  background: #f9f9f9;
}

.options {
  margin: 10px 0;
  padding-left: 20px;
}

.answers table {
  width: 100%;
  border-collapse: collapse;
}

.answers th,
.answers td {
  border: 1px solid #ccc;
  padding: 8px;
  text-align: center;
}

.answers th {
  background: #f0f0f0;
}

.correct {
  color: green;
  font-weight: bold;
}

.incorrect {
  color: red;
  font-weight: bold;
}
</style>
