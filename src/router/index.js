import { createRouter, createWebHistory } from 'vue-router'

// 1. 定义路由组件（也可以从其他文件导入，这里以你截图中的日语抽练为例）
// 假设你有 Home.js 和 Practice.vue 组件
const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/Home.vue') // 路由懒加载
  },
  {
    path: '/practice',
    name: 'Practice',
    component: () => import('../views/Practice.vue') // 你的日语抽练页面
  }
]

// 2. 创建 router 实例
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL), // 使用 HTML5 历史模式
  routes
})

export default router