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



const app = createApp(App)

app.provide('baseURL', import.meta.env.VITE_BASE_API || 'http://localhost:5000/api/')

app.config.globalProperties.$http = axios
app.config.globalProperties.$echart = echarts;

app.use(router)
app.use(ElementPlus)
app.use(mavonEditor)
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}
// app.use

app.mount('#app')
