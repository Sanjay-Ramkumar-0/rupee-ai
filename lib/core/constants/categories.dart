/// Permanent defaults — cannot be removed by users.
const permanentCategories = ['Others', 'Do Not Include'];

/// Default category for money received (UPI/bank credits).
const receivedCategory = 'Received';

const defaultExpenseCategories = [
  'Food',
  'Snacks',
  'Transport',
  'Shopping',
  'Fuel',
  'EMI',
  'Medical',
  'Family',
  receivedCategory,
  ...permanentCategories,
];

const paymentAppPackages = {
  'com.google.android.apps.nbu.paisa.user',
  'net.one97.paytm',
  'com.phonepe.app',
  'in.org.npci.upiapp',
  'com.dreamplug.androidapp',
  'com.csam.icici.bank.imobile',
  'com.sbi.lotusintouch',
  'com.axis.mobile',
  'com.hdfcbank',
};
