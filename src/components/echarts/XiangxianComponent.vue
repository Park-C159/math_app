<template>
  <div ref="chart" style="width: 100%; height: 100%;"></div>
</template>

<script>
export default {
  name: "ChoicechartComponent",
  data() {
    return {
      data: [{
        question_id: 1,
        question_text: "已知",
        question_type: "proof",
        user_scores: [3, 3, 3, 1, 2, 1, 4]
      }]
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
    isTotal: {
      type: Boolean,
      default: false,
    }
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
      let scores = []
      this.seriesData.forEach(item => {
        if(item.question_type!=="choice")
          scores.push(item.user_scores)
      })

      return {
        title: [
          {
            text: this.title,
            left: 'center'
          },
          {
            text: 'upper: Q3 + 1.5 * IQR \nlower: Q1 - 1.5 * IQR',
            borderColor: '#999',
            borderWidth: 1,
            textStyle: {
              fontWeight: 'normal',
              fontSize: 14,
              lineHeight: 20
            },
            left: '10%',
            top: '90%'
          }
        ],
        dataset: [
          {
            // prettier-ignore
            source: scores
          },
          {
            transform: {
              type: 'boxplot',
              config: {
                itemNameFormatter: (param) => {
                  console.log(param)
                  let val = param.value + 1
                  return "主观：" + val
                }
              }
            }
          },
          {
            fromDatasetIndex: 1,
            fromTransformResult: 1
          }
        ],
        tooltip: {
          trigger: 'item',
          axisPointer: {
            type: 'shadow'
          }
        },
        grid: {
          left: '10%',
          right: '10%',
          bottom: '15%'
        },
        xAxis: {
          type: 'category',
          boundaryGap: true,
          nameGap: 30,
          splitArea: {
            show: false
          },
          splitLine: {
            show: false
          }
        },
        yAxis: {
          type: 'value',
          name: '分数',
          splitArea: {
            show: true
          }
        },
        series: [
          {
            name: 'boxplot',
            type: 'boxplot',
            datasetIndex: 1
          },
          {
            name: 'outlier',
            type: 'scatter',
            datasetIndex: 2
          }
        ]
      };
    }


  },
};
</script>
