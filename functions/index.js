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

/**
 * Creates a Plaid Link token to initiate the OAuth flow in the Flutter app.
 * The link token is short-lived (30 min) and single-use.
 */
exports.createLinkToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  }

  const response = await plaidClient.linkTokenCreate({
    user: { client_user_id: context.auth.uid },
    client_name: 'MoneyInSight',
    products: ['transactions'],
    country_codes: ['US'],
    language: 'en',
  });

  return { linkToken: response.data.link_token };
});

/**
 * Exchanges a Plaid public_token (from Link success) for an access_token.
 * Stores the access_token encrypted in Firestore — never returned to the client.
 */
exports.exchangeToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  }

  const { publicToken } = data;
  if (!publicToken) {
    throw new functions.https.HttpsError('invalid-argument', 'publicToken required');
  }

  const response = await plaidClient.itemPublicTokenExchange({
    public_token: publicToken,
  });

  await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .collection('plaid')
    .doc('connection')
    .set({
      accessToken: response.data.access_token,
      itemId: response.data.item_id,
      connectedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  return { success: true };
});

/**
 * Fetches transactions from Plaid since the given date.
 * Returns raw transaction and account data for the Flutter app to process.
 */
exports.fetchTransactions = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  }

  const plaidDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .collection('plaid')
    .doc('connection')
    .get();

  if (!plaidDoc.exists) {
    return { transactions: [], accounts: [], connected: false };
  }

  const { accessToken } = plaidDoc.data();

  // Default to 30 days back if no since date provided
  const sinceDate = data.since
    ?? new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
  const today = new Date().toISOString().split('T')[0];

  const response = await plaidClient.transactionsGet({
    access_token: accessToken,
    start_date: sinceDate,
    end_date: today,
    options: { count: 500, offset: 0 },
  });

  return {
    connected: true,
    transactions: response.data.transactions.map((t) => ({
      plaidId: t.transaction_id,
      plaidAccountId: t.account_id,
      // Plaid: positive = money out (debit), negative = money in (credit)
      amountCents: Math.round(t.amount * 100),
      date: t.date,
      payee: t.merchant_name || t.name,
      memo: t.name !== t.merchant_name ? t.name : null,
    })),
    accounts: response.data.accounts.map((a) => ({
      plaidAccountId: a.account_id,
      name: a.name,
      mask: a.mask,
      type: a.type,
      subtype: a.subtype,
    })),
  };
});

/**
 * Revokes Plaid access and removes stored credentials from Firestore.
 * Called when user disconnects their bank account.
 */
exports.revokeToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  }

  const plaidRef = admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .collection('plaid')
    .doc('connection');

  const plaidDoc = await plaidRef.get();
  if (!plaidDoc.exists) return { success: true };

  const { accessToken } = plaidDoc.data();
  await plaidClient.itemRemove({ access_token: accessToken });
  await plaidRef.delete();

  return { success: true };
});
