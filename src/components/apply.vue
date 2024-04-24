<template>
  <div>
    <div class="container">
      <b-navbar toggleable="lg" type="" variant="" class="p-0">
        <b-navbar-brand class="text-dark" href="#"
          >Intellectual Property Filing and Granting System
        </b-navbar-brand>
        <b-navbar-nav class="ml-auto">
          <b-navbar-nav>
            <b-nav-item href="#" disable v-if="role === 1">
              <p style="color: black !important">Admin</p>
            </b-nav-item>

            <b-nav-item href="#" disabled v-else-if="role === 2">
              <p style="color: #3f704d !important">User</p>
            </b-nav-item>

            <b-nav-item href="#" disabled v-else>
              <p style="color: #800000 !important">Unknown Role</p>
            </b-nav-item>
          </b-navbar-nav>
        </b-navbar-nav>
      </b-navbar>
    </div>
    <p v-if="account">Connected Account: {{ account }}</p>

    <form @submit.prevent="submitForm">
      <label>IPC Classification</label>
      <input type="text" v-model="IPC_classification" required />
      <label>Applicant</label>
      <input type="text" v-model="applicant" required />
      <label>Inventor</label>
      <input type="text" v-model="inventor" required />
      <label>Title</label>
      <input type="text" v-model="title" required />

      <div class="submit">
        <button type="submit">Submit</button>
      </div>
    </form>
  </div>
</template>

<script>
import { ethers } from "ethers";

import contractAbi from "../contracts-abi/ip.json";

export default {
  data() {
    return {
      provider: null,
      account: null,
      contract: null,
      IPC_classification: "",
      applicant: "",
      inventor: "",
      title: "",
      role: null,
    };
  },
  beforeMount() {
    this.connectWallet();
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        this.provider = new ethers.providers.Web3Provider(window.ethereum);
        const accounts = await this.provider.send("eth_requestAccounts", []);
        this.account = accounts[0];
        await this.createContractInstance(); // wait for contract instance creation
        await this.getRole(); // fetch role after contract instance is created
      } else {
        console.error("Metamask is not installed");
      }
    },
    async createContractInstance() {
      var contractAddress = "0x47b7B8292f938324E97235684577d7bfb11Cf1Ec";
      this.contract = new ethers.Contract(contractAddress, contractAbi);
      this.contract = this.contract.connect(this.provider);
    },
    async submitForm() {
      try {
        const tx = await this.contract.applyForPatent(
          this.IPC_classification,
          this.applicant,
          this.inventor,
          this.title
        );
        await tx.wait();
        console.log("Transaction mined:", tx.hash);
      } catch (error) {
        console.error("Error submitting form:", error);
      }
    },
    async getRole() {
  try {
    // Get the signer
    const signer = this.provider.getSigner();
    // Connect the contract with the signer
    const contractWithSigner = await this.contract.connect(signer);
    // Get the role from the contract
    const role = await contractWithSigner.getRole(await signer.getAddress());
    // Parse the role to an integer
    this.role = parseInt(role);
    // Log the role for debugging
    console.log("Role:", this.role);
  } catch (error) {
    console.error("Error getting role:", error);
  }
},

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
