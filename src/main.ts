import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import axios from "./services/request"
import mavonEditor from 'mavon-editor'
import 'mavon-editor/dist/css/index.css'
import * as echarts from 'echarts'
import { io } from 'socket.io-client'

// 创建 WebSocket 连接实例
const socket = io('http://localhost:5000/chat_ai', {
    transports: ['websocket'], // 强制使用 WebSocket 协议
    autoConnect: true, // 自动连接
})

// 创建 Vue 应用
const app = createApp(App)

// 全局注入 WebSocket 实例
app.config.globalProperties.$socket = socket

// 注册其他插件
app.provide('baseURL', import.meta.env.VITE_BASE_API || 'http://localhost:5000/api/')
app.config.globalProperties.$http = axios
app.config.globalProperties.$echart = echarts
app.use(router)
app.use(ElementPlus)
app.use(mavonEditor)

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

app.mount('#app')
