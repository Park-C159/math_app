<template>
  <div>
    <div class="problems" v-for="(question, index) in formattedQuestions" :key="index">
      <div class="question">
        <div style="margin-bottom: 0.5rem">
          <span v-if="question.question_type === 'choice'">选择题：</span>
          <span v-if="question.question_type === 'blank'">填空题：</span>
          <span v-if="question.question_type === 'proof'">证明题：</span>
          <span v-if="question.question_type === 'flow'">流程题：</span>
          <MathTextRenderer :raw-text="question.question_text" />
        </div>
        <!--        证明题-->
        <el-input
            v-if="question.question_type === 'proof'"
            type="textarea"
            placeholder="请补全流程"
            rows="4"
        ></el-input>
        <!-- 填空题 -->
        <div v-if="question.question_type === 'blank'" class="blank">
          <input
              v-model="userAnswer[index]"
              placeholder="请在此输入答案，用“,”分隔多个答案"
          />
        </div>

        <!-- 选择题 -->
        <ul v-if="question.question_type === 'choice'">
          <li v-for="(option, optionIndex) in question.options" :key="optionIndex">
            <input
                type="radio"
                :name="'mcq_' + index"
                :value="option.option_label"
                v-model="userAnswer[index]"
            />
            {{ option.option_label }}. <MathTextRenderer :raw-text="option.option_text" />

          </li>
        </ul>

        <!-- 流程题 -->
        <ul v-if="question.question_type === 'flow'">
          <li v-for="(step, stepIndex) in question.steps" :key="stepIndex" class="flow-block">
            <div class="flow-item">
              <span v-if="!step.is_hidden"><MathTextRenderer :raw-text="step.step_text" /></span>
              <el-input
                  v-else
                  type="textarea"
                  placeholder="请补全流程"
                  rows="2"
              ></el-input>
            </div>
            <div v-if="stepIndex < question.steps.length - 1" class="arrow">
              &darr;
            </div>
          </li>
        </ul>
      </div>

    </div>
  </div>
</template>

<script>
import MathTextRenderer from "@/components/MathTextRenderer.vue";

export default {
  components: {
    MathTextRenderer
  },
  props: {
    exercises: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      userAnswer: []
    };
  },
  computed: {
    formattedQuestions() {
      return this.exercises.map((exercise) => {
        let questionText = exercise.question;
        let questionType = exercise.type;
        let options = exercise.options.map((opt, index) => ({
          option_label: exercise.option_label[index],
          option_text: opt
        }));
        let steps = exercise.steps.map((step, index) => ({
          step_label: exercise.step_label[index],
          step_text: step,
          is_hidden: exercise.answer.includes(exercise.step_label[index])
        }));
        return {
          question_text: questionText,
          question_type: questionType,
          options: options,
          steps: steps,
          check: null
        };
      });
    }
  },
  methods: {
    // 可根据需要添加答案验证逻辑
    checkAnswers() {
      // 答案验证逻辑
    }
  },
  mounted() {
  }
};
</script>

<style scoped>
.arrow{
  font-size: 2rem;
  font-weight: bold;
  line-height: 2rem;
}
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
.problems {
  margin-bottom: 2rem;
}

.question {
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
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

.blank {
  margin-top: 0.5rem;
}

.blank input {
  width: 100%;
  border-bottom: 1px solid black;
}
</style>
