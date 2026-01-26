<template>
  <div class="card">
    <h2>日语单词抽练</h2>

    <p>{{ question }}</p>
    <p class="timer">⏱ 剩余时间：{{ timeLeft }} 秒</p>

    <input
      v-model="input"
      @keyup.enter="checkAnswer"
      placeholder="输入答案"
    />

    <button @click="checkAnswer" :disabled="!input">
      确认
    </button>

    <p>{{ result }}</p>
    <p>正确率：{{ correct }}/{{ total }}</p>
  </div>
</template>

<script>
export default {
  data() {
    return {
      words: [
        { jp: 'たべる', cn: '吃' },
        { jp: 'いく', cn: '去' },
        { jp: 'みる', cn: '看' }
      ],
      current: null,
      mode: 'jpToCn',
      input: '',
      result: '',
      total: 0,
      correct: 0,
      timeLeft: 10,
      timer: null,
      paused: false
    }
  },

  computed: {
    question() {
      if (!this.current) return ''
      return this.mode === 'jpToCn'
        ? `「${this.current.jp}」是什么意思？`
        : `「${this.current.cn}」用日语怎么说？`
    }
  },

  methods: {
    next() {
      // 只在用户答对后调用
      clearInterval(this.timer)
      this.timeLeft = 10
      this.input = ''
      this.result = ''
      this.paused = false

      this.current = this.words[
        Math.floor(Math.random() * this.words.length)
      ]
      this.mode = Math.random() > 0.5 ? 'jpToCn' : 'cnToJp'

      this.startTimer()
    },

    startTimer() {
      if (this.timer) clearInterval(this.timer)
      this.timer = setInterval(() => {
        if (this.paused) return // 错误时暂停
        if (this.timeLeft > 0) {
          this.timeLeft--
        }
      }, 1000)
    },

    checkAnswer() {
      if (!this.input) return

      const right =
        this.mode === 'jpToCn'
          ? this.input === this.current.cn
          : this.input === this.current.jp

      if (!right) {
        // 错误答案：暂停时间，提示错误，但不跳到下一题
        this.paused = true
        this.result = `❌ 错误，请重新输入`
      } else {
        // 正确答案：解锁时间并进入下一题
        clearInterval(this.timer)
        this.correct++
        this.total++
        this.result = '✅ 正确'
        // 手动点击下一题或按回车触发
        setTimeout(() => {
          this.next()
        }, 800)
      }
    }
  },

  mounted() {
    this.next()
  }
}
</script>

<style scoped>
.card {
  max-width: 420px;
  margin: auto;
  padding: 30px;
  background: white;
  border-radius: 12px;
}
.timer {
  color: #e67e22;
}
button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
