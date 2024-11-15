<template>
  <div ref="chart" style="width: 100%; height: 100%;"></div>
</template>

<script>
export default {
  name: "EChartsComponent",
  props: {
    type: {
      type: String,
      default: "pie", // 图表类型：bar、pie 等
    },
    title: {
      type: String,
      default: "默认标题", // 图表标题
    },
    xData: {
      type: Array,
      default: () => [], // x 轴数据
    },
    yData: {
      type: Array,
      default: () => [], // y 轴数据，仅柱状图需要
    },
    seriesData: {
      type: Array,
      default: () => [], // 饼图或其他类型图表的数据
    },
  },
  mounted() {
    const chartDom = this.$refs.chart;
    const myChart = this.$echart.init(chartDom);

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
      if (this.type === "bar") {
        return {
          title: {
            text: this.title,
          },
          tooltip: {},
          xAxis: {
            type: "category",
            data: this.xData,
          },
          yAxis: {
            type: "value",
          },
          series: [
            {
              name: "销量",
              type: "bar",
              data: this.yData,
            },
          ],
        };
      } else if (this.type === "pie") {
        return {
          title: {
            text: this.title,
            left: "center",
          },
          tooltip: {
            trigger: "item",
          },
          series: [
            {
              name: this.title,
              type: "pie",
              radius: "50%",
              data: this.seriesData,
              emphasis: {
                itemStyle: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: "rgba(0, 0, 0, 0.5)",
                },
              },
            },
          ],
        };
      }
    },
  },
};
</script>
