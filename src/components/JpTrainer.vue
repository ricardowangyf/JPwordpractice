<template>
  <div class="card">
    <h2>🇯🇵 日语抽练</h2>
    <p class="question">{{ current.question }}</p>
    <p class="timer">⏱ 剩余 {{ timeLeft }} 秒</p>
    <input v-model="input" placeholder="输入你的回答" @keyup.enter="check" />
    <p v-if="result === 'correct'" class="ok">✔️ 正确</p>
    <p v-if="result === 'wrong'" class="err">
      ❌ 错误，正确答案：{{ current.answer }}
    </p>
    <button @click="skip">跳过</button>
  </div>
</template>

<script>
import questions from '@/data/jpTrainer'

export default {
  name: 'jpTrainer',
  data() {
    return {
      result: null,        // 'correct' | 'wrong'
      list: questions,
      index: 0,
      input: '',
      wrongList: [],       // 错题索引列表
      timeLeft: 10,
      records: [],         // 学习记录
      timer: null          // 倒计时定时器
    }
  },
  computed: {
    current() {
      return this.list[this.index]
    }
  },
  mounted() {
    const saved = localStorage.getItem('jp-daily-records')
    if (saved) {
      this.records = JSON.parse(saved)
    }
    this.startTimer()
  },
  beforeDestroy() {
    if (this.timer) clearInterval(this.timer)
  },
  methods: {
    // 启动倒计时
    startTimer() {
      if (this.timer) clearInterval(this.timer)
      this.timer = setInterval(() => {
        this.timeLeft--
        if (this.timeLeft <= 0) {
          this.next(false) // 自动跳题
        }
      }, 1000)
    },

    // manual = true 表示用户点击跳过或手动下一题
    // manual = false 表示倒计时自动跳题
    next(manual = true) {
      // 清除旧倒计时
      if (this.timer) clearInterval(this.timer)
      this.timer = null

      // 重置状态
      this.input = ''
      this.timeLeft = 10
      this.result = null

      if (manual) {
        // 用户点击跳过或手动下一题，直接下一题
        this.index = (this.index + 1) % this.list.length
      } else {
        // 自动跳题时，优先抽错题，否则顺序
        if (this.wrongList.length && Math.random() < 0.5) {
          this.index = this.wrongList.shift()
        } else {
          this.index = (this.index + 1) % this.list.length
        }
      }

      // 重启倒计时
      this.startTimer()
    },

    // 点击跳过按钮
    // skip() {
    //   this.next(true)
    // },
    // 点击跳过按钮
    skip() {
      this.next(true)
    },

    // 检查答案
    check() {
      if (this.timer) clearInterval(this.timer)
      this.timer = null

      const userAnswer = this.input.trim().toLowerCase()
      const correctAnswer = this.current.answer.trim().toLowerCase()
      const isCorrect = userAnswer === correctAnswer

      this.result = isCorrect ? 'correct' : 'wrong'

      if (!isCorrect) this.wrongList.push(this.index)

      // 保存学习记录
      this.records.push({
        question: this.current.question,
        answer: this.current.answer,
        input: this.input,
        correct: isCorrect,
        time: new Date().toLocaleTimeString()
      })

      localStorage.setItem('jp-daily-records', JSON.stringify(this.records))

      // ✅ 不再用 setTimeout 自动跳题，倒计时 timer 会处理
    }
  }
}
</script>

<style scoped>
.card {
  max-width: 420px;
  margin: 40px auto;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.question {
  font-size: 20px;
  margin: 16px 0;
}

.timer {
  color: #888;
  font-size: 14px;
}

input {
  width: 100%;
  padding: 8px;
  margin-top: 12px;
  box-sizing: border-box;
}

button {
  margin-top: 12px;
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  background-color: #4CAF50;
  color: white;
  cursor: pointer;
}

button:hover {
  background-color: #45a049;
}

.ok {
  color: green;
  margin-top: 8px;
}

.err {
  color: red;
  margin-top: 8px;
}
</style>
