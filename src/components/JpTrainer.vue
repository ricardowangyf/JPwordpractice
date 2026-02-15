<template>
  <div class="card">
    <h2>🇯🇵 日语抽练</h2>
    <p class="question">{{ current.question }}</p>
    <p class="timer">⏱ 剩余 {{ timeLeft }} 秒</p>
    <input v-model="input" placeholder="输入你的回答" @keyup.enter="check" />
    <!-- <p v-if="result === 'correct'" class="ok">✔️ 正确</p> -->
    <p v-if="result === 'wrong'" class="err">
      ❌ 错误，正确答案：{{ current.answer }}
    </p>
    <button @click="skip" :disabled="!input.trim()">正确</button>
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
      try {
        this.records = JSON.parse(saved)
      } catch (e) {
        this.records = []
      }
    }
    this.startTimer()
  },
  beforeDestroy() {
    if (this.timer) clearInterval(this.timer)
  },
  methods: {
    // 启动倒计时（超时不再自动换题，只将当前题标为错误）
    startTimer() {
      if (this.timer) clearInterval(this.timer)
      this.timer = setInterval(() => {
        this.timeLeft--
        if (this.timeLeft <= 0) {
          // 标记为错误但不自动换题，避免页面自动变化
          this.result = 'wrong'
          if (!this.wrongList.includes(this.index)) this.wrongList.push(this.index)
          this.timeLeft = 10
        }
      }, 1000)
    },

    // manual = false 表示程序触发的下一题
    next(manual = true) {
      if (this.timer) clearInterval(this.timer)
      this.timer = null

      // 重置状态
      this.input = ''
      this.timeLeft = 10
      this.result = null

      if (manual) {
        this.index = (this.index + 1) % this.list.length
      } else {
        if (this.wrongList.length && Math.random() < 0.5) {
          this.index = this.wrongList.shift()
        } else {
          this.index = (this.index + 1) % this.list.length
        }
      }

      this.startTimer()
    },

    // 跳过按钮：仅在有输入时可点击。若当前已显示正确，直接下一题；否则先校验，答案正确时跳题
    skip() {
      if (!this.input.trim()) return
      if (this.result === 'correct') {
        this.next(true)
        return
      }
      this.check(true)
    },

    // 检查答案，autoNext 表示是否在答对后自动跳题（skip 调用会传 true）
    check(autoNext = false) {
      if (this.timer) clearInterval(this.timer)
      this.timer = null

      const userAnswer = this.input.trim().toLowerCase()
      const correctAnswer = (this.current && this.current.answer ? this.current.answer : '').trim().toLowerCase()
      const isCorrect = userAnswer === correctAnswer

      this.result = isCorrect ? 'correct' : 'wrong'

      if (!isCorrect && !this.wrongList.includes(this.index)) this.wrongList.push(this.index)

      // 保存学习记录
      this.records.push({
        question: this.current ? this.current.question : '',
        answer: this.current ? this.current.answer : '',
        input: this.input,
        correct: isCorrect,
        time: new Date().toLocaleTimeString()
      })

      localStorage.setItem('jp-daily-records', JSON.stringify(this.records))

      if (autoNext) {
        if (isCorrect) {
          this.next(true)
        } else {
          this.startTimer()
        }
      } else {
        // 手动检查后不自动换题，重启倒计时
        this.startTimer()
      }
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
