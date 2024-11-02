// src/shims-vue.d.ts
import { AxiosInstance } from 'axios';

declare module '@vue/runtime-core' {
    interface ComponentCustomProperties {
        $http: AxiosInstance;  // 为 $http 添加类型
    }
}
