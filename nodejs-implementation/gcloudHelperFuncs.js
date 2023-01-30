// Imports the Google Cloud client library
const { Storage } = require("@google-cloud/storage");

const { BigQuery } = require("@google-cloud/bigquery");

const fs = require('fs')

// Creates a client

const storage = new Storage();
const bigquery = new BigQuery();

async function loadCSVFromGCS() {
  // Imports a GCS file into a table with autodetected schema.

  // Configure the load job. For full list of options, see:
  // https://cloud.google.com/bigquery/docs/reference/rest/v2/Job#JobConfigurationLoad

  // The ID of your GCS bucket
  const bucketName = "raw-landing-ok-dk";

  // The ID of your GCS file
  const fileName = "readings.csv";
  
  const datasetId = "raw";
  const tableId = "readings";

  const metadata = {
    sourceFormat: 'CSV',
    autodetect: true,
    location: 'US',
  };

  // Load data from a Google Cloud Storage file into the table
  const [job] = await bigquery
    .dataset(datasetId)
    .table(tableId)
    .load(storage.bucket(bucketName).file(fileName), metadata);
  // load() waits for the job to finish
  console.log(`Job ${job.id} completed.`);

  // Check the job's status for errors
  const errors = job.status.errors;
  if (errors && errors.length > 0) {
    throw errors;
  }
}

module.exports = { loadCSVFromGCS};
