<template>
  <div id="apply-form">
    <!-- responsive nav bar -->
    <!-- horizontal and vertical padding -->
    <b-navbar
      toggleable="lg"
      type=""
      variant=""
      class="navbar-custom px-5 py-3"
    >
      <!-- logo section -->
      <b-navbar-brand href="#">
        <img src="../assets/logo.png" alt="Logo" class="logo-img" />
      </b-navbar-brand>

      <!-- navigation section -->
      <!-- left margin auto - right end of navbar -->
      <b-navbar-nav class="ml-auto">
        <!-- single navigation item - noninteractive -->
        <b-nav-item href="#" disabled>
          <b-button
            variant="outline-dark"
            class="user-role d-flex align-items-center bg-white"
          >
            <!-- container for user/admin icon -->
            <div class="user-icon rounded-circle shadow-sm bg-white">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="2em"
                height="2em"
                viewBox="0 0 1792 1792"
              >
                <!-- shape -->
                <!-- path data that defines the shape of the svg -->
                <path
                  fill="#212529bf"
                  d="M1523 1339q-22-155-87.5-257.5T1251 963q-67 74-159.5 115.5T896 1120t-195.5-41.5T541 963q-119 16-184.5 118.5T269 1339q106 150 271 237.5t356 87.5t356-87.5t271-237.5m-243-699q0-159-112.5-271.5T896 256T624.5 368.5T512 640t112.5 271.5T896 1024t271.5-112.5T1280 640m512 256q0 182-71 347.5t-190.5 286T1245 1721t-349 71q-182 0-348-71t-286-191t-191-286T0 896t71-348t191-286T548 71T896 0t348 71t286 191t191 286t71 348"
                />
              </svg>
            </div>
            <!-- inline containter for text -->
            <span class="ml-2">{{ role === 1 ? "ADMIN" : "USER" }}</span>
          </b-button>
        </b-nav-item>
      </b-navbar-nav>
    </b-navbar>

    <div
      class="heading-title d-flex text-white align-items-center pt-3 pb-1 px-5 justify-content-between"
    >
      <h5 class="heading-text text-uppercase mr-4 text-left">
        Blockchain-based Intellectual Property Filing and Granting System
      </h5>
      <div class="d-flex flex-column align-items-center justify-content-center">
        <span>{{ currentDayOfWeek }} | {{ currentDate }}</span>
        <h3>{{ currentTime }}</h3>
      </div>
    </div>

    <p class="account-text mt-4" v-if="account">
      Account Address: {{ account }}
    </p>

    <!-- Patent Application Form -->
    <b-modal
      id="modal-prevent-closing"
      ref="modal"
      title="Patent Application Form"
      @show="resetModal"
      @hidden="resetModal"
      @ok="handleOk"
    >
      <form ref="form" @submit.stop.prevent="handleSubmit">
        <b-form-group
          label="IPC Classification"
          label-for="ipc_classification"
          invalid-feedback="IPC Classification is required"
          :state="ipcClassificationState"
        >
          <b-form-input
            id="ipc_classification"
            v-model="ipcClassification"
            :state="ipcClassificationState"
            required
          ></b-form-input>
        </b-form-group>

        <b-form-group
          label="Applicant"
          label-for="applicant"
          invalid-feedback="Applicant is required"
          :state="applicantState"
        >
          <b-form-input
            id="applicant"
            v-model="applicant"
            :state="applicantState"
            required
          ></b-form-input>
        </b-form-group>

        <b-form-group
          label="Inventor"
          label-for="inventor"
          invalid-feedback="Inventor is required"
          :state="inventorState"
        >
          <b-form-input
            id="inventor"
            v-model="inventor"
            :state="inventorState"
            required
          ></b-form-input>
        </b-form-group>

        <b-form-group
          label="Title"
          label-for="title"
          invalid-feedback="Title is required"
          :state="titleState"
        >
          <b-form-input id="title" v-model="title" :state="titleState" required>
          </b-form-input>
          <b-form-file
            :state="fileState"
            placeholder="Choose a file or drop it here..."
            drop-placeholder="Drop file here..."
            accept=".pdf,.docx"
            @change="handleFileUpload"
          ></b-form-file>
        </b-form-group>
      </form>
    </b-modal>

    <div class="container mb-3">
			<input type="text" v-model="searchQuery" placeholder="Search patents..." class="form-control" />
		</div>

    <b-button
      class="ml-auto mr-auto"
      v-b-modal.modal-prevent-closing
      v-if="role === 2"
      >Apply</b-button
    >

    <b-tabs content-class="mt-3" class = "tab">
      <b-tab title="View All">
        <!-- Table to display all patent applications -->
        <!-- dynamically extend feilds array -->
        <b-table
          v-if="!isLoading"
          striped
          hover
          :items="filteredApplications"
          :fields="[...fields, 'status']"
        >

          <!-- Action buttons for all patent applications -->
          <template v-slot:cell(action)="data">
            <b-link
              href="#"
              v-b-modal.patent-details
              @click="handleOpenPatentDetailsModal(data.item)"
              >Details</b-link
            >
          </template>
        </b-table>
        <b-table v-else>LOADING...</b-table>
      </b-tab>
      <b-tab title="Pending" active class="pending-tab">
        <!-- Table to display pending patents -->
        <b-table
          v-if="!isLoading"
          striped
          hover
          :items="pendingList"
          :fields="fields"
        >
          <!-- Action buttons for pending patents ('Deny' & 'Grant' only for admin) -->
          <template v-slot:cell(action)="data">
            <b-link
              href="#"
              class="mr-2"
              v-b-modal.patent-details
              @click="handleOpenPatentDetailsModal(data.item)"
            >
              Details
            </b-link>
            <b-button
              v-if="role === 1"
              class="mr-2"
              variant="danger"
              @click="denyPatentApp(data.item.applicationNumber)"
              >Deny</b-button
            >
            <b-button
              v-if="role === 1"
              variant="success"
              @click="grantPatentApp(data.item.applicationNumber)"
            >
              Grant
            </b-button>
          </template>
          <!-- <template v-if="showStatusColumn" v-slot:cell(status)="data">
							{{ data.item.status }}
						</template> -->
        </b-table>
        <b-table v-else>LOADING...</b-table>
      </b-tab>

      <b-tab title="Granted" class="granted-tab">
        <!-- Table to display granted patents -->
        <b-table
          v-if="!isLoading"
          striped
          hover
          :items="grantedList"
          :fields="fields"
        >
          <!-- Action buttons for granted patents -->
          <template v-slot:cell(action)="data">
            <b-link
              href="#"
              v-b-modal.patent-details
              @click="handleOpenPatentDetailsModal(data.item)"
              >Details</b-link
            >
          </template>
        </b-table>
        <b-table v-else>LOADING...</b-table>
      </b-tab>

      <b-tab title="Denied" class="denied-tab">
        <!-- Table to display granted patents -->
        <b-table
          v-if="!isLoading"
          striped
          hover
          :items="deniedList"
          :fields="fields"
        >
          <!-- Action buttons for granted patents -->
          <template v-slot:cell(action)="data">
            <b-link
              href="#"
              v-b-modal.patent-details
              @click="handleOpenPatentDetailsModal(data.item)"
              >Details</b-link
            >
          </template>
        </b-table>
        <b-table v-else>LOADING...</b-table>
      </b-tab>
    </b-tabs>

    <!-- Modal dialog for showing the more of selected patent's details -->
    <PatentDetails :patent="patentToViewDetails" />
  </div>
