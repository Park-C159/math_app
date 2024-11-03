<script setup lang="ts">
import {ref} from "vue";
import ExampleEditor from "@/components/operating/ExampleEditor.vue";
import ArticleEditor from "@/components/operating/ArticleEditor.vue";
import ChapterManagement from "@/components/operating/ChapterManagement.vue";
import QuestionEditor from "@/components/operating/QuestionEditor.vue";

let ContentID = ref(1);

const handleSelect = (key: string, keyPath: string[]) => {
  ContentID.value = parseInt(key);
}
</script>

<template>
  <table></table>
  <el-container class="main-container">
    <el-container class="app-container">
      <el-aside width="160px">
        <el-menu
            style="border-right: none;"
            background-color="#1d1e28"
            text-color="#fff"
            active-text-color="rgb(173, 145, 255)"
            class="el-menu-vertical-demo"
            default-active="1"
            @select="handleSelect"
        >
          <el-menu-item index="1">
            <el-icon>
              <Notebook/>
            </el-icon>
            <span>课程管理器</span>
          </el-menu-item>
          <el-menu-item index="2">
            <el-icon>
              <Notebook/>
            </el-icon>
            <span>章节编辑器</span>
          </el-menu-item>
          <el-menu-item index="3">
            <el-icon>
              <SetUp />
            </el-icon>
            <span>习题编辑器</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <div v-if="ContentID === 1">
          <ChapterManagement />
        </div>
        <div v-if="ContentID === 2">
          <ArticleEditor />
        </div>
        <div class="main-content" v-else-if="ContentID === 3">
          <QuestionEditor />
        </div>
      </el-main>
    </el-container>

  </el-container>
</template>

<style scoped>
.main-container {
  max-width: 1200px;
  margin: 2rem auto;
  box-shadow: 0px 0px 20px 0px rgba(0, 0, 0, 0.25);

}
.el-aside{
  background-color: #1d1e28;
}
.main-content{
  width: 100%;
}
</style>