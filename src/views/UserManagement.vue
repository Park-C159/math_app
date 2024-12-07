<script setup lang="ts">
import {ref, getCurrentInstance, onMounted} from 'vue'
import {ElMessage} from "element-plus";
// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况

interface CourseInfo {
  course_id: number;
  course_name: string;
}

interface Users {
  id: number,
  username: string,
  user_id: string,
  role: string,
  phone_number: string,
  course_infos: CourseInfo[]
}

const UserList = ref<Users[]>([]);
const centerDialogVisible = ref(false);
const ModUser = ref<Users>()
const courseList = ref<CourseInfo[]>([])

const getUsers = () => {
  proxy?.$http.get('/users').then((res) => {
    let response = res.data;
    if (response.code === 200) {
      let users: Users[] = response.data
      UserList.value = users;
    }
  }).catch((e: Error) => {
    console.error(e)
  })
}

const deleteUser = (user_id: number) => {
  proxy?.$http.delete(`users?user_id=${user_id}`).then((res) => {
    let response = res.data;
    if (response.code === 200) {
      getUsers()
      ElMessage({
        type: 'success',
        message: "删除成功！"
      })
    } else {
      ElMessage({
        type: "warning",
        message: response.data.msg
      })
    }
  }).catch((e: Error) => {
    ElMessage({
      type: 'error',
      message: "服务器开小差了，请联系管理员。"
    })
    console.error(e)
  })
}

const updateUser = (user: Users) => {
  centerDialogVisible.value = true
  ModUser.value = user
}

const getCourseList = () => {
  proxy?.$http.get('/get_course_name').then((res) => {
    let response = res.data;
    if (response.code === 200) {
      courseList.value = response.data.map((data: any) => {
        return {
          course_id: data.id,
          course_name: data.name,
        }
      });
    } else {
      ElMessage({
        type: 'error',
        message: response.msg
      })
    }

  }).catch((e: Error) => {
    ElMessage({
      type: 'error',
      message: "服务器开小差了，请联系管理员！"
    })
    console.error(e)
  })
}

const cancelUpdate = () => {
  getUsers()
  centerDialogVisible.value = false
}
const confirmUpdate = async () => {
  await proxy?.$http.put("/users", ModUser.value).then((res) => {
    let response = res.data;
    if (response.code === 200) {
      ElMessage({
        type: "success",
        message: "修改成功！"
      })
    } else {
      ElMessage({
        type: "warning",
        message: response.msg
      })
    }
    // 成功后的处理逻辑
  }).catch((e: Error) => {
    ElMessage({
      type: 'error',
      message: "服务器开小差了，请联系管理员！"
    })
    console.error(e)
  })


  getUsers()
  centerDialogVisible.value = false

}

onMounted(() => {
  getUsers()
  getCourseList()
})
</script>

<template>
  <div>
    <el-button size="small">批量导入</el-button>
    <table width="100%">
      <thead>
      <tr>
        <th>姓名</th>
        <th>学号</th>
        <th>用户权限</th>
        <th>所属课程</th>
        <th>操作</th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="(user, index) in UserList" :key="index">
        <td>{{ user.username }}</td>
        <td>{{ user.user_id }}</td>
        <td>{{ user.role }}</td>
        <td>
          <div>
            <span v-if="user.course_infos.length === 0">无</span>
            <span v-else>{{ user.course_infos.map(course => course.course_name).join(', ') }}</span>
          </div>
        </td>
        <td>
          <el-button link type="primary" @click="updateUser(user)"
                     :disabled="user.role!='student' && user.role!='teacher'">修改
          </el-button>
          <el-button link type="danger" @click="deleteUser(user.id)" :disabled="user.role!='student'">删除</el-button>
        </td>

      </tr>
      </tbody>
    </table>
    <!--    修改用户   -->
    <el-dialog v-model="centerDialogVisible" title="请修改用户信息" width="500">
      <el-form :model="ModUser" label-width="auto">
        <el-form-item label="姓名">
          <el-input v-model="ModUser.username"></el-input>
        </el-form-item>
        <el-form-item label="学号">
          <el-input v-model="ModUser.user_id"></el-input>
        </el-form-item>
        <el-form-item label="用户权限">
          <el-select v-model="ModUser.role">
            <el-option label="admin" value="admin"/>
            <el-option label="teacher" value="teacher"/>
            <el-option label="student" value="student"/>
          </el-select>
        </el-form-item>
        <el-form-item label="所属课程">
          <el-select multiple v-model="ModUser.course_infos">
            <el-option v-for="item in courseList" :label="item.course_name" :value="item"/>
          </el-select>
        </el-form-item>

      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelUpdate">取消</el-button>
          <el-button type="primary" @click="confirmUpdate">
            确认
          </el-button>
        </div>
      </template>
    </el-dialog>

  </div>
</template>

<style scoped>
table {
  text-align: center;
}
</style>