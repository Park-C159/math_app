<template>
  <div ref="chart" style="width: 50vw; height: 50vh;"></div>
</template>

<script>
export default {
  name: "FenbuchartComponent",
  data(){
    return {
      data: [0,0,1,1,2,2,2,2,2,2,2,2,2,2,3,4,2,1,1,3,2,4,1,5,6,6,6,6,6,6,6]
    }
  },
  props: {
    type: {
      type: String,
      default: "scatter", // 图表类型：bar、pie 等
    },
    title: {
      type: String,
      default: "", // 图表标题
    },
    seriesData: {
      type: Array,
      default: () => [], // 饼图或其他类型图表的数据
    },
  },
  mounted() {
    const chartDom = this.$refs.chart;
    const myChart = this.$echart.init(chartDom, 'dark');

    // 动态生成配置项
    const option = this.getChartOption();

    // 渲染图表
    myChart.setOption(option);

    // 窗口大小变化时自动调整
    window.addEventListener("resize", () => {
      myChart.resize();
    });
  },
  methods: {
    calculateFrequency(numbers) {
      const frequency = {};
      numbers.forEach((number) => {
        frequency[number] = (frequency[number] || 0) + 1;
      });

      // 创建二维数组
      const frequencyArray = [];
      for (const number in frequency) {
        const count = frequency[number];
        const probability = count / numbers.length;
        frequencyArray.push([parseInt(number), probability]);
      }

      return frequencyArray;
    },
    getChartOption() {
      if (this.type === "scatter") {
        let countOptionMap = this.seriesData.reduce((acc, str) => {
          acc[str] = (acc[str] || 0) + 1;
          return acc;
        }, {});

        let frequencyArray = this.calculateFrequency(this.data)
        console.log(frequencyArray)

        return {
          xAxis: {},
          yAxis: {},
          series: [
            {
              symbolSize: 20,
              data: frequencyArray,
              type: 'scatter'
            }
          ]
        }
      }
    }

  },
};
</script>
