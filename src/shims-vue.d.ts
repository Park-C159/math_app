// src/shims-vue.d.ts
import { AxiosInstance } from 'axios';

// declare module '@vue/runtime-core' {
//     interface ComponentCustomProperties {
//         $http: AxiosInstance;  // 为 $http 添加类型
//     }
// }
// vue-shims.d.ts
declare module "*.vue" {
    import { DefineComponent } from "vue";
    const component: DefineComponent<{}, {}, any>;
    export default component;
}
declare module '@vue/runtime-core' {
    interface ComponentCustomProperties {
        $http: typeof AxiosInstance;
    }
}
