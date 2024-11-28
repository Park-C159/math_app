<template>
  <div ref="pdfContent" class="pdf-content">
    <div class="problems" v-for="(question, index) in questions" :key="index">
      <div class="info" :v-model="pageInfo" style="display: none">
        <h1 style="text-align: center; font-size: 32px">{{ pageInfo.title }}</h1>
        <div class="userInfo">
          <div>考生姓名: ______________</div>
          <div>学号: ______________</div>
          <div>考场: ______________</div>
        </div>
        <p style="font-size: 12px">说明: 请仔细阅读每道题目，确保答题完整。</p>
        <p style="font-size: 12px; margin-bottom: 1rem">注意事项: 请在答题纸上写下答案，不要在试卷上作答。</p>
      </div>
      <div class="question">
        <div style="margin-bottom: 0.5rem">
          <span v-if="question.question_type === 'choice'">选择题：</span>
          <span v-if="question.question_type === 'blank'">填空题：</span>
          <span v-if="question.question_type === 'proof'">解答题：</span>
          <span v-if="question.question_type === 'flow'">流程题：</span>
          <span>（{{ question.score }}分）</span>
          <MathTextRenderer :raw-text="question.question_text"/>
        </div>
        <!-- 证明题 -->
        <el-input
            v-if="question.question_type === 'proof'"
            type="textarea"
            placeholder="请输入解答过程"
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
              ></el-input>
            </div>
            <div v-if="stepIndex < question.steps.length - 1" class="arrow">
              &darr;
            </div>
          </li>
        </ul>
        <div class="deleteQuestion" @click="deleteQuestion(index)">删除</div>
      </div>
    </div>
    <!--    按钮区    -->
    <div class="button-list">
      <el-button @click="isAdd = true" type="warning">添加习题</el-button>
      <el-button @click="isPosition = true" type="success">保存</el-button>
      <el-button @click="isOutput = true" type="primary">导出PDF</el-button>
    </div>
  </div>
  <el-dialog v-model="isOutput">
    <el-input placeholder="请输入试卷标题" v-model="pageInfo.title"></el-input>
    <el-button @click="generatePDF">确认导出</el-button>
  </el-dialog>
  <el-dialog v-model="isAdd">
    <ExampleEditor @addData="addQuestion"/>
  </el-dialog>

  <el-dialog
      v-model="isPosition"
      width="600"
      title="请输入题目基本信息"
      append-to-body
  >

    <span>考试：</span>
    <el-switch v-model="isTest"></el-switch>
    <br>
    <br>
    <el-form
        v-if="isTest"
        :model="exam"
        label-width="auto"
        style="max-width: 600px">
      <el-form-item label="考试标题">
        <el-input v-model="exam.name" placeholder="请输入考试标题"/>
      </el-form-item>
      <el-form-item label="课程">
        <el-select v-model="exam.course_id" placeholder="请选择考试课程">
          <el-option
              v-for="(course, index) in exam.courses"
              :label="course.name"
              :value="course.id"
              :key="index"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="考试时间">
        <el-col :span="11">
          <el-date-picker
              v-model="exam.start_time"
              type="datetime"
              placeholder="请选择开始时间"
              style="width: 100%"
          />
        </el-col>
        <el-col :span="2" style="text-align: center;">
          <span class="text-gray-500">-</span>
        </el-col>
        <el-col :span="11">
          <el-date-picker
              type="datetime"
              v-model="exam.end_time"
              placeholder="请选择结束时间"
              style="width: 100%"
          />
        </el-col>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="uploadExam">上传</el-button>
        <el-button @click="isPosition = false">取消</el-button>
      </el-form-item>
    </el-form>
    <el-form v-else>
      <el-form-item label="课程">
        <el-cascader
            v-model="value"
            :options="options"
            :props="cascaderProps"
            @change="handleChange"
        />

      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="uploadQuestion">上传</el-button>
        <el-button @click="isPosition = false">取消</el-button>
      </el-form-item>

    </el-form>
    <!--    <span slot="footer" class="dialog-footer">-->
    <!--    </span>-->
  </el-dialog>
</template>

<script>
import MathTextRenderer from "@/components/MathTextRenderer.vue";
import ExampleEditor from "@/components/operating/ExampleEditor.vue";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";

