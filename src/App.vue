<template>
  <div id="app">
    <ApplyForm />
  </div>
</template>

<script>
import ApplyForm from './components/ApplyForm.vue'

export default {
  name: 'App',
  components: { ApplyForm }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

body {
  margin: 0;
  background: white;
}
</style>