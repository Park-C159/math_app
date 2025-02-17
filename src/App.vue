<script setup lang="ts">
import {RouterLink, RouterView, useRoute} from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
import HeaderComponent from "@/components/HeaderComponent.vue";
import FooterComponent from "@/components/FooterComponent.vue";

const route = useRoute();

const toChat = ()=>{
  window.open(`${window.location.origin}/chat_ai`, '_blank')
}

</script>

<template>
  <header v-if="!route.meta.hideHeaderFooter">
    <div class="header-top"></div>
    <HeaderComponent/>
  </header>
<!--  <div class="helper" @click="toChat"  v-if="route.path !== '/chat_ai'">-->
<!--    <img width="100%" src="@/assets/images/robot_black.svg" alt="数学小助手">-->
<!--  </div>-->
  <RouterView/>
  <FooterComponent/>
</template>

<style scoped>
.header-top {
  border-top: 6px solid rgb(173, 145, 255);
}
.helper {
  position: fixed;
  bottom: 5vh;
  right: 5vw;
  background: #409eff;
  border-radius: 50%;
  width: 75px;
  height: 75px;
  padding: 10px;
}
.helper:hover {
  cursor: pointer;
}
</style>
