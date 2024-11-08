<template>
  <div>
    <h2>请输入数学公式</h2>
    <div id="mathInput"></div>
    <br>
    <el-button type="success" @click="getMathValue">获取公式</el-button>
    <div v-if="mathValue">
      <h3>输入的公式:</h3>
      <div>{{ mathValue }}</div>
    </div>
  </div>
</template>

<script lang="ts">
import { ref, onMounted } from 'vue';
import { MathfieldElement } from 'mathlive';

export default {
  setup(_, { emit }) {
    const mathField = ref<MathfieldElement | null>(null);
    const mathValue = ref<string>('');

    onMounted(() => {
      // 创建 MathfieldElement 实例
      mathField.value = new MathfieldElement();

      if (mathField.value) {
        // 启用虚拟键盘模式
        mathField.value.virtualKeyboardMode = 'on';

        // 将 MathfieldElement 挂载到 DOM 中
        document.getElementById('mathInput')?.appendChild(mathField.value);

        // 监听输入事件并处理换行
        mathField.value.addEventListener('input', () => {
          mathValue.value = mathField.value?.getValue().replace(/\n/g, '\\n') || '';
        });
      }
    });

    const getMathValue = () => {
      // 获取输入的公式并传递给父组件
      if (mathField.value) {
        mathValue.value = mathField.value.getValue();
        emit('addFormula', mathValue.value);
      }
    };

    return {
      mathField,
      getMathValue,
      mathValue,
    };
  },
};
</script>

<style scoped>
#mathInput {
  width: 100%;
  height: 200px;
}
</style>
