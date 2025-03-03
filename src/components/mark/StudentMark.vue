<script setup lang="ts">
import {ref, getCurrentInstance, onMounted} from "vue";
import {useRoute} from "vue-router";
import {ElMessage} from "element-plus"

const instance = getCurrentInstance()
const proxy = instance?.proxy;
const route = useRoute()




</script>

<template>
学生成绩
</template>

<style scoped>

</style>