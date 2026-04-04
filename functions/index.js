const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { PlaidApi, PlaidEnvironments, Configuration } = require('plaid');

admin.initializeApp();

const plaidConfig = new Configuration({
  basePath: process.env.PLAID_ENV === 'sandbox'
    ? PlaidEnvironments.sandbox
    : PlaidEnvironments.development,
  baseOptions: {
    headers: {
      'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
      'PLAID-SECRET': process.env.PLAID_SECRET,
    },
  },
});
const plaidClient = new PlaidApi(plaidConfig);

// Functions will be added in next task
exports.ping = functions.https.onCall(async (data, context) => {
  return { ok: true };
});
