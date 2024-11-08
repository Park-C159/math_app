<template>
  <div class="editor-container">
    <div class="tools">
      <el-icon @click="addFormula"><SetUp /></el-icon>
<!--      <el-dialog v-model="isFormula">-->
<!--        <FormulaEditor @addFormula="insertFormula" />-->
<!--      </el-dialog>-->
      <el-dialog v-model="isFormula">
        <FormulaEditor @addFormula="insertFormula" />
      </el-dialog>

    </div>
    <el-form ref="exerciseForm" :model="exerciseForm" label-width="80px">
      <!-- 选择题类型 -->
      <el-form-item label="题目类型">
        <el-select v-model="exerciseForm.type" placeholder="请选择题目类型">
          <el-option label="选择题" value="choice"></el-option>
          <el-option label="填空题" value="blank"></el-option>
          <el-option label="证明题" value="proof"></el-option>
          <el-option label="流程题" value="flow"></el-option>
        </el-select>
      </el-form-item>

      <!-- 输入题干 -->
      <el-form-item label="题干">
        <el-input
            type="textarea"
            v-model="exerciseForm.question"
            placeholder="请输入题干"
            rows="4"
            ref="question"
            @focus="currentInput = 'question'"
        ></el-input>
      </el-form-item>

      <!-- 根据题目类型动态渲染不同的答案输入 -->
      <template v-if="exerciseForm.type === 'choice'">
        <!-- 选择题答案输入 -->
        <el-form-item label="选项">
          <el-input
              v-for="(option, index) in exerciseForm.options"
              :key="index"
              v-model="exerciseForm.options[index]"
              placeholder="请输入选项"
              class="option-input"
              :ref="'options'+index"
              @focus="currentInput = 'options' + index"
          >
          </el-input>
          <el-button type="primary" @click="addOption">添加选项</el-button>
          <el-button type="warning" @click="deleteOption">删除选项</el-button>
        </el-form-item>

        <el-form-item label="正确答案">
          <el-select v-model="exerciseForm.answer" placeholder="请选择正确答案">
            <el-option
                v-for="(option, index) in exerciseForm.option_label"
                :key="index"
                :label="option"
                :value="option"
            ></el-option>
          </el-select>
        </el-form-item>
      </template>

      <template v-else-if="exerciseForm.type === 'blank'">
        <!-- 填空题答案输入 -->
        <el-form-item label="答案">
          <el-input
              type="text"
              ref="answer"
              @focus="currentInput = 'answer'"
              v-model="exerciseForm.answer"
              placeholder="请输入填空题答案"
          ></el-input>
        </el-form-item>
      </template>


      <!-- 流程题答案输入 -->
      <template v-else-if="exerciseForm.type === 'flow'">
        <el-form-item label="流程步骤">
          <el-input
              v-for="(step, index) in exerciseForm.steps"
              :key="index"
              v-model="exerciseForm.steps[index]"
              placeholder="请输入流程步骤"
              :ref="'steps'+index"
              @focus="currentInput = 'steps'+ index"
              class="step-input"
          ></el-input>
          <el-button type="primary" @click="addStep">添加步骤</el-button>
          <el-button type="warning" @click="deleteStep">删除步骤</el-button>
        </el-form-item>
        <el-form-item label="填空流程">
          <el-select
              v-model="exerciseForm.answer"
              multiple
              placeholder="请选择空出的流程"
          >
            <el-option
                v-for="(option, index) in exerciseForm.step_label"
                :key="index"
                :label="option"
                :value="option"
            ></el-option>
          </el-select>
        </el-form-item>
      </template>


      <!-- 提交和预览按钮 -->
      <el-form-item>
        <el-button type="primary" @click="confirmQuestion">确认</el-button>

<!--        <el-button type="primary" @click="submitForm">提交</el-button>-->
<!--        <el-button type="success" @click="previewForm">预览</el-button>-->
        <el-button @click="resetForm">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 预览模态框 -->
    <el-dialog
        title="习题预览"
        v-model="previewVisible"
        width="50vw"
        align-center

        @close="resetPreview"
    >
      <el-dialog
          v-model="innerVisible"
          width="500"
          title="请选择题目位置"
          append-to-body
      >

        <el-cascader
            v-model="value"
            :options="options"
            :props="cascaderProps"
            @change="handleChange"
        />
        <span slot="footer" class="dialog-footer">
          <el-button type="primary" @click="uploadQuestion">上传</el-button>

        </span>
      </el-dialog>
      <QuestionPre :exercises="exercises"/>
      <span slot="footer" class="dialog-footer">
        <el-button @click="previewVisible = false">关闭</el-button>
        <el-button type="primary" @click="confirmQuestion">
          确认
        </el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import QuestionPre from "@/components/operating/QustionPre.vue";
import FormulaEditor  from "@/components/toolbox/FormulaEditor.vue";

