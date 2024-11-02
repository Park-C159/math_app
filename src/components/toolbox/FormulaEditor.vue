<template>
  <div>
    <h2>请输入数学公式</h2>
    <math-field ref="mathField" id="mathInput"></math-field>
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
  setup(_, {emit}) {
    const mathField = ref<MathfieldElement | null>(null);
    const mathValue = ref<string>('');

    onMounted(() => {
      // 启用虚拟键盘
      if (mathField.value) {
        mathField.value.setOptions({
          virtualKeyboard: 'on'
        });

        // 监听输入事件以支持换行
        mathField.value.addEventListener('input', () => {
          // 获取输入的值并替换换行符
          mathValue.value = mathField.value.getValue().replace(/\n/g, '\\n');
        });
      }
    });

    const getMathValue = () => {
      // 获取输入的公式
      if (mathField.value) {
        mathValue.value = mathField.value.getValue();
        emit('addFormula', mathValue.value);

      }
    };

    const sendData = ()=>{
      console.log(mathValue.value);
    }

    return {
      mathField,
      getMathValue,
      mathValue,
      sendData,
    };
  }
};
</script>

<style scoped>
/* 你可以根据需要添加样式 */
#mathInput {
  width: 100%;
  height: 200px;

}
</style>
