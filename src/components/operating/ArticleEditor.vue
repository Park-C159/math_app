<template>
  <div>
    <!-- 显示实时编辑的 Markdown 转换结果 -->
    <div class="editor">
      <h2>请输入课程内容</h2>

      <mavon-editor
          v-model="value"
          :subfield="true"
          :toolbars="toolbars"
      ></mavon-editor>
      <div>
        <el-button type="success" @click="dialogVisible = true">保存</el-button>
      </div>

      <el-dialog
          v-model="dialogVisible"
          title="提示"
          width="500"
      >
        <el-form
            ref="ruleFormRef"
            style="max-width: 600px"
            :model="ruleForm"
            status-icon
            label-width="auto"
            class="demo-ruleForm"
        >
          <el-form-item label="课程">
            <el-input v-model="ruleForm.course_name" placeholder="请输入课程名称" />
          </el-form-item>
          <el-form-item label="章节">
            <el-input
                v-model="ruleForm.chapter_title" placeholder="请输入章节标题"
            />
          </el-form-item>
          <el-form-item label="小节">
            <el-switch v-model="switchBtn" />
            <el-input v-if="switchBtn" v-model="ruleForm.section_title" placeholder="请输入小节标题"/>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="submitForm">
              提交
            </el-button>
            <el-button @click="resetForm">重置</el-button>
          </el-form-item>
        </el-form>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import MarkdownIt from 'markdown-it'

export default {
  data() {
    return {
      switchBtn: false,
      value: '# 标题一', // 初始值为空
      toolbars: {
        bold: true,
        italic: true,
        header: true,
        underline: true,
        strikethrough: true,
        mark: true,
        superscript: true,
        subscript: true,
        quote: true,
        ol: true,
        ul: true,
        link: true,
        imagelink: true,
        code: true,
        table: true,
        fullscreen: true,
        readmodel: true,
        htmlcode: true,
        help: true,
        undo: true,
        redo: true,
        trash: true,
        save: true,
        navigation: true,
        alignleft: true,
        aligncenter: true,
        alignright: true,
        subfield: true,
        toc: true,
        codeTheme: true,
        previewTheme: true
      },
      dialogVisible: false,
      ruleForm: {
        course_name: '',
        chapter_title: '',
        section_title: null,
      },
      markdownIt: new MarkdownIt() // 实例化 MarkdownIt
    }
  },
  computed: {
    renderedMarkdown() {
      // 将 Markdown 文本转换为 HTML 显示
      return this.markdownIt.render(this.value)
    }
  },
  methods: {
    submitForm(){
      let form = {
        course_name: this.ruleForm.course_name,
        chapter_title: this.ruleForm.chapter_title,
        is_section: this.switchBtn,
        section_title: this.ruleForm.section_title,
      }
      this.$http.post('/content', {
        params: {
          course_name: this.ruleForm.course_name,
          chapter_title: this.ruleForm.chapter_title,
          is_section: this.switchBtn,
          section_title: this.ruleForm.section_title,
          content: this.value
        }
      }).then((response) => {
        this.$message()
      })
    },
    resetForm(){
      this.ruleForm = {
        course_name: '',
        chapter_title: '',
        section_title: null,
      }
    },
    saveContent() {
      this.dialogVisible = true
      console.log(this.value)
    }
  }
}
</script>

<style scoped>
/* 可以根据需要添加自定义样式 */
.editor {
  text-align: center;
}
</style>