export default {
  data() {
    return {
      currentInput: 'expr1',
      isFormula: false,
      value: "0",
      options: [
        {
          id: "0",
          label: "随堂练习",
        },
      ],
      innerVisible: false,
      exercises: [],
      exerciseForm: {
        type: 'choice', // 题目类型
        question: '', // 题干
        option_label: ['A'],
        options: [''], // 选择题选项
        answer: '', // 答案
        steps: [''], // 流程题步骤
        step_label: [1]
      },
      previewVisible: false, // 控制预览模态框的显示
      formatExercise: [],
      cascaderProps:{
        value: 'id',
      },
      previousInputRef: null, // 用于记录之前的输入框引用
    };
  },
  components: {
    FormulaEditor,
    QuestionPre
  },
  computed: {},
  mounted() {
    this.getCourse()
  },
  methods: {
    focusInput() {
      // 恢复光标到当前输入框
      const inputRef = this.$refs[this.currentInput];
      if (inputRef) {
        const textArea = inputRef.$refs.input; // 获取实际的输入框
        if (textArea) {
          textArea.focus(); // 重新聚焦到输入框
        }
      }
    },
    insertSymbol(symbol) {
      // 获取当前输入框的引用
      const inputRef = this.$refs[this.currentInput]?.$refs?.input || this.$refs[this.currentInput]?.$refs?.textarea;
      var value;
      console.log(this.currentInput)

      if (inputRef) {
        if (this.currentInput.includes("options") || this.currentInput.includes("steps")) {
        } else{
          value = this.exerciseForm[this.currentInput]; // 使用正确的模型引用
        }
        // 获取输入框的值
        console.log(value)
        // 在文本末尾插入符号
        this.exerciseForm[this.currentInput] = value + symbol;

        // 更新光标位置
        this.$nextTick(() => {
          // 将光标设置到文本末尾
          inputRef.setSelectionRange(this.exerciseForm[this.currentInput].length, this.exerciseForm[this.currentInput].length);
          inputRef.focus();
        });
      } else {
        if (this.currentInput.includes("options") || this.currentInput.includes("steps")) {
          const regex = /([a-zA-Z]+)(\d+)/; // 匹配字母和数字
          const match = this.currentInput.match(regex); // 使用正则表达式进行匹配
          let text = match[1];
          let index = match[2];
          this.exerciseForm[text][index] = this.exerciseForm[text][index] + symbol;
        }
        console.error('当前输入框引用不存在');
      }
    },
    insertFormula(data){
      this.insertSymbol("$"+data+"$");
      this.isFormula = false
    },
    addFormula(){
      this.isFormula = true;
      console.log(this.isFormula)
    },
    uploadQuestion() {
      // 获取选中的课程ID
      let course_id = this.value[this.value.length - 1];

      // 将题目数据转换为JSON字符串
      let formData = JSON.stringify(this.formatExercise);

      // 发送PUT请求
      this.$http.put("/question", {
        course_id: course_id, // 作为请求体中的参数
        format_data: formData    // JSON格式化后的题目数据
      }).then(response => {
        console.log('上传成功:', response);
        this.$message.success('题目上传成功！');
      }).catch(error => {
        console.error('上传失败:', error);
        this.$message.error('题目上传失败！');
      });
    },
    getCourse() {
      let courseName = '数理逻辑'
      this.$http.get('/course', {
        params: {
          courseName: courseName,
        }
      }).then(res => {
        this.options.push({
          value: "数理逻辑",
          label: "数理逻辑",
          children: res.data,
          leaf: false
        })
      })
    },
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
          check: exercise.answer
        };
      });
    },
    // 确认命题
    confirmQuestion() {
      let options = this.exerciseForm.options.map((opt, index) => ({
        option_label: this.exerciseForm.option_label[index],
        option_text: opt
      }));
      let steps = this.exerciseForm.steps.map((step, index) => ({
        step_label: this.exerciseForm.step_label[index],
        step_text: step,
        is_hidden: this.exerciseForm.answer.includes(this.exerciseForm.step_label[index])
      }));
      this.formatExercise = {
        question_text: this.exerciseForm.question,
        question_type: this.exerciseForm.type,
        options: options,
        steps: steps,
      }
      // this.formatExercise = this.formattedQuestions()
      console.log(this.formatExercise)
      this.$emit('addData', this.formatExercise);
      // this.innerVisible = true
    },
    // 添加选项
    addOption() {
      this.exerciseForm.options.push('');
      let labelIndex = this.exerciseForm.options.length;
      this.exerciseForm.option_label.push(String.fromCharCode('A'.charCodeAt(0) + labelIndex - 1));
    },
    deleteOption() {
      this.exerciseForm.options.splice(this.exerciseForm.options.indexOf(this.exerciseForm.options), 1);
      this.exerciseForm.option_label.splice(this.exerciseForm.options.length, 1);
    },
    // 添加流程步骤
    addStep() {
      this.exerciseForm.steps.push('');
      let labelIndex = this.exerciseForm.steps.length;
      this.exerciseForm.step_label.push(labelIndex)

    },
    deleteStep() {
      if (this.exerciseForm.steps.length > 0) {
        this.exerciseForm.steps.pop();
        this.exerciseForm.step_label.pop();
      }
    },
    // 提交表单
    submitForm() {
      this.exercises.push(this.exerciseForm);
      this.$message.success('提交成功！');
      this.resetForm();
    },
    // 重置表单
    resetForm() {
      this.exerciseForm = {
        type: '', // 题目类型
        question: '', // 题干
        option_label: ['A'],
        options: [''], // 选择题选项
        answer: '', // 答案
        steps: [''], // 流程题步骤
        step_label: [1]
      };
    },
    // 预览表单
    previewForm() {
      if (!this.exercises || this.exercises.length === 0) {
        this.$message.warning('请先输入题干和选择题目类型');
        return;
      }
      this.previewVisible = true;
    },
    // 重置预览
    resetPreview() {
      this.previewVisible = false;
    }
  }
};
</script>

<style scoped>
.editor-container {
  width: 100%;
  margin: 20px auto;
}

.option-input,
.step-input {
  margin-bottom: 10px;
}

.el-form-item {
  margin-bottom: 20px;
}
</style>
