// src/service/request.ts
import axios from 'axios';
import type { AxiosInstance } from 'axios';

const instance: AxiosInstance = axios.create({
    baseURL: import.meta.env.VITE_BASE_API || 'http://localhost:5000/api/',  // 使用环境变量
    timeout: 10000,  // 请求超时时间
    headers: {
        'Content-Type': 'application/json',
    },
});

export default instance;
