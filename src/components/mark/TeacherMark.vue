<script setup lang="ts">
import {ref, getCurrentInstance, onMounted} from "vue";
import {useRoute} from "vue-router";
import {ElMessage} from "element-plus"

const instance = getCurrentInstance()
const proxy = instance?.proxy;
const route = useRoute()





</script>

<template>
  <div class="content_head">
    <el-button @click="">导入成绩</el-button>
    <button @click="triggerFileInput">选择 Excel 文件</button>
    <input type="file" ref="fileInput" @change="handleFileUpload" accept=".xlsx, .xls" style="display: none" />
    <pre v-if="jsonData">{{ jsonData }}</pre>

  </div>

</template>

<style scoped>

</style>