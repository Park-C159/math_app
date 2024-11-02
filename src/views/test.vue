<template>
  <div>
    <div v-for="(item, index) in items" :key="index">
      <el-input
          v-model="item.value"
          :ref="'input' + index"
          placeholder="请输入内容"
          @input="updateInput(index, item.value)">
      </el-input>
    </div>
    <el-button @click="getInputs">获取输入值</el-button>
  </div>
</template>

<script>
export default {
  data() {
    return {
      items: [
        {value: ''},
        {value: ''},
        {value: ''}
      ]
    };
  },
  methods: {
    updateInput(index, value) {
      this.$set(this.items, index, {value});
    },
    getInputs() {
      this.items.forEach((item, index) => {
        console.log(`输入框 ${index + 1} 的值:`, item.value);
      });
    }
  }
};
</script>

<style scoped>
/* 添加样式 */
</style>
