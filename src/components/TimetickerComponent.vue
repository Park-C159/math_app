<template>
  <div v-if="remainingTime > 0">
    <p>倒计时: {{ formatTime(remainingTime) }}</p>
  </div>
  <div v-else>
    <p>倒计时结束！</p>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, computed } from 'vue';

// 定义 props
const props = defineProps({
  endTime: {
    type: String,
    required: true,
  },
});

// 剩余时间（秒）
const remainingTime = ref(0);
// 定时器 ID
let timer: NodeJS.Timeout | null = null;

// 将传入的 ISO 格式时间转换为 Date 对象
const endDate = computed(() => new Date(props.endTime));

// 格式化剩余时间为 "XX:XX:XX" 格式
const formatTime = (seconds: number): string => {
  const hours = String(Math.floor(seconds / 3600)).padStart(2, '0');
  const minutes = String(Math.floor((seconds % 3600) / 60)).padStart(2, '0');
  const secs = String(seconds % 60).padStart(2, '0');
  return `${hours}:${minutes}:${secs}`;
};

// 更新剩余时间
const updateTime = () => {
  const now = new Date();
  const timeLeft = Math.floor((endDate.value.getTime() - now.getTime()) / 1000); // 毫秒转换为秒
  if (timeLeft <= 0) {
    remainingTime.value = 0;
    if (timer) {
      clearInterval(timer); // 停止倒计时
      timer = null;
    }
  } else {
    remainingTime.value = timeLeft;
  }
};

// 组件挂载时启动倒计时
onMounted(() => {
  updateTime();
  timer = setInterval(updateTime, 1000); // 每秒更新一次
});

// 组件销毁时清除定时器
onBeforeUnmount(() => {
  if (timer) {
    clearInterval(timer);
  }
});
</script>

<style scoped>
/* 自定义样式 */
p {
  font-size: 20px;
  font-weight: bold;
  color: #333;
}
</style>
