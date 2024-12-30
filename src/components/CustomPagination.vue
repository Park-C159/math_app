<script setup lang="ts">
import {ref} from 'vue'
import {ElMessage} from "element-plus";

const props = defineProps<{
  currentPage: number
  perPage: number
  totalItems: number
}>()

const emit = defineEmits<{
  'update:currentPage': [page: number]
  'page-change': [page: number]
}>()

const jumpToPage = ref<number | null>(null)

// 处理页面变化
const handlePageChange = (page: number) => {
  emit('update:currentPage', page)
  emit('page-change', page)
}

// 跳转到指定页面
const jumpToSpecificPage = () => {
  const totalPages = Math.ceil(props.totalItems / props.perPage)
  if (jumpToPage.value && jumpToPage.value > 0 && jumpToPage.value <= totalPages) {
    handlePageChange(jumpToPage.value)
    jumpToPage.value = null
  } else {
    ElMessage.error('请输入有效页码')
  }
}
</script>

<template>
  <div class="pagination-container">
    <div class="pagination-wrapper">
      <!-- 分页器 -->
      <el-pagination
          :current-page="currentPage"
          :page-size="perPage"
          :total="totalItems"
          layout="prev, pager, next"
          @current-change="handlePageChange"
          class="custom-pagination"
      />
      <!-- 跳转 -->
      <div class="jump-to-page">
        <el-input
            v-model="jumpToPage"
            type="number"
            placeholder="跳转页码"
            size="small"
            class="jump-input"
        />
        <el-button
            type="primary"
            size="small"
            @click="jumpToSpecificPage"
            class="jump-button"
        >
          跳转
        </el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.pagination-wrapper {
  display: flex;
  align-items: center;
  background-color: rgba(50, 50, 50, 0.5);
  padding: 15px 25px;
  border-radius: 12px;
  backdrop-filter: blur(15px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.custom-pagination {
  margin-right: 30px;
}

.jump-to-page {
  display: flex;
  align-items: center;
}

.jump-input {
  width: 120px;
  margin-right: 15px;
}

.jump-button {
  background-color: rgba(95, 95, 95, 0.7);
  border-color: transparent;
  color: #fff;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.jump-button:hover {
  background-color: rgba(110, 110, 110, 0.8);
  transform: scale(1.05);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

.custom-pagination :deep(.el-pager li) {
  background-color: rgba(70, 70, 70, 0.5);
  backdrop-filter: blur(10px);
  margin: 0 5px;
  border-radius: 6px;
  transition: all 0.3s ease;
  color: white !important;
}

.custom-pagination :deep(.el-pager li:hover) {
  background-color: rgba(90, 90, 90, 0.7);
  transform: scale(1.1);
}
</style>