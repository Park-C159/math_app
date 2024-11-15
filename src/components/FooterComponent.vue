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
    <img src="@/assets/images/mathword.svg" width="150"><br /> Copyright © [Tianhao Yuan and Yongjun Wang] - 2024
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

</style>