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
    <el-avatar :icon="UserFilled"/>
  </div>
</template>

<script>
import {defineComponent, computed} from 'vue';
import {UserFilled} from '@element-plus/icons-vue'; // Assuming you are using Element Plus

export default defineComponent({
  name: 'AvatarWithRole',
  props: {
    // Expecting a 'replier_role' prop to define the role of the user
    replierRole: {
      type: String,
      required: true
    }
  },
  components: {
    UserFilled
  },
  computed: {
    UserFilled() {
      return UserFilled
    },
    // Compute the role color based on the role
    roleColor() {
      return this.getRoleColor(this.replierRole);
    },
    // Compute the role text to be displayed in the circle
    roleText() {
      return this.getRoleText(this.replierRole);
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
      return roleTexts[role] || 'student';
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
</style>
