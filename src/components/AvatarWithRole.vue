<template>
  <div class="discussion-avatar" style="position: relative; display: inline-block;">
    <span
        class="role-tag"
        :style="{
        position: 'absolute',
        top: 'calc(var(--el-avatar-size, 40px) * 0.7)',
        left: 'calc(var(--el-avatar-size, 40px) * 0.7)',
        fontSize: 'calc(var(--el-avatar-size, 40px) / 5)',
        width: 'calc(var(--el-avatar-size, 40px) / 3)',
        height: 'calc(var(--el-avatar-size, 40px) / 3)',
        lineHeight: 'calc(var(--el-avatar-size, 40px) / 3)',
        backgroundColor: roleColor,
        color: 'white',
        textAlign: 'center',
        borderRadius: '50%',
        zIndex: '1'
      }"
    >
      {{ roleText }}
    </span>
    <div
        class="avatar-text"
        :style="{
        width: 'var(--el-avatar-size, 40px)',
        height: 'var(--el-avatar-size, 40px)',
        borderRadius: '50%',
        backgroundColor: '#e5e5e5',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: 'calc(var(--el-avatar-size, 40px) / 2)',
        color: '#333'
      }"
    >
      {{ avatarText }}
    </div>
  </div>
</template>

<script>
import {defineComponent} from 'vue';

export default defineComponent({
  name: 'AvatarWithRole',
  props: {
    // Expecting a 'replier_role' prop to define the role of the user
    Role: {
      type: String,
      required: true
    },
    userName: {
      type: String,
      required: true
    }
  },
  computed: {
    // Compute the role color based on the role
    roleColor() {
      return this.getRoleColor(this.Role);
    },
    // Compute the role text to be displayed in the circle
    roleText() {
      return this.getRoleText(this.Role);
    },
    // Extract the first letter or character from userName
    avatarText() {
      return this.userName.charAt(0);
    }
  },
  methods: {
    // Define your logic to get the role color based on the role
    getRoleColor(role) {
      const colors = {
        admin: 'red',
        teacher: 'blue',
        student: 'green'
      };
      return colors[role] || 'green';
    },
    // Define your logic to get the role text
    getRoleText(role) {
      const roleTexts = {
        admin: '管',
        teacher: '师',
        student: '学'
      };
      return roleTexts[role] || '学';
    }
  }
});
</script>

<style scoped>
.discussion-avatar {
  display: inline-block;
  position: relative;
}

.role-tag {
  position: absolute;
  top: calc(var(--el-avatar-size, 40px) * 0.7);
  left: calc(var(--el-avatar-size, 40px) * 0.7);
  font-size: calc(var(--el-avatar-size, 40px) / 5);
  width: calc(var(--el-avatar-size, 40px) / 3);
  height: calc(var(--el-avatar-size, 40px) / 3);
  line-height: calc(var(--el-avatar-size, 40px) / 3);
  background-color: #f00;
  color: white;
  text-align: center;
  border-radius: 50%;
  z-index: 1;
}

.avatar-text {
  display: flex;
  justify-content: center;
  align-items: center;
  text-transform: uppercase;
}
</style>
