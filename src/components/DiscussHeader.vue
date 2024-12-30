<script setup lang="ts">
import {ref} from "vue";
import {Search, ArrowDown} from "@element-plus/icons-vue";

const props = defineProps<{
  input: string
}>();

const emit = defineEmits<{
  'update:input': [value: string]
  'search': []
  'create-discussion': []
  'time-filter-change': [filter: string]
  'author-filter-change': [filter: string]
}>();

const handleSearch = () => {
  emit('search');
};

const handleCreateDiscussion = () => {
  emit('create-discussion');
};

const handleTimeFilterClick = (filter: string) => {
  emit('time-filter-change', filter);
};

const handleAuthorFilterClick = (filter: string) => {
  emit('author-filter-change', filter);
};
</script>

<template>
  <div class="discuss-header">
    <div class="discuss-header-left">
      <el-input
          :model-value="input"
          @update:modelValue="(val:any) => emit('update:input', val)"
          style="max-width: 300px; text-align: left"
          placeholder="请输入需要搜索的关键字"
          class="input-with-select"
          @keyup.enter="handleSearch"
      >
        <template #append>
          <el-button :icon="Search" @click="handleSearch"/>
        </template>
      </el-input>
      <el-button
          class="new_discussion-btn"
          color="rgb(173, 145, 255)"
          plain
          @click="handleCreateDiscussion"
      >
        发起讨论
      </el-button>
    </div>
    <div class="filter">
      <el-dropdown>
        <span class="el-dropdown-link">
          全部帖子
          <el-icon class="el-icon--right">
            <ArrowDown/>
          </el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handleAuthorFilterClick('created_by_me')">我发布的</el-dropdown-item>
            <el-dropdown-item @click="handleAuthorFilterClick('teacher_involved')">老师参与</el-dropdown-item>
            <el-dropdown-item @click="handleAuthorFilterClick('all')">恢复默认</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          所有时间
          <el-icon class="el-icon--right">
            <ArrowDown/>
          </el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handleTimeFilterClick('last_week')">最近一周</el-dropdown-item>
            <el-dropdown-item @click="handleTimeFilterClick('last_month')">最近一月</el-dropdown-item>
            <el-dropdown-item @click="handleTimeFilterClick('all')">恢复默认</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<style scoped>
.discuss-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.discuss-header-left {
  display: flex;
  align-items: center;
}

.discuss-header-left > * {
  margin-right: 10px;
}

.filter {
  display: flex;
  gap: 20px;
}
</style>