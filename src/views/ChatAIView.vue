<template>
  <div>
    <h1>数学小助手</h1>
    <input v-model="message" placeholder="Enter your message" />
    <button @click="sendMessage">Send</button>

    <div>
      <h2>回复:</h2>
      <ul>
        <li v-for="(msg, index) in messages" :key="index">{{ msg }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      message: '',
      messages: [''],
      count:0
    }
  },
  mounted() {
    // 监听 WebSocket 消息
    this.$socket.on('server_response', (data) => {
      if(data == '[END]'){
        this.count ++;
        this.messages[this.count] = ''
      }else{
        if (data!=='undefined' && data!==null){
          this.messages[this.count] += data

        }
      }

    })
  },
  methods: {
    sendMessage() {
      if (this.message.trim()) {
        this.$socket.emit('user_message', this.message) // 发送消息到后端
        this.message = ''
      }
    }
  }
}
</script>
