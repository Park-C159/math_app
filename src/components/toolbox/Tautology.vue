<template>
  <div class="calculator">
    <h1 style="text-align: center">重言式计算器</h1>
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
        <el-form-item label="表达式">
          <el-input
              v-model="form.expr1"
              ref="expr1"
              placeholder="例如: p ∨ ¬p"
              @focus="currentInput = 'expr1'"
          ></el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm">检查重言式</el-button>
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
          v-if="isTautology !== null"
          :icon="isTautology ? 'success' : 'error'"
          :title="isTautology ? '重言式' : '非重言式'"
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
      },
      currentInput: 'expr1', // 当前输入框
      isTautology: null, // 等值判断结果
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
      if (this.form.expr1) {
        this.$http.get("is_tautology", {
          params: this.form,
        }).then((response) => {
          let data = response.data;
          this.isTautology = data.is_tautology;
          this.truthTable = data.truth_table;
          console.log(data);

        })
      } else {
        this.isTautology = null;
      }
    },
    resetForm() {
      // 重置表单和结果
      this.form.expr1 = '';
      this.form.expr2 = '';
      this.isTautology = null;
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
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
}
</style>
