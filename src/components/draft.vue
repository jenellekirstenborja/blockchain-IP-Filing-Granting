<template>
  <div>
  <!-- <div>
    <div class="container">
      <b-navbar toggleable="lg" type="" variant="" class="p-0">
        <b-navbar-brand class="text-dark" href="#">
          Intellectual Property Filing and Granting System</b-navbar-brand>
        <b-navbar-nav class="ml-auto">
          <b-navbar-nav>
            <b-nav-item href="#" disabled v-if="role === 1">
              <p style="color: black !important">Admin</p>
            </b-nav-item>
            <b-nav-item href="#" disabled v-else-if="role === 2">
              <p style="color: #3f704d !important">User</p>
            </b-nav-item>
            <b-nav-item href="#" v-else>
              <p>Loading...</p>
            </b-nav-item>
          </b-navbar-nav>
        </b-navbar-nav>
      </b-navbar>
    </div> -->

    <!-- <form @submit.prevent="submitForm">  -->
    <form>
      <label> IPC Classification</label>
      <input type="text" v-model="IPC_classification" required />
      <label> Applicant</label>
      <input type="text" v-model="applicant" required />
      <label> Inventor</label>
      <input type="text" v-model="inventor" required />
      <label> Title </label>
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
      role: null,
      IPC_classification: "",
      applicant: "",
      inventor: "",
      title: "",
      applicationNumber: "",
    };
  },
  methods: {
    // async getRole() {
    //   var signer = this.provider.getSigner()
    //   var contractWithSigner = await this.contract.connect(signer)
    //   const role = await contractWithSigner.getRole(await signer.getAddress());
    //   this.role = parseInt(role)
    // },
    async connectWallet() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      this.accounts = await this.provider.send('eth_requestAccounts', [])
      this.createContractInstance()
      this.getElectionStatus()
      this.getCandidates()
      this.getRole()
    },
    // Function that creates contract instance
    async createContractInstance() {
      var contractAddress = '0xfCb7cAD6c116fB0cfC443F3b975e73595896A2B1'
      this.contract = new ethers.Contract(contractAddress, contractAbi)
      this.contract = this.contract.connect(this.provider)

    },
    // async submitForm() {
    //   if (this.role === 1) {
    //     // Admin logic: Grant the patent
    //     try {
    //       await this.contract.grantPatent(this.applicationNumber);
    //       // Optionally, you can show a success message or perform any other action
    //     } catch (error) {
    //       console.error("Error granting patent:", error);
    //       // Optionally, you can show an error message or perform any other action
    //     }
    //   } else if (this.role === 2) {
    //     // Regular user logic: Apply for the patent
    //     try {
    //       await this.contract.applyForPatent(
    //         this.IPC_classification,
    //         this.applicant,
    //         this.inventor,
    //         this.title
    //       );
    //       // Optionally, you can show a success message or perform any other action
    //     } catch (error) {
    //       console.error("Error applying for patent:", error);
    //       // Optionally, you can show an error message or perform any other action
    //     }
    //   } else {
    //     // Handle the case where the role is not yet determined or loading
    //     console.log("Role not determined yet.");
    //   }
    // },

    // beforeMount() {
    //   this.connectWallet();
    // },
  }
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
