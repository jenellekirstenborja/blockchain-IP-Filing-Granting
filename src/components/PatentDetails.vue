<template>
  <!-- Modal Dialog component to show more details of selected patent -->
  <b-modal id="patent-details" hide-footer>
    <template #modal-title> Patent Details </template>

    <section class="patent-details-contents">
      <!-- Loop through properties of `patent` prop object, except of `file` property  -->
      <!-- `key` is the name of the property, such as `applicationNumber` -->
      <template v-if="patent">
        <template v-for="(value, key) in patent">
          <div
            v-if="key !== 'file'"
            :key="`patent-details-${key}`"
            class="d-flex align-items-center"
          >
            <label :for="key" class="my-3 mr-2 text-right">{{
              formatKeyToTitleCase(key)
            }}</label>
            <span class="mr-4">:</span>
            <p :id="key" class="my-3">{{ value }}</p>
          </div>
        </template>

        <!-- Show a link to download the file for `file` property if it exists -->
        <div v-if="patent.file" class="d-flex align-items-center">
          <label for="file" class="my-3 mr-2 text-right">File</label>
          <span class="mr-4">:</span>
          <template v-if="patent.file.name && patent.file.ipfsHash">
            <b-link href="#" @click="openFile(patent.file)">{{
              patent.file.name
            }}</b-link>
          </template>
          <span v-else>File not available</span>
        </div>
      </template>
      <template v-else>
        <p>No patent details available.</p>
      </template>
    </section>
  </b-modal>
</template>

<script>
import _lodash from "lodash";
import axios from "axios";

export default {
  name: "PatentDetails",

  props: ["patent"],

  data() {
    return {};
  },

  methods: {
    formatKeyToTitleCase(key) {
      return _lodash.startCase(_lodash.camelCase(key));
    },

    async openFile(file) {
      // Check if file object exists and contains necessary properties
      if (file && file.ipfsHash) {
        try {
          const response = await axios({
            url: `https://${process.env.VUE_APP_PINATA_GATEWAY_URL}/ipfs/${file.ipfsHash}`,
            method: "GET",
            responseType: "blob",
          });

          const url = window.URL.createObjectURL(new Blob([response.data]));
          const link = document.createElement("a");
          link.href = url;
          link.setAttribute("download", file.name);
          document.body.appendChild(link);
          link.click();
        } catch (error) {
          console.error("Error downloading file:", error);
        }
      } else {
        console.error("File information missing or invalid.");
      }
    },
  },
};
</script>

<style scoped>
.patent-details-contents > div > label {
  width: 146.12px;
}
</style>