export default {
  components: {
    MathTextRenderer,
    ExampleEditor,
  },
  data() {
    return {
      exam: {
        name: null,
        courses: {},
        course_id: null,
        start_time: null,
        end_time: null,
      },
      form: {},
      courseValue: '',
      courseOptions: [],
      courseNameList: [],
      isTest: true,
      isOutput: false,
      pageInfo: {
        title: ""
      },
      value: "0",
      options: [],
      cascaderProps: {
        value: 'id',
      },
      isPosition: false,
      isAdd: false,
      userAnswer: [],
      questions: [],
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
    uploadQuestion() {
      // 获取选中的课程ID
      let course_id = this.value[this.value.length - 1];
      // 将题目数据转换为JSON字符串
      let formData = JSON.stringify(this.questions);

      this.$http.post("/question",{
        course_id: course_id,
        questions: this.questions,
      }).then((res) => {
        console.log(res);
      })

      // 发送PUT请求
      // this.$http.put("/question", {
      //   course_id: course_id, // 作为请求体中的参数
      //   test_info: JSON.stringify({
      //     test_title: this.pageInfo.title,
      //     test_course: this.courseValue
      //   }),
      //   format_data: formData    // JSON格式化后的题目数据
      // }).then(response => {
      //   console.log('上传成功:', response);
      //   this.$message.success('题目上传成功！');
      // }).catch(error => {
      //   console.error('上传失败:', error);
      //   this.$message.error('题目上传失败！');
      // });
      this.isPosition = false;
    },
    uploadExam() {
      this.$http.post("exams", {
        exam: this.exam,
        questions: this.questions,
      }).then(res => {
        let response = res.data
        if (response.code === 200) {
          this.$message.success(response.msg);
          this.isPosition = false;

        } else {
          this.$message.warning(response.msg)
        }

      }).catch(err => {
        this.$message.error(err.message);
        console.log(err);
      })
    },
    async getCourseList() {
      this.$http.get("/course_management").then((response) => {
        this.exam.courses = response.data;
      })
    },
    async getCourseName() {
      await this.$http.get('/get_course_name').then(res => {
        this.courseNameList = []
        res.data.data.map(value => {
          this.courseNameList.push(value.name)
          this.courseOptions.push({
            value: value,
            label: value
          })
        })
      }).catch((err) => {
        console.error(err)
      })
    },
    async generatePDF() {
      const pdfContent = this.$refs.pdfContent;

      // 临时更改文字颜色为黑色
      const originalColor = pdfContent.style.color;
      const originalFontSize = pdfContent.style.fontSize;
      pdfContent.style.color = '#000';
      pdfContent.style.fontSize = pdfContent.style.fontSize = '16px';

      // 隐藏所有删除按钮和底部按钮
      const info = document.getElementsByClassName('info')[0];
      const deleteButtons = document.querySelectorAll('.deleteQuestion');
      const buttonList = document.querySelector('.button-list');
      deleteButtons.forEach(button => button.style.display = 'none');
      buttonList.style.display = 'none';
      info.style.display = 'block'

      // 使用 html2canvas 将 HTML 转换为图像
      const canvas = await html2canvas(pdfContent, {
        scale: 2, // 提高分辨率
        useCORS: true // 如果有跨域的图片，启用 CORS
      });

      // 恢复原有的文字颜色、删除按钮和底部按钮
      pdfContent.style.color = originalColor;
      deleteButtons.forEach(button => button.style.display = 'block');
      buttonList.style.display = 'block';
      info.style.display = 'none'
      pdfContent.style.fontSize = originalFontSize;

      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF('p', 'mm', 'a4');

      // 设置页边距
      const margin = 25; // 2.5cm 等于 25mm
      const imgWidth = pdf.internal.pageSize.getWidth() - margin * 2;
      const pageHeight = pdf.internal.pageSize.getHeight();
      const imgHeight = (canvas.height * imgWidth) / canvas.width;

      let heightLeft = imgHeight;
      let position = margin;


      // 添加图像到 PDF，考虑页边距
      pdf.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      while (heightLeft >= 0) {
        position = heightLeft - imgHeight + margin;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      // 下载 PDF
      pdf.save('questions.pdf');
    },
    handleChange() {
      // console.log(this.value);
    },
    async getCourse() {
      await this.getCourseName();
      console.log(this.courseNameList)

      // 应该将courseNameList数组来进行遍历，留有接口
      for (let courseName of this.courseNameList) {
        this.$http.get('/course', {
          params: {
            courseName: courseName,
          }
        }).then(res => {
          this.options.push({
            value: courseName,
            label: courseName,
            children: res.data,
            leaf: false
          })
        })
      }
    },
    saveQuestion() {

    },
    deleteQuestion(index) {
      this.questions.splice(index, 1);
      this.updateQuestions()
    },
    // 可根据需要添加答案验证逻辑
    test() {
      let questions = localStorage.getItem('edit-questions');
      if (questions) {
        let questions_json = JSON.parse(questions);
        this.questions = questions_json;
      } else {

      }
      // this.questions.push(this.formatQuestion)
    },
    addQuestion(question) {
      this.questions.push(question);
      this.updateQuestions()
      this.isAdd = false;
    },
    updateQuestions() {
      localStorage.setItem('edit-questions', JSON.stringify(this.questions));
    }
  },
  async mounted() {
    await this.getCourse()
    await this.getCourseList()
    this.test()
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
