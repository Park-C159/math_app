<template>
  <div class="LatexGanerate">
    <h1>Latex公式生成器</h1>
<!--    <div>注意：与latex语法略有不同，公式中\需要两个</div>-->
    <el-form>
      <el-form-item label="表达式">
        <el-input
            v-model="latex"
            ref="expr1"
            placeholder="例如: \pm\sqrt{a^2 + b^2}"
            @focus="currentInput = 'expr1'"
        ></el-input>
      </el-form-item>
      <el-form-item label="公式预览区">
        <div v-html="renderedFormula"></div>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="generateCode">生成</el-button>
      </el-form-item>
      <el-form-item label="生成的LaTeX代码">
        <el-input
            v-model="copyLatex"
            ref="copyInput"
            readonly
        ></el-input>
        <el-button type="success" @click="copyToClipboard">复制</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
import katex from 'katex'
import 'katex/dist/katex.min.css'

export default {
  data() {
    return {
      latex: '',
      copyLatex: ''
    }
  },
  computed: {
    renderedFormula() {
      return katex.renderToString(this.latex, {throwOnError: false})
    },
  },
  methods: {
    generateCode() {
      this.copyLatex = `$${this.latex}$`
    },
    copyToClipboard() {
      // 复制到剪贴板
      if (this.copyLatex) {
        const input = this.$refs.copyInput.$el.querySelector('input')
        input.select()
        console.log(input)
        document.execCommand('copy')
        this.$message.success('复制成功')
      } else {
        this.$message.warning('没有生成的内容可复制')
      }
    }
  }
}
</script>

<style scoped>
.LatexGanerate h1 {
  text-align: center;
}
</style>
