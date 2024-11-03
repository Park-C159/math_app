<template>
  <el-table :data="tableData" style="width: 100%">
    <el-table-column fixed prop="name" label="课程名称" width="150"/>
    <el-table-column prop="teacher" label="任课教师" width="100"/>
    <el-table-column prop="time" label="课程时间">
      <template #default="{ row }">
        {{ formatTime(row.time) }}
      </template>
    </el-table-column>
    <el-table-column prop="intro" label="课程简介">
      <template #default="{ row }">
        <div class="intro-text">{{ row.intro }}</div>
      </template>
    </el-table-column>
    <el-table-column fixed="right" label="操作" width="120">

      <template #default="{row}">
        <el-button link type="primary" size="small" @click="deleteCourse(row.id)">
          删除
        </el-button>
        <!--        <el-button link type="primary" size="small">编辑</el-button>-->
      </template>
    </el-table-column>
  </el-table>
  <el-button class="addBtn" type="success" plain @click="isAdd = true">添加</el-button>
  <el-drawer v-model="isAdd" direction="rtl">
    <template #header>
      <h1>请输入课程信息</h1>
    </template>
    <template #default>
      <el-form :model="newCourse" ref="form">
        <el-form-item label="课程名称" prop="name" :rules="[{ required: true, message: '请输入课程名称', trigger: 'blur' }]">
          <el-input v-model="newCourse.name" />
        </el-form-item>
        <el-form-item label="任课教师" prop="teacher" :rules="[{ required: true, message: '请输入任课教师', trigger: 'blur' }]">
          <el-input v-model="newCourse.teacher" />
        </el-form-item>
        <el-form-item label="开始时间" prop="start_time" :rules="[{ required: true, message: '请选择开始时间', trigger: 'change' }]">
          <el-date-picker v-model="newCourse.start_time" type="datetime" placeholder="选择开始时间" />
        </el-form-item>
        <el-form-item label="结束时间" prop="end_time" :rules="[{ required: true, message: '请选择结束时间', trigger: 'change' }]">
          <el-date-picker v-model="newCourse.end_time" type="datetime" placeholder="选择结束时间" />
        </el-form-item>
        <el-form-item label="课程简介" prop="intro">
          <el-input type="textarea" v-model="newCourse.intro" />
        </el-form-item>
      </el-form>
    </template>
    <template #footer>
      <div style="flex: auto">
        <el-button @click="isAdd = false">取消</el-button>
        <el-button type="primary" @click="addCourse">确认</el-button>
      </div>
    </template>
  </el-drawer>
</template>

<script lang="ts" setup>
import {getCurrentInstance, onMounted, ref} from "vue";

const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况

const tableData = ref([]); // 使用 ref 定义响应式数据
const isAdd = ref<boolean>(false);
const newCourse = ref({
  name: '',
  teacher: '',
  start_time: '',
  end_time: '',
  intro: ''
});

const getCourse = () => {
  proxy?.$http.get('/course_management').then((res) => {
    tableData.value = res.data.map(course => ({
      id: course.id,
      name: course.name,
      teacher: course.teacher,
      time: [course.start_time, course.end_time],
      intro: course.intro,
    }));
  })
}

const addCourse = () => {
  proxy?.$http.put('/course_management', newCourse.value).then((res) => {
    let addData = {
      name: res.data.name,
      teacher: res.data.teacher,
      intro: res.data.intro,
      time: [res.data.start_time, res.data.end_time],
      id: res.data.id // 这里假设后端返回了新课程的 ID
    }
    console.log(addData)
    tableData.value.push(addData);
    newCourse.value = { name: '', teacher: '', start_time: '', end_time: '', intro: '' }; // 重置表单
    isAdd.value = false; // 关闭抽屉
    proxy?.$message.success('课程添加成功！');
  }).catch((error) => {
    console.error('Error adding course:', error);
    proxy?.$message.error('添加课程失败，请重试。');
  });
};


const deleteCourse = (courseId: string) => {
  // 确认删除
  const confirmed = confirm('确定要删除这门课程吗？');
  if (!confirmed) return;  // 用户取消删除操作

  proxy?.$http.delete(`/course_management?id=${courseId}`).then((res) => {
    // 从表格数据中移除已删除课程
    tableData.value = tableData.value.filter(course => course.id !== courseId);
    console.log(`Course with ID ${courseId} deleted.`);
    // 可以在这里添加提示用户删除成功的消息
    proxy?.$message.success('课程删除成功！');
  }).catch((error) => {
    console.error('Error deleting course:', error);
    // 处理错误情况，可以在这里提示用户
    proxy?.$message.error('删除课程失败，请重试。');
  });
};


const formatTime = (time: string[]) => {
  return `${time[0]} - ${time[1]}`;
};


onMounted(() => {
  getCourse()
})
</script>

<style scoped>
.intro-text {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1; /* 显示3行 */
  overflow: hidden;
  text-overflow: ellipsis; /* 超出部分用...表示 */
}
.addBtn{
  width: 100%;
  margin-top: 1rem;
}
</style>
