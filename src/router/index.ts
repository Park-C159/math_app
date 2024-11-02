import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import TruthTable from "@/views/TruthTable.vue";
import ComTheory from "@/views/ComTheory.vue";
import SymbolicLogic from "@/views/SymbolicLogic.vue";
import CourseContent from "@/views/CourseContent.vue";
import ToolBox from "@/views/ToolBox.vue";
import OperatingFloor from "@/views/OperatingFloor.vue";
import UserLoginView from "@/views/UserLogin.vue";
import UserRegist from "@/views/UserRegist.vue";
import test from '@/views/test.vue'
import TestManagement from "@/views/TestManagement.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },{
      path: '/truth',
      name: 'truth',
      component: TruthTable
    },{
      path: '/comtheory',
      name: 'comtheory',
      component: ComTheory
    },{
      path: '/symbolic',
      name: 'symbolic',
      component: SymbolicLogic,
      // meta: { hideHeaderFooter: true }
    },{
      path: '/course_content',
      name: 'course_content',
      component: CourseContent,
      // meta: { hideHeaderFooter: true }
    },{
      path: '/toolbox',
      name: 'toolbox',
      component: ToolBox,
      // meta: { hideHeaderFooter: true }
    },{
      path: '/test_management',
      name: 'test_management',
      component: TestManagement,
    },{
      path: '/operating',
      name: 'operating',
      component: OperatingFloor,
      meta: { hideHeaderFooter: true }
    },{
      path: '/test',
      name: 'test',
      component: test,
    },{
      path: '/login',
      name: 'login',
      component: UserLoginView,
    },{
      path: '/regist',
      name: 'regist',
      component: UserRegist,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue')
    }
  ]
})

export default router
