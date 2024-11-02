/// <reference types="vite/client" />
interface ImportMetaEnv {
    readonly VUE_APP_BASE_API: string;
}

interface ImportMeta {
    readonly env: ImportMetaEnv;
}
