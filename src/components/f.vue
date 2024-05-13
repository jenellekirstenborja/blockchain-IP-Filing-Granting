<template>
	<div id="app">
		<div class="container">
			<b-navbar toggleable="lg" type="" variant="" class="p-0">
				<b-navbar-brand class="text-dark" href="#">
					<p class="header">Intellectual Property Filing and Granting System</p>
				</b-navbar-brand>
				<b-navbar-nav class="ml-auto">
					<b-navbar-nav>
						<b-nav-item href="#" disabled v-if="role === 1">
							<p class="admin-text">Admin</p>
						</b-nav-item>

						<b-nav-item href="#" disabled v-else>
							<p class="user-text">User</p>
						</b-nav-item>
					</b-navbar-nav>
				</b-navbar-nav>
			</b-navbar>
		</div>
		<p class="account-text" v-if="account">Account Address: {{ account }}</p>

		<b-row>
			<b-col lg="6" class="my-1">
				<b-form-group
					label="Search"
					label-for="search-input"
					label-cols-sm="3"
					label-align-sm="right"
					label-size="sm"
					class="mb-0"
				>
					<b-input-group size="sm">
						<b-form-input id="search-input" v-model="searchQuery" type="search" placeholder="Type to Search"></b-form-input>

						<b-input-group-append>
							<b-button :disabled="!searchQuery" @click="searchQuery = ''">Clear</b-button>
						</b-input-group-append>
					</b-input-group>
				</b-form-group>
			</b-col>

			<b-button class="ml-auto mr-auto" v-b-modal.modal-prevent-closing v-if="role === 2">Apply</b-button>
		</b-row>

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
					<b-form-input id="applicant" v-model="applicant" :state="applicantState" required></b-form-input>
				</b-form-group>

				<b-form-group label="Inventor" label-for="inventor" invalid-feedback="Inventor is required" :state="inventorState">
					<b-form-input id="inventor" v-model="inventor" :state="inventorState" required></b-form-input>
				</b-form-group>

				<b-form-group label="Title" label-for="title" invalid-feedback="Title is required" :state="titleState">
					<b-form-input id="title" v-model="title" :state="titleState" required> </b-form-input>
				</b-form-group>

				<b-form-group label="File" label-for="file" invalid-feedback="File is required" :state="fileState">
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

		<b-tabs content-class="mt-3">
			<b-tab title="Pending" active>
				<!-- Table to display pending patents -->
				<b-table striped hover :items="filteredPendingList" :fields="fields">
					<!-- Action buttons for pending patents ('Deny' & 'Grant' only for admin) -->
					<template v-slot:cell(action)="data">
						<b-link href="#" class="mr-2" v-b-modal.patent-details @click="handleOpenPatentDetailsModal(data.item)">
							Details
						</b-link>
						<b-button v-if="role === 1" class="mr-2" variant="danger" @click="denyItem(data.item)">Deny</b-button>
						<b-button v-if="role === 1" variant="success" @click="grantPatentApp(data.item.applicationNumber)">
							Grant
						</b-button>
					</template>
				</b-table>
			</b-tab>

			<b-tab title="Granted">
				<!-- Table to display granted patents -->
				<b-table striped hover :items="filteredGrantedList" :fields="fields">
					<!-- Action buttons for granted patents -->
					<template v-slot:cell(action)="data">
						<b-link href="#" v-b-modal.patent-details @click="handleOpenPatentDetailsModal(data.item)">Details</b-link>
					</template>
				</b-table>
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
			file: "", // Variable for storing uploaded file inside of <input> element.
			fileIpfsHash: "", // Variable for storing the IPFS hash returned by Pinata's API after successful upload.
			fileState: null,

			pendingList: [],
			grantedList: [],

			fields: ["applicationNumber", "applicationDate", "applicant", "title", "action"],

			patentToViewDetails: null, // Variable for the selected patent's data to pass to <PatentDetails /> component

			searchQuery: "",
		};
	},

	computed: {
		filteredPendingList() {
			if (this.searchQuery) {
				const searchTerm = this.searchQuery.toLowerCase();
				return this.pendingList.filter((patent) => {
					return (
						patent.applicant.toLowerCase().includes(searchTerm) ||
						patent.inventor.toLowerCase().includes(searchTerm) ||
						patent.title.toLowerCase().includes(searchTerm)
					);
				});
			} else {
				return this.pendingList;
			}
		},

		filteredGrantedList() {
			if (this.searchQuery) {
				const searchTerm = this.searchQuery.toLowerCase();
				return this.grantedList.filter((patent) => {
					return (
						patent.applicant.toLowerCase().includes(searchTerm) ||
						patent.inventor.toLowerCase().includes(searchTerm) ||
						patent.title.toLowerCase().includes(searchTerm)
					);
				});
			} else {
				return this.grantedList;
			}
		},
	},

	methods: {
		// Function to set-up the patent's data to pass to <PatentDetails /> component.
		handleOpenPatentDetailsModal(patent) {
			this.patentToViewDetails = patent;
		},

		// Function to pin/upload a file to Pinata's API.
		async pinFileToIPFS() {
			try {
				// Setup the data for pinning.
				const data = new FormData();
				data.append("file", this.file); // Append the file itself.
				data.append("pinataOptions", '{"cidVersion": 1}');
				data.append("pinataMetadata", {"name": "${this.file.name}"}); // Append file-name metadata.

				// Send the request to Pinata's API.
				const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", data, {
					headers: {
						// Attach the Pinata's JWT key/token in Authorization property of the request's header.
						Authorization: Bearer ${process.env.VUE_APP_PINATA_JWT},
					},
				});

				// Store the returned IPFS hash from the API's response.
				this.fileIpfsHash = await res.data.IpfsHash;
			} catch (error) {
				console.error(error);
			}
		},

		/**
		 * Handles the file upload event.
		 * Stores the uploaded from <input> element.
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
				// In case applyForPatent() fails, unpin/delete the recently pinned/uploaded file in Pinata's IPFS.
				await axios.delete(https://api.pinata.cloud/pinning/unpin/${this.fileIpfsHash}, {
					headers: {
						// Attach the Pinata's JWT key/token in Authorization property of the request's header.
						Authorization: Bearer ${process.env.VUE_APP_PINATA_JWT},
					},
				});

				console.error("Error submitting patent application:", error);
			}
		},

		async connectWallet() {
			if (window.ethereum) {
				this.provider = new ethers.providers.Web3Provider(window.ethereum);
				const accounts = await this.provider.send("eth_requestAccounts", []);
				this.account = accounts[0];
				await this.createContractInstance();

				await this.getAllPendingLists();
				await this.getAllGrantedLists();
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
			this.appliedPatentsLength = await this.contract.getAllAppliedPatents();
			this.pendingList = [];

			for (let i = 0; i < this.appliedPatentsLength; i++) {
				var patent = await this.contract.appliedPatents(i);
				var _patent = {
					applicationNumber: patent.applicationNumber, // Appended the applicationNumber field from the contract's patent itself.
					ipcClassification: patent.IPC_Classification,
					applicant: patent.applicant,
					inventor: patent.inventors,
					title: patent.title,
					patentNumber: patent.patentNumber,
					applicationDate: moment(patent.applicationDate * 1000).format("MMMM Do YYYY, h:mm:ss a"),
					publicationDate:
						patent.publicationDate == 0 ? 0 : moment(patent.publicationDate * 1000).format("MMMM Do YYYY, h:mm:ss a"), // or lll
					// Put both fileName & fileIpfsHash fields from the contract's patents in a object property.
					file: { name: patent.fileName, ipfsHash: patent.fileIpfsHash },
				};

				this.pendingList.push(_patent);
			}
		},

		async getAllGrantedLists() {
			this.grantedPatentsLength = await this.contract.getAllGrantedPatents();
			this.grantedList = [];

			for (let i = 0; i < this.grantedPatentsLength; i++) {
				var grant = await this.contract.grantedPatents(i);
				var _grant = {
					applicationNumber: grant.applicationNumber, // Appended the applicationNumber field from the contract's patent itself.
					ipcClassification: grant.IPC_Classification,
					applicant: grant.applicant,
					inventor: grant.inventors,
					title: grant.title,
					patentNumber: grant.patentNumber,
					applicationDate: moment(grant.applicationDate * 1000).format("MMMM Do YYYY, h:mm:ss a"),
					publicationDate: moment(grant.publicationDate * 1000).format("MMMM Do YYYY, h:mm:ss a"),
					// Put both fileName & fileIpfsHash fields from the contract's patents in a object property.
					file: { name: grant.fileName, ipfsHash: grant.fileIpfsHash },
				};

				this.grantedList.push(_grant);
			}
		},

		async grantPatentApp(applicationNumber) {
			try {
				const signer = this.provider.getSigner();
				const contractWithSigner = await this.contract.connect(signer);

				// Grant the patent
				const grant = await contractWithSigner.grantPatent(applicationNumber);
				await grant.wait();

				// Remove the granted patent from the pending list
				const index = this.pendingList.findIndex((patent) => patent.applicationNumber === applicationNumber);
				if (index !== -1) {
					this.pendingList.splice(index, 1);
				}
				// Save the updated pending list to local storage
				localStorage.setItem("pendingList", JSON.stringify(this.pendingList));

				// Fetch the updated list of granted patents
				await this.getAllGrantedLists();

				console.log("Patent granted successfully:", grant);
			} catch (error) {
				console.error("Error granting patent:", error);
			}
		},

		async getAllPatents() {
			await this.getAllPendingLists();
			await this.getAllGrantedLists();
			this.allPatents = [...this.pendingList, ...this.grantedList]; // Combine the arrays
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
				console.log("Role: ", this.role);
			} catch (error) {
				console.error("Error getting role:", error);
			}
		},
	},

	beforeMount() {
		this.connectWallet();
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
.user-text {
	font-size: 1.1em;
	letter-spacing: 1.2px;
	font-weight: bold;
	color: #ab9a91;
}
.admin-text {
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
	margin: 15px auto;
	text-align: left;
	padding: 10px;
	border-radius: 10px;
}
label {
	color: #aaa;
	display: inline-block;
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