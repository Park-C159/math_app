<template>
  <div class="common-layout">
    <table></table>
    <div ref="pdfContent" class="pdf-content">
      <div class="info" :v-model="pageInfo">
        <h1 style="text-align: center; font-size: 32px">{{ pageInfo.title }}</h1>
        <!--        <div class="userInfo">-->
        <!--          <div>考生姓名: ______________</div>-->
        <!--          <div>学号: ______________</div>-->
        <!--          <div>考场: ______________</div>-->
        <!--        </div>-->
        <p style="font-size: 12px">说明: 请仔细阅读每道题目，确保答题完整。</p>
        <p style="font-size: 12px; margin-bottom: 1rem">注意事项: 请在答题纸上写下答案，不要在试卷上作答。</p>
      </div>
      <div class="problems" v-if="questions.length !== 0" v-for="(question, index) in questions" :key="index">
        <div class="question">
          <div style="margin-bottom: 0.5rem">
            <span v-if="question.question_type === 'choice'">选择题：</span>
            <span v-if="question.question_type === 'blank'">填空题：</span>
            <span v-if="question.question_type === 'proof'">证明题：</span>
            <span v-if="question.question_type === 'flow'">流程题：</span>
            <MathTextRenderer :raw-text="question.question_text"/>
          </div>
          <!-- 证明题 -->
          <div v-if="question.question_type === 'proof'">
<!--            <el-input-->
<!--                type="textarea"-->
<!--                placeholder="请输入证明过程"-->
<!--                rows="4"-->
<!--                v-model="question.user_answer"-->
<!--            ></el-input>-->
            <el-upload
                v-model:file-list="question.fileList"
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
                        @click="handleRemove(file, question)"
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
          <!-- 填空题 -->
          <div v-if="question.question_type === 'blank'" class="blank">
            <input
                v-model="question.user_answer"
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
                  v-model="question.user_answer"
              />
              {{ option.option_label }}.
              <MathTextRenderer :raw-text="option.option_text"/>

            </li>
          </ul>

          <!-- 流程题 -->
          <ul v-if="question.question_type === 'flow'">
            <li v-for="(step, stepIndex) in question.steps" :key="stepIndex" class="flow-block">
              <div class="flow-item">
                <span v-if="!step.is_hidden"><MathTextRenderer :raw-text="step.step_text"/></span>
                <el-input
                    v-else
                    type="textarea"
                    placeholder="请补全流程"
                    rows="2"
                    v-model="question.user_answer[stepIndex]"
                ></el-input>
              </div>
              <div v-if="stepIndex < question.steps.length - 1" class="arrow">
                &darr;
              </div>
            </li>
          </ul>
        </div>
      </div>
      <h1 v-else>习题暂未发布！</h1>
    </div>
    <el-button @click="submitTest" style="width: 100%">提交</el-button>
  </div>
</template>

<script>
import MathTextRenderer from "@/components/MathTextRenderer.vue";
import ExampleEditor from "@/components/operating/ExampleEditor.vue";

export default {
  components: {
    MathTextRenderer,
    ExampleEditor,
  },
  data() {
    return {
      isTest: false,
      isOutput: false,
      pageInfo: {
        title: ""
      },
      value: "1",
      options: [],
      cascaderProps: {
        value: 'id',
      },
      isPosition: false,
      isAdd: false,
      userAnswer: [],
      questions: [],
      formatQuestion: {
        question_text: '',
        question_type: '',
        options: [],
        steps: [],
        check: null
      },
      course_id: 0,
      menuItems: [],

      dialogImageUrl: '',
      fileList: [],
      dialogVisible: false,
      disabled: false
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
    handleRemove(file, question) {
      this.$http.delete(`upload?file_name=${file.response.file_path}`).then(res => {
        question.fileList = question.fileList.filter((item) => item.name !== file.name);
      }).catch(err => {
        console.error(err)
      })
    },
    handlePictureCardPreview(file) {
      this.dialogImageUrl = file.url;
      this.dialogVisible = true;
    },
    handleDownload(file) {
      console.log(file);
    },
    handleUploadSuccess(response, file, fileList) {
      console.log("Upload Success:", response);
    },
    customUpload(option) {
      const formData = new FormData();
      formData.append("file", option.file);

      this.$http.post('upload', formData, {
        headers: {
          "Content-Type": "multipart/form-data"
        }
      }).then((res) => {
        option.onSuccess(res.data, option.file);
      })

    },
    getTestContent(courseId) {
      this.$http.get(`/question`, {
        params: {course_id: courseId}
      }).then(response => {
        // 处理成功响应
        console.log("题目内容:", response);
        // 你可以将获取的数据保存到组件的状态中，比如：
        this.questions = response.data;
      }).catch(error => {
        // 处理错误响应
        console.error("请求失败:", error);
      });
    },
    submitTest(){
      let userInfo =JSON.parse(localStorage.getItem("userInfo"));
      let userId = userInfo.id;
      let answers = []
      this.questions.map(answer =>{
        if(answer.question_type === 'flow'){
          answer.user_answer = answer.user_answer.join(',');
        }else if(answer.question_type === 'proof'){
          let fileLists = [];
          answer.fileList.map(fileList=>{
            fileLists.push(fileList.response.file_path);
          });
          answer.user_answer = fileLists;
        }
        answer.is_correct = answer.correct_answer === answer.user_answer;
        answers.push({
          user_id: userId,
          question_id: answer.id,
          user_answer: answer.user_answer,
          is_correct: answer.is_correct,
        });
      })
      this.$http.put(`/answered_questions`, {
        user_answer: JSON.stringify(answers),
      }).then(res => {
        this.$message.success("提交成功！")
        window.close();
      }).catch(error => {
        console.error(error)
      })
    },
    // 可根据需要添加答案验证逻辑
    test() {
      this.questions.push(this.formatQuestion)
    },
    addQuestion(question) {
      this.questions.push(question);
      this.isAdd = false;
    }
  },
  mounted() {
    this.pageInfo.title = "测试"
    this.getTestContent(19)
  }
};
</script>

<style scoped>
.userInfo {
  display: flex;
  justify-content: space-between;
  line-height: 1.5rem;
  margin-top: 1rem;
}

.arrow {
  font-size: 2rem;
  font-weight: bold;
  line-height: 2rem;
}

.deleteQuestion {
  position: absolute;
  right: 20px;
  top: 20px;
  cursor: pointer;
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

.problems {
  margin-bottom: 2rem;
}

.question {
  position: relative;
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
