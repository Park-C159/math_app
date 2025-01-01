<script setup lang="ts">
import EmojiPicker from './EmojiPicker.vue';
import FileUploader from "./FileUploader.vue";

interface Props {
  showRight?: boolean; // 控制是否显示右侧按钮组
  onEmojiSelect?: (emoji: string) => void;
  onFileUpload?: (content: string) => void;
  onSubmit?: () => void;
  onCancel?: () => void;
}

const props = withDefaults(defineProps<Props>(), {
  showRight: true
});
</script>

<template>
  <div class="editor-buttons">
    <div class="editor-buttons-left">
      <EmojiPicker @select="(emoji) => props.onEmojiSelect?.(emoji)"/>
      <FileUploader
          :show-progress="true"
          @upload-success="(content) => props.onFileUpload?.(content)"
      />
    </div>
    <div v-if="showRight" class="editor-buttons-right">
      <el-button plain icon="Promotion" @click="props.onSubmit?.()"/>
      <el-button icon="Close" @click="props.onCancel?.()"/>
    </div>
  </div>
</template>

<style scoped>
.editor-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8px 0;
}

.editor-buttons-left {
  display: flex;
  gap: 8px;
}

.editor-buttons-right {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>