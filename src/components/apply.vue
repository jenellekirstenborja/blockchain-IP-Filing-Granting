<template>
  <form>
    <label> IPC Classification </label>
    <input type="IPC_classification" required v-model="IPC_classification" />
    <label> Applicant </label>
    <input type="applicant" required v-model="applicant" />
    <label> Inventor </label>
    <input type="inventor" required v-model="inventor" />
    <label> Title </label>
    <input type="title" required v-model="title" />

    <div class ="submit">
        <button> submit </button>
    </div>
  </form>
</template>

<script>
export default {
  data() {
    return {};
  },
};
</script>

<style>
form {
  max-width: 420px;
  margin: 30px auto;
  background: white;
  text-align: left;
  padding: 40px;
  border-radius: 10px;
}
label {
  color: #aaa;
  display: inline-block;
  margin: 25px 0 15px;
  font-size: 0.6em;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: bold;
}
input {
  display: block;
  padding: 10px 6px;
  width: 100%;
  box-sizing: border-box;
  border: none;
  border-bottom: 1px solid #ddd;
  color: #555;
}
button {
  background: #aaa;
  border: 0;
  padding: 10px 20px;
  margin-top: 20px;
  color: white;
  border-radius: 20px;
  text-transform: uppercase;
}
.submit {
  text-align: center;
}
</style>
