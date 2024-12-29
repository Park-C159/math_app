<template>
  <div ref="chart" style="width: 100%; height: 100%;"></div>
</template>

<script>
export default {
  name: "EChartsExample",
  props: {
    title: {
      type: String,
      default: "关系图"
    }
  },
  data() {
    return {
      graph: null, // 用来存储图表数据
      nodeIndexMap: {},
      updateLinks: []
    };
  },
  methods: {
    // 异步加载图表数据
    async loadKnowledgeGraph() {
      await this.$http.get('/knowledge_graph').then((response) => {
        let res = response.data;
        if (res.code === 200) {
          let data = res.data;
          this.graph = data;
          data.nodes.forEach((node, index) => {
            this.nodeIndexMap[node.id] = index;
          })
          this.updateLinks = data.links.map(link=>{
            return {
              ...link,
              source: this.nodeIndexMap[link.source],
              target: this.nodeIndexMap[link.target]
            }
          })
        }
      })
    },

    // 初始化 ECharts 图表
    initChart() {
      // 获取 echart DOM 容器
      const chartDom = this.$refs.chart;
      const myChart = this.$echart.init(chartDom);

      // 设置图表的配置和数据
      const option = {
        backgroundColor: "rgba(29, 30, 40, 1)",
        title: {
          text: this.title,
          subtext: 'Circular layout',
          top: 'bottom',
          left: 'right',
          textStyle: {
            color: '#fff'
          }
        },
        tooltip: {
          trigger: 'item',
          formatter: (params) => {
            let data = params.data;
            // 判断是否是节点还是边
            if (params.dataType === 'node') {
              return `
                <div style="color: #000;">
                  <strong>节点名称: </strong>${data.name}<br/>
                  <strong>节点类别: </strong>${data.category ? params.data.category : '无类别'}<br/>
                  <strong>额外信息: </strong>${data.extraInfo || '没有更多信息'}
                </div>
              `;
            } else if (params.dataType === 'edge') {
              return `
                <div style="color: #000;">
                  <strong>连接关系: </strong>${params.data.name}<br/>
                  <strong>源节点: </strong>${params.data.source}<br/>
                  <strong>目标节点: </strong>${params.data.target}
                </div>
              `;
            }
            return ''; // 如果不是节点或边，不显示内容
          }
        },
        toolbox: {
          feature: {
            saveAsImage: {
              type: "png",
              pixelRatio: 10,
            }
          }
        },
        legend: [
          {
            data: this.graph.categories.map(function (a) {
              return a.name;
            }),
            textStyle: {
              color: '#fff'
            }
          }
        ],
        animationDurationUpdate: 1500,
        animationEasingUpdate: 'quinticInOut',
        series: [
          {
            name: '关系图',
            type: 'graph',
            layout: 'circular',
            circular: {
              rotateLabel: true
            },
            data: this.graph.nodes,
            links: this.updateLinks,
            categories: this.graph.categories,
            roam: true,
            label: {
              show: true,
              position: 'right',
              formatter: '{b}',
              textStyle: {
                color: '#fff'
              }
            },
            lineStyle: {
              color: 'target',
              curveness: 0.3
            }
          }
        ]
      };

      // 渲染图表
      myChart.setOption(option);

      // 窗口大小变化时自动调整
      window.addEventListener("resize", () => {
        myChart.resize();
      });
    }
  },
  // 改为 async 函数，以便在加载图表数据时使用 await
  async mounted() {
    await this.loadKnowledgeGraph();
    this.initChart(); // 初始化图表
  }
};
</script>
