<template>
  <div ref="chart" style="width: 100%; height: 100%;"></div>
</template>

<script>
export default {
  name: "FenbuchartComponent",
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
    // 计算正态分布拟合曲线数据
    generateNormalDistributionData(data) {
      // 计算均值
      const mean = data.reduce((sum, value) => sum + value, 0) / data.length;

      // 计算标准差
      const variance = data.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) / data.length;
      const stdDev = Math.sqrt(variance);

      // 生成正态分布曲线数据
      const normalDistribution = [];
      for (let x = Math.min(...data) - 1; x <= Math.max(...data) + 1; x += 0.1) {
        const y = (1 / (stdDev * Math.sqrt(2 * Math.PI))) * Math.exp(-Math.pow(x - mean, 2) / (2 * variance));
        normalDistribution.push([x, y]);
      }

      return [normalDistribution, mean, variance]
    },
    getChartOption() {

      if (this.type === "scatter") {
        let countOptionMap = this.seriesData.reduce((acc, str) => {
          acc[str] = (acc[str] || 0) + 1;
          return acc;
        }, {});

        let frequencyArray = this.calculateFrequency(this.seriesData)

        return {
          title: {
            text: this.title,
            left: 'center',
          },
          xAxis: {},
          yAxis: {},
          series: [
            {
              name: "分布",
              symbolSize: 5,
              data: frequencyArray,
              type: 'scatter',
              itemStyle: {
                color: 'red'
              }
            }
          ]
        }
      } else if (this.type === "scatter-line") {
        let countOptionMap = this.seriesData.reduce((acc, str) => {
          acc[str] = (acc[str] || 0) + 1;
          return acc;
        }, {});

        // 计算正态分布拟合曲线数据
        const [normalDistributionData, mean, variance] = this.generateNormalDistributionData(this.seriesData);
        let frequencyArray = this.calculateFrequency(this.seriesData)

        return {
          title: {
            text: this.title,
            left: 'center',
          },
          xAxis: {
            type: 'value',
            min: 0,
            max: 100,
          },
          yAxis: {
            type: 'value',
          },
          tooltip: {
            trigger: 'item',
            formatter: function (params) {
              if (params.componentSubType === "line") {
                console.log(mean, variance)
                return `均值: ${mean.toFixed(2)}<br>标准差:${variance.toFixed(2)}`;
              }
              return params.value[0].toFixed(1) + '分：' + (params.value[1] * 100).toFixed(2) + "%";
            }
          },
          series: [
            {
              name: "分布",
              symbolSize: 5,
              data: frequencyArray,
              type: 'scatter',
              itemStyle: {
                color: 'red'
              }
            },
            {
              name: "正态分布拟合",
              type: "line",
              symbolSize: 2,
              data: normalDistributionData,
              smooth: true,
              itemStyle:{
                color: '#fff'
              },
              lineStyle: {
                color: 'white' // 设置正态分布曲线为白色
              }
            }
          ]
        };
      }
    }

  },
};
</script>
