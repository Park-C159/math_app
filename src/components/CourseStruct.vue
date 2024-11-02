<script setup lang="ts">
import 'element-plus/theme-chalk/dark/css-vars.css'
import {useRouter, useRoute} from 'vue-router';  // 引入 Vue Router

import {getCurrentInstance, onMounted, ref} from 'vue';
// 定义 props 来接收父组件传递的参数
const props = defineProps<{ courseName: string }>();
const route = useRoute()

// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况
// 创建路由实例
const router = useRouter();

interface Tree {
  label: string
  time: string
  id: string
  children?: Tree[]
}

const handleNodeClick = (data: Tree) => {
  if (Reflect.get(data, 'length') > 0) {
    return
  } else {
    console.log(data.label, data.id)
    // 如果是叶子节点，跳转到新页面，并传递 class_name 和 course_id
    router.push({
      path: '/course_content',
      query: {
        class_name: route.query.courseName,
        course_id: data.id
      }
    });
  }
}
// 响应式数据，初始化为空数组
const data = ref<Tree[]>([]);

// 使用全局的 $http（即 axios 实例）获取课程数据
const getCourse = async () => {
  try {
    const response = await proxy?.$http.get('/course', {
      params: {
        courseName: props.courseName,
      }
    }); // 通过 proxy 访问 $http
    // console.log(response?.data); // 获取数据后可以根据需求处理
    if (response?.data) {
      data.value = response?.data;

    }

  } catch (error) {
    console.error('Error fetching course data:', error);
  }
};
onMounted(() => {
  getCourse();
});

</script>

<template>
  <el-tree
      :data="data"
      @node-click="handleNodeClick"
      class="struct"
      default-expand-all
  >
    <template #default="{ node, data }">
        <div class="custom-tree-node">
          <div style="display: flex; align-items: center; width:  auto">
            {{ node.label }}
            <span class="planning-time" v-if="!data.children || data.children.length == 0">（{{ data.time }} 学时）</span>
          </div>

          <div class="planning-time">未开始</div>
        </div>
    </template>
  </el-tree>
</template>

<style>
.struct {
  background-color: transparent !important;
  color: white !important;
}

.struct .el-tree-node__content {
  font-size: 1rem;
  height: 2rem;
}

.struct .el-tree-node__children {
  font-size: 0.5rem !important;
}

.struct .el-tree-node.is-current .el-tree-node__content {
  background-color: #333 !important; /* 自定义选中背景色 */
  color: #ffffff !important; /* 自定义选中文本颜色 */
}

.struct .el-tree-node__content:hover {
  background-color: #222 !important; /* 自定义悬停时的背景色 */
  color: #ffffff !important; /* 自定义悬停时的文本颜色 */
}

.struct:focus {
  background-color: #1c1c2c;
}

.struct:hover {
  background-color: #1c1c2c;
}
.custom-tree-node{
  display: flex;
  width: calc(100vw - 4rem - 150px - 40px) !important;
  align-items: center;
  justify-content: space-between;
}
.struct .planning-time{
  display: block;
  font-size: 0.8rem !important;
  color: #999 !important;
  margin-left: 1rem !important;
}
</style>