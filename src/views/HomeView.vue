<script setup lang="ts">
// 使用 import 导入图片
import buaa1 from '@/assets/images/buaa1.jpg';
import buaa2 from '@/assets/images/buaa2.jpg';
import buaa3 from '@/assets/images/buaa3.jpg';
import buaa4 from '@/assets/images/buaa4.jpg';
import buaa5 from '@/assets/images/buaa5.jpg';

// 定义图片数组
const images = [buaa1, buaa2, buaa3, buaa4, buaa5];
</script>

<template>
  <main class="container">
    <div class="carousel">
      <el-carousel height="500px" arrow="always">
        <el-carousel-item v-for="(image, index) in images" :key="index">
          <img :src="image" :alt="'buaa' + (index + 1)" class="carousel-image" />
        </el-carousel-item>
      </el-carousel>
    </div>
    <h1 class="courage">It's time to test your Logic skills.</h1>
    <div class="bg"></div>
  </main>
</template>

<style scoped>
.container{
  padding: 0 5%;
  min-height: calc(500px + 30px + 300px);
  z-index: 1;
}
.carousel{
  margin-top: 20px;
  height: 500px;
}
.carousel-image {
  width: 100%;
  height: 100%;
  object-fit: cover; /* 保持图片比例，裁剪多余部分 */
}
.courage{
  color: #fff;
  font-weight: 700;
  margin-top: 30px;
}
.container{
  background-image: url("../assets/images/wavy-purple-by-nouridio.svg");
  background-size: 300%;
  background-repeat: no-repeat;
  background-position: bottom;
}
</style>
