<script setup lang="ts">
import {ref, getCurrentInstance, onMounted} from "vue";
import {useRoute} from "vue-router";
import {ElMessage} from "element-plus"

const instance = getCurrentInstance()
const proxy = instance?.proxy;
const route = useRoute()

interface Exam {
  course_id: number;
  created_at: string;
  end_time: string;
  id: number;
  is_checked: boolean;
  name: string;
  start_time: string;
}

interface UserInfoInterface {
  extra: string;         // 额外信息，可以为空字符串
  id: number;            // 用户ID
  phone_number: string;  // 用户的手机号
  role: string; // 用户角色，可以是 'admin' 或 'user'
  user_id: string;       // 用户唯一标识符
  username: string;      // 用户名
}

const ExamList = ref<Exam[]>([]);
const UserInfo = ref<UserInfoInterface>();
const isLogin = ref(false);
const userLevel = ref('')


const getExamList = () => {
  proxy?.$http.get('/exams_list', {
    params: {
      course_id: route.query.course_id,
    }
  }).then((res) => {
    let response = res.data;
    if (response.code === 200) {
      ExamList.value = response.data
      // ElMessage.success(response.msg)
    } else {
      ElMessage({
        message: response.msg,
        type: 'error',
      })
    }
  }).catch((err) => {
    console.error("获取考试列表失败：", err)
  })
}
// 检查当前时间是否在考试时间范围内
const isWithinExamTime = (exam: Exam) => {
  const currentTime = new Date();  // 获取当前时间
  const startTime = new Date(exam.start_time);  // 转换考试开始时间为 Date 对象
  const endTime = new Date(exam.end_time);  // 转换考试结束时间为 Date 对象

  return currentTime >= startTime && currentTime <= endTime;
}

const toTestCenter = (exam_id: number, end_time: string, exam_name: string) => {
  window.open(`${window.location.origin}/test_center?exam_id=${exam_id}&end_time=${end_time}&exam_name=${exam_name}`, '_blank')
}
const toBrowserExam = (exam_id: number, exam_name: string) => {
  window.open(`${window.location.origin}/browser_exam?exam_id=${exam_id}&exam_name=${exam_name}`, '_blank')
}
const toCheckCenter = (exam_id: number, exam_name: string) => {
  window.open(`${window.location.origin}/check_test?exam_id=${exam_id}&exam_name=${exam_name}&course_id=${route.query.course_id}`, '_blank')
}
const toMarkCenter = (exam_id: number, exam_name: string) => {
  window.open(`${window.location.origin}/mark_center?exam_id=${exam_id}&exam_name=${exam_name}&course_id=${route.query.course_id}`, '_blank')
}
const deleteExam = (exam_id: number) => {
  proxy?.$http.delete("exams", {
    params: {
      exam_id: exam_id,
    }
  }).then((res: any) => {
    let response = res.data;
    if (response.code === 200) {
      getExamList()
      ElMessage({
        type: 'success',
        message: response.msg
      })
    } else {
      ElMessage({
        type: 'error',
        message: response.msg,
      })
    }
  }).catch((err: any) => {
    console.error(err)
    ElMessage({
      type: 'error',
      message: "服务器开小差了，请联系管理员！",
    })
  })
}

onMounted(() => {
  let is_login = localStorage.getItem('isLogin') === 'true';
  let userInfo = localStorage.getItem('userInfo');
  if (userInfo) {
    UserInfo.value = JSON.parse(userInfo) as UserInfoInterface;
    userLevel.value = UserInfo.value.role;
  }
  isLogin.value = is_login;
  getExamList()
})

</script>

<template>
  <div class="container">
    <table class="test-table">
      <thead>
      <tr>
        <td>名称</td>
        <td>发布时间</td>
        <td>考试时间</td>
        <td>操作</td>
      </tr>
      </thead>
      <tbody>
      <tr v-for="(exam, index) in ExamList" :key="index">
        <td>{{ exam.name }}</td>
        <td>{{ exam.created_at }}</td>
        <td>{{ exam.start_time }}-{{ exam.end_time }}</td>
        <td>
          <el-button
              type="primary"
              link
              :disabled="!isWithinExamTime(exam)"
              @click="toTestCenter(exam.id, exam.end_time, exam.name)"
          >
            进入考试
          </el-button>
          <el-button
              type="primary"
              link
              :disabled="!exam.is_checked"
              @click="toBrowserExam(exam.id, exam.name)"

          >
            查看试卷
          </el-button>
          <el-button
              type="primary"
              link
              :disabled="UserInfo?.role==='student'"
              v-if="userLevel!='student' && userLevel!='' && userLevel!=null"
              @click="toCheckCenter(exam.id, exam.name)"

          >
            阅卷中心
          </el-button>
          <el-button
              type="primary"
              link
              :disabled="UserInfo?.role==='student'"
              v-if="userLevel!='student' && userLevel!='' && userLevel!=null"
              @click="toMarkCenter(exam.id, exam.name)"

          >
            成绩中心
          </el-button>
          <el-button
              type="primary"
              link
              :disabled="UserInfo?.role==='student'"
              v-if="userLevel!='student' && userLevel!='' && userLevel!=null"
              @click="deleteExam(exam.id)"

          >
            删除
          </el-button>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.test-table {
  width: 100%;
}
</style>