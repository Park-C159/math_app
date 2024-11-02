<template>
  <div class="calculator">
    <h1 style="text-align: center">等值演算计算器</h1>
    <el-main>
      <!-- 符号按钮 -->
      <div class="symbols">
        <span>插入符号:</span>
        <div class="buttons">
          <el-button
              v-for="symbol in logicSymbols"
              :key="symbol.symbol"
              @click="insertSymbol(symbol.symbol)"
              color="rgb(173, 145, 255)"
              plain
          >
            {{ symbol.symbol }} ({{ symbol.description }})
          </el-button>
        </div>
      </div>

      <!-- 输入表单 -->
      <el-form :model="form" @submit.native.prevent="submitForm">
        <el-form-item label="输入表达式1">
          <el-input
              v-model="form.expr1"
              ref="expr1"
              placeholder="例如: p ∨ q"
              @focus="currentInput = 'expr1'"
          ></el-input>
        </el-form-item>

        <el-form-item label="输入表达式2">
          <el-input
              v-model="form.expr2"
              ref="expr2"
              placeholder="例如: ¬(¬p ∧ ¬q)"
              @focus="currentInput = 'expr2'"
          ></el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm">检查等值性</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
      <table class="truthTable">
        <thead>
          <tr>
            <th v-for="(header, index) in truthTable[0]" :key="index">
              {{ header }}
            </th>
          </tr>
        </thead>
        <tbody>
        <tr v-for="(row, rowIndex) in truthTable.slice(1)" :key="rowIndex">
          <td v-for="(cell, cellIndex) in row" :key="cellIndex">
            {{ cell ? "真" :"假"}}
          </td>
        </tr>
        </tbody>
      </table>


      <!-- 结果显示 -->
      <el-result
          v-if="isEquivalent !== null"
          :icon="isEquivalent ? 'success' : 'error'"
          :title="isEquivalent ? '等值' : '不等值'"
          description="表达式判断结果"
      ></el-result>
    </el-main>
  </div>
</template>

<script>
export default {
  data() {
    return {
      truthTable: [],
      form: {
        expr1: '',
        expr2: ''
      },
      currentInput: 'expr1', // 当前输入框
      isEquivalent: null, // 等值判断结果
      logicSymbols: [
        {symbol: '∧', description: '与'},
        {symbol: '∨', description: '或'},
        {symbol: '¬', description: '非'},
        {symbol: '→', description: '蕴含'},
        {symbol: '↔', description: '等价'}
      ]
    };
  },
  methods: {
    insertSymbol(symbol) {
      // 获取当前输入框的引用
      const inputRef = this.$refs[this.currentInput].$refs.input;
      if (inputRef) {
        // 获取光标位置和输入框的值
        const start = inputRef.selectionStart;
        const end = inputRef.selectionEnd;
        const value = this.form[this.currentInput];

        // 在光标位置插入符号
        this.form[this.currentInput] =
            value.substring(0, start) + symbol + value.substring(end);

        // 更新光标位置
        this.$nextTick(() => {
          inputRef.setSelectionRange(start + symbol.length, start + symbol.length);
          inputRef.focus();
        });
      }
    },
    submitForm() {
      // 模拟等值性检查
      if (this.form.expr1 && this.form.expr2) {
        this.$http.get("is_equivalent", {
          params: this.form,
        }).then((response) => {
          let data = response.data;
          this.isEquivalent = data.is_equivalent;
          this.truthTable = data.truth_table;
          console.log(data);

        })
      } else {
        this.isEquivalent = null;
      }
    },
    resetForm() {
      // 重置表单和结果
      this.form.expr1 = '';
      this.form.expr2 = '';
      this.isEquivalent = null;
      this.truthTable = [];
    }
  }
};
</script>

<style scoped>

.truthTable{
  margin-top: 2rem;
  width: 100%;
  box-shadow: 0 0 20px 0 green;
  padding: 2rem;
}
.truthTable thead{
  line-height: 3rem;
  font-size: large;
  font-weight: bold;
}
.truthTable td{
  text-align: center;
}
.calculator {
  width: 600px;
  margin: 0 auto;
}

.symbols {
  margin-bottom: 20px;
}

.buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: space-between;
}
</style>
