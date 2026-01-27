// Vue CLI
module.exports = {
  publicPath: process.env.NODE_ENV === 'production' ? '/JPwordpractice/' : '/'
}

// Vite
export default defineConfig({
  base: process.env.NODE_ENV === 'production' ? '/JPwordpractice/' : '/'
})
