<script setup lang="ts">
import {ref, watch} from "vue";
import {Search, ArrowDown} from "@element-plus/icons-vue";

const timeFilterText = ref('所有时间');
const authorFilterText = ref('全部帖子');
const props = defineProps<{
  input: string
  buttonText: string
  buttonDisabled?: boolean
  showManageButton?: boolean
}>();

const emit = defineEmits<{
  'update:input': [value: string]
  'search': []
  'create-discussion': []
  'time-filter-change': [filter: string]
  'author-filter-change': [filter: string]
  'manage-topics': []
}>();

const inputValue = ref(props.input);
const timeFilter = ref('all');
const authorFilter = ref('all');

watch(inputValue, (newValue) => {
  emit('update:input', newValue);
});

const handleSearch = () => {
  emit('search');
};

const handleCreateDiscussion = () => {
  emit('create-discussion');
};

const handleTimeFilterClick = (filter: string) => {
  timeFilterText.value = filter === 'last_week' ? '最近一周' : filter === 'last_month' ? '最近一月' : '所有时间';
  emit('time-filter-change', filter);
};

const handleAuthorFilterClick = (filter: string) => {
  authorFilterText.value = filter === 'created_by_me' ? '我发布的' : filter === 'teacher_involved' ? '老师参与' : '全部帖子';
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
          :disabled="props.buttonDisabled"
          @click="handleCreateDiscussion"
      >
        {{ props.buttonText}}
      </el-button>
      <el-button
        v-if="showManageButton"
        type="primary"
        @click="$emit('manage-topics')"
      >
        管理话题
      </el-button>
    </div>
    <div class="filter">
      <el-dropdown>
        <span class="el-dropdown-link">
          {{ authorFilterText }}
          <el-icon class="el-icon--right">
            <ArrowDown/>
          </el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handleAuthorFilterClick('created_by_me')">我发布的</el-dropdown-item>
            <el-dropdown-item @click="handleAuthorFilterClick('teacher_involved')">老师参与</el-dropdown-item>
            <el-dropdown-item @click="handleAuthorFilterClick('all')">全部帖子</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          {{ timeFilterText }}
          <el-icon class="el-icon--right">
            <ArrowDown/>
          </el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handleTimeFilterClick('last_week')">最近一周</el-dropdown-item>
            <el-dropdown-item @click="handleTimeFilterClick('last_month')">最近一月</el-dropdown-item>
            <el-dropdown-item @click="handleTimeFilterClick('all')">所有时间</el-dropdown-item>
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