<script setup lang="ts">
import {useRoute} from "vue-router";
import {computed} from "vue";

const route = useRoute();

// 判断是否是根路径
const isRootPath = computed(() => route.path !== '/');
</script>

<template>
  <footer class="footer">
    <div class="bot-footer" :style="{ paddingTop: isRootPath ? '120px' : '20px' }">
      <div class="footer-content">
        <img src="@/assets/images/mathword.svg" width="150">
        <span class="copyright">Copyright © [Tianhao Yuan and Yongjun Wang] - 2024</span>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.bot-footer {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-image: url("@/assets/images/wavy-light-by-nouridio.svg");
  background-repeat: no-repeat;
  background-position: bottom;
  background-size: 200%;
  padding-bottom: 20px;
}

.footer-content {
  display: flex;
  align-items: center;
  gap: 10px;
}

.copyright {
  font-size: 0.9em;
  color: #666;
}
</style>