<script setup lang="ts">
import {RouterLink, RouterView, useRoute} from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
import HeaderComponent from "@/components/HeaderComponent.vue";
import FooterComponent from "@/components/FooterComponent.vue";

const route = useRoute();
</script>

<template>
  <header v-if="!route.meta.hideHeaderFooter">
    <div class="header-top"></div>
    <HeaderComponent/>
  </header>
  <RouterView/>
  <FooterComponent/>
</template>

<style scoped>
.header-top {
  border-top: 6px solid rgb(173, 145, 255);
}
</style>
