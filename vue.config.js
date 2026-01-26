module.exports = {
  // 打包后的静态资源引用路径
  publicPath: process.env.NODE_ENV === 'production'
    ? '/JPwordpractice/' // 你的 GitHub 仓库名
    : '/',

  outputDir: 'dist', // 构建输出目录
}
