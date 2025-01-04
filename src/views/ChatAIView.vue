<template>
  <div class="chat">
    <h1>数学小助手</h1>
    <div class="message">
      <ul>
        <li
            v-for="(msg, index) in messages"
            :key="index"
            :class="{ 'user-message': index % 2 !== 0, 'robot-message': index % 2 === 0 }"
            class="single-msg"
        >
          <div class="message-box" v-if="msg !== ''">
            {{ msg }}
          </div>
        </li>
      </ul>
    </div>
    <div class="user-input">
      <el-input v-model="message" type="textarea" :row="2" placeholder="请输入您的问题"></el-input>
      <el-button
          :disabled="isGenerating"
          @click="sendMessage"
          type="success"
          style="margin-left: 4px"
          size="large"
      >发送</el-button>
    </div>
  </div>
</template>

<script>

export default {
  data() {
    return {
      message: "",
      messages: ["你好，我是数学小助手，请问有什么可以帮助你的吗？","user1","assistant1","user2","assistant2"],
      count: 1,
      isGenerating: false,
      sessionId: "29b2fbac-1337-4e5e-ae93-ea38e08bd9aa",
    };
  },
  mounted() {
    this.$socket.on("session_id", (session_id) => {
      localStorage.setItem("session_id", session_id);
      this.sessionId = session_id;
    });

    // 监听 WebSocket 消息
    this.$socket.on("server_response", (data) => {
      if (data == "[END]") {
        this.count++;
        this.isGenerating = false;
        this.saveMessageToDB();

      } else {
        if (data !== "undefined" && data !== null) {
          this.messages[this.count] += data;
        }
      }
    });

    this.saveMessageToDB();
  },
  methods: {
    sendMessage() {
      if (this.message.trim()) {
        this.messages.push(this.message);
        this.messages.push("");
        this.count++;
        this.$socket.emit("user_message", this.message); // 发送消息到后端
        this.isGenerating = true;
        this.message = "";
      }
    },
    saveMessageToDB() {
      const userInfo = JSON.parse(localStorage.getItem("userInfo"));
      const user_id = userInfo?.id || null;
      let save_messages = []
      let len = this.messages.length;

      for (let i = 0; i < len; i++) {
        if(i > len - 1 - 2){
          save_messages.push({
            content: this.messages[i],
            type: i %2 === 0 ? "assistant": "user"
          })
        }
      }

      const sessionData = {
        session_id: this.sessionId,
        user_id: user_id,
        messages: save_messages,
      };

      this.$http
          .put("/save_messages", sessionData)
          .then((response) => {
            console.log("Messages saved:", response.data);
          })
          .catch((error) => {
            console.error("Error saving messages:", error);
          });
    },
  },
};
</script>

<style scoped>
.chat {
  padding: 10px 4rem;
  text-align: center;
}

.user-input {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.message {
  height: calc(100vh - 250px - 20px - 52px - 48px - 20px);
  overflow-y: auto;
  margin-bottom: 20px;
}

.message-box {
  padding: 10px 15px;
  border-radius: 12px;
  max-width: 80%;
  word-wrap: break-word;
}

.user-message {
  text-align: right;
  display: flex;
  justify-content: flex-end;
}

.robot-message {
  text-align: left;
}

.user-message .message-box {
  background-color: #409eff;
  color: white;
}

.robot-message .message-box {
  background-color: #f4f4f4;
  color: #333;
}

.single-msg {
  margin-top: 10px;
}

.el-input {
  width: 80%;
}

.el-button {
  width: 18%;
}
</style>
