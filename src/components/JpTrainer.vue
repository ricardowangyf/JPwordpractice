<template>
  <div class="card">
    <h2>🇯🇵 日语抽练</h2>

    <p class="question">{{ current.question }}</p>

    <p class="timer">⏱ 剩余 {{ timeLeft }} 秒</p>

    <!-- <input
      v-model="input"
      placeholder="输入你的回答"
      @keyup.enter="next"
    /> -->
    <input v-model="input" placeholder="输入你的回答" @keyup.enter="check" />
    <p v-if="result === 'correct'" class="ok">✔️ 正确</p>
    <p v-if="result === 'wrong'" class="err">
      ❌ 错误，正确答案：{{ current.answer }}111
    </p>

    <button @click="next">跳过</button>
  </div>
</template>

<script>
import questions from '@/data/jpTrainer'


export default {
  name: 'jpTrainer',
  data() {
    return {
      result: null, // 'correct' | 'wrong'
      list: questions,
      index: 0,
      input: '',
      wrongList: [],
      timeLeft: 10,
      records: [],
      timer: null
    }
  },
  computed: {
    current() {
      return this.list[this.index]
    }
  },
  mounted() {
    this.startTimer()
    const saved = localStorage.getItem('jp-daily-records')
    if (saved) {
      this.records = JSON.parse(saved)
    }
    this.startTimer()
  },
  beforeDestroy() {
    clearInterval(this.timer)
  },
  methods: {
    startTimer() {
      this.timer = setInterval(() => {
        this.timeLeft--
        if (this.timeLeft === 0) {
          this.next()
        }
      }, 1000)
    },
    next() {
      clearInterval(this.timer)
      this.input = ''
      this.timeLeft = 10
      this.result = null

      if (this.wrongList.length && Math.random() < 0.5) {
        this.index = this.list.indexOf(
          this.wrongList.shift()
        )
      } else {
        this.index = (this.index + 1) % this.list.length
      }

      this.startTimer()
    },

    check() {
      clearInterval(this.timer)

      const isCorrect =
        this.input.trim() === this.current.answer.trim()

      this.result = isCorrect ? 'correct' : 'wrong'

      // ⭐ 记录学习数据
      this.records.push({
        question: this.current.question,
        answer: this.current.answer,
        input: this.input,
        correct: isCorrect,
        time: new Date().toLocaleTimeString()
      })

      // ⭐ 同步到 localStorage
      localStorage.setItem(
        'jp-daily-records',
        JSON.stringify(this.records)
      )

      setTimeout(() => {
        this.next()
      }, 2000)
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
  box-shadow: 0 4px 12px rgba(0, 0, 0, .1);
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
}

button {
  margin-top: 12px;
}
</style>
