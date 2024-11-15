<template>
    <div ref="chart" style="width: 100%; height: 200px;"></div>
</template>

<script>
export default {
  name: "EChartsExample",
  mounted() {
    // 获取 echart DOM 容器
    const chartDom = this.$refs.chart;
    const myChart = this.$echart.init(chartDom);

    // 设置图表的配置和数据
    const option = {
      title: {
        text: "示例柱状图",
      },
      tooltip: {},
      xAxis: {
        type: "category",
        data: ["苹果", "橘子", "香蕉", "葡萄", "草莓", "西瓜"],
      },
      yAxis: {
        type: "value",
      },
      series: [
        {
          name: "销量",
          type: "bar",
          data: [120, 200, 150, 80, 70, 110],
        },
      ],
    };

    // 渲染图表
    myChart.setOption(option);

    // 窗口大小变化时自动调整
    window.addEventListener("resize", () => {
      myChart.resize();
    });
  },
};
</script>
