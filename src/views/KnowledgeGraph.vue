<script setup lang="ts">
import CircularRelation from "@/components/knowledge/CircularRelation.vue";

</script>

<template>
<div class="knowledge-container">
  <div class="graph">
    <CircularRelation />
  </div>

</div>
</template>

<style scoped>
.graph {
  margin: 0 auto;
  width: 80vw;
  height: calc(100vh - 100px);
}
</style>