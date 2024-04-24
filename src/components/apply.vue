<template>
  <div id="app">
    <div class="container">
      <b-navbar toggleable="lg" type="" variant="" class="p-0">
        <b-navbar-brand class="text-dark" href="#">
          <p class ="header"> Intellectual Property Filing and Granting System </p>
        </b-navbar-brand>
        <b-navbar-nav class="ml-auto">
          <b-navbar-nav>
            <b-nav-item href="#" disable v-if="role === 1">
              <p class ="admin-text">Admin</p>
            </b-nav-item>

            <b-nav-item href="#" disabled v-else="role === 2">
              <p class ="user-text">User</p>
              
            </b-nav-item>

   
          </b-navbar-nav>
        </b-navbar-nav>
      </b-navbar>


    </div>
    <p class = "account-text" v-if="account" > Account Address: {{ account }}</p>

    <form @submit.prevent="submitForm" >
      <label>IPC Classification</label>
      <input type="text" v-model="IPC_classification" required />
      <label>Applicant</label>
      <input type="text" v-model="applicant" required />
      <label>Inventor</label>
      <input type="text" v-model="inventor" required />
      <label>Title</label>
      <input type="text" v-model="title" required />

      <div class="submit">
        <button type="submit" class="submit-button">Submit</button>
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
      var contractAddress = "0x290f9DcA9905B98eD02120440bEa5050eBE8AEb7";
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
        const role = await contractWithSigner.getRole(
          await signer.getAddress()
        );
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

#app{

}
.container{


  
}
.header {
  font-size: 1em;
  text-transform: uppercase;
  letter-spacing: 2.5px;
  font-weight: bold;
  color: #555;

}
.user-text {
  font-size: 1.1em;
  letter-spacing: 1.2px;
  font-weight: bold;
  color: #ab9a91;

}
.admin-text{
  font-size: 1.1em;
  letter-spacing: 1.2px;
  font-weight: bold;
  color: #d5bdaf;
}
.account-text {
  font-size: 1em;
  letter-spacing: 3px;
  color: #afb3a2;

}
form {
  max-width: 450px;
  margin: 30px auto;
  text-align: left;
  padding: 40px;
  border-radius: 10px;
}
label {
  color: #aaa;
  display: inline-block;
  margin: 25px 0 15px;
  font-size: 0.9em;
  text-transform: uppercase;
  letter-spacing: 2px;
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
.submit-button {

  background: #555; /* Updated button background color */
  border: 0;
  padding: 15px 30px; /* Adjusted padding */
  margin-top: 20px;
  color: white;
  border-radius: 40px;
  text-transform: uppercase;
  font-weight: bold; /* Added font weight */
  cursor: pointer; /* Added cursor style */

}
.submit {
  text-align: center;
}
</style>
