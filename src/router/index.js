import Vue from 'vue'
import VueRouter from 'vue-router'

// 1. 注册路由插件
Vue.use(VueRouter)

// 2. 定义路由
const routes = [
  {
    path: '/',
    name: 'HomeView',
    component: () => import('../views/HomeView.vue')
  },
  {
    path: '/practice',
    name: 'Practice',
    component: () => import('../views/Practice.vue')
  }
]

// 3. 创建 router 实例（Vue 2 的写法）
const router = new VueRouter({
  mode: 'history', // 在 Vue 2 中，HTML5 历史模式用 mode: 'history'
  base: process.env.BASE_URL,
  routes
})

export default router