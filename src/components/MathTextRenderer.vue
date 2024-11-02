<template>
    <!-- 遍历文本片段，分别渲染普通文本和公式 -->
    <span v-for="(segment, index) in renderedSegments" :key="index">
      <span v-if="segment.type === 'text'">{{ segment.content }}</span>
      <span v-else v-html="segment.content"></span>
    </span>
</template>

<script>
import katex from 'katex';
import 'katex/dist/katex.min.css';

export default {
  name: 'MathTextRenderer',
  props: {
    rawText: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      renderedSegments: [] // 渲染后的文本片段
    };
  },
  watch: {
    // 监听rawText变化，重新渲染
    rawText: {
      immediate: true,
      handler() {
        this.renderTextWithKaTeX();
      }
    }
  },
  methods: {
    renderTextWithKaTeX() {
      // 正则表达式匹配 $...$ 内的数学公式
      const parts = this.rawText.split(/(\$[^\$]+\$)/g);

      // 遍历文本片段，分别处理普通文本和公式
      this.renderedSegments = parts.map((part) => {
        if (part.startsWith('$') && part.endsWith('$')) {
          // 如果是公式部分，进行双反斜杠替换并用KaTeX渲染
          const latex = part.slice(1, -1);

          return {
            type: 'math',
            content: katex.renderToString(latex, { throwOnError: false })
          };
        } else {
          // 如果是普通文本
          return {
            type: 'text',
            content: part
          };
        }
      });
    }
  }
};
</script>

<style scoped>
.katex {
  font-size: 1.2em;
}
</style>
