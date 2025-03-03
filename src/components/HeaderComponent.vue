<script setup lang="ts">

import {RouterLink} from "vue-router";
import {ref, getCurrentInstance, onMounted} from 'vue'
import router from "@/router";
import {ElMessage} from "element-plus";
// 获取 Vue 实例
const instance = getCurrentInstance();
const proxy = instance?.proxy;  // 通过可选链操作符来处理 null 的情况

interface Course {
  "id": number;
  "name": string;
}

const courseNameList = ref<string[]>([]);
const courseList = ref<Course[]>([])


const getCourseName = () => {
  proxy?.$http.get('/get_course_name').then((res:any) => {
    let response = res.data;
    if(response.code === 200){
      courseList.value = response.data;
    }else{
      ElMessage({
        type: 'error',
        message: response.msg
      })
    }
    // courseNameList.value.length = 0;
    // courseNameList.value.push(...res.data)
  }).catch((err:any) => {
    ElMessage({
      type: 'error',
      message: "服务其开小差了，请联系管理员！"
    })
    console.log(err)
  })
}
onMounted(() => {
  getCourseName()
})

const activeIndex = ref('1')
const handleSelect = (key: string, keyPath: string[]) => {
  console.log(key, keyPath)
}
// 控制汉堡菜单的显示状态
const isMenuOpen = ref(false);
const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
};

const isLogin = ref(false);
const Avatar = ref('')
const userLevel = ref('')

const consoleBox = () => {
  window.open(`${window.location.origin}/operating`, '_blank');
}
const login = () => {
  router.push('/login');
}
const logout = () => {
  localStorage.removeItem('userInfo');
  localStorage.removeItem('isLogin');
  location.reload()
}
const toCourse = (courseName: string, courseId: number) => {
  // 使用 router.push 跳转到目标路由，并将 courseName 作为查询参数传递
  router.push({
    path: '/symbolic',
    query: {
      courseName, courseId
    }
  });
  // window.location.reload();
}
const toUserManage = () =>{
  router.push({
    path: '/user_management',
  })
}

onMounted(() => {
  let is_login = localStorage.getItem('isLogin') === 'true';
  let userInfo = localStorage.getItem('userInfo');
  if (is_login && userInfo != null) {
    userInfo = JSON.parse(userInfo);
  }
  Avatar.value = userInfo?.username[0]
  userLevel.value = userInfo?.role
  isLogin.value = is_login;
})

</script>

<template>
  <nav class="top-menu">
    <div class="small-screen">
      <div class="hamburger-menu left" @click="toggleMenu">
        <span class="bar"></span>
        <span class="bar"></span>
        <span class="bar"></span>
      </div>

      <div class="right">
        <img
            style="width: 50px; padding: 5px;"
            src="@/assets/images/math_white.svg"
            alt="Element logo"
        />
      </div>
    </div>
    <div class="large-screen">
      <div class="left">
        <img
            style="width: 50px; padding: 5px;"
            src="@/assets/images/math_white.svg"
            alt="Element logo"
        />
        <el-menu
            style="border-bottom: none;"
            :default-active="activeIndex"
            class="el-menu-demo"
            mode="horizontal"
            :ellipsis="false"
            @select="handleSelect"
            background-color="#1d1e28"
            text-color="#ccc"
            active-text-color="rgb(173, 145, 255)"
        >
          <el-menu-item index="1" @click="$router.push('/')">
            Home
          </el-menu-item>
          <el-menu-item
              v-for="(course, index) in courseList"
              :key="index"
              :index="index+2"
              @click="toCourse(course.name, course.id)"
          >
            {{ course.name }}
          </el-menu-item>
          <!--          <el-menu-item index="2" @click="$router.push('/symbolic')">数理逻辑</el-menu-item>-->
          <!--          <el-menu-item index="3" @click="$router.push('/comtheory')">可计算性与计算复杂性</el-menu-item>-->
<!--          <el-menu-item index="10" v-if="userLevel!='student' && userLevel!=null"-->
<!--                        @click="$router.push('/test_management')">考试-->
<!--          </el-menu-item>-->
          <el-menu-item index="11" @click="$router.push('/toolbox')">工具箱</el-menu-item>
          <el-menu-item index="12" @click="$router.push('/knowledge_graph')">知识图谱</el-menu-item>
        </el-menu>

      </div>
      <div class="right">
        <div class="use-illlustrate" @click="consoleBox" v-if="userLevel!='student' && userLevel!=null">工作台</div>
        <div class="login avatar" v-if="isLogin">
          <el-dropdown>
            <el-avatar> {{ Avatar }}</el-avatar>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="toUserManage" v-if="userLevel!='student' && userLevel!=null">用户管理</el-dropdown-item>
              </el-dropdown-menu>
              <el-dropdown-menu>
                <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>

          </el-dropdown>
        </div>
        <el-button v-else class="login" color="rgb(173, 145, 255)" @click="login" plain>登录</el-button>
      </div>


    </div>
    <el-menu
        :class="['mobile-menu', { 'open': isMenuOpen }]"
        v-if="isMenuOpen"
        style="border-right: none;"
        :default-active="activeIndex"
        class="el-menu-demo"
        mode="vertical"
        :ellipsis="false"
        @select="handleSelect"
        background-color="#1d1e28"
        text-color="#ccc"
        active-text-color="rgb(173, 145, 255)"
    >
      <el-menu-item index="1" @click="$router.push('/')">
        Home
      </el-menu-item>
      <el-menu-item index="2" @click="$router.push('/symbolic')">数理逻辑</el-menu-item>
      <el-menu-item index="3" @click="$router.push('/comtheory')">可计算性与计算复杂性</el-menu-item>
    </el-menu>

  </nav>
</template>

<style scoped>
.hamburger-menu .bar {
  display: block;
  width: 25px;
  height: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 1px;
}

a {
  color: #ccc;
}

.header-top {
  border-top: 6px solid rgb(173, 145, 255);
}

.large-screen, .small-screen {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0px 10px;
  box-shadow: 0px 0px 20px 0px rgba(0, 0, 0, 0.25);
}

.top-menu .left {
  display: flex;
}

.hamburger-menu {
  display: none;
  width: 25px;
  height: 25px;
  flex-direction: column;
  cursor: pointer;
  justify-content: space-around;
}

.top-menu .right {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.login {
  margin: 0 25px 0 25px;
}

.use-illlustrate {
  color: #ccc;
  cursor: pointer;
}

.use-illlustrate:hover {
  color: rgb(173, 145, 255);
  font-weight: 500;
}

.small-screen {
  display: none;
}

.el-avatar {
  background: darkmagenta;
  font-size: 1.3rem;
  font-weight: bold;
}

.avatar {
  cursor: pointer;
}

@media (max-width: 1000px) {
  /* 隐藏桌面端菜单 */
  .large-screen {
    display: none;
  }

  /* 显示汉堡菜单 */
  .small-screen {
    display: flex;
  }


}
</style>