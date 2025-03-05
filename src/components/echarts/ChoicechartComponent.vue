<template>
  <div ref="chart" style="width: 100%; height: 100%;"></div>
</template>

<script>
export default {
  name: "ChoicechartComponent",
  props: {
    type: {
      type: String,
      default: "pie", // 图表类型：bar、pie 等
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
    getChartOption() {
      if (this.type === "pie") {
        let countOptionMap = this.seriesData.reduce((acc, str) => {
          acc[str] = (acc[str] || 0) + 1;
          return acc;
        }, {});

        let countOption = Object.entries(countOptionMap).map(([name, value]) => ({ name, value }));

        return {
          tooltip: {
            trigger: 'item',
            formatter: (params) => {
              return `${params.name} : ${params.value} 人 (${params.percent}%)`;
            }
          },
          legend: {
            show: false,
            orient: 'vertical',
            left: 'left',
          },
          series: [
            {
              name: '人数',
              type: 'pie',
              radius: '50%',
              data: countOption,
              emphasis: {
                itemStyle: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
              }
            }
          ]
        };
      }
    }

  },
};
</script>