</template>

<script>
import { ethers } from "ethers";
import contractAbi from "../contracts-abi/ip.json";
import moment from "moment";
import axios from "axios"; // Package used for sending request to APIs.
import FormData from "form-data"; // To append data into a form to submit to Pinata's API.
import PatentDetails from "./PatentDetails.vue"; // Import the <PatentDetails /> component.

export default {
  name: "ApplyForm",

  components: { PatentDetails }, // Use the <PatentDetails /> component.

  data() {
    return {
      provider: null,
      account: null,
      contract: null,
      role: null,

      ipcClassification: "",
      ipcClassificationState: null,
      applicant: "",
      applicantState: null,
      inventor: "",
      inventorState: null,
      title: "",
      titleState: null,
      file: "", // Variable for storing uploaded file inside of `<input>` element.
      fileIpfsHash: "", // Variable for storing the IPFS hash returned by Pinata's API after successful upload.
      fileState: null,

      pendingList: [],
      grantedList: [],
      deniedList: [],
      searchQuery: "",
      allList: [],

      fields: [
        "applicationNumber",
        "applicationDate",
        "applicant",
        "title",
        "action",
      ],
      showStatusColumn: false,

      patentToViewDetails: null, // Variable for the selected patent's data to pass to <PatentDetails /> component

      currentDayOfWeek: "", // For storing the current day of the week
      currentDate: "", // For storing current date
      currentTime: "", // For storing current date

      isLoading: false, // For loading indicator
    };
  },
  computed: {
    // Compute the filtered applications including status
    filteredApplications() {
      // Assuming this.pendingList, this.grantedList, and this.deniedList are already defined
      const allApplications = this.pendingList.concat(
        this.grantedList,
        this.deniedList
      );

      // Add status to each application
      const applicationsWithStatus = allApplications.map((application) => {
        // Determine the status of each application
        let status = "";
        if (this.pendingList.includes(application)) {
          status = "Pending";
        } else if (this.grantedList.includes(application)) {
          status = "Granted";
        } else if (this.deniedList.includes(application)) {
          status = "Denied";
        }
        // Add status property to the application object
        return { ...application, status };
      });

      if (this.searchQuery) {
        const searchTerm = this.searchQuery.toLowerCase();

        // Filter out each `patent` that matches the search query.
        return applicationsWithStatus.filter((patent) => {
          return (
            !this.searchQuery ||
            patent.applicant.toLowerCase().includes(searchTerm) ||
            patent.inventor.toLowerCase().includes(searchTerm) ||
            patent.title.toLowerCase().includes(searchTerm)
          );
        });
      } else {
        return applicationsWithStatus;
      }
    },
  },

  methods: {
    /**
     * Function to set-up the patent's data to pass to <PatentDetails /> component.
     */
    handleOpenPatentDetailsModal(patent) {
      this.patentToViewDetails = patent;
    },

    /**
     * Function to pin/upload a file to Pinata's API.
     */
    async pinFileToIPFS() {
      try {
        // Setup the data for pinning.
        const data = new FormData();
        data.append("file", this.file); // Append the file itself.
        data.append("pinataOptions", '{"cidVersion": 1}');
        data.append("pinataMetadata", `{"name": "${this.file.name}"}`); // Append file-name metadata.

        // Send the request to Pinata's API.
        const res = await axios.post(
          "https://api.pinata.cloud/pinning/pinFileToIPFS",
          data,
          {
            headers: {
              // Attach the Pinata's JWT key/token in `Authorization` property of the request's header.
              Authorization: `Bearer ${process.env.VUE_APP_PINATA_JWT}`,
            },
          }
        );

        // Store the returned IPFS hash from the API's response.
        this.fileIpfsHash = await res.data.IpfsHash;
      } catch (error) {
        console.error(error);
      }
    },

    /**
     * Handles the file upload event.
     * Stores the uploaded from `<input>` element.
     * @param {InputEvent} event - The DOM event triggered by the file input.
     */
    handleFileUpload(event) {
      this.file = event.target.files[0];
    },

    checkFormValidity() {
      const valid = this.$refs.form.checkValidity();
      this.ipcClassificationState = valid;
      this.applicantState = valid;
      this.inventorState = valid;
      this.titleState = valid;
      this.fileState = valid;
      return valid;
    },

    resetModal() {
      this.ipcClassification = "";
      this.ipcClassificationState = null;
      this.applicant = "";
      this.applicantState = null;
      this.inventor = "";
      this.inventorState = null;
      this.title = "";
      this.titleState = null;
      this.file = "";
      this.fileIpfsHash = "";
      this.fileState = null;
    },

    handleOk(bvModalEvent) {
      // Prevent modal from closing
      bvModalEvent.preventDefault();
      // Trigger submit handler
      this.handleSubmit();
    },

    async handleSubmit() {
      // Exit when the form isn't valid
      if (!this.checkFormValidity()) {
        return;
      }

      try {
        // Execute the uploaded file pinning to Pinata's API.
        await this.pinFileToIPFS();

        // Connect the contract with the signer
        var signer = this.provider.getSigner(); // signer - user's ethereum address
        var contractWithSigner = await this.contract.connect(signer);
        // Call the applyForPatent function on the smart contract
        var apply = await contractWithSigner.applyForPatent(
          this.ipcClassification,
          this.applicant,
          this.inventor,
          this.title,
          this.fileIpfsHash, // Attach the retrieved IPFS hash from Pinata's API response.
          this.file.name // Attach the name of the uploaded file.
        );

        console.log(apply, "Transaction successful");

        this.$nextTick(() => {
          this.$bvModal.hide("modal-prevent-closing");
        });
      } catch (error) {
        // In case `applyForPatent()` fails, unpin/delete the recently pinned/uploaded file in Pinata's IPFS.
        await axios.delete(
          `https://api.pinata.cloud/pinning/unpin/${this.fileIpfsHash}`,
          {
            headers: {
              // Attach the Pinata's JWT key/token in `Authorization` property of the request's header.
              Authorization: `Bearer ${process.env.VUE_APP_PINATA_JWT}`,
            },
          }
        );

        console.error("Error submitting patent application:", error);
      }
    },

    async connectWallet() {
      if (window.ethereum) {
        this.provider = new ethers.providers.Web3Provider(window.ethereum);
        const accounts = await this.provider.send("eth_requestAccounts", []);
        this.account = accounts[0];
        await this.createContractInstance();

        await this.getAllList();
        await this.getRole();

        // fetch role after contract instance is created
      } else {
        console.error("Metamask is not installed");
      }
    },

    async createContractInstance() {
      var contractAddress = process.env.VUE_APP_CONTRACT_ADDRESS; // Get the configured contract address in .env file.
      this.contract = new ethers.Contract(contractAddress, contractAbi);
      this.contract = this.contract.connect(this.provider);
    },

    async getAllPendingLists() {
      this.isLoading = true;
      this.appliedPatentsLength = await this.contract.getAllAppliedPatents();
      this.pendingList = [];

      for (let i = 0; i < this.appliedPatentsLength; i++) {
        var patent = await this.contract.appliedPatents(i);
        var _patent = {
          applicationNumber: patent.applicationNumber, // Appended the `applicationNumber` field from the contract's patent itself.
          ipcClassification: patent.IPC_Classification,
          applicant: patent.applicant,
          inventor: patent.inventors,
          title: patent.title,
          patentNumber: patent.patentNumber,
          applicationDate: moment(patent.applicationDate * 1000).format(
            "MMMM Do YYYY, h:mm:ss a"
          ),
          // `publicationDate` property/field is not need since these patents are not granted yet.
          // Put both `fileName` & `fileIpfsHash` fields from the contract's patents in a object property.
          file: { name: patent.fileName, ipfsHash: patent.fileIpfsHash },
        };

        this.pendingList.push(_patent);
      }

      this.isLoading = false;
    },

    async getAllGrantedLists() {
      this.isLoading = true;
      this.grantedPatentsLength = await this.contract.getAllGrantedPatents();
      this.grantedList = [];

      for (let i = 0; i < this.grantedPatentsLength; i++) {
        var grant = await this.contract.grantedPatents(i);
        var _grant = {
          applicationNumber: grant.applicationNumber, // Appended the `applicationNumber` field from the contract's patent itself.
          ipcClassification: grant.IPC_Classification,
          applicant: grant.applicant,
          inventor: grant.inventors,
          title: grant.title,
          patentNumber: grant.patentNumber,
          applicationDate: moment(grant.applicationDate * 1000).format(
            "MMMM Do YYYY, h:mm:ss a"
          ),
          publicationDate: moment(grant.publicationDate * 1000).format(
            "MMMM Do YYYY, h:mm:ss a"
          ),
          // Put both `fileName` & `fileIpfsHash` fields from the contract's patents in a object property.
          file: { name: grant.fileName, ipfsHash: grant.fileIpfsHash },
        };

        this.grantedList.push(_grant);
      }

      this.isLoading = false;
    },

    async getAllDeniedLists() {
      this.isLoading = true;
      this.deniedPatentsLength = await this.contract.getAllDeniedPatents();
      this.deniedList = [];

      for (let i = 0; i < this.deniedPatentsLength; i++) {
        var deny = await this.contract.deniedPatents(i);
        var _deny = {
          applicationNumber: deny.applicationNumber,
          ipcClassification: deny.IPC_Classification,
          applicant: deny.applicant,
          inventor: deny.inventors,
          title: deny.title,
          patentNumber: deny.patentNumber,
          applicationDate: moment(deny.applicationDate * 1000).format(
            "MMMM Do YYYY, h:mm:ss a"
          ),
          // Doesn't need publicationDate property since the patent/s has/have been denied
          deniedAt: moment(deny.deniedAt * 1000).format(
            "MMMM Do YYYY, h:mm:ss a"
          ),
          file: { name: deny.fileName, ipfsHash: deny.fileIpfsHash },
        };

        this.deniedList.push(_deny);
      }

      this.isLoading = false;
    },

    async getAllList() {
      this.allList = [];

      await this.getAllPendingLists();
      await this.getAllGrantedLists();
      await this.getAllDeniedLists();

      // Merge all patent lists
      this.allList = this.pendingList.concat(this.grantedList, this.deniedList);
    },

    async grantPatentApp(applicationNumber) {
      try {
        const signer = this.provider.getSigner();
        const contractWithSigner = await this.contract.connect(signer);

        // Grant the patent
        const grant = await contractWithSigner.grantPatent(applicationNumber);
        await grant.wait();

        // Refetch updated pending-list from Smart Contract.
        // Since the removal of granted patent from pending-list was already done in the Smart Contract side
        await this.getAllPendingLists();

        console.log("Patent granted successfully:", grant);
      } catch (error) {
        console.error("Error granting patent:", error);
      }
    },

    async denyPatentApp(applicationNumber) {
      try {
        const signer = this.provider.getSigner();
        const contractWithSigner = await this.contract.connect(signer);

        // Deny the patent application
        const deny = await contractWithSigner.denyPatent(applicationNumber);
        await deny.wait();

        // Refetch updated pending-list from Smart Contract.
        // Since the removal of granted patent from pending-list was already done in the Smart Contract side
        await this.getAllPendingLists();

        console.log("Patent application denied successfully:", deny);
      } catch (error) {
        // Log the specific error message and details
        console.error(
          "Error denying patent application:",
          error.message,
          error
        );
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
        console.log("Role: ", this.role);
      } catch (error) {
        console.error("Error getting role:", error);
      }
    },
  },

  beforeMount() {
    this.connectWallet();
  },

  mounted() {
    setInterval(() => {
      let now = new Date();
      this.currentDayOfWeek = now.toLocaleString("en-US", { weekday: "long" });
      this.currentDate = now.toLocaleString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
      });
      this.currentTime = now.toLocaleString("en-US", {
        hour: "numeric",
        minute: "numeric",
        hour12: true,
      });
    }, 1000);
  },
};
</script>

