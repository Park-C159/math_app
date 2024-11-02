<script setup lang="ts">
import {ref} from "vue";
import Tautology from "@/components/toolbox/Tautology.vue";
import EquivalentCalc from "@/components/toolbox/EquivalentCalc.vue";
import LatexGanerate from "@/components/toolbox/LatexGanerate.vue";
import FormulaEditor from "@/components/toolbox/FormulaEditor.vue";

let ContentID = ref(1);

const handleSelect = (key: string, keyPath: string[]) => {
  ContentID.value = parseInt(key);
}
</script>

<template>
  <el-container class="main-container">
    <el-container class="app-container">
      <el-aside width="200px">
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
            <span>重言式计算器</span>
          </el-menu-item>
          <el-menu-item index="2">
            <el-icon>
              <SetUp />
            </el-icon>
            <span>等值演算计算器</span>
          </el-menu-item>
          <el-menu-item index="3">
            <el-icon>
              <SetUp />
            </el-icon>
            <span>Latex公式生成器</span>
          </el-menu-item>
          <el-menu-item index="4">
            <el-icon>
              <SetUp />
            </el-icon>
            <span>Latex公式编辑器</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <div v-if="ContentID === 1">
          <Tautology />
        </div>
        <div v-else-if="ContentID === 2">
          <EquivalentCalc />
        </div>
        <div v-else-if="ContentID === 3">
          <LatexGanerate />
        </div>
        <div v-else-if="ContentID === 4">
          <FormulaEditor />
        </div>


      </el-main>
    </el-container>

  </el-container>
</template>

<style scoped>
.main-container {
  max-width: 1000px;
  margin: 2rem auto;
  box-shadow: 0px 0px 20px 0px rgba(0, 0, 0, 0.25);

}
.el-aside{
  background-color: #1d1e28;
}
</style>