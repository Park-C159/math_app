<script setup lang="ts">
import {ref} from 'vue'
import {ElButton, ElPopover} from 'element-plus'

interface Props {
  width?: number
}

interface Emits {
  (e: 'select', emoji: string): void
}

const props = withDefaults(defineProps<Props>(), {
  width: 300
})

const emit = defineEmits<Emits>()

// 表情包分类数组
const emojiCategories = [
  {
    name: '😀',
    list: [
      "😀", "😁", "😂", "🤣", "😃", "😄", "😅", "😆", "😉", "😊",
      "😋", "😎", "😍", "😘", "🥰", "😗", "😙", "😚", "☺", "🙂",
      "🤗", "🤩", "🤔", "🤨", "😐", "😑", "😶", "🙄", "😏", "😣",
      "😥", "😮", "🤐", "😯", "😪", "😫", "🥱", "😴", "😌", "😛"
    ]
  },
  {
    name: '🐶',
    list: [
      "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
      "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆",
      "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋"
    ]
  },
  {
    name: '🍎',
    list: [
      "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒",
      "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬",
      "🥒", "🌶", "🌽", "🥕", "🥔", "🍠", "🥐", "🥯", "🍞", "🥖"
    ]
  },
  {
    name: '❤️',
    list: [
      "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔",
      "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟", "☮️",
      "✝️", "☪️", "🕉", "☸️", "✡️", "🔯", "🕎", "☯️", "☦️", "🛐"
    ]
  }
]

const currentCategoryIndex = ref(0)

const handleEmojiSelect = (emoji: string) => {
  emit('select', emoji)
}

const changeCategory = (index: number) => {
  currentCategoryIndex.value = index
}
</script>

<template>
  <el-popover
      placement="bottom"
      :width="width"
      trigger="click"
  >
    <template #reference>
      <el-button>
        <svg x="1735548720998" class="icon" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
             p-id="2115" width="20" height="20">
          <path
              d="M512 832c-176.448 0-320-143.552-320-320S335.552 192 512 192s320 143.552 320 320-143.552 320-320 320m0-704C300.256 128 128 300.256 128 512s172.256 384 384 384 384-172.256 384-384S723.744 128 512 128"
              fill="#bfbfbf" p-id="2116"></path>
          <path
              d="M700.64 580.288a32 32 0 0 0-43.712 11.68A160.608 160.608 0 0 1 518.304 672a160.576 160.576 0 0 1-138.592-80 32 32 0 0 0-55.424 32.032 224.896 224.896 0 0 0 194.016 112 224.768 224.768 0 0 0 194.016-112 32 32 0 0 0-11.68-43.744M384 512a32 32 0 0 0 32-32v-96a32 32 0 0 0-64 0v96a32 32 0 0 0 32 32M640 512a32 32 0 0 0 32-32v-96a32 32 0 0 0-64 0v96a32 32 0 0 0 32 32"
              fill="#bfbfbf" p-id="2117"></path>
        </svg>
      </el-button>
    </template>

    <div class="emoji-picker-container">
      <!-- 表情显示区域 -->
      <div class="emoji-container">
        <span
            v-for="emoji in emojiCategories[currentCategoryIndex].list"
            :key="emoji"
            class="emoji-item"
            @click="handleEmojiSelect(emoji)"
        >
          {{ emoji }}
        </span>
      </div>

      <!-- 分类切换按钮 -->
      <div class="category-buttons">
        <el-button
            v-for="(category, index) in emojiCategories"
            :key="index"
            size="small"
            :type="currentCategoryIndex === index ? 'primary' : ''"
            @click="changeCategory(index)"
        >
          {{ category.name }}
        </el-button>
      </div>
    </div>
  </el-popover>
</template>

<style scoped>
.emoji-picker-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.emoji-container {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 8px;
  padding: 8px;
  height: 200px;
  overflow-y: auto;
}

.emoji-container::-webkit-scrollbar {
  width: 6px;
}

.emoji-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.emoji-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.emoji-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.emoji-item {
  cursor: pointer;
  text-align: center;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.emoji-item:hover {
  background-color: #f5f7fa;
}

.category-buttons {
  display: flex;
  gap: 8px;
  padding: 0 8px 8px 8px;
  flex-wrap: wrap;
  justify-content: center;
}

.category-buttons .el-button {
  margin: 0;
}
</style>