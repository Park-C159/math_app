<template>
  <div class="common-layout">
    <el-container>
      <el-aside width="200px">
        <el-menu
            active-text-color="#ffd04b"
            background-color="#545c64"
            class="el-menu-vertical-demo"
            default-active="2"
            text-color="#fff"
            @select="selectMenu"
            @open="handleOpen"
            @close="handleClose"
        >
          <el-sub-menu v-for="(item, i) in menuItems" :index="i" :key="i">
            <template #title>
              <span>{{ item.label }}</span>
            </template>
            <el-menu-item v-for="(subItem, j) in item.children" :index="subItem.id" :key="j">
              {{ subItem.label }}
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>
      <el-main>
        <div ref="pdfContent" class="pdf-content">
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
              <div class="deleteQuestion" @click="deleteQuestion(index, question.id)">删除</div>
            </div>
          </div>
          <h1 v-else>请选择课程</h1>
          <!--    按钮区    -->
          <div class="button-list">
            <el-button @click="isAdd = true" type="warning">添加习题</el-button>
            <el-button @click="isOutput = true" type="primary">导出PDF</el-button>
            <el-button @click="deleteTest" type="danger">删除考试</el-button>
            <el-button @click="checkTest" type="success">阅卷中心</el-button>
          </div>
        </div>
      </el-main>
    </el-container>
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
      width="500"
      title="请选择题目位置"
      append-to-body
  >
    考试：
    <el-switch v-model="isTest"></el-switch>
    <br>
    <el-input v-if="isTest" placeholder="请输入考试标题"></el-input>
    <el-cascader
        v-else
        v-model="value"
        :options="options"
        :props="cascaderProps"
        @change="handleChange"
    />
    <span slot="footer" class="dialog-footer">
      <el-button type="primary" @click="uploadQuestion">上传</el-button>
    </span>
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
    checkTest() {
      this.$router.push("/check_test");
    },
    deleteTest() {
      this.$http.delete('/course', {
        params: {
          course_id: this.course_id,
        }
      }).then((res) => {
        console.log(res);
        this.getTestList()
      })

    },
    selectMenu(key, kePath) {
      this.course_id = key;
      this.getTestContent(key)
    },
    getTestContent(courseId) {
      this.$http.get(`/question`, {
        params: {course_id: courseId}
      }).then(response => {
        // 处理成功响应
        console.log("题目内容:", response.data);
        // 你可以将获取的数据保存到组件的状态中，比如：
        this.questions = response.data;
      }).catch(error => {
        // 处理错误响应
        console.error("请求失败:", error);
      });
    },
    getTestList() {
      try {
        const response = this.$http.get('/course', {
          params: {
            courseName: '考试',
          }
        }).then(res => {
          if (res.status === 200) {
            this.menuItems = res.data
          }
          this.course_id = res.data[0].id

        }).catch(err => {
          console.error('Error fetching course data:', error);

        }) // 通过 proxy 访问 $http

      } catch (error) {
      }
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
    uploadQuestion() {
      // 获取选中的课程ID
      let course_id = this.value[this.value.length - 1];
      // 将题目数据转换为JSON字符串
      let formData = JSON.stringify(this.questions);

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
      this.isPosition = false;
    },
    getCourse() {
      // 应该将courseNameList数组来进行遍历，留有接口
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
    saveQuestion() {

    },
    deleteQuestion(index, question_id) {
      console.log(question_id)
      this.$http.delete('/question', {
        params: {question_id: question_id}
      })
          .then(response => {
            this.questions.splice(index, 1);  // 删除成功后移除对应项
            console.log("删除成功:", response.data.message);
          })
          .catch(error => {
            console.error("删除失败:", error);
          });
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
    this.getTestList()
    this.getCourse()
    // this.test()
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