<style>
.header {
  font-size: 1em;
  text-transform: uppercase;
  letter-spacing: 2.5px;
  font-weight: bold;
  color: #555;
}
.account-text {
  font-size: 1em;
  letter-spacing: 3px;
  color: #555;
}
.logo-img {
  width: 150px;
}
.navbar-custom {
  width: 100%;
  background-color: ;
}
.user-role.btn {
  border-radius: 1rem;
  border-width: 2px;
  /* horizontal offset of 0
		vertical offset of 4px
		blur radius of 3px
		color with 20% opacity */
  filter: drop-shadow(0 4px 3px rgb(0 0 0 / 0.2))
    drop-shadow(0 2px 2px rgb(0 0 0 / 0.19));
}
.user-icon {
  filter: drop-shadow(0 1px 1px rgb(0 0 0 / 0.24));
}

.heading-title {
  background: rgb(74, 74, 74);
  /* linear gradient for firefox 
		gradient direction top to bottom:  */
  background: -moz-linear-gradient(
    180deg,
    rgba(74, 74, 74, 1) 0%,
    rgba(146, 146, 146, 1) 100%
  );
  /* chrome and safari */
  background: -webkit-linear-gradient(
    180deg,
    rgba(74, 74, 74, 1) 0%,
    rgba(146, 146, 146, 1) 100%
  );
  background: linear-gradient(
    180deg,
    rgba(74, 74, 74, 1) 0%,
    rgba(146, 146, 146, 1) 100%
  );
  /* internet explorer */
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#4a4a4a",endColorstr="#929292",GradientType=1);
}

.heading-text {
  font-size: 1.1em;
  letter-spacing: 3px;
}



form {
  max-width: 450px;
  margin: 15px auto;
  text-align: left;
  padding: 10px;
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

.tab .b-table {
  font-size: 13px; /* Common font size for all tables */
  font-family: 'Verdana', sans-serif; /* Common font family for all tables */
}









</style>
