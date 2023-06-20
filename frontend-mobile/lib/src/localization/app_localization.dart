import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get holdingsNote {
    return 'If Average Price is unavailable, would be excluded from the calculation of the Portfolio Overview. Further more, it is included in 1D P&L and Current value and not included in Invested amount & Overall return.';
  }

  String get alerts {
    return 'Alerts';
  }

  String get myAlerts {
    return "My Alerts";
  }

  String get alertSettings {
    return "Alert Settings";
  }

  String get addNomineeDetail {
    return 'Add nominee details before 31st Mar 2023';
  }

  String get addNominee {
    return 'Add Nominee';
  }

  String get ratio {
    return 'Ratio';
  }

  String get optoutOfNominee {
    return 'Opt-out of Nominee';
  }

  String get toKeepDematAccACTIVE {
    return 'to keep demat account active';
  }

  String get charges {
    return ' + Charges';
  }

  String get tapOnPrice {
    return "Tap on the price to select";
  }

  String get day {
    return Intl.message('Day');
  }

  String get depth {
    return Intl.message("Depth");
  }

  String get setBiometrics {
    return Intl.message('Or else, set biometrics');
  }

  String get enableBiometrics {
    return Intl.message('Or else, Enable biometrics');
  }

  String get currentExposure {
    return Intl.message('Current Exposure');
  }

  String get exposureTaken {
    return Intl.message('Exposure Taken');
  }

  String get biometricNotRecognized {
    return Intl.message("Your biometrics have not been recognised, try again.");
  }

  String get passwordChangedToast {
    return Intl.message(
        'Yay! Your new password is set. Keep it safe now 😀. Let`s login now!');
  }

  String get undermaintanence {
    return Intl.message('Our shelf is under maintenance');
  }

  String get networkissue {
    return Intl.message('Network issue !!!');
  }

  String get wewillback {
    return Intl.message('We will be back soon !!!');
  }

  String get accountsuspended {
    return Intl.message('Account Suspended');
  }

  String get withdrawAll {
    return Intl.message("Withdraw All");
  }

  String get myaacountBlockedHeading {
    return "My Account is Blocked!";
  }

  String get noSymbolFound {
    return "No symbols Found";
  }

  String get myaacountBlocked {
    return Intl.message('My account is blocked! Help!');
  }
  //

  String get myaacountBlockeddesc1 {
    return "Don’t panic.. Sometimes when we type an old/incorrect password a little too many times, the account gets blocked. Lucky for you, we’ve kept unblocking pretty simple.";
  }

  String get myaacountBlockeddesc2 {
    return "Just click on the dialog box ”Unblock now” Enter your email ID and Date of Birth, Viola! Your account is activated. You now need to set a new password, a new PIN and enable biometrics to make sure it doesn’t happen again!\n";
  }

  String get openInfotitle1 {
    return Intl.message("What is an open position?");
  }

  String get openInfotitle3 {
    return Intl.message("How to navigate this screen?");
  }

  String get openInfotitle4 {
    return Intl.message("Your open positions are summarized here.");
  }

  String get openInfosubtitle1 {
    return Intl.message(
        "When a position is open its value fluctuates continuously depending on the stock price movement.");
  }

  String get openInfobullettitle1 {
    return Intl.message("Cash : ");
  }

  String get openInfobullettitle2 {
    return Intl.message("F&O : ");
  }

  String get openInfobullettitle3 {
    return Intl.message("Understanding Positions Table : ");
  }

  String get openInfobullettitle4 {
    return Intl.message("Search : ");
  }

  String get openInfobullettitle5 {
    return Intl.message("Sort and filter : ");
  }

  String get openInfobullettitle6 {
    return Intl.message("Close or Add to your position: ");
  }

  String get openInfobulletdata6 {
    return Intl.message(
        "Tap on any of the positions on the list to view more details. From here, you can also choose to 'Exit' the position, 'Convert' it from intraday to delivery or 'Add' more positions.");
  }

  String get openInfobulletdata5 {
    return Intl.message("Your positions using the smart filter");
  }

  String get openInfobulletdata4 {
    return Intl.message(
        "You can view all your positions from the list or cut through the clutter using the search feature. Just tap on search icon and type the name of security you are looking for.");
  }

  String get openInfobulletdata3 {
    return Intl.message(
        "On the left side, you will find the details of the security you bought/sold, your order type (e.g., delivery or intraday) and the quantity and average price of your order. On the right column, by default, you will see the day’s profit and loss, as of now, in absolute and percentage terms. Tapping on the right column header will display the current value of your investment and the amount you invested along with the last traded price of that security.");
  }

  String get openInfobulletdata1 {
    return Intl.message(
        "Only includes trades done today. Previously traded positions are not shown here.");
  }

  String get openInfobulletdata2 {
    return Intl.message(
        "For derivatives, it includes trades done today and all carried forward previous positions.");
  }

  String get openInfotitle2 {
    return Intl.message(
        "An open position is a buy or sell trade that has been entered, but which has yet to be closed with a trade going in the opposite direction. For example, if you bought a stock but have not sold it yet, then it will be standing under “open position”.");
  }

  String get confirm {
    return Intl.message('Confirm');
  }

  String get commodity {
    return Intl.message('commodity');
  }

  String get currency {
    return Intl.message('currency');
  }

  String get overall {
    return Intl.message('Overall');
  }

  String get overallPosition {
    return Intl.message('Overall Position');
  }

  String get dayPosition {
    return Intl.message('Day Position');
  }

  String get state {
    return Intl.message('State');
  }

  String get overallPnlInfoSubheading1 {
    return Intl.message('For stocks purchased today,');
  }

  String get todayPnlInfodescription1 {
    return Intl.message(
        'shows the profitability of your current positions since the last trading day in absolute and percentage terms.');
  }

  String get overallPnlDescription1 {
    return Intl.message(
        'shows the overall profit or loss of your position (cash and derivatives) in absolute and percentage terms.');
  }

  String get overallPnlFormula {
    return Intl.message(
        "= (Current LTP – Avg buy price/ sell price) x Quantity");
  }

  String get fromDate {
    return Intl.message('From Date');
  }

  String get toDate {
    return Intl.message('To Date');
  }

  String get threemonths {
    return Intl.message('3M');
  }

  String get oneweek {
    return Intl.message('1 W');
  }

  String get onemonth {
    return Intl.message('1 M');
  }

  String get threeweeks {
    return Intl.message('3 W');
  }

  String get customDates {
    return Intl.message('Custom Dates');
  }

  String get letsInvest {
    return Intl.message('Let\'s Invest');
  }

  String get exitAppMsg {
    return Intl.message("Are you sure you want to exit the app?");
  }

  String get pinCode {
    return Intl.message('Pin Code');
  }

  String get passwordMismatch {
    return Intl.message('"Password" & "Confirm password" should match.');
  }

  String get maxTryError {
    return Intl.message("Max Attempt Reached Try Again");
  }

  String get passwordAlphaNumValidation {
    return Intl.message(
        'Your password should be alphanumeric & 8-16 character long');
  }

  String get changepasswordAlphaNumValidation {
    return Intl.message('Password should be alphanumeric');
  }

  String get viewHoldings {
    return Intl.message('View Holdings');
  }

  String get symbolnotfound {
    return Intl.message(
        'We are sorry but there are no results for your search. Did you make a typo? Try again');
  }

  String get relationship {
    return Intl.message('Relationship');
  }

  String get nomineeName {
    return Intl.message('Nominee Name');
  }

  String get helpAndSupport {
    return Intl.message('Help and Support');
  }

  String get support {
    return Intl.message('Support');
  }

  String get links {
    return Intl.message('Links');
  }

  String get tradetron {
    return Intl.message('Tradetron');
  }

  String get wealth4me {
    return Intl.message('Wealth4Me');
  }

  String get wealthdesk {
    return Intl.message('Wealthdesk');
  }

  String get wealthdeskwithbasket {
    return Intl.message('Wealthdesk with premium stock basket');
  }

  String get whatsappreport {
    return Intl.message('Whatsapp Report');
  }

  String get pledgewhatsapp {
    return Intl.message('Pledge Whatsapp');
  }

  String get socialmediaLink {
    return Intl.message('Social Media Link');
  }

  String get monthlyNewsletter {
    return Intl.message('Monthly Newsletter');
  }

  String get maxlimitReached {
    return Intl.message('Maximum Limit Reached');
  }

  String get selectatopic {
    return Intl.message('Select a Topic');
  }

  String get verified {
    return Intl.message('Verified');
  }

  String get payments {
    return Intl.message('Payments');
  }

  String get reportProblem {
    return Intl.message('Report a Problem');
  }

  String get requestNewFeature {
    return Intl.message('Request a New Feature');
  }

  String get readBlog {
    return Intl.message('Read Blog');
  }

  String get userguide {
    return Intl.message('User Guide');
  }

  String get ipo {
    return Intl.message('IPO');
  }

  String get getHelp {
    return Intl.message('Get Help');
  }

  String get otherInvestments {
    return Intl.message('Other Investments');
  }

  String get rewardsAndReferral {
    return Intl.message('Rewards and Referrals');
  }

  String get equity {
    return Intl.message('equity');
  }

  String get equityTitle {
    return Intl.message('Equity');
  }

  String get fandoTitle {
    return Intl.message('F & O');
  }

  String get commodityTitle {
    return Intl.message('Commodity');
  }

  String get currencyTitle {
    return Intl.message('Currency');
  }

  String get fando {
    return Intl.message('f&o');
  }

  String get mutualfunds {
    return Intl.message('mutualFunds');
  }

  String get trades {
    return Intl.message('Trades');
  }

  String get funds {
    return Intl.message('Funds');
  }

  String get accNo {
    return Intl.message('Account Number');
  }

  String get branchName {
    return Intl.message('Branch Name');
  }

  String get holdings {
    return Intl.message('Holdings');
  }

  String get dpholdings {
    return Intl.message('DP Holdings');
  }

  String get tradeHistory {
    return Intl.message('Trade History');
  }

  String get myBasket {
    return Intl.message('My Basket');
  }

  String get contractNote {
    return Intl.message('Contract Note');
  }

  String get fundsHistory {
    return Intl.message('Funds History');
  }

  String get cashplreport {
    return Intl.message('Cash P&L Report');
  }

  String get fnoplreport {
    return Intl.message('F&O P&L Report');
  }

  String get arihantLedger {
    return Intl.message('Arihant Ledger');
  }

  String get ifscCode {
    return Intl.message('IFSC Code');
  }

  String get bankAccounts {
    return Intl.message('Bank Accounts');
  }

  String get fundView {
    return Intl.message('Funds View');
  }

  String get fundHistory {
    return Intl.message('Fund History');
  }

  String get myProfile {
    return Intl.message('My Profile');
  }

  String get permanentAddress {
    return Intl.message('Permanent Address');
  }

  String get tradingPreferences {
    return Intl.message('Active Segments');
  }

  String get comingSoon {
    return Intl.message('Coming Soon');
  }

  String get activate {
    return Intl.message('Activate');
  }

  String get depositoryName {
    return Intl.message('Depository Name');
  }

  String get nominee {
    return Intl.message('Nominee Details');
  }

  String get mtf {
    return Intl.message('MTF');
  }

  String get inactive {
    return Intl.message('Inactive');
  }

  String get accOpen {
    return Intl.message('Account Opening forms and others');
  }

  String get mydoc {
    return Intl.message('My Documents');
  }

  String get younominee {
    return Intl.message('Your nominee Details');
  }

  String get dpid {
    return Intl.message('DP ID');
  }

  String get dematAccountNo {
    return Intl.message('Demat Account No');
  }

  String get depositoryParticipant {
    return Intl.message('Depository Participant');
  }

  String get gender {
    return Intl.message('Gender');
  }

  String get dematAccountDetails {
    return Intl.message('Demat Account Details');
  }

  String get accountDetails {
    return Intl.message("Account Details");
  }

  String get taxResidency {
    return Intl.message('Tax Residency');
  }

  String get na {
    return Intl.message('NA');
  }

  String get fatherName {
    return Intl.message('Father\'s Name');
  }

  String get martialStatus {
    return Intl.message('Martial Status');
  }

  String get pan {
    return Intl.message('PAN');
  }

  String get dateofbirth {
    return Intl.message('Date of Birth');
  }

  String get personDetail {
    return Intl.message('Personal Detail');
  }

  String get correspondenceAddress {
    return Intl.message('Correspondence Address');
  }

  String get email {
    return Intl.message('Email');
  }

  String get mobile {
    return Intl.message('Mobile');
  }

  String get contactDetails {
    return Intl.message('Contact Details');
  }

  String get reports {
    return Intl.message('Reports');
  }

  String get yourTradingReports {
    return Intl.message('Your trading reports');
  }

  String get referandEarn {
    return Intl.message('Refer and Earn');
  }

  String get refernNEarn {
    return Intl.message("Refer & Earn");
  }

  String get earnByreference {
    return Intl.message('Earn by refering your friends');
  }

  String get calculator {
    return Intl.message('Calculator');
  }

  String get calculateTradeEarnings {
    return Intl.message('Calculate your trade earnings');
  }

  String get withDraw {
    return Intl.message('Withdraw');
  }

  String get withDrawalcash {
    return Intl.message('Withdrawable Cash');
  }

  String get marginPledge {
    return Intl.message('Margin Pledge');
  }

  String get marginCalulator {
    return Intl.message("Margin Calculator");
  }

  String get pledgeHoldings {
    return Intl.message('Pledge Holdings');
  }

  String get settings {
    return Intl.message('Settings');
  }

  String get profileSettings {
    return Intl.message('Profile Settings');
  }

  String get faq {
    return Intl.message('FAQs, Contact Support');
  }

  String get readyToInvest {
    return Intl.message('Ready to Invest');
  }

  String get availableForInvest {
    return Intl.message('Available for Invest');
  }

  String get accountBalance {
    return Intl.message('Account Balance');
  }

  String get recentTransaction {
    return Intl.message('Recent Transactions');
  }

  String get moneyWithdrawn {
    return Intl.message('Money Withdrawn');
  }

  String get moneyWithdrawnFail {
    return Intl.message('Money Withdrawn Failed');
  }

  String get moneyAdded {
    return Intl.message('Money Added');
  }

  String get moneyAddedFailed {
    return Intl.message('Money Added (Failed)');
  }

  String get bankandAutopay {
    return Intl.message('Bank & AutoPay mandates');
  }

  String get snapshotFundposition {
    return Intl.message('Snapshot of your fund position');
  }

  String get historyCashpay {
    return Intl.message('History of your cash payin & payout');
  }

  String get myAccout {
    return Intl.message('My Account');
  }

  String get poweredBy {
    return Intl.message('Powered by Arihant Capital');
  }

  String get poweredby {
    return Intl.message('Powered by ');
  }

  String get arihantcapName {
    return Intl.message('Arihant Capital Markets Ltd.');
  }

  String get bording1 {
    return Intl.message('Easy trade with our mobile ');
  }

  String get bording11 {
    return Intl.message('application');
  }

  String get bording2 {
    return Intl.message('Track your positions using');
  }

  String get bording22 {
    return Intl.message('web platform');
  }

  String get bording3 {
    return Intl.message('We support you to trade in');
  }

  String get bording33 {
    return Intl.message('a better way ');
  }

  String get tradeWith {
    return Intl.message('Trade with');
  }

  String get arihant {
    return Intl.message('Arihant');
  }

  String get joinarihant {
    return Intl.message('Join Arihant');
  }

  String get exitToLoginScreen {
    return Intl.message('Exit to Login Screen');
  }

  String get noInternetConnnection {
    return Intl.message('No Internet Connection');
  }

  String get loginAndSetNewPin {
    return Intl.message("Login Again and Set New Pin");
  }

  String get networkError {
    return Intl.message(
        'We seem to have lost touch. Check your internet connection & reload Arihant+ app');
  }

  String get ok {
    return Intl.message('Ok');
  }

  String get login {
    return Intl.message('Login');
  }

  String get logout {
    return Intl.message('Logout');
  }

  String get logoutWarningMessage {
    return Intl.message(
        'Are you sure that you want to logout ACML application?');
  }

  String get joinArihant {
    return Intl.message('Join Arihant');
  }

  String get loginTitle {
    return Intl.message('Welcome');
  }

  String get loginDescription {
    return Intl.message('Login here to start investing.');
  }

  String get viewPositions {
    return Intl.message('View Position');
  }

  String get repeatOrder {
    return Intl.message('Repeat Order');
  }

  String get repeat {
    return Intl.message('Repeat');
  }

  String get cancel {
    return Intl.message('Cancel');
  }

  String get save {
    return Intl.message('Save');
  }

  String get success {
    return Intl.message('Success');
  }

  String get modify {
    return Intl.message('Modify');
  }

  String get userIdTitle {
    return Intl.message('Email id/Client code/Mobile');
  }

  String get passwordTitle {
    return Intl.message('Password');
  }

  String get search {
    return Intl.message('Search Results');
  }

  String get explore {
    return Intl.message('Explore');
  }

  String get exploreInfo {
    return Intl.message(
        'Arihant loves to simplify your investment decisions. You can access popularly tracked stock lists like Top Gainers & Losers and 52-week High/Low all in one click!');
  }

  String get recentSearch {
    return Intl.message('Recent Search');
  }

  String get searchHint {
    return Intl.message('Search eg: TCS, M&M or Infy');
  }

  String get proceed {
    return Intl.message('Proceed');
  }

  String get writeToUs {
    return Intl.message('Write To Us');
  }

  String get needHelp {
    return Intl.message('Need Help');
  }

  String get escalationMatrix {
    return Intl.message('Escalation Matrix');
  }

  String get signUpDescription {
    return Intl.message('Not an Arihant client yet? ');
  }

  String get signUp {
    return Intl.message('Sign up');
  }

  String get forgotPassword {
    return Intl.message('Forgot Password');
  }

  String get verifyItsyou {
    return Intl.message('Verify its really you !');
  }

  String get setPin {
    return Intl.message('Set PIN');
  }

  String get setPinDescription {
    return Intl.message(
        'Markets are fast, and logins can be faster. Set a 4-digit pin to quickly access your account next time (so you never miss a great deal)!');
  }

  String get reSetPinDescription {
    return Intl.message('Just to confirm, can you enter it again?');
  }

  String get enterPin {
    return Intl.message('Enter PIN');
  }

  String get reEnterPin {
    return Intl.message("Re-enter PIN");
  }

  String get confirmation {
    return Intl.message("Confirmation");
  }

  String get withdrawalConfirmation {
    return Intl.message("Withdrawal Confirmation");
  }

  String get withdrawFunds {
    return Intl.message("Withdraw Funds");
  }

  String get modifyFunds {
    return Intl.message("Modify Funds");
  }

  String get viewFundsHistory {
    return Intl.message('View Funds History');
  }

  String get pinNotMatchingErrorDescription {
    return Intl.message("Did you hit a wrong key? Enter PIN again.");
  }

  String get networkIssueDescription {
    return Intl.message('Oops!'
        'We seem to have lost touch. Go check your internet connection and try again.');
  }

  String get noDataAvailableErrorMessage {
    return Intl.message('No data available');
  }

  String get nodatainWatchlist {
    return Intl.message(
        "Oops! We can't find what you are looking for, Refine your search and try again.");
  }

  String get noDataAvailableErrorMessageFornews {
    return Intl.message('No recent news for this stock');
  }

  //

  String get noDealsDataAvailableErrorMessage {
    return Intl.message('No Deals Available');
  }

  String get noSearchResults {
    return Intl.message('No search results.');
  }

  String get recentSearchNotAvailbleErrorMessage {
    return Intl.message('Recent Search Not Available');
  }

  String get retry {
    return Intl.message('Retry');
  }

  String get welcome {
    return Intl.message("Welcome,");
  }

  String get welcomeDescription {
    return Intl.message(
        "Your PIN is set. Enable lightning-fast logins with biometrics.");
  }

  String get accountBlocked {
    return Intl.message("Account Blocked!");
  }

  String get pinBlocked {
    return Intl.message("Pin Blocked!");
  }

  String get reregisterMpin {
    return Intl.message("Re-register Mpin!");
  }

  String get accountBlockedDescription {
    return Intl.message(
        "Your account has been blocked.Try unblocking the account to proceed further.");
  }

  String get unblockAccount {
    return Intl.message("Unblock Account");
  }

  String get unblockPin {
    return Intl.message("Unblock Pin");
  }

  String get reregisterPin {
    return Intl.message("Re-register Pin");
  }

  String get unBlockAccountDescription {
    return Intl.message(
        "Looks like your account is blocked. But don’t worry, just enter the details below and you can login again.");
  }

  String get dob {
    return Intl.message("DOB");
  }

  String get welcomeBack {
    return Intl.message("Welcome back");
  }

  String get welcomeBackDescription {
    return Intl.message("Enter PIN to login to your account.");
  }

  String get welcomeBackDescriptionBiometric {
    return Intl.message("Use Biometric to login to your account.");
  }

  String get forgotPin {
    return Intl.message("Forgot PIN");
  }

  String get switchAccount {
    return Intl.message("Switch account");
  }

  String get passwordExpired {
    return Intl.message("Password Expired!");
  }

  String get passwordExpiredDescription {
    return Intl.message(
        "Your account password had expired. Kindly change your old password for trading with Arihant.");
  }

  String get passwordExpiryButton {
    return Intl.message("Change password");
  }

  String get setNewPassword {
    return Intl.message("Set New Password");
  }

  String get setPasswordDescription {
    return Intl.message(
        "Make sure to keep it safe (and in your memory) for next time!");
  }

  String get setPasswordheader {
    return Intl.message("Enter new password");
  }

  String get oldPassword {
    return Intl.message("Old Password");
  }

  String get newPassword {
    return Intl.message("New Password");
  }

  String get confirmPassword {
    return Intl.message("Confirm Password");
  }

  String get currentPasswordLengthError {
    return Intl.message('Current password should be minimum 2 characters');
  }

  String get newPasswordAndConfrimPasswordNotMatchingError {
    return Intl.message('"Password" & "Confirm password" should match.');
  }

  String get currentPasswordAndNewPasswordShouldNotBeSameError {
    return Intl.message(
        'Your new password cannot be the same as your old password.');
  }

  String get usernameMinimumError {
    return Intl.message(
        'Userid should be minimum 1 characters and maximum 50 characters');
  }

  String get invalidDOBError {
    return Intl.message('Invalid DOB');
  }

  String get minimumPasswordError {
    return Intl.message(
        'Your password should be alphanumeric & 8-16 character long');
  }

  String get invalidPasswordError {
    return Intl.message('Invalid Password');
  }

  String get passwordEmptyError {
    return Intl.message("Password field can't be empty");
  }

  String get passwordValidationError {
    return Intl.message('Password field will not accept spaces');
  }

  String get passwordValidationError8 {
    return Intl.message(
        'Password should contain atleast 8 characters and one Uppercase and Smallcase letter and should contain one special character too');
  }

  String get newPasswordShouldNotContainUserId {
    return Intl.message('Password should not contain user id');
  }

  String get switchAccountTitle {
    return Intl.message("Switch Account");
  }

  String get switchAccountDescription {
    return Intl.message(
        "Which account do you want to login to? Or open a new one instead!.");
  }

  String get newAccount {
    return Intl.message("New Account");
  }

  String get loggedOn {
    return Intl.message("Logged on");
  }

  String get setFingerPrintAuthentication {
    return Intl.message("Set Biometric Authentication");
  }

  String get setFingerPrintDescription {
    return Intl.message(
        "Let’s get your Biometric for one step login next time.");
  }

  String get fingerPrintAuthentication {
    return Intl.message("Biometric Authentication");
  }

  String get setFingerPrint {
    return Intl.message("Set Biometric");
  }

  String get setFaceIdAuthentication {
    return Intl.message("Setup Biometric to get a hands-free login.");
  }

  String get setFaceIdDescription {
    return Intl.message(
        "Let’s get your Biometric for one step login next time.");
  }

  String get faceIdAuthentication {
    return Intl.message("Biometric Authentication");
  }

  String get setFaceId {
    return Intl.message("Set Biometric");
  }

  String get skip {
    return Intl.message("Skip");
  }

  String get loginViaOtp {
    return Intl.message("Login via OTP");
  }

  String get authenticateFingerPrint {
    return Intl.message("Use your fingerprint sensor for Login to Arihant.");
  }

  String get loginWithBiometrics {
    return Intl.message("Or else, try biometrics.");
  }

  String get gotoSettingorEnableBiometric {
    return Intl.message(
        "If you want to Login using OTP, Please click on the Skip button or Set the Biometric on your device by clicking on Go to Settings");
  }

  String get enterPinandOtp {
    return Intl.message("Or else, Enter Pin and OTP.");
  }

  String get orElseEnterPin {
    return Intl.message("Or else, Enter Pin.");
  }

  String get forgetPasswordDescription {
    return Intl.message(
        "Don’t worry, it happens to the best of us! Just enter the following details and let’s get you back on the radar. ");
  }

  String get verifyDetails {
    return Intl.message(
        "Verify your details & set your password to start trading");
  }

  String get setOtpDescription1 {
    return Intl.message('Enter the OTP which sent to your registered');
  }

  String get setOtpDescription2 {
    return Intl.message('e-mail ID and phone number');
  }

  String get enterOtp {
    return Intl.message("Enter OTP");
  }

  String get setResentOtpDescription {
    return Intl.message('Resend OTP in ');
  }

  String get setResentSecs {
    return Intl.message('secs');
  }

  String get setResentOtp {
    return Intl.message('Resend OTP');
  }

  String get versionUpdateAndroidDesc {
    return Intl.message(
        'A New version of Arihant Plus is available in Google Play Store. Update Now?');
  }

  String get versionUpdateiOSDesc {
    return Intl.message(
        'A New version of Arihant Plus is available in App Store. Update Now?');
  }

  String get update {
    return Intl.message('Update');
  }

  String get invalidUid {
    return Intl.message('Invalid uid');
  }

  String get watchlist {
    return Intl.message('Watchlist');
  }

  String get newwatch {
    return Intl.message('Newwatch');
  }

  String get markets {
    return Intl.message('Markets');
  }

  String get myOrders {
    return Intl.message('My Orders');
  }

  String get topIndices {
    return Intl.message('TopIndices');
  }

  String get topIndicesEditor {
    return Intl.message('TopIndicesEditor');
  }

  String get myFunds {
    return Intl.message('My Funds');
  }

  String get positions {
    return Intl.message('Positions');
  }

  String get startTrading {
    return Intl.message('Start Trading');
  }

  String get startInvesting {
    return Intl.message('Start Investing');
  }

  String get addFund {
    return Intl.message('Add Fund');
  }

  String get empty {
    return Intl.message('Empty');
  }

  String get emptyStockDescription1 {
    return Intl.message('Kick start your trading with Arihant');
  }

  String get emptyStockDescription2 {
    return Intl.message(
        'Dont wait for your time, start trading with us for a secure investment.');
  }

  String get suggestedStocks {
    return Intl.message('Suggested Stocks');
  }

  String get buy {
    return Intl.message('Buy');
  }

  String get addtoBasket {
    return Intl.message("Add to Basket");
  }

  String get modifyBasket {
    return Intl.message("Modify Basket");
  }

  String get bought {
    return Intl.message('Bought');
  }

  String get boughtDemat {
    return Intl.message('Bought(Demat)');
  }

  String get boughtT1 {
    return Intl.message('Bought(T1)');
  }

  String get sell {
    return Intl.message('Sell');
  }

  String get sold {
    return Intl.message('Sold');
  }

  String get watchlistGroups {
    return Intl.message('Watchlist Groups');
  }

  String get transferToArihant {
    return Intl.message('Transfer To Arihant');
  }

  String get addmoneyNEFTandIMPS {
    return Intl.message('Add Money via NEFT/RTGS/IMPS');
  }

  String get chooseBankList {
    return Intl.message('Choose Bank');
  }

  String get generalNeedHelp {
    return Intl.message('Need Help?');
  }

  String get chooseWatchlistGroups {
    return Intl.message('Choose watchlist');
  }

  String get watchlists {
    return Intl.message('Watchlists');
  }

  String get myWatchlists {
    return Intl.message('My Watchlists');
  }

  String get predefinedWatchlists {
    return Intl.message('Predefined Watchlists');
  }

  String get manageWatchlist {
    return Intl.message('Manage Watchlist');
  }

  String get manage {
    return Intl.message('Manage');
  }

  String get create {
    return Intl.message('Create');
  }

  String get myStocks {
    return Intl.message('My Stocks');
  }

  String get edit {
    return Intl.message('Edit');
  }

  String get deleteWatchlistTitle {
    return Intl.message('Delete Watchlist Group?');
  }

  String get deleteDescriptionWatchlist {
    return Intl.message('Are you sure you want to delete ');
  }

  String get deleteDescription {
    return Intl.message('Are you sure ? Do you want to delete ');
  }

  String get delete {
    return Intl.message('Delete');
  }

  String get deleteYes {
    return Intl.message('Yes, Delete');
  }

  String get yesSave {
    return Intl.message('Yes,Save');
  }

  String get editBasketDesc {
    return Intl.message('Do you want to save changes?');
  }

  String get deleteBasketorderDesc {
    return Intl.message('Are you sure you want to delete this order?');
  }

  String get deleteBasketDesc {
    return Intl.message('Are you sure you want to delete this basket?');
  }

  String get no {
    return Intl.message('No');
  }

  String get notNow {
    return Intl.message('Not now');
  }

  String get editWatchlist {
    return Intl.message('Edit Watchlist');
  }

  String get editBasket {
    return Intl.message('Edit Basket');
  }

  String get rename {
    return Intl.message('Rename');
  }

  String get done {
    return Intl.message('Done');
  }

  String get stocks {
    return Intl.message('Stocks');
  }

  String get sortAndFilter {
    return Intl.message('Sort & Filter');
  }

  String get convert {
    return Intl.message('Convert');
  }

  String get sort {
    return Intl.message('Sort');
  }

  String get clear {
    return Intl.message('Clear');
  }

  String get deleteBasket {
    return Intl.message('Delete Basket');
  }

  String get deleteBasketorder {
    return Intl.message('Delete Order');
  }

  String get deleteSymbol {
    return Intl.message('Delete Symbol');
  }

  String get manageWatchlistEmptyTitle {
    return Intl.message('Group your favourite scrips');
  }

  String get manageWatchlistEmptyDescription {
    return Intl.message(
        'Create a Watchlist group and add your favourite scrips for easy trading.');
  }

  String get createNew {
    return Intl.message('Create New');
  }

  String get executeAllorder {
    return Intl.message('Execute All Orders');
  }

  String get createAlert {
    return Intl.message('Create Alert');
  }

  String get createWatchlist {
    return Intl.message('Create Watchlist');
  }

  String get createBasket {
    return Intl.message('Create Basket');
  }

  String get createWatchlistDescription {
    return Intl.message('Watchlist Name');
  }

  String get createBasketDescription {
    return Intl.message('Basket Name');
  }

  String get charactersRemaining {
    return Intl.message('characters remaining');
  }

  String get searchInfotext {
    return Intl.message('How Search Works?');
  }

  String get searchInfoDescrptiontext {
    return Intl.message(
        'We’re pretty sure you have an idea about what the Search function does. But there’s a twist to the Arihant Search page 😃. We have added a few smart features to make it easier for you to explore stocks, futures and options, ETFs and check out what’s going on in the market.');
  }

  String get searchInfotitletext {
    return Intl.message('The Search Box');
  }

  String get searchInfoDescriptiontext1 {
    return Intl.message(
        'Our smart search box is anything but basic. It helps you search companies with pre-defined filters. You can search the company across the universe of securities, or cut through the clutter and choose to search from only equity, only futures, options or ETFs category. \n \nEvery time you’ll enter the search section, the list of your last viewed stocks will be right there - we named it ');
  }

  String get searchInfoDescriptiontext2 {
    return Intl.message(
        '. Smart isn’t it? We understand what a pain it is to keep typing the same stock in search. Hence, we added this feature to make it easier for you to find those in just a click. \n \nThrough search you can also ');
  }

  String get searchInfoDescriptiontext3 {
    return Intl.message('add stocks to your watchlist, ');
  }

  String get searchInfoDescriptiontext4 {
    return Intl.message(' from the search results, using the small “+” icon ');
  }

  String get searchInfoDescriptiontext5 {
    return Intl.message(
        '. If the security is already added to one of your watchlists, you will see a filled green button against it ');
  }

  String get searchInfoDescriptiontext6 {
    return Intl.message(
        '. However, you can still choose to add it to other watchlists.');
  }

  String get exploreInfoDescription {
    return Intl.message(
        'That’s not it. We have also created some popular lists for you to easily check out what’s going on in the markets. With one click, you can see the list of stocks that hit 52-week high or low, top gainers or losers of the day, Nifty 50 stocks watchlist and more. These are for informational purposes and are not recommendations. ');
  }

  String get searchInfoFooterText {
    return Intl.message('🌟 Enjoy your Arihant Search experience!');
  }

  String get watchlistNameExistError {
    return Intl.message('Enter a unique name for your new watchlist.');
  }

  String get basketNameExistError {
    return Intl.message('Enter a unique name for your new basket.');
  }

  String get watchlistNameNoChangeError {
    return Intl.message('No changes were made');
  }

  String get invalidNewWnameError {
    return Intl.message('Invalid NewMWname');
  }

  String get trade {
    return Intl.message('Trade');
  }

  String get porfolio {
    return Intl.message('Porfolio');
  }

  String get nse {
    return Intl.message('NSE');
  }

  String get bse {
    return Intl.message('BSE');
  }

  String get marketsCash {
    return Intl.message('Cash');
  }

  String get marketsDummySpacer {
    return Intl.message('Dummy');
  }

  String get orders {
    return Intl.message('Orders');
  }

  String get gtdOrders {
    return Intl.message('GTD Orders');
  }

  String get indexRollover {
    return Intl.message('Index Rollover');
  }

  String get highestRollover {
    return Intl.message('Highest Rollover');
  }

  String get lowestRollover {
    return Intl.message('Lowest Rollover');
  }

  String get marketsTopGainers {
    return Intl.message('Top Gainers');
  }

  String get marketsTopLosers {
    return Intl.message('Top Losers');
  }

  String get marketsTopFiftyTwoWkHgh {
    return Intl.message('52W High');
  }

  String get marketsMostActive {
    return Intl.message('Most Active');
  }

  String get marketsTopFiftyTwoWkLow {
    return Intl.message('52W Low');
  }

  String get marketsMostActiveVolume {
    return Intl.message('Most Active Volume');
  }

  String get marketsMostActiveValue {
    return Intl.message('Most Active Value');
  }

  String get marketsUpperCircuit {
    return Intl.message('Upper Circuit');
  }

  String get marketsLowerCircuit {
    return Intl.message('Lower Circuit');
  }

  String get oIGainers {
    return Intl.message('OI Gainers');
  }

  String get oILosers {
    return Intl.message('OI Losers');
  }

  String get fiiDiiActivity {
    return Intl.message('FII DII Activity');
  }

  String get putCallRatio {
    return Intl.message('Put Call Ratio');
  }

  String get deals {
    return Intl.message('Deals');
  }

  String get rollOver {
    return Intl.message('Roll Over');
  }

  String get marketMovers {
    return Intl.message('Market Movers');
  }

  String get marketIndices {
    return Intl.message('Market Indices');
  }

  String get customizeIndices {
    return Intl.message('Customize Indices');
  }

  String get chooseIndices {
    return Intl.message('Choose Market Indices');
  }

  String get chooseIndex {
    return Intl.message('Choose Index');
  }

  String get marketsOIGainers {
    return Intl.message('OI Gainers');
  }

  String get marketsOILosers {
    return Intl.message('OI Losers');
  }

  String get marketsFandO {
    return Intl.message('F&O');
  }

  String get nfo {
    return Intl.message('FO');
  }

  String get manageAlerts {
    return Intl.message('Manage Alerts');
  }

  String get addAlert {
    return Intl.message('Add Alert');
  }

  String get constituents {
    return Intl.message('Constituents');
  }

  String get contributor {
    return Intl.message('Contributors');
  }

  String get quoteOverview {
    return Intl.message('Overview');
  }

  String get quoteChart {
    return Intl.message('Chart');
  }

  String get quoteFandO {
    return Intl.message('F&O');
  }

  String get quoteAnalysis {
    return Intl.message('Analysis');
  }

  String get quoteFinancials {
    return Intl.message('Financials');
  }

  String get quoteFinancialsIncomeStatements {
    return Intl.message('Income Statement');
  }

  String get stockDeals {
    return Intl.message('Stock Deals');
  }

  String get stockDetails {
    return Intl.message('Stock Details');
  }

  String get netHoldings {
    return Intl.message('Net Holdings');
  }

  String get quoteFinancialsShareHoldings {
    return Intl.message('Shareholding');
  }

  String get quarterly {
    return Intl.message('Quarterly');
  }

  String get yearly {
    return Intl.message('Yearly');
  }

  String get valuesInCr {
    return Intl.message('value are in ₹.Cr');
  }

  String get viewMore {
    return Intl.message('View More');
  }

  String get quoteDeals {
    return Intl.message('Deals');
  }

  String get quoteNews {
    return Intl.message('News');
  }

  String get quoteCorporateAction {
    return Intl.message('Corporate Actions');
  }

  String get quotePeers {
    return Intl.message('Peers');
  }

  String get asOf {
    return Intl.message('As of');
  }

  String get vol {
    return Intl.message('Vol');
  }

  String get marketDepth {
    return Intl.message('Market Depth');
  }

  String get bid {
    return Intl.message('Bid');
  }

  String get ask {
    return Intl.message('Ask');
  }

  String get qty {
    return Intl.message('Qty');
  }

  String get todaysTradeSummary {
    return Intl.message('Today’s Trade Summary');
  }

  String get broughtForward {
    return Intl.message('Brought Forward');
  }

  String get order {
    return Intl.message('Order');
  }

  String get bidTotal {
    return Intl.message('Bid Total');
  }

  String get askTotal {
    return Intl.message('Ask Total');
  }

  String get performance {
    return Intl.message('Performance');
  }

  String get fiftytwow {
    return Intl.message('52W');
  }

  String get high {
    return Intl.message('High');
  }

  String get low {
    return Intl.message('Low');
  }

  String get volume {
    return Intl.message('Volume');
  }

  String get avgPrice {
    return Intl.message('Avg Price');
  }

  String get open {
    return Intl.message('Open');
  }

  String get ordStatusClosed {
    return Intl.message('Closed');
  }

  String get oneDayPLChange {
    return Intl.message('1D Return (Change %)');
  }

  String get getCurrent {
    return Intl.message('Current (Invested)');
  }

  String get lowerCircuit {
    return Intl.message('Lower Circuit');
  }

  String get upperCircuit {
    return Intl.message('Upper Circuit');
  }

  String get oI {
    return Intl.message('OI');
  }

  String get oiChg {
    return Intl.message('OI Chg');
  }

  String get faceValue {
    return Intl.message('Face Value');
  }

  String get varMargin {
    return Intl.message('VaR Margin');
  }

  String get series {
    return Intl.message('Series');
  }

  String get lotSize {
    return Intl.message('Lot size');
  }

  String get tickSize {
    return Intl.message('Tick Size');
  }

  String get maxOrderSize {
    return Intl.message('Max Order Size');
  }

  String get deliveryPercent {
    return Intl.message('Delivery %');
  }

  String get fundamentals {
    return Intl.message('Fundamentals');
  }

  String get about {
    return Intl.message('About');
  }

  String get mktCap {
    return Intl.message('Mkt Cap');
  }

  String get mktCapcr {
    return Intl.message('Mkt Cap (Cr)');
  }

  String get pE {
    return Intl.message('PE');
  }

  String get priceToBook {
    return Intl.message('Price to Book');
  }

  String get bookValue {
    return Intl.message('Book Value');
  }

  String get epsTtm {
    return Intl.message('EPS (TTM)');
  }

  String get dividendYield {
    return Intl.message('Dividend Yield');
  }

  String get roe {
    return Intl.message('ROE');
  }

  String get debtToEquity {
    return Intl.message('Debt to Equity');
  }

  String get operatingMargin {
    return Intl.message('Operating Margin');
  }

  String get roa {
    return Intl.message('ROA');
  }

  String get netSalesGrowth {
    return Intl.message('Net Sales Growth');
  }

  String get interestCover {
    return Intl.message('Interest Cover');
  }

  String get evToEbit {
    return Intl.message('EV to EBIT');
  }

  String get evToEbida {
    return Intl.message('EV to EBITDA');
  }

  String get evToSales {
    return Intl.message('EV to Sales');
  }

  String get pegRatio {
    return Intl.message('PEG Ratio');
  }

  String get fixedTurnOver {
    return Intl.message('Fixed Turnover');
  }

  String get netProfitMargin {
    return Intl.message('Net Profit Margin');
  }

  String get myHoldings {
    return Intl.message('My Holdings');
  }

  String get mktValue {
    return Intl.message('Mkt Value');
  }

  String get avgCost {
    return Intl.message('Avg Cost');
  }

  String get avg {
    return Intl.message('Avg');
  }

  String get todaysReturn {
    return Intl.message("Today's Return");
  }

  String get overallReturn {
    return Intl.message('Overall Return');
  }

  String get porfolioPercent {
    return Intl.message('Portfolio %');
  }

  String get alltransaction {
    return Intl.message('All Transactions');
  }

  String get fifityTwoWL {
    return Intl.message('52W Low');
  }

  String get fifityTwoWH {
    return Intl.message('52W High');
  }

  String get fifityTwoWeekL {
    return Intl.message('52-Week Low');
  }

  String get fifityTwoWeekH {
    return Intl.message('52-Week High');
  }

  String get downSide {
    return Intl.message(' down side');
  }

  String get upSide {
    return Intl.message('up Side ');
  }

  String get company {
    return Intl.message('Company');
  }

  String get similarStocks {
    return Intl.message('Similar Stocks');
  }

  String get ltpCap {
    return Intl.message('LTP');
  }

  String get futures {
    return Intl.message('Futures');
  }

  String get options {
    return Intl.message('Options');
  }

  String get technical {
    return Intl.message('Technical');
  }

  String get movingAverages {
    return Intl.message('Moving Averages');
  }

  String get pivotsPoints {
    return Intl.message('Pivot Points');
  }

  String get volumeAnalysis {
    return Intl.message('Volume Analysis');
  }

  String get macd12269 {
    return Intl.message('MACD (12,26,9)');
  }

  String get macd1226 {
    return Intl.message('MACD (12,26)');
  }

  String get indicator {
    return Intl.message('Indicator');
  }

  String get orderValue {
    return Intl.message('Order Value');
  }

  String get orderId {
    return Intl.message('Order Id');
  }

  String get orderID {
    return Intl.message('Order ID');
  }

  String get exchangeOrdId {
    return Intl.message('Exchange Order Id');
  }

  String get value {
    return Intl.message('Value');
  }

  String get rsi {
    return Intl.message('RSI');
  }

  String get ema10 {
    return Intl.message('EMA 10');
  }

  String get ema20 {
    return Intl.message('EMA 20');
  }

  String get ema50 {
    return Intl.message('EMA 50');
  }

  String get sma10 {
    return Intl.message('SMA 10');
  }

  String get sma20 {
    return Intl.message('SMA 20');
  }

  String get sma50 {
    return Intl.message('SMA 50');
  }

  String get sma100 {
    return Intl.message('SMA 100');
  }

  String get sma200 {
    return Intl.message('SMA 200');
  }

  String get totalVolume {
    return Intl.message('Total Volume');
  }

  String get delivery {
    return Intl.message('Delivery');
  }

  String get carryForward {
    return Intl.message('Carry Forward');
  }

  String get carryForwardQty {
    return Intl.message('Carry Forward Qty');
  }

  String get all {
    return Intl.message('All');
  }

  String get closed_ {
    return Intl.message('Closed');
  }

  String get brackets {
    return Intl.message('Brackets');
  }

  String get myreports {
    return Intl.message('My Reports');
  }

  String get filterBy {
    return Intl.message('Filter');
  }

  String get pushNotifications {
    return Intl.message('Push Notifications');
  }

  String get themeSettings {
    return Intl.message('Theme Settings');
  }

  String get changePassword {
    return Intl.message('Change Password');
  }

  String get biometric {
    return Intl.message('Biometric');
  }

  String get review {
    return Intl.message('Review order');
  }

  String get privacyPolicy {
    return Intl.message('Privacy Policy');
  }

  String get iosExperience {
    return Intl.message('Make your iOS experience');
  }

  String get lightMode {
    return Intl.message('Activate Light Mode');
  }

  String get darkMode {
    return Intl.message('Activate Dark Mode');
  }

  String get termandConditions {
    return Intl.message('Terms & Conditions');
  }

  String get helpandSupport {
    return Intl.message('Help & Support');
  }

  String get foplReports {
    return Intl.message('F&O P&L Report');
  }

  String get sortBy {
    return Intl.message('Sort by');
  }

  String get fiveCr {
    return Intl.message('5cr');
  }

  String get tenCr {
    return Intl.message('10cr');
  }

  String get fifteenCr {
    return Intl.message('15cr');
  }

  String get twentyCr {
    return Intl.message('20cr');
  }

  String get today {
    return Intl.message('Today');
  }

  String get yesterday {
    return Intl.message('Yesterday');
  }

  String get oneWeekAvg {
    return Intl.message('1 Week Avg');
  }

  String get oneMonthAvg {
    return Intl.message('1 Month Avg');
  }

  String get blocDeals {
    return Intl.message('Block Deals');
  }

  String get bulkDeals {
    return Intl.message('Bulk Deals');
  }

  String get revenue {
    return Intl.message('Revenue');
  }

  String get profit {
    return Intl.message('Profit');
  }

  String get intraDay {
    return Intl.message('Intraday');
  }

  String get selectConvertScreen {
    return Intl.message('Select any one');
  }

  String get weekly {
    return Intl.message('Weekly');
  }

  String get monthly {
    return Intl.message('Monthly');
  }

  String get netWorth {
    return Intl.message('Net Worth');
  }

  String get quantity {
    return Intl.message('Quantity');
  }

  String get netTotal {
    return Intl.message('Net Total');
  }

  String get price {
    return Intl.message('Price');
  }

  String get tradedPercentage {
    return Intl.message('% Traded');
  }

  String get emptyCorporateActionMessage {
    return Intl.message('No Corporate Actions');
  }

  String get exDate {
    return Intl.message('Ex date');
  }

  String get expiryDate {
    return Intl.message('Expiry date');
  }

  String get ltd {
    return Intl.message('Last Trade date');
  }

  String get actionDate {
    return Intl.message('Action date');
  }

  String get annocementDate {
    return Intl.message('Announcement Date');
  }

  String get recordDate {
    return Intl.message('Record Date');
  }

  String get bonusDate {
    return Intl.message('Bonus Date');
  }

  String get bonusRatio {
    return Intl.message('Bonus Ratio');
  }

  String get remarks {
    return Intl.message('Remarks');
  }

  String get details {
    return Intl.message('Details');
  }

  String get totalAvailableQty {
    return Intl.message('Total available qty: ');
  }

  String get lots {
    return Intl.message('Lots');
  }

  String get rightDate {
    return Intl.message('Right Date');
  }

  String get rightsRatio {
    return Intl.message('Rights Ratio');
  }

  String get premium {
    return Intl.message('Premium');
  }

  String get noDeliveryStartDate {
    return Intl.message('No Delivery Start Date');
  }

  String get noDeliveryEndDate {
    return Intl.message('No Delivery End Date');
  }

  String get splitDate {
    return Intl.message('Split Date');
  }

  String get faceValueBefore {
    return Intl.message('Face Value Before');
  }

  String get faceValueAfter {
    return Intl.message('Face Value After');
  }

  String get splitRatio {
    return Intl.message('Split Ratio');
  }

  String get exDividendDate {
    return Intl.message('Ex Dividend Date');
  }

  String get dividendType {
    return Intl.message('Dividend Type');
  }

  String get amount {
    return Intl.message('Amount');
  }

  String get dividendPercent {
    return Intl.message('Dividend %');
  }

  String get optionChain {
    return Intl.message('Option Chain');
  }

  String get consolidated {
    return Intl.message('Consolidated');
  }

  String get standalone {
    return Intl.message('Standalone');
  }

  String get discovery {
    return Intl.message('⭐ Discovery');
  }

  String get promoters {
    return Intl.message('Promoters');
  }

  String get fiis {
    return Intl.message('FIIs');
  }

  String get mutualFunds {
    return Intl.message('Mutual Funds');
  }

  String get insuranceCompanies {
    return Intl.message('Insurance Companies');
  }

  String get otherDiis {
    return Intl.message('Other DIIs');
  }

  String get nonInstitution {
    return Intl.message('Non-Institutional');
  }

  String get call {
    return Intl.message('CALL');
  }

  String get put {
    return Intl.message('PUT');
  }

  String get strikePrice {
    return Intl.message('Strike Price');
  }

  String get aboutUs {
    return Intl.message('About Us');
  }

  String get live {
    return Intl.message('Live');
  }

  String get closed {
    return Intl.message('Closed');
  }

  String get prevClose {
    return Intl.message('Prev. Close');
  }

  String get emptyOrdersDescriptions1 {
    return Intl.message('You haven’t placed any order for today');
  }

  String get emptytradeHistoryDescriptions1 {
    return Intl.message(
        'Don\'t wait for your time start trading with us for secure investment ');
  }

  String get emptyOrdersDescriptions2 {
    return Intl.message('Buy or sell stocks to view order');
  }

  String get emptyPositionsDescriptions1 {
    return Intl.message('Oops, looks like you haven’t made any trade today');
  }

  String get emptyPositionsDescriptions2 {
    return Intl.message('Lets get you started            ');
  }

  String get emptySearchDescriptions1 {
    return Intl.message(
        'It looks like you have not placed any order for this security');
  }

  String get emptySearchDescriptions2 {
    return Intl.message('Back to Order Book');
  }

  String get viewWatchlist {
    return Intl.message('View Watchlist');
  }

  String get clone {
    return Intl.message('Clone');
  }

  String get placeOrder {
    return Intl.message('Place Order');
  }

  String get viewReports {
    return Intl.message('View Reports');
  }

  String get viewFunds {
    return Intl.message('View Funds');
  }

  String get analytics {
    return Intl.message('Analytics');
  }

  String get viewboReports {
    return Intl.message('View BO Reports');
  }

  String get viewAnalytics {
    return Intl.message('View Analytics');
  }

  String get stockQuote {
    return Intl.message('Stock Quote');
  }

  String get add {
    return Intl.message('Add');
  }

  String get exit {
    return Intl.message('Exit');
  }

  String get cancelordermessage {
    return Intl.message('Are you sure you want to cancel this order?');
  }

  String get successMsg {
    return Intl.message('Order executed successfully');
  }

  String get exitordermessage {
    return Intl.message('Are you sure you want to exit this order?');
  }

  String get netQty {
    return Intl.message('Net Qty');
  }

  String get pledgedQty {
    return Intl.message('Pledged Qty');
  }

  String get freeQty {
    return Intl.message('Free Qty');
  }

  String get netdayQty {
    return Intl.message('Net Day Qty');
  }

  String get invest {
    return Intl.message('Invest');
  }

  String get regular {
    return Intl.message('Regular');
  }

  String get coverOrder {
    return Intl.message('Cover Order');
  }

  String get cover {
    return Intl.message('Cover');
  }

  String get bracket {
    return Intl.message('Bracket');
  }

  String get bracketOrder {
    return Intl.message('Bracket Order');
  }

  String get forDelivery {
    return Intl.message('For Delivery');
  }

  String get forCarryForward {
    return Intl.message('For Carry Forward');
  }

  String get forIntraday {
    return Intl.message('For Intraday');
  }

  String get customPrice {
    return Intl.message('Custom Price');
  }

  String get convertCheckMsg {
    return Intl.message('Convert all ');
  }

  String get convertCheckBoxMsg {
    return Intl.message('You can convert all your ');
  }

  String get advancedOptions {
    return Intl.message('Advanced Options');
  }

  String get orderType {
    return Intl.message('Order Type');
  }

  String get validity {
    return Intl.message('Validity');
  }

  String get afterMarketOrder {
    return Intl.message('After Market Order');
  }

  String get amo {
    return Intl.message('AMO');
  }

  String get disclosedQtyOpt {
    return Intl.message('Disclosed Qty (optional)');
  }

  String get disclosedQty {
    return Intl.message('Disclosed quantity');
  }

  String get validityDate {
    return Intl.message('Validity Date');
  }

  String get chooseDate {
    return Intl.message('Choose Date');
  }

  String get atMarket {
    return Intl.message('At market');
  }

  String get triggerPrice {
    return Intl.message('Trigger Price');
  }

  String get stopLossTrigger {
    return Intl.message('Stop Loss Trigger');
  }

  String get stopLossSell {
    return Intl.message('Stop Loss Sell');
  }

  String get stopLossBuy {
    return Intl.message('Stop Loss Buy');
  }

  String get targetPrice {
    return Intl.message('Target Price');
  }

  String get priceHits52WH {
    return Intl.message('Price hits 52WH');
  }

  String get priceHits52WL {
    return Intl.message('Price hits 52WL');
  }

  String get trailingStopLoss {
    return Intl.message('Trailing Stop Loss (optional)');
  }

  String get tick {
    return Intl.message('Tick : ');
  }

  String get lot {
    return Intl.message('Lot: ');
  }

  String get lotWithoutcolon {
    return Intl.message('Lot ');
  }

  String get range {
    return Intl.message('Range: ');
  }

  String get orderInfo {
    return Intl.message('Order Info.');
  }

  String get market {
    return Intl.message('Market');
  }

  String get limit {
    return Intl.message('Limit');
  }

  String get sl {
    return Intl.message('SL');
  }

  String get slm {
    return Intl.message('SL-M');
  }

  String get availableFunds {
    return Intl.message('Available Funds');
  }

  String get fundsRequired {
    return Intl.message('Funds Required');
  }

  String get availableMargin {
    return Intl.message('Available Margin');
  }

  String get requiredMargin {
    return Intl.message('Required Margin');
  }

  String get addFunds {
    return Intl.message('Add Funds');
  }

  String get chooseBank {
    return Intl.message('Step 1: Choose Bank');
  }

  String get choosePaymentmode {
    return Intl.message('Step 2: Choose Your Payment Mode');
  }

  String get fundsWillTransfer {
    return Intl.message('Funds will be transferred to this account');
  }

  String get addFundsErrorMsg1 {
    return Intl.message(
        'Oops! Your account balance is insufficient.Transfer at least ₹');
  }

  String get addFundsErrorMsg2 {
    return Intl.message(
        ' to your account to execute this trade or change the order quantity. Your current account balance is ₹');
  }

  String get orderSuccessMessage1 {
    return Intl.message('Hooray! Your order is succesfully placed.');
  }

  String get orderSuccessMessage2 {
    return Intl.message(' shares of ');
  }

  String get orderSuccessMessage3 {
    return Intl.message(' has been placed!');
  }

  String get orderSuccessMessage4 {
    return Intl.message('Happy investing');
  }

  String get noHoldingsAvailable {
    return Intl.message('No Holdings Available');
  }

  String get insufficientHoldings {
    return Intl.message('Insufficient Holdings');
  }

  String get forSlSlm {
    return Intl.message('For SL & SL-M');
  }

  String get slSlmDescription {
    return Intl.message(
        'Trigger a market buy order if your stock rises to stop Loss price.');
  }

  String get viewOrder {
    return Intl.message('View Order');
  }

  String get lotIssueErrorDisclose {
    return Intl.message(
        ' Disclosed Quantity should be in multiples of the lot size');
  }

  String get lotIssueError {
    return Intl.message('Quantity should be in multiples of the lot size');
  }

  String get qtyMultipleError {
    return Intl.message('Quantity value should be mutiple of the min quantity');
  }

  String get disQtyLessThanQtyError {
    return Intl.message('Disclosed qty cannot be greater than the qty');
  }

  String get oneHelpMsg {
    return Intl.message('Can I change or modify my order?');
  }

  String get t1 {
    return Intl.message('T1 : ');
  }

  String get orderbookyes {
    return Intl.message('Yes');
  }

  String get orderbookno {
    return Intl.message('No');
  }

  String get oneHelpMsgAns {
    return Intl.message(
        'You can change or modify or cancel an order only till it is in pending status and yet to be executed onin the market. Once yourthe order is successfully executed, on the market, you cannot change it. You can place an additional order or you can reverse your position by creating an opposite order.');
  }

  String get twoHelpMsg {
    return Intl.message('When will my order get executed?');
  }

  String get successOrderheading2 {
    return Intl.message(
        'My buy order is successful, but I can’t see the stocks in my holdings. Why?');
  }

  String get successOrderheading3 {
    return Intl.message(
        'My sell order is successful, but I can still see the stocks in my holdings. Why?');
  }

  String get successOrderheading4 {
    return Intl.message('Why did my limit order get executed at market price?');
  }

  String get successOrderheading5 {
    return Intl.message('Why did my order go through at a different price?');
  }

  String get rejectedorderHeading1 {
    return Intl.message('Why was my order cancelled?');
  }

  String get twoHelpMsgAns {
    return Intl.message(
        'Your order will go through when there are enough shares available at the specified price or number. Keep in mind that there must be a buyer and seller on both sides of the trade for an order to execute. Also, the orders are executed based on the price-time priority. If there are other orders placed before your order at the same price, those orders will be given priority by the exchange, and they will be executed first.');
  }

  String get successOrderdescription2 {
    return Intl.message(
        'According to exchange settlement timelines, your buy trade executed today will get updated in your holdings on T+1 day.');
  }

  String get successOrderdescription3 {
    return Intl.message(
        'According to exchange settlement timelines, your buy trade executed today will get updated in your holdings on T+1 day. When you sell a stock, the quantity of your holding is also updated the next day. However, you can see a briefcase with qty tagged against the holding indicating you’ve sold some or part of that particular holding. ');
  }

  String get rejectedOrderdescription1 {
    return Intl.message(
        'There are a number of reasons why your order was cancelled or rejected.\n /bu It could not be executed during market hours. /bu \n  /bu Incorrect order type selection: You may have entered a wrong order type (e.g., IOC order aka Immediate or Cancel). /bu \n /bu There is a freeze on the order quantity. /bu ');
  }

  String get successOrderdescription4 {
    return Intl.message(
        'A limit order allows you to buy or sell a stock at the price you have set or a /bbetter/b price.\n\nIn other words, if you place a buy limit order, your order will buy the stock at your limit price or a lesser price but not at a higher price. Similarly, a sell limit order will sell the stock at your limit price or at a higher price but not at a lower price.');
  }

  String get successOrderdescription5 {
    return Intl.message(
        "When you place a market order, the order will get executed at the best bid/offer available at the exchange. If the quantity of the existing bids/offers isn't enough to match your order quantity, in that case, the remaining unexecuted quantity will be matched against the next best bid/offer.");
  }

  String get pendingOrderdescription1 {
    return Intl.message(
        'Yes, you can cancel and even modify your order, even after it has been placed on the exchange until it has not been executed. Just click on the Cancel or Modify buttons on the order detail screen');
  }

  String get pendingOrderheading1 {
    return Intl.message('Can I cancel or modify my order? ');
  }

  String get pendingOrderheading3 {
    return Intl.message('When will my order get executed? ');
  }

  String get pendingOrderheading4 {
    return Intl.message(
        'Why didn’t my Limit order get executed even after the stock hit my limit price? ');
  }

  String get pendingOrderdesc3 {
    return Intl.message(
        "Your order will go through when there are enough shares available at the specified price or number. Keep in mind that there must be a buyer and seller on both sides of the trade for an order to execute. Also, the orders are executed based on the price/time priority. If there are other orders placed before your order at the same price, those orders will be given priority by the exchange, and they will be executed first.\nIn case you have placed an AMO order, it will be executed after market opens. An SL and an SLM order can only get executed once the trigger price is hit.");
  }

  String get pendingOrderdesc4 {
    return Intl.message(
        "The limit order doesn't sometimes execute even if the stock reaches the limit price because there is a queue system on the exchange. This means that orders are placed on a 'first come, first serve' basis. If there are multiple bids at the same price and only one offer to counter it, then the person who placed their order first will get executed. Hence, even if the stock price hits the level set by you, the order might not get executed.");
  }

  String get pendingOrderdesc2 {
    return Intl.message(
        "There are two reasons why your order could be pending.\n /h 1. If you've placed a Limit Order/h\nWhen you place a limit order, the order is placed and open until the scrip hits the desired price.This is one of the reasons your order could be pending. Learn more on Limit Orders /link1here/link.\n/h2. When the scrip has hit the circuit limit/h \nIf there is no liquidity in the particular scrip, which means, if there are no buyers when you place a sell order, or if there are no sellers when you place a buy order, your order would be pending. Learn more on Circuit Limits /link2here/link.");
  }

  String get pendingOrderheading2 {
    return Intl.message('Why is my order pending ?');
  }

  String get threeHelpMsg {
    return Intl.message(
        'Why didn’t my Limit order get executed even after the stock hit my limit price?');
  }

  String get threeHelpMsgAns {
    return Intl.message(
        "The limit order doesn't sometimes execute even if the stock reaches the limit price because there is a queue system on the exchange. This means that orders are placed on a ‘first come first serve’ basis. If there are multiple bids at the same price and only one offer to counter it, then the person who placed their order first will get executed. Hence, even if the stock price hits the level set by you, the order might not get executed.");
  }

  String get fourHelpMsg {
    return Intl.message('Why was my order cancelled?');
  }

  String get fourHelpMsgAns {
    return Intl.message(
        'There are a number of reasons why your order was cancelled or rejected like it could not be executed during market hours, you had insufficient funds, you incorrectly placed the wrong order type (e.g., IOC order aka Immediate or Cancel). ');
  }

  String get fiveHelpMsg {
    return Intl.message(
        'Why is my average price different from my order price?');
  }

  String get fiveHelpMsgAns {
    return Intl.message(
        'If you placed a market order, your average price changed because the stock price moved while the order was being executed. In case of limit order (custom price), the average price changed because limit orders are executed at your custom price or a better price and you got a better price than your limit order.');
  }

  String get sixHelpMsg {
    return Intl.message(
        'When will the stocks be delivered to my demat account?');
  }

  String get sixHelpMsgAns {
    return Intl.message(
        'Your purchased stocks will be delivered to your demat account at the end of the second day after the transaction as per the T+2 settlement, excluding weekends and market holidays. Of course, this would happen if you didn’t sell the stocks before they are delivered.');
  }

  String get sevenHelpMsg {
    return Intl.message(
        'Can you customize the questions in the order detail window based on Order Status?');
  }

  String get sevenHelpMsgAns {
    return Intl.message(
        'Like, for pending orders – different set of questions, cancelled orders questions relevant to cancellation and successfully executed orders – questions relevant to them. We have already colored the questions before based on the status – orange for pending, red for cancelled or rejected and green for successful. If yes, let us know and we can add more questions for each order status type.');
  }

  String get lastHelpMsg {
    return Intl.message('Can’t find what you are looking for?');
  }

  String get helpSection {
    return Intl.message('Visit');
  }

  String get visitHelp {
    return Intl.message(' Help Section');
  }

  String get orderStatus {
    return Intl.message('Order Status');
  }

  String get orderHistory {
    return Intl.message('Order History');
  }

  String get orderPlacedOnArihant {
    return Intl.message('Order Placed on Arihant');
  }

  String get orderPlacedOn {
    return Intl.message('Order Placed on ');
  }

  String get ltp {
    return Intl.message('LTP');
  }

  String get amoOrderMessage {
    return Intl.message(
        'Markets are closed right now, your order will be placed when the market opens.');
  }

  String get qtyCannotMoreError {
    return Intl.message('Quantity cannot be more than ');
  }

  String get invalidQtyError {
    return Intl.message('Invalid Quantity');
  }

  String get disQtyMin10Error {
    return Intl.message('Disclosed qty should be Min 10% of qty');
  }

  String get disQtyMin25Error {
    return Intl.message('Disclosed qty should be Min 25% of qty');
  }

  String get qtyGretLotSize {
    return Intl.message('Disclosed Quantity should be greater than lotsize');
  }

  String get priceEmptyError {
    return Intl.message('Please enter the Price');
  }

  String get priceTickSizeError {
    return Intl.message('Price should be in the multiple of tick size');
  }

  String get priceRangeError {
    return Intl.message('Enter a price within the Daily Price Range');
  }

  String get triggerPriceEmptyError {
    return Intl.message('Please enter the Trigger Price');
  }

  String get triggetPriceTickSizeError {
    return Intl.message('Trigger price should be multiple of tick size');
  }

  String get triggerPriceRangeError {
    return Intl.message(
        'The trigger price you entered is out of the range specified.');
  }

  String get triggerPriceGreaterThanLimitPriceError {
    return Intl.message('Trigger price should be more than the limit price.');
  }

  String get tiggerPriceLesserThanLimitPriceError {
    return Intl.message('Trigger price should be less than the limit price.');
  }

  String get buyStopLossEmptyError {
    return Intl.message('Please enter the stop loss buy');
  }

  String get sellStopLossEmptyError {
    return Intl.message('Please enter the stop loss sell');
  }

  String get buyStopLossTickSizeError {
    return Intl.message('Stop loss buy should be multiple of tick size');
  }

  String get sellStopLossTickSizeError {
    return Intl.message('Stop loss sell should be multiple of tick size');
  }

  String get sellStopLossRangeError {
    return Intl.message('Please enter the Stop Loss sell price between');
  }

  String get buyStopLossRangeError {
    return Intl.message('Please enter the Stop Loss buy price between');
  }

  String get buyStopLossGreaterThanLimitPriceError {
    return Intl.message('Stop loss buy should be greater than Limit price');
  }

  String get sellStopLossPriceLessThanLimitPriceError {
    return Intl.message('Stop loss sell should be less than Limit price');
  }

  String get targetPriceEmptyError {
    return Intl.message('Please enter the Target price');
  }

  String get targetPriceTickSizeError {
    return Intl.message('Target price should be multiple of tick size');
  }

  String get targetPriceLesserThanLimitPriceError {
    return Intl.message('Target price cannot be lesser than Limit price');
  }

  String get targetPriceGreaterThanLimitPriceError {
    return Intl.message('Target price cannot be greater than Limit price');
  }

  String get targetPriceRangeError {
    return Intl.message('Please enter the Target price between');
  }

  String get valueInPercent {
    return Intl.message('Value in % :');
  }

  String get gtdDateError {
    return Intl.message('Please enter valid Date');
  }

  String get min {
    return Intl.message('Min.');
  }

  String get minQty {
    return Intl.message('Min Quantity');
  }

  String get emptyHoldingsDescriptions1 {
    return Intl.message(
        'You dont have any Holdings now. Kick start your trading with Arihant');
  }

  String get emptyHoldingsDescriptions2 {
    return Intl.message(
        'Dont wait for your time, start trading with us for a secure investment.');
  }

  String get scrips {
    return Intl.message('Scrips');
  }

  String get todaysPnL {
    return Intl.message('Today\'s Return');
  }

  String get overallPL {
    return Intl.message('Overall Return');
  }

  String get buyingPower {
    return Intl.message('Buying Power');
  }

  String get mktValueOverallPnL {
    return Intl.message('Overall Return (Return %)');
  }

  String get mktValueOneDayPnL {
    return Intl.message('1D Return (1D %)');
  }

  String get currentValueInvestedValue {
    return Intl.message('Current Val (Invested Val)');
  }

  String get oneDayReturn {
    return Intl.message('1D Return');
  }

  String get currentValue {
    return Intl.message('Current Value');
  }

  String get investedAmount {
    return Intl.message('Invested Amount');
  }

  String get amountToWithdrawal {
    return Intl.message('Amount to Withdrawal');
  }

  String get investedValue {
    return Intl.message('Invested Value');
  }

  String get overallPnL {
    return Intl.message('Overall Return');
  }

  String get portfolioWeightage {
    return Intl.message('Portfolio Weightage %');
  }

  String get orderDetails {
    return Intl.message('Order Details');
  }

  String get holdingsSearchHint {
    return Intl.message('Search (e.g. Reliance, Tata Motors)');
  }

  String get basketsearchhint {
    return Intl.message('Search Basket');
  }

  String get addBaskethint {
    return Intl.message('Search scrips & Add to basket');
  }

  String get positionProfitAnnocementText {
    return Intl.message('🎉  Hurray! Your positions are in profit');
  }

  String get positionLossAnnocementText {
    return Intl.message(
        '😐 Uh oh. Looks like there’s a loss in your positions.');
  }

  String get oopsNoresults {
    return Intl.message('Oops, your search returned no results.');
  }

  String get trywithdiffFilter {
    return Intl.message(
        'Why don\'t you try with differen filters or search options?');
  }

  String get authorization {
    return Intl.message('Authorization ');
  }

  String get authorizeTransaction {
    return Intl.message('Authorize Transaction');
  }

  String get authorizeStatement1 {
    return Intl.message('Authorize Sell Transaction');
  }

  String get authorizeStatement2 {
    return Intl.message(
        'As per new regulations, selling stocks will require e-DIS verification on ');
  }

  String get authorizeStatement3 {
    return Intl.message(
        ' using TPIN and OTP. This has to be done once a day. ');
  }

  String get learnMore {
    return Intl.message('Learn more');
  }

  String get authorizeFooter {
    return Intl.message(
        'To skip this step, submit Demat Debit and Pledge Instruction (DDPI). ');
  }

  String get clickForrekyc {
    return Intl.message('Click for Rekyc');
  }

  String get haveTpin {
    return Intl.message('I have a TPIN');
  }

  String get verifyTpinAndOtp {
    return Intl.message('Verify using TPIN & OTP');
  }

  String get cdsl {
    return Intl.message('CDSL');
  }

  String get continueToCDSL {
    return Intl.message('Continue to CDSL');
  }

  String get priceMovesabove {
    return Intl.message('Price moves above');
  }

  String get volumeMovesabove {
    return Intl.message('Volume moves above');
  }

  String get priceMovesupByPer {
    return Intl.message('Price moves up by (%)');
  }

  String get priceMovesdownByPer {
    return Intl.message('Price moves down by (%)');
  }

  String get priceMovesbelow {
    return Intl.message('Price moves below');
  }

  String get volumeMovesbelow {
    return Intl.message('Volume moves below');
  }

  String get noTpin {
    return Intl.message('I don’t have a TPIN');
  }

  String get noTpinStatement {
    return Intl.message(
        'First time approving a transaction / Forgot your PIN?');
  }

  String get generateTpin {
    return Intl.message('Generate TPIN');
  }

  String get tpinStatement {
    return Intl.message(
        'TPIN can be generated once and can be reused. Ex: Like your ATM pin.');
  }

  String get needVerification {
    return Intl.message('Need Verification');
  }

  String get ndslStatement {
    return Intl.message('Verify using MPIN & OTP');
  }

  String get nsdl {
    return Intl.message('NSDL');
  }

  String get continueToNSDL {
    return Intl.message('Continue to NSDL');
  }

  String get authorizationNotNeeded {
    return Intl.message('Authorization not needed.');
  }

  String get marketOrderDespText {
    return Intl.message(
        'A market order allows you to buy or sell a stock quickly at the best available price.You just need to mention the quantity and the order is executed according to live market price.');
  }

  String get limitOrderDespText {
    return Intl.message(
        "A limit order is when you want to buy or sell a stock at a fixed price. You can place a limit order by entering your desired quantity and clicking on “Custom Price” (within the daily price range set by the exchange for that stock). You should know that limit orders aren't guaranteed to execute. There must be a buyer and seller on both sides of the trade. If there aren't enough shares in the market at your limit price, it may take multiple trades to fill the entire order, or the order may not be filled at all.");
  }

  String get slOrderDespText {
    return Intl.message(
        'A stop-loss order is a request to execute a trade, but only if a stock reaches a specified price level. It is commonly used as an offsetting order placed to exit your existing buy or sell position once the stock hits the defined trigger price. It helps you to limit your risk by squaring off your position in case of adverse price movements.');
  }

  String get slOrderDespText1 {
    return Intl.message(
        'Stop loss limit order or SL order gets placed on exchange when the trigger price set by you is hit in market. Once triggered, it acts like a regular limit order.');
  }

  String get slOrderDespText2 {
    return Intl.message(
        'When you select stop-loss order option, it will display an additional Trigger Price field, that you need to fill in.');
  }

  String get slOrderDespText3 {
    return Intl.message('Tip: You can either set a ₹ limit or a % limit.');
  }

  String get slMOrderDespText {
    return Intl.message(
        'Stop-loss market (SL-M) order is similar to a stop loss order, where your order will get triggered when “trigger price” is hit in the market, however in SLM the order gets executed at the market price.');
  }

  String get slMOrderDespText1 {
    return Intl.message('To understand more about SL and SL-M differences,');
  }

  String get clickhere {
    return Intl.message('click here.');
  }

  String get slMOrderDespText2 {
    return Intl.message(
        'This is not valid in equity options and currency options as per the latest guidelines.');
  }

  String get tgOrderDesp1Text {
    return Intl.message(
        'Trigger price is the price at which your stop-loss buy or sell order becomes active for execution and is submitted to the exchange. In other words, once the price of the stock hits the trigger price set by you, your stop-loss buy or sell order is sent to the exchange for execution.');
  }

  String get tgOrderDesp2Text {
    return Intl.message(
        'After the stop-loss order has been triggered, your shares/contract will be bought or sold at the limit price set by you for SL orders or at the market rate for SLM orders.');
  }

  String get placingOrder {
    return Intl.message('Placing an order');
  }

  String get regularOrder {
    return Intl.message('Regular Order');
  }

  String get placingOrdertext1 {
    return Intl.message(
        'Select what kind of order you want to place by clicking on');
  }

  String get placingOrdertext2 {
    return Intl.message(
        'If the market is Live, you will see a green dot along with the stock prices on both exchanges. The stock price on both the exchanges is shown and you can choose the exchange you want to trade on.');
  }

  String get placingOrdertext3 {
    return Intl.message(
        'Choose whether you want to Invest (delivery order) or Trade (intraday order).');
  }

  String get placingOrdertext4_1 {
    return Intl.message(
        'Choose the quantity and the price of the order.The market price is selected by default, but if you want to put a ');
  }

  String get placingOrdertext4_2 {
    return Intl.message('limit order ');
  }

  String get placingOrdertext4_3 {
    return Intl.message('you can click on ');
  }

  String get placingOrdertext4_4 {
    return Intl.message('“custom price”.');
  }

  String get placingOrdertextNote {
    return Intl.message(
        '💡Remember you can only place an order for a custom price if the price entered is in the daily price range defined by the exchange for that stock.');
  }

  String get placingOrdertext5 {
    return Intl.message(
        'Check the margin amount required to place the order and confirm if you have the available margin. The amount is automatically calculated and displayed towards the bottom of the screen. If your available margin is insufficient, you may be prompted to transfer funds to your Arihant account.');
  }

  String get placingOrdertext6 {
    return Intl.message('Click on BUY/SELL button to place your order.');
  }

  String get placingOrdertext7 {
    return Intl.message(
        'Choose Advanced Options, if you need additional options for placing the order like validity (IOC, GTD) or want to place a stop loss order. You will have to input additional information like Trigger Price, according to the type of order. You can set the trigger price in both absolute terms (₹) or as a percentage change from the price. You can also choose to disclose your order partially or place an After Market Order (AMO) here.');
  }

  String get regularOrdertext1 {
    return Intl.message(
        'The simplest way to place a buy or sell order is through regular order. Simply enter the quantity of shares you want to buy, enter the price at which you want to buy the shares and decide whether you want to TRADE, i.e., place an intraday order (which will square off at 3:15pm automatically) or INVEST, i.e., take delivery of the shares to your demat account. Also, an intraday order cannot be placed after 3:15pm, only delivery orders are accepted in the last 15 minutes of the market hours.');
  }

  String get regularTypes {
    return Intl.message('Regular order is of two types:');
  }

  String get regularOrdertext2 {
    return Intl.message(
        'A market order allows you to buy or sell a stock quickly at the best available price.You just need to mention the quantity and the order is executed according to live market price.');
  }

  String get regularOrdertext3 {
    return Intl.message(
        "A limit order is when you want to buy or sell a stock at a fixed price. You can place a limit order by entering your desired quantity and clicking on “Custom Price” (within the daily price range set by the exchange for that stock). You should know that limit orders aren't guaranteed to execute. There must be a buyer and seller on both sides of the trade. If there aren't enough shares in the market at your limit price, it may take multiple trades to fill the entire order, or the order may not be filled at all.");
  }

  String get mktOdr {
    return Intl.message('Market Order :');
  }

  String get lmtOdr {
    return Intl.message('Limit Order : ');
  }

  String get cvrDesctext {
    return Intl.message(
        'Cover order is a type of intraday order that combines a buy order and a compulsory stop-loss order. Its inbuilt risk-mitigating mechanism helps minimise the losses by safeguarding traders from unexpected market movements.');
  }

  String get cvrDesctext1_1 {
    return Intl.message('To place a cover order, you need to enter a ');
  }

  String get cvrDesctext1_3 {
    return Intl.message(
        ' price along with the required quantity and price(market or limit).');
  }

  String get cvrDesctext2 {
    return Intl.message(
        'The “stop loss” allows you to automatically exit your outstanding position if the trade is becoming unprofitable. This way you are well aware of the maximum loss you will bear in advance, and you protect yourself from the downside. Smart, isn’t it?');
  }

  String get cvrDesctext3 {
    return Intl.message(
        'Cover order = Initial Order (buy or sell) + Stop-Loss Order (sell or buy).');
  }

  String get cvrDesctext4 {
    return Intl.message(
        '💡All cover orders get squared-off automatically at 3:15pm, if you have not done it yourself before.');
  }

  String get bracOrdDesc {
    return Intl.message(
        'Bracket orders are designed to help limit your loss and lock in a profit by "bracketing" an order with two opposite-side orders. This way, you decide both the ceiling and floor prices for squaring off your position while entering a trade.');
  }

  String get bracOrdDesc1 {
    return Intl.message('A bracket order combines three orders in one.');
  }

  String get bracSubDesc1 {
    return Intl.message('An initial order');
  }

  String get bracSubDesc2 {
    return Intl.message('A corresponding stop-loss order (2nd leg)');
  }

  String get bracSubDesc3 {
    return Intl.message(
        'A corresponding profit objective limit order (3rd leg)');
  }

  String get bracOrdDesc2 {
    return Intl.message(
        'If the stop loss trigger price is hit, the stop loss order gets executed as a market order and the 3rd leg (the profit objective order) automatically gets cancelled. Similarly, if the profit objective trigger price gets hit, the 2 nd leg stoploss automatically gets cancelled. If the condition for the two limit trades is not met by 3:15pm, the order is automatically squared off (unless its manually closed by the trader).');
  }

  String get bracOrdDesc3 {
    return Intl.message(
        'For placing a bracket order, you need to specify a trigger price (in ₹ or in %), the limit price, a stop loss price (your floor price) and the target price (your ceiling price). You can also choose to add a trailing stop loss here.');
  }

  String get bracOrdDesc4 {
    return Intl.message(
        'There is also an additional field called “Trailing Stop Loss."When you place a bracket order, you get an option to either place a fixed stop-loss order or also an ability to trail your stop-loss. In Trailing Stop Loss, if the stock or contract moves in your direction by a particular number of ticks,the stop-loss will go up/down based on if you are long or short automatically.');
  }

  String get todayRetDesc {
    return Intl.message(
        'This box shows the total of today’s profit or loss of all your holdings due to the price movements during the market hours today. It shows your change in returns from yesterday in both absolute and percentage terms.');
  }

  String get lastTradePrice {
    return Intl.message("Last Traded Price");
  }

  String get ltpDesc {
    return Intl.message(
        "The price at which the stock was traded last is known as the Last Traded Price or LTP of the stock. The percentage change shows the change from yesterday’s closing price.");
  }

  String get ovrRetDesp {
    return Intl.message(
        'This box shows you the cumulative profit and loss of your current holdings. Overall return is effectively the difference between the current value of the investments and the cost of acquisition of the securities.');
  }

  String get curValDesp {
    return Intl.message(
        'The value of your holdings changes with the price movements in the markets. The current value is the total value of all the securities in your holding.');
  }

  String get curValDesp2 {
    return Intl.message(
        'The stocks purchased and sold today will not reflect in your current holdings, until the next trading day.');
  }

  String get invAmntDesp {
    return Intl.message(
        'The invested amount represents the cumulative purchase cost of the holdings in your account.');
  }

  String get advOptDesc {
    return Intl.message(
        'This section allows you to place stop-loss orders, change the validity of your order and change the disclosed quantity on your order. Let’s understand each option below.');
  }

  String get validtyDesc1 {
    return Intl.message('Your order is valid till the end of the trading day.');
  }

  String get validtyDesc2 {
    return Intl.message(
        'An Immediate or Cancelled (IOC) order is either executed immediately or is cancelled.');
  }

  String get validtyDesc3 {
    return Intl.message(
        'A Good Till Date (GTD) order is a type of order that is active until specified date (selected by you while placing the order), unless it has already been fulfilled or cancelled.');
  }

  String get amoDesc1 {
    return Intl.message(
        'AMO stands for after-market order. Traditionally, the markets are open from 9:00 AM to 3:30 PM IST during normal business days, during which you can trade and place your orders. AMO allows you to place your buy or sell order outside of market hours as well.');
  }

  String get amoDesc2 {
    return Intl.message(
        'If you are busy during market hours - or would like some trades to be executed as soon as the market opens, you can place an After Market Order (AMO) which will get executed when the market opens.');
  }

  String get amoDesc3 {
    return Intl.message('/link1Learn more/link about AMO and AMO timings.');
  }

  String get dQtyDesc {
    return Intl.message(
        'Disclosed quantity allows only a part of the total order quantity to be disclosed to the market. Once first part of the order is executed, the next part is disclosed to the market and shown in the market depth. This feature is often used by traders while placing large orders to reduce impact cost and to get a better execution by disclosing only a portion of the large order in the best bids and offers in the market depth.');
  }

  String get dQtyDesc1 {
    return Intl.message(
        'For example, if you want to buy 2,500 shares of TCS at ₹3,400, you can choose to disclose only 500 qty. In this case, for your order, only 500 qty will be shown in the market depth window for everyone else, against the actual quantity of 2,500.');
  }

  String get dQtyDesc2 {
    return Intl.message(
        'The disclosed quantity cannot be greater than or equal to your order quantity and cannot be lesser than 10% of the order quantity.');
  }

  String get dQtyDesc3 {
    return Intl.message(
        '💡Exchanges follow a "price-time priority" principle for orders. So this means that in the above example, once the first 500 is executed, the next 500 will be placed based on price-time priority and orders placed before this will have priority.');
  }

  String get overText {
    return Intl.message('Overall Return');
  }

  String get invsText {
    return Intl.message('Invested Amount');
  }

  String get currValText {
    return Intl.message('Current Value');
  }

  String get oneDayText {
    return Intl.message('Today’s Return');
  }

  String get watrHoldings {
    return Intl.message('What are Holdings ?');
  }

  String get holdingsDesc {
    return Intl.message(
        'Simply put, holdings are a collection of securities (stocks, ETFs, etc.) held in your portfolio as on a particular date. The value of every security in your holdings fluctuates with stock market movements, impacting the value of your portfolio.');
  }

  String get holdingsDesc1 {
    return Intl.message(
        'If I buy or sell stocks from my portfolio, will it be updated in Holdings?');
  }

  String get holdingsDesc2 {
    return Intl.message(
        'When you purchase or sell a stock, your holdings get updated the next day.');
  }

  String get holdingsDesc3 {
    return Intl.message(
        'When you buy a new stock and take its delivery, it shows up in your holdings on the next day of your purchase.');
  }

  String get holdingsDesc4 {
    return Intl.message(
        'When you sell a stock, your holding is updated the next day, but you can see a briefcase with qty tagged against the holding indicating the quantity sold today.');
  }

  String get holdingsDesc5 {
    return Intl.message(
        '💡In the above example, a briefcase tag with -5 indicates that 5 stocks of Mayuruniq were sold from your holdings today, and the quantity of your holding will stay the same, i.e. “1,995”.');
  }

  String get navNxtScn {
    return Intl.message('How to navigate this screen?');
  }

  String get navNxtScnDesc {
    return Intl.message(
        'The stocks you own are summarized here for your quick reference.');
  }

  String get navNxtScnDesc1 {
    return Intl.message(
        'On the left side, you will find the details of the shares you bought, the quantity and the average price of your order along with the last trading price. On the right column, by default, you will see the market value of the shares and their overall returns, as of now, in absolute terms. Tapping on the small green arrows in header of right column will display the market value of your holdings & their 1D returns. Another tap will display the current value and your actual purchase price.');
  }

  String get navNxtScnDesc2_1 {
    return Intl.message('Select');
  }

  String get navNxtScnDesc2_2 {
    return Intl.message(
        ' the share you want to view from the list of securities or cut through the clutter using the search feature');
  }

  String get navNxtScnDesc3_1 {
    return Intl.message('Sort and filter');
  }

  String get navNxtScnDesc3_2 {
    return Intl.message(' your positions using the smart filter  ');
  }

  String get navNxtScnDesc3_3 {
    return Intl.message(
        '.You have various sorting and filtering options in different tabs including sorting using 1-day returns, overall returns and the current value and filtering only profit-making holdings.');
  }

  String get navNxtScnDesc4_1 {
    return Intl.message('Get more information about a particular holding');
  }

  String get navNxtScnDesc4_2 {
    return Intl.message(
        ' by clicking on it.Clicking on an individual holding will open a new page with the following details:');
  }

  String get navNxtScnSubTitle {
    return Intl.message('Understand the Holdings table: ');
  }

  String get navNxtScnSubTitle1 {
    return Intl.message('Select ');
  }

  String get navNxtScnSubTitle2 {
    return Intl.message('Sort and filter ');
  }

  String get navNxtScnSubTitle5 {
    return Intl.message('Get additional options ');
  }

  String get navNxtScnSubTitle3 {
    return Intl.message('Get more information about a particular holding ');
  }

  String get navNxtScnSubTitle4 {
    return Intl.message('View BO Report: ');
  }

  String get viwRepDesc {
    return Intl.message(
        'Click on this button will take you to your backoffice Holdings report. ');
  }

  String get navNxtScnDesc5 {
    return Intl.message(
        'The average price and weightage of this holding in your overall portfolio in percentage. ');
  }

  String get navNxtScnDesc6 {
    return Intl.message(
        'Exit (sell) or Add (buy more) CTAs and the stock’s market depth in case you want to trade.');
  }

  String get navNxtScnDesc7 {
    return Intl.message(
        'Performance of the stock as of today and Stock Quote CTA button to dig in deeper about this stock.');
  }

  String get openPos {
    return Intl.message("Open Positions");
  }

  String get openPosDesc {
    return Intl.message(
        "An open position is a buy or sell trade that has been entered, but which has yet to be closed with a trade going in the opposite direction. For example, if you bought a stock but have not sold it yet, then it will be standing under “open position”.");
  }

  String get openPosDesc1 {
    return Intl.message(
        'Only includes trades done today. Previously traded positions are not shown here.');
  }

  String get openPosDesc2 {
    return Intl.message(
        'For derivatives, it includes trades done today and all carried forward previous positions.');
  }

  String get openPosDesc3 {
    return Intl.message(
        'When a position is open its value fluctuates continuously depending on the stock price movement. ');
  }

  String get serchDesc {
    return Intl.message(
        'You can view all your positions from the list or cut through the clutter using the search feature. Just tap on search icon and type the name of security you are looking for.');
  }

  String get sortDesc {
    return Intl.message('your positions using the smart filter ');
  }

  String get closeDesc1 {
    return Intl.message(
        'Tap on any of the positions on the list to view more details. From here, you can also choose ');
  }

  String get closeDesc2 {
    return Intl.message('Exit ');
  }

  String get closeDesc3 {
    return Intl.message('the position, ');
  }

  String get closeDesc4 {
    return Intl.message('Convert ');
  }

  String get closeDesc5 {
    return Intl.message('it from intraday to delivery or ');
  }

  String get closeDesc6 {
    return Intl.message('Add ');
  }

  String get closeDesc7 {
    return Intl.message('more positions.');
  }

  String get positionTdyre {
    return Intl.message('more positions.');
  }

  String get tgDesc {
    return Intl.message(
        'Trigger price is the price at which your stop-loss buy or sell order becomes active for execution and is submitted to the exchange. In other words, once the price of the stock hits the trigger price set by you, your stop-loss buy or sell order is sent to the exchange for execution.');
  }

  String get tgDesc1 {
    return Intl.message(
        'After the stop-loss order has been triggered, your shares/contract will be bought or sold at the limit price set by you for SL orders or at the market rate for SLM orders.');
  }

  String get tgDesc2 {
    return Intl.message(
        'The stop loss (SL) order has two price components to it');
  }

  String get tgDesc3 {
    return Intl.message('The stop loss price, also called the SL Limit Price.');
  }

  String get tgDesc4 {
    return Intl.message(
        'The stop loss trigger price, known as the Trigger Price.');
  }

  String get tgDesc5 {
    return Intl.message(
        '💡You can set the trigger price in both value and in percentage.');
  }

  String get webContentTitle {
    return Intl.message('Media Preview');
  }

  String get notification {
    return Intl.message('Notifications');
  }

  String get gotoSettings {
    return Intl.message('Go to settings ');
  }

  String get fingerprintrequired {
    return Intl.message('Biometric Required');
  }

  String get faceIdrequired {
    return Intl.message('Biometric Required');
  }

  String get myorderFirstQue {
    return Intl.message('How do new orders get reflected here?');
  }

  String get myorderFirstAns1_1 {
    return Intl.message(
        'When you place an order using the Arihant Web or Mobile app, it gets updated automatically in the My orders.\n\nYou can use this screen to');
  }

  String get myorderFirstAns1_2 {
    return Intl.message('See your order history');
  }

  String get myorderFirstAns1_3 {
    return Intl.message('Check out the status of the orders you placed');
  }

  String get myorderFirstAns1_4 {
    return Intl.message('Modify / cancel an existing order ');
  }

  String get myorderSecQue {
    return Intl.message('How to navigate this screen?');
  }

  String get myorderSecAns2_1 {
    return Intl.message(
        'The orders you have placed are summarized here for your quick reference.');
  }

  String get myorderSecAns2_2 {
    return Intl.message(
        'the order you want to view from the list of securities or cut through the clutter using the search feature. Just tap on search icon and type the name of security you are looking for. You can also view only your “Open” “Closed” “GTT” or “Bracket” orders using the navigation panel above.');
  }

  String get myorderSecAns2_3 {
    return Intl.message('your positions using the smart filter ');
  }

  String get myorderSecAns2_4 {
    return Intl.message('Understand the orders table');
  }

  String get myorderSecAns2_5 {
    return Intl.message('On the left side, you will find  ');
  }

  String get myorderSecAns2_6 {
    return Intl.message('The details of the shares you bought/sold ');
  }

  String get myorderSecAns2_7 {
    return Intl.message('The type of order (delivery/ intraday)');
  }

  String get myorderSecAns2_8 {
    return Intl.message(
        'The status of the order is colour-coded for your convenience, rejected and cancelled orders are coloured in red, pending in orange, and executed orders are in green.');
  }

  String get myorderSecAns2_9 {
    return Intl.message('On the right column, you can see');
  }

  String get myorderSecAns2_10 {
    return Intl.message('The price at which you placed the order ');
  }

  String get myorderSecAns2_11 {
    return Intl.message('The number of trades executed');
  }

  String get myorderSecAns2_12 {
    return Intl.message('The number of trades placed');
  }

  String get myorderSecAns2_13 {
    return Intl.message('The last trading price');
  }

  String get myorderSecAns2_14 {
    return Intl.message('The type of order ');
  }

  String get myorderSecAns2_15 {
    return Intl.message('by tapping on the order and dragging the screen up. ');
  }

  String get myorderSecAns2_16 {
    return Intl.message('“Modify” or “cancel” the order.');
  }

  String get myorderSecAns2_17 {
    return Intl.message(
        'Check additional details such as your order type, disclosed price, trigger price, order ID and exchange order ID.');
  }

  String get myorderSecAns2_18 {
    return Intl.message('Check the detailed status of the order.');
  }

  String get noDataHoldings {
    return Intl.message('No results for ');
  }

  String get watchlistInfoQue1 {
    return Intl.message('What is a watchlist?');
  }

  String get watchlistInfoQue2_1 {
    return Intl.message('Why are some scrips');
  }

  String get watchlistInfoQue2_2 {
    return Intl.message('and others marked as ');
  }

  String get watchlistInfoQue3_1 {
    return Intl.message('Why is ');
  }

  String get watchlistInfoQue3_2 {
    return Intl.message('BSE/NSE/NFO');
  }

  String get watchlistInfoQue3_3 {
    return Intl.message(' written along with the name of the scrip');
  }

  String get watchlistInfoQue4 {
    return Intl.message(
        'How do I buy or sell the stocks which are on my watchlist?');
  }

  String get watchlistInfoQue5 {
    return Intl.message('How can I add stocks to my watchlist?');
  }

  String get watchlistInfoQue6 {
    return Intl.message(
        'What does the briefcase symbol next to the stock on my watchlist mean?');
  }

  String get useThe {
    return Intl.message('Use the ');
  }

  String get watchlistInfo {
    return Intl.message(
        "Popular stocks are a curated list of frequently viewed A-group stocks. These are not stock recommendations by Arihant. Please research carefully before investing.");
  }

  String get watchlistGuide1 {
    return Intl.message('Your Watchlist Guide');
  }

  String get choosetheAlertType {
    return Intl.message('Choose the Alert type');
  }

  String get watchlistGuide2 {
    return Intl.message(
        'Here’s a quick guide for understanding every element on your watchlist.');
  }

  String get watchlistGuide3 {
    return Intl.message(
        'Stocks which touched their highest price in 52 weeks today (or the last updated trading day).');
  }

  String get watchlistGuide4 {
    return Intl.message('Bonus');
  }

  String get watchlistGuide5 {
    return Intl.message(
        'All the stocks which declared a bonus today have a B tagged against them.');
  }

  String get watchlistGuide6 {
    return Intl.message('Split ');
  }

  String get watchlistGuide7 {
    return Intl.message(
        'Stocks which had a split today have an “S” tagged against them.');
  }

  String get watchlistGuide8 {
    return Intl.message('Ex Dividend ');
  }

  String get watchlistGuide9 {
    return Intl.message(
        'Stocks which just paid out dividends have an eD tagged against them.The ex-dividend date or "ex-date" is the day the stock starts trading without the value of its next dividend payment.');
  }

  String get watchlistGuide10 {
    return Intl.message('Cum Dividend');
  }

  String get watchlistGuide11 {
    return Intl.message(
        'Stocks where the dividend is about to be paid have a cD tagged against it.');
  }

  String get watchlistGuide12 {
    return Intl.message('Holding');
  }

  String get watchlistGuide13 {
    return Intl.message(
        'The securities from your watchlist which are also part of your holdings with Arihant have a briefcase tag along with the quantity against it. ');
  }

  String get watchlistGuide14 {
    return Intl.message("National Stock Exchange");
  }

  String get watchlistGuide15 {
    return Intl.message('Tag for cash stocks of NSE.');
  }

  String get watchlistGuide16 {
    return Intl.message('Bombay Stock Exchange');
  }

  String get watchlistGuide17 {
    return Intl.message('Tag for cash stocks of BSE.');
  }

  String get watchlistGuide18 {
    return Intl.message('Futures and Options');
  }

  String get watchlistGuide19 {
    return Intl.message('Tag for Future and Options scrips of NSE.');
  }

  String get watchlistGuide20 {
    return Intl.message('Tag for Future and Options scrips of BSE.');
  }

  String get watchlistGuide21 {
    return Intl.message('CDS');
  }

  String get cdfullform {
    return Intl.message('Currency Derivative Segment');
  }

  String get watchlistGuide22 {
    return Intl.message(
        "Tag for scrips listed in the currency derivatives segment.");
  }

  String get watchlistInfoAns1 {
    return Intl.message(
        "Tired of searching for one stock, again and again, to check for its prices?We have created a place that you can use to discover, analyse and follow stocks you are interested in. What’s more, you can trade in them with just a swipe!");
  }

  String get watchlistInfoAns2_1 {
    return Intl.message(
        "against a scrip name allows you to add it to a watchlist. If the plus is filled ");
  }

  String get watchlistInfoAns2_2 {
    return Intl.message(
        ", this means that the stock is already added to any one of your watchlists, but you can still add this stock to another watchlist. Cool, right");
  }

  String get watchlistInfoAns3_1 {
    return Intl.message(
        "On your watchlist, NSE/BSE/NFO & CDS tags are added against a security, to make it easier for you to identify which scrip from which segment has been added by you in your watchlist. For e.g., ");
  }

  String get watchlistInfoAns3_2 {
    return Intl.message(
        "If you see Wipro NSE, then the price in the watchlist shown is of Wipro on NSE Segment");
  }

  String get watchlistInfoAns3_3 {
    return Intl.message(
        "If you see Wipro BSE, then the price in the watchlist shown is of Wipro on BSE Segment");
  }

  String get watchlistInfoAns3_4 {
    return Intl.message(
        "If you see Wipro NFO, then the Wipro security is of F&O segment of NSE.");
  }

  String get watchlistInfoAns3_5 {
    return Intl.message("CDS stands for currency derivatives segment");
  }

  String get watchlistInfoAns4 {
    return Intl.message(
        "Buying or selling securities from your watchlists just became lightning fast. Just swipe right or left if you wish to sell on the security in your watchlist to instantly place an order. Alternatively, you can click on the name of the security to open its stock quote page. Here you can view its market depth, charts, financials and numerous other analysis points to help you make a decision.");
  }

  String get watchlistInfoAns5_1 {
    return Intl.message(
        "Adding a stock to your Watchlist is extremely easy. There are two ways you can do this.");
  }

  String get watchlistInfoAns5_2 {
    return Intl.message(
        "Open the “Watchlist” section from your home screen and click on the search box");
  }

  String get watchlistInfoAns5_3 {
    return Intl.message(
        "Type in the first three letters of the scrip in the search box. ");
  }

  String get watchlistInfoAns5_4 {
    return Intl.message(
        "You can either select the scrip you want to add from the universe of securities or use pre-defined filters (Cash, F&O, ETFs) and cut through the clutter or scroll down and identify the scrip you wish to add.");
  }

  String get watchlistInfoAns5_5 {
    return Intl.message(
        " icon against the scrip name. This will open a new screen with the available watchlists. Choose the watchlist you want the security to be added to.\n\nIn some cases,  you will see a filled green button against it ");
  }

  String get watchlistInfoAns5_6 {
    return Intl.message(
        " .This happens when the security is already added to one of your watchlists. However, you can still choose to add it to other watchlists.");
  }

  String get watchlistInfoAns5_7 {
    return Intl.message(
        "\nVoila, you have added the stock to your chosen watchlist!\n/bHere’s another way you can build your watchlists./b\n");
  }

  String get watchlistInfoAns5_8 {
    return Intl.message(
        "Open the “Stock Quotes” page for the scrip you want to add.");
  }

  String get watchlistInfoAns5_9 {
    return Intl.message(
        "Click on “+” icon in the top right corner to add this scrip to a watchlist.");
  }

  String get watchlistInfoAns5_10 {
    return Intl.message(
        "Select the name of the watchlist.\n/bJust like that, you have added your favourite stock to your watchlist./b");
  }

  String get watchlistInfoAns6 {
    return Intl.message(
        "The briefcase symbol highlights those stocks which are part of your holdings and are also added to your preferred watchlist. The briefcase will be shown along with the total quantity of shares you hold.");
  }

  String get loginhelpQue1 {
    return Intl.message("How do I log in?");
  }

  String get loginhelpQue2 {
    return Intl.message(
        "Why do I need a 2FA? Can I login with FaceID or OTP on Arihant Plus? ");
  }

  String get loginhelpQue3 {
    return Intl.message(
        "I couldn’t setup biometrics the first time, can I still use login using biometrics? ");
  }

  String get loginhelpQue4 {
    return Intl.message("Do I have to enter an OTP every time I login? ");
  }

  String get loginhelpQue5 {
    return Intl.message("What is a client code? Where do I find mine? ");
  }

  String get loginhelpQue6 {
    return Intl.message("Can I change my login ID?");
  }

  String get loginhelpQue7 {
    return Intl.message(
        "Why am I unable to login with just my email ID/ mobile number? ");
  }

  String get loginhelpAns1_1 {
    return Intl.message(
        "We know remembering user ids is tough, so we've made the login process very simple. You can use login using your email id, client code, or phone number as your username.");
  }

  String get loginhelpAns1_2 {
    return Intl.message(
        "As a first-time user, you will have to do the following steps ");
  }

  String get loginhelpAns1_3 {
    return Intl.message("Set up your new password ");
  }

  String get loginhelpAns1_4 {
    return Intl.message("Set up a 4-digit PIN. ");
  }

  String get loginhelpAns1_5 {
    return Intl.message("Set up your two-factor authentication (2FA) ");
  }

  String get loginhelpAns1_6 {
    return Intl.message(
        "We’ve made 2FA authentication convenient for you by giving you the option to login viz biometrics, pattern lock or OTP verification.\n\nEvery subsequent time you log in, simply use your biometrics or pin – no need to enter the username and password again.");
  }

  String get loginhelpAns1_7 {
    return Intl.message("For all subsequent logins  ");
  }

  String get loginhelpAns1_8 {
    return Intl.message("You can use the biometrics of your choice");
  }

  String get loginhelpAns1_9 {
    return Intl.message(
        "Alternatively, you can skip biometrics by clicking on “Use PIN and OTP” ");
  }

  String get loginhelpAns1_10 {
    return Intl.message(
        "Once you login using this OTP it will be valid for 7 days. ");
  }

  String get loginhelpAns2 {
    return Intl.message(
        "As part of setting up robust cyber security, for your own safety, as defined by SEBI, a 2 Factor Authentication (2FA) is required to login to your trading platform.\n\nFor your convenience, we have given you a variety of options and you can decide how you would like to login. ");
  }

  String get loginhelpAns2_1 {
    return Intl.message('BIOMETRICS:');
  }

  String get loginhelpAns2_1_1 {
    return Intl.message(
        ' For super fast logins, you can use biometrics (fingerprint or FaceID) available on your device.');
  }

  String get loginhelpAns2_1_2 {
    return Intl.message(
        'If you have biometrics available, but don’t currently use them you can enable fingerprint/ Face ID by going to settings and enabling ');
  } //

  String get loginhelpAns2_1_3 {
    return Intl.message('“Biometrics”');
  }

  String get loginhelpAns2_2 {
    return Intl.message("PHONE PIN OR PATTERN: ");
  }

  String get loginhelpAns2_2_1 {
    return Intl.message(
        "If you do not have biometrics on your device or prefer not to use them, you can use the pattern lock or PIN, that you use on your device to login to Arihant Plus.");
  }

  String get loginhelpAns2_2_2 {
    return Intl.message(
        "If you don’t have device locks enabled, you can enable pattern/PIN by going to settings and enabling ");
  }

  String get loginhelpAns2_2_3 {
    return Intl.message("“Biometrics” ");
  }

  String get loginhelpAns2_3 {
    return Intl.message("PIN + OTP: ");
  }

  String get loginhelpAns2_3_1 {
    return Intl.message(
        "You can choose to skip biometrics and log in using PIN and OTP. You will receive this OTP on your registered mobile number and email ID.");
  }

  String get loginhelpAns2_3_2 {
    return Intl.message(
        "Once you login using this OTP it will be valid for 7 days for all your subsequent logins.");
  }

  String get loginhelpAns3 {
    return Intl.message(
        "Yes, you can enable biometrics any time you want, simply go through the following steps ");
  }

  String get loginhelpAns3_1 {
    return Intl.message("Login to Arihant Plus using your current login mode ");
  }

  String get loginhelpAns3_2_1 {
    return Intl.message("Go to  ");
  }

  String get loginhelpAns3_2_2 {
    return Intl.message("“My account”");
  }

  String get loginhelpAns3_2_3 {
    return Intl.message(" then ");
  }

  String get loginhelpAns3_2_4 {
    return Intl.message("“Settings”");
  }

  String get loginhelpAns3_3 {
    return Intl.message("Click on /b“Enable biometrics”/b");
  }

  String get loginhelpAns3_4 {
    return Intl.message(
        "You will now be redirected to your mobile device’s settings which will guide you in the biometrics setup depending on yoru device. ");
  }

  String get loginhelpAns4 {
    return Intl.message(
        "No, we know you may not like to enter an OTP every time you login. So, an OTP is only required if you have not enabled any of the 2-factor authentication modes such as fingerprint/ FaceID/ pattern lock.Even if you use PIN and OTP for login, OTP verification is mandatory only /bonce in every 7 days./b This is just one of the many things we have done to make your login super-fast so you never miss a good trade. ");
  }

  String get loginhelpAns4_1 {
    return Intl.message("Not working?Don’t worry.");
  }

  String get loginhelpAns4_2 {
    return Intl.message(
        "This may happen if you are a new client and your details are still being updated. For accounts opened before 2005, it is also possible if your date of birth is incorrect in our systems. Please get it corrected for a hasslefree experience by contacting modification@arihantcapital.com from your registered email ID along with a copy of your PAN card. ");
  }

  String get loginhelpAns5 {
    return Intl.message(
        "You are unique and we love it! A client code helps us recognize you from our various clients and customize the dashboard to your orders. Your client code is mentioned in your welcome email or in your transaction statements. If you are unable to find both, reach out to us at 0731-4217003, and our representatives will be happy to help! ");
  }

  String get loginhelpAns6 {
    return Intl.message(
        "You can’t change your Login ID once your account has been created and the ID has been allocated to you. Once the unique client code is updated on the exchange, it is not possible to change it. If you can’t remember your login id, you can login using your email id or mobile number. ");
  }

  String get loginhelpAns7 {
    return Intl.message(
        "This usually happens when one email ID or mobile number is associated with multiple clients. In this case, you have to use your unique client code to login. While this may seem inconvenient, this is a check added to enhance your security.\n\nPlease get your email id updated for easy access next time./link You can update your account here./link ");
  }

  String get whatbuyingpwr {
    return Intl.message('What is buying power?');
  }

  String get buypwrAns {
    return Intl.message(
        'Buying power is the amount of money you can use to purchase stocks, ETFs or derivatives through your Arihant account.');
  }

  String get incBuypwr {
    return Intl.message('How do I increase my buying power?');
  }

  String get whydoesBuypwr {
    return Intl.message(
        "Why does my buying power not include profits or credits from the previous trading day?");
  }

  String get diffBuypwr {
    return Intl.message(
        'What is the difference between buying power and utilised margin?');
  }

  String get diffBuypwrAns {
    return Intl.message(
        'Your buying power is the total amount of funds that you can use trade for that particular day. The account balance in your trading account is the opening balance of today\'s ledger. \n \n The utilized margin is: \n\n • The amount blocked for your open orders that are not yet executed. \n • The net funds utilized for your executed equity, intraday and delivery orders, F&O and CDS positional/intraday trading orders. \n • And M2M relized or unrealized loss of the day on equity intraday, F&O and CDS posiitons. \n \n Whenever you square off your positions, the utilizes margin will be credited back to your buying power.');
  }

  String get buyPwrupdate {
    return Intl.message('What does my buying power get updated?');
  }

  String get buyPwrupdateAns {
    return Intl.message(
        'Your buying power gets updated whenever: \n • You fund your trading account with cash (via bank transfer,cheque, or UPI) \n • You put through a fund withdrawal request, and it is processed. \n • You place a buy or sell order in the market. \n • Your existing open positions incur a loss.');
  }

  String get marketMoversDesc {
    return Intl.message(
        "Market Movers section allows you to easily discover the stocks that are trending in the market.In theMarket Movers snippet section, check out Top Gainers, Top Losers, 52W High &amp; Low, Most Active stocks of the day of Nifty 50 index (by default). However, when you click on View More, you can choose the index whose market movers you want to see.\n\nYou can discover what is trending in these major categories by navigating the panel below.");
  }

  String get cashMarket {
    return Intl.message("CASH MARKET");
  }

  String get topgainersCashinfo {
    return Intl.message(
        "The stocks which had the largest percentage increase in their price today.");
  }

  String get toplosersCashinfo {
    return Intl.message(
        "The stocks which had the largest percentage reduction in their market price today.");
  }

  String get fiftytwoweekhigh {
    return Intl.message("52 Week High");
  }

  String get fiftytwoweeklow {
    return Intl.message("52 Week Low");
  }

  String get fiftytwoweekhighCashinfo {
    return Intl.message(
        "The stocks which touched their 52-week high prices today.");
  }

  String get fiftytwoweeklowCashinfo {
    return Intl.message(
        "The stocks which touched their 52-week low prices today. A 52-week low is the lowest share price that the stock has traded during the last 12 months.");
  }

  String get mostactiveVolume {
    return Intl.message("Most Active Volume");
  }

  String get mostactiveVolumecashifo {
    return Intl.message(
        'The stocks which had the highest trading volume during the day.');
  }

  String get mostactiveValue {
    return Intl.message("Most Active Value");
  }

  String get mostactiveValuecashinfo {
    return Intl.message(
      "The stocks which were traded the most by their value during the day.",
    );
  }

  String get upperCircuitCashinfo {
    return Intl.message(
        "The stocks which have only buyers and no sellers present, due to which it hit the Upper Circuit. The upper circuit is the maximum price that the stock can touch in a day.");
  }

  String get lowerCircuitCashinfo {
    return Intl.message(
        "The stocks which have only sellers and no buyers present, due to which it hit the Lower Circuit. The lower circuit is the minimum price that the stock can touch in a day.");
  }

  String get protipCash {
    return Intl.message("Pro tip: ");
  }

  String get protipCashinfo {
    return Intl.message(
        "You can choose the index you want to track e.g., Nifty Midcap and create your own customized list of market movers. You can also use “Sort and Filter” to refine this list according to the price or percentage change in the stock.");
  }

  String get note {
    return Intl.message("Note: ");
  }

  String get enableBiometricsfromSettings {
    return Intl.message(
        "Instead, Login via Biometric, Go to My accounts and then Settings to enable.");
  }

  String get noteCashinfo {
    return Intl.message(
        "These stocks are not recommendations by Arihant but are auto populated based on the market and stock movements.");
  }

  String get marketMoverfando {
    return Intl.message("F&O");
  }

  String get topgainerfandoInfo {
    return Intl.message(
        "The F&O contracts which had the largest percentage increase in their price today.");
  }

  String get toploserfandoInfo {
    return Intl.message(
        "The F&O contracts which had the largest percentage reduction in their market price today.");
  }

  String get mostActivefando {
    return Intl.message("Most Active");
  }

  String get mostActivefandoInfo {
    return Intl.message(
        "The F&O contracts which had the most open interest in the markets today.");
  }

  String get protipFandoinfo {
    return Intl.message(
        "You can also use “Sort and Filter” to refine this list according to the price or percentage change in the contracts.");
  }

  String get noteFandoinfo {
    return Intl.message(
        "These contracts are not recommendations by Arihant but are auto-populated based on the market and contract movements.");
  }

  String get iOSbiometricDisabled {
    return Intl.message(
        "Biometrics is disabled. Please enable in your phone settings and try again");
  }

  String get biometricCantBeDisabled {
    return Intl.message("Biometric can't be disabled");
  }

  String get biometricNotAvailable {
    return Intl.message("Biometrics Not Available");
  }

  String get loginToSetBiometric {
    return Intl.message("Login Again to Set Biometrics");
  }

  String get biometricDisabled {
    return Intl.message("Biometrics Disabled");
  }

  String get buypwrNeedhlpque2Desc {
    return Intl.message(
        'You can increase your buying power by transferring money into your brokerage account or closing any existing positions. To transfer money, you can go to My Account or Funds and click on Add Transfer. The money deposited via UPI or Net Banking will be credited to your trading account and you can use it instantly for your trades.\nYou can also increase your buying power by  pledging your securities with Arihant. Sounds cool right');
  }

  String get learnmoreWithdot {
    return Intl.message('Learn more.');
  }

  String get buypwrNeedhlpque5Desc {
    return Intl.message("Your buying power gets updated whenever:");
  }

  String get buypwrNeedhlpque5DescPnt1 {
    return Intl.message(
      "You fund your trading account with cash (via bank transfer, cheque, or UPI). ",
    );
  }

  String get buypwrNeedhlpque5DescPnt2 {
    return Intl.message(
      "You put through a fund withdrawal request, and it is processed. You place a buy or sell order in the market. ",
    );
  }

  String get buypwrNeedhlpque5DescPnt3 {
    return Intl.message(
      "You place a buy or sell order in the market. ",
    );
  }

  String get buypwrNeedhlpque5DescPnt4 {
    return Intl.message(
      "Your existing open positions incur a loss.",
    );
  }

  String get buypwrNeedhlpque4Desc1 {
    return Intl.message(
        "Your buying power is the total amount of funds that you can use to trade for that particular day. The account balance in your trading account is the opening balance of today’s ledger. ");
  }

  String get buypwrNeedhlpque4Desc2 {
    return Intl.message("The utilized margin is: ");
  }

  String get buypwrNeedhlpque4Pnt1 {
    return Intl.message(
        "The amount blocked for your open orders that are not yet executed.");
  }

  String get buypwrNeedhlpque4Pnt2 {
    return Intl.message(
        "The net funds utilized for your executed equity, intraday and delivery orders, F&O and CDS positional/intraday trading orders.");
  }

  String get buypwrNeedhlpque4Pnt3 {
    return Intl.message(
        "Any M2M realized or unrealized loss of the day on equity intraday, F&O and CDS positions. ");
  }

  String get buypwrNeedhlpque4Desc3 {
    return Intl.message(
        "Whenever you square off your positions, the utilized margin will be credited back to your buying power.");
  }

  String get buypwrNeedhlpque3Desc {
    return Intl.message(
        'The buying power (or available margin) in your Arihant account does not inlcude any credits from profit or sales made on the previous date (T1) due to the upfront margin requirements applicable from September 2020 onwards. \n \nIf a trading session falls on a settlement holiday or settlement is delayed on a given day, these balance will not be a part of your available margin: \n \n');
  }

  String get buypwrNeedhlpque3Pnt1Head {
    return Intl.message('• Intraday profits -');
  }

  String get buypwrNeedhlpque3Pnt1Desc {
    return Intl.message(
        'Any intraday profits from the previous trade day for F&O and the previous two trade days for equity. \n');
  }

  String get buypwrNeedhlpque3Pnt2Head {
    return Intl.message('• Other F&O credits -');
  }

  String get buypwrNeedhlpque3Pnt2Desc {
    return Intl.message(
        'Any other derivative segment credits (i.e ., premium from options sold, marked-to-market profit, etc.) from previous trade day. \n \n');
  }

  String get buypwrNeedhlpque3Desc2 {
    return Intl.message(
        'The above credits will reflects in your available margins after they are settled by the exchange.');
  }

  String get buypwrNeedhlpClickhere {
    return Intl.message(" Click here to ");
  }

  String get manageWatchlistQue1 {
    return Intl.message("How to add a new watchlist?");
  }

  String get manageWatchlistQue1Desc1 {
    return Intl.message(
        "Let’s set up a new watchlist to help you in your investment journey. ");
  }

  String get manageWatchlistQue1Step1 {
    return Intl.message(
        "Go to the “Watchlist” section, and click on the drop-down button that will invoke the lists of watchlists. ");
  }

  String get manageWatchlistQue1Step2 {
    return Intl.message("Click on “Create new”.");
  }

  String get manageWatchlistQue1Step3 {
    return Intl.message(
        "Define the new watchlist with a name that will help you recognize the purpose of the watchlist. Eg: “EV stocks”,  “High Dividend”, “My favourites”  (under 15 characters). You can always rename the watchlist as you refine your investment goals in the “Manage Watchlist” section by clicking on “Rename”.");
  }

  String get manageWatchlistQue2 {
    return Intl.message("How can I delete a watchlist?");
  }

  String get manageWatchlistQue2Desc {
    return Intl.message(
        "Enter the “Manage Watchlist” section and click on the “x” button next to the watchlist you want to delete.");
  }

  String get manageWatchlistQue3 {
    return Intl.message("How can I delete a scrip from a watchlist?");
  }

  String get manageWatchlistQue3Desc {
    return Intl.message(
        "Don’t want to follow a scrip? No worries, simply long-press on any of the security in the watchlist or click “Edit Watchlist” button at the bottom. Your watchlist will now enter the edit mode. From here you can delete a scrip, rearrange securities within the watchlist or rename your watchlist. Click on “Done” when you have made the changes. ");
  }

  String get edisInfo1 {
    return Intl.message("Why do I need to authorize a sell transaction?");
  }

  String get edisInfo2 {
    return Intl.message(
        "To ensure you have a secure transfer of securities, SEBI has prescribed guidelines which need all investors to authorize their sale transactions.");
  }

  String get edisInfo3 {
    return Intl.message(
        "What are the various methods I can use to authorize my sell transactions?");
  }

  String get edisInfo4 {
    return Intl.message(
        "You can authorize the sale of their securities using these methods.");
  }

  String get edisInfo5 {
    return Intl.message("POA: ");
  }

  String get edisInfo6 {
    return Intl.message(
        "You can provide a Power of Attorney (POA) to Arihant. This will allow Arihant to automatically debit your shares from your demat account whenever you sell your holdings. This is a one-time process and ensures that you have a seamless and smooth trading experience.");
  }

  String get edisInfo7 {
    return Intl.message("eDIS: ");
  }

  String get edisInfo8 {
    return Intl.message(
        "If you choose not to give a POA to Arihant, you can authorize your sale transactions using the ");
  }

  String get edisInfo9 {
    return Intl.message("Electronic Delivery Instruction Slip or eDIS");
  }

  String get edisInfo10 {
    return Intl.message(
        " facility. Here, you must submit a TPIN (for CDSL) or MPIN (for NSDL) to validate your sell transaction.For your convenience, you can authorize all the sale transactions in one shot. You will also need an OTP sent on your registered mobile number.");
  }

  String get edisInfo11 {
    return Intl.message("Physical DIS:");
  }

  String get edisInfo12 {
    return Intl.message(" You can also choose to submit a physical ");
  }

  String get edisInfo13 {
    return Intl.message(
        "Delivery Instruction Slip to the nearest Arihant branch.");
  }

  String get edisInfo14 {
    return Intl.message("How can I allow POA to Arihant?");
  }

  String get edisInfo15 {
    return Intl.message("To allow Power of Attorney to Arihant you need to ");
  }

  String get edisInfo16 {
    return Intl.message("download the POA form");
  }

  String get edisInfo17 {
    return Intl.message(" and submit it to your ");
  }

  String get edisInfo18 {
    return Intl.message("nearest Arihant branch");
  }

  String get edisInfo19 {
    return Intl.message("What is a TPIN? How do I find my TPIN?");
  }

  String get edisInfo20 {
    return Intl.message(
        "A TPIN is a 6-digit code provided by CDSL to authenticate your sale transactions. You can find it in your email or SMS from CDSL when you opened a demat account with Arihant. If you cannot find the TPIN, click on “Forgot TPIN” and create a new TPIN. You will just need to verify the OTP received on your registered email id and phone number");
  }

  String get edisInfo21 {
    return Intl.message("What is an MPIN? How do I find my MPIN?");
  }

  String get edisInfo22 {
    return Intl.message(
        "An MPIN is a 6-digit code provided by NSDL to authenticate your sale transactions. You can find it in your email or SMS registered with your demat account. If you cannot find the MPIN, click on “Forgot MPIN” and create a new MPIN. You will just need to verify the OTP received on your registered email id and phone number.");
  }

  String get edisInfo23 {
    return Intl.message("Do I need to authorize every sale transaction?");
  }

  String get edisInfo24 {
    return Intl.message(
        "If you have provided a POA to Arihant, you do not need to authorize a transaction. However, if you have not provided a POA, you will need to provide an e-DIS to authorize your sale transactions. You can authorize all sale transactions in one shot which will stay valid for one trading day.");
  }

  String get edisInfo25 {
    return Intl.message(
        "Pro tip:⚡ For lightning-fast executions, you can authorize all transactions at the beginning of a trading day and ensure you never miss a good deal. You can authorize upto 50 scrips in one go.");
  }

  String get helpTopics {
    return Intl.message("Help Topics");
  }

  String get plus {
    return Intl.message("Plus");
  }

  String get biometricNotVerified {
    return Intl.message("Biometrics Not Verified. Try Again");
  }

  String get cantfind {
    return Intl.message('Can\'t find what you are looking for?');
  }

  String get visit {
    return Intl.message('Visit');
  }

  String get helpsection {
    return Intl.message('Help Section');
  }

  String get mytransferfailed {
    return Intl.message(
        'My transfer has failed but the amount was debited from my account. When can I expect it back?');
  }

  String get transferfailed {
    return Intl.message(
        'Uh - oh! Transfer failures happens sometimes. No need to worry, if your amount is not showing up in your Arihant account, it might already be on its way. Contact your bank to know the status. Alternatively, if the money was transferred from a bank account linked with your Arihant brokerage account, then it may show up soon in your balance and you can request for fund withdrawal once its up.');
  }

  String get netbankfailmessage {
    return Intl.message(
        'What did I get failure message for Net Banking transactions?');
  }

  String get upifail {
    return Intl.message('Why did my UPI payment fail?');
  }

  String get upifailamounttransfer {
    return Intl.message(
        'Why did my fund tranfer fail when I tried transferring money through my husband\'s bank account?');
  }

  String get mypayfail {
    return Intl.message(
        'My payment failed, is there another way to get some limit to trade before the market ends?');
  }

  String get maxAttempts {
    return Intl.message("Maximum attempts reached.Try again later");
  }

  String get biometricNotavailable {
    return Intl.message("Biometrics not available");
  }

  String get accntBalinfo {
    return Intl.message("Your account balance is your opening balance.");
  }

  String get accntBalheading {
    return Intl.message("Account Balance");
  }

  String get whatisPriBankAcc {
    return Intl.message('What is a primary bank account?');
  }

  String get whatisPriBankAccAns {
    return Intl.message(
        'To buy/sell securities at Arihant Capital, you need to register your bank account(s). One of your bank accounts will be marked as a Primary Bank Account. The first bank you register with Arihant will be marked as primary, by default. This will be the bank account in which all transfers from Arihant will be made to you, if another bank is not chosen.');
  }

  String get choosebankNeedhelp2Qns {
    return Intl.message(
        'Can I transfer from an account that is not listed here?');
  }

  String get choosebankNeedhelp2Ans {
    return Intl.message(
        'No, you can only transfer funds from bank accounts in your name that are linked to your trading account(shown above) as mandated by SEBI regulations.');
  }

  String get choosebankNeedhelp3Qns {
    return Intl.message('How do I add a new bank account?');
  }

  String get choosebankNeedhelp4Qns {
    return Intl.message('How can I change my primary bank account?');
  }

  String get choosebankNeedhelp3Ans1 {
    return Intl.message('You can add a new bank account through ');
  }

  String get choosebankNeedhelp3Ans2 {
    return Intl.message('re-KYC request');
  }

  String get choosebankNeedhelp3Ans3 {
    return Intl.message('Click here ');
  }

  String get choosebankNeedhelp3Ans4 {
    return Intl.message(
        'to enter the re-KYC application, enter your bank account details here. We will try to make your verification as easy as possible, by transferring ');
  }

  String get rupeeSymbol {
    return Intl.message('₹');
  }

  String get choosebankNeedhelp3Ans5 {
    return Intl.message(
        '1 to your bank account. In case re-KYC does not work for some reason, then:');
  }

  String get choosebankNeedhelp3Ans6 {
    return Intl.message('1. Download ');
  }

  String get choosebankNeedhelp3Ans7 {
    return Intl.message('Account Details Modification Request Form');
  }

  String get choosebankNeedhelp3Ans8 {
    return Intl.message(' PDF file.');
  }

  String get choosebankNeedhelp3Ans9 {
    return Intl.message('2. Print it, fill the form and sign it.');
  }

  String get choosebankNeedhelp3Ans10 {
    return Intl.message(
        '3. Attach a copy of a cancelled cheque, bank statement or a copy of the bank passbook.');
  }

  String get choosebankNeedhelp3Ans11 {
    return Intl.message(
        '4. Submit or courier it to your Arihant Investment Center.');
  }

  String get choosebankNeedhelp4Ans1 {
    return Intl.message(
        'To change your primary account in your trading account, you just need to send an email to ');
  }

  String get choosebankNeedhelp4Ans2 {
    return Intl.message('modification@arihantcapital.com');
  }

  String get choosebankNeedhelp4Ans3 {
    return Intl.message(
        ' indicating which account you woulld like to be marked as "primary" for future transactions.');
  }

  String get paymentmodes {
    return Intl.message('Payment Modes');
  }

  String get paymentmodesNeedhelp {
    return Intl.message(
        'We have made fund transfer really simple for you! You can now use any of the following three methods to add cash to your Arihant Balance in just a few clicks.');
  }

  String get upi {
    return Intl.message('UPI');
  }

  String get upiSubtitle {
    return Intl.message('Get instant cash for trading');
  }

  String get free {
    return Intl.message('free');
  }

  String get netBanking {
    return Intl.message('Netbanking');
  }

  String get netBankingSubtitle {
    return Intl.message('Instant payment gateway');
  }

  String get neft {
    return Intl.message('NEFT/RTGS/IMPS');
  }

  String get neftSubtitle {
    return Intl.message('Get cash in 3 minutes (Bank charges may apply)');
  }

  String get throughOffline {
    return Intl.message('Through Offline');
  }

  String get throughOfflineSubtitle {
    return Intl.message(
        'In case you are having troube transferring funds online, you can always drop off a cheque to your nearest branch.\n');
  }

  String get branchLocator {
    return Intl.message('Branch Locator');
  }

  String get upitransfer {
    return Intl.message('UPI Transfer');
  }

  String get netBanking1 {
    return Intl.message('Net Banking');
  }

  String get transferText {
    return Intl.message('NEFT/RTGS/IMPS Transfer');
  }

  String get upitransferContent {
    return Intl.message(
        'Unified payments Interface (UPI) has made making online payments really simple and secure. using UPI, you can transfer funds instantly from your registered bank account for free.');
  }

  String get upitransferStep1 {
    return Intl.message('Step 1');
  }

  String get upitransferStep1Info {
    return Intl.message('Enter the amount you wish to transfer.');
  }

  String get upitransferStep2 {
    return Intl.message('Step 2');
  }

  String get upitransferStep2Info {
    return Intl.message(
        'Choose the UPI app you frequently use from the list or click "other UPI" and enter your UPI ID and click on "Proceed".');
  }

  String get upitransferStep3 {
    return Intl.message('Step 3');
  }

  String get upitransferStep3Info {
    return Intl.message('Enter your 6-digit UPI Pin.');
  }

  String get upitransferStep4 {
    return Intl.message('Step 4');
  }

  String get upitransferStep4Info {
    return Intl.message(
        'Hooray! Your Arihant account is now funded for trading.');
  }

  String get optionChainDisclaimer {
    return Intl.message("Disclaimer:");
  }

  String get optionChainDisclaimerInfo1 {
    return Intl.message(
        "Arihant’s discovery feature for options trading is meant for informational purposes only and is not a recommendation to any customer to enter into any particular transaction or adopt any particular strategy. Every strategy and investment in the securities market are subject to market risks.Investors should carefully consider their investment objectives and risks carefully before investing.Visit ");
  }

  String get optionChainDisclaimerInfo2 {
    return Intl.message('www.arihantcapital.com');
  }

  String get optionChainDisclaimerInfo3 {
    return Intl.message(' for complete disclaimers.');
  }

  String get disclaimer {
    return Intl.message("Disclaimer");
  }

  String get disclaimerContent {
    return Intl.message(
        "Investing in the stock markets is subject to market risks, it also requires a careful understanding of financial data to understand the company's valuations. This financial data shown above is sourced from information available in the public domain by reliable data provider. Arihant Capital is not responsible for the accuracy, adequacy and verity of the data provided. Please ensure you do a thorough stock analysis before making your investments.");
  }

  String get cmotsData {
    return Intl.message(
        "Data provided by C-MOTS Internet Technologies Pvt Ltd");
  }

  String get step1 {
    return Intl.message('Step 1: ');
  }

  String get step2 {
    return Intl.message('Step 2: ');
  }

  String get step3 {
    return Intl.message('Step 3: ');
  }

  String get overviewInfo1 {
    return Intl.message(
        'Operating income as a ratio of the sales revenue. This shows the amount of revenue created per ');
  }

  String get overviewInfo2 {
    return Intl.message(' of sales.');
  }

  String get overviewInfo3 {
    return Intl.message(
        'The financial ratios and statistics which are relevant in understanding the company’s financial health. This information is updated quarterly or annually.');
  }

  String get marketSequenceOrderSuccessMsg {
    return Intl.message("Sequence of customized indices changed successfully");
  }

  String get aboutus1 {
    return Intl.message(
        "Generating wealth for you is at the heart of everything we do");
  }

  String get aboutus2 {
    return Intl.message(
        "We want to help our clients meet their financial goals with passion and integrity. Since day one, we are committed to giving our customers the best services while holding to our core values which always place our client's interests first.\n \n Started as a boutique stock broking company in Central India, today Arihant Capital Markets Limited is one of the leading financial services companies of India. We provide a gamut of products and services including equities, commodities, currency, financial planning, depository services, priority client group services (PCG), merchant banking and investment banking services to a substantial and diversified clientele that includes individuals, corporations and financial institutions.\n\nWe are committed to giving our customers the best services and holding to our core values which always place our client's interests first.\n\nArihant Capital provides investing and trading services to over 1.45 lac customers through its 800 plus investment centers that are spread over 185 plus cities in India. Clients turn to Arihant for its complete platform of financial services and the trust that we work in the interest of our clients. (Details as on 31st March 2019)\n\nWe have a dedicated institutional team which caters to India's leading mutual fund houses, insurance companies and almost all the banks active in the capital market segment.\n\nOur goal is to create wealth for our customers through sound financial advice and appropriate investment strategies. We want to help our clients met their financial goals with passion and integrity.");
  }

  String get aboutus3 {
    return Intl.message(
        "NSE, BSE (Equity & CDS) – SEBI registration no.: INZ000180939 | TM Code: NSE – 07839 & BSE – 313 | NSDL: IN-DP-127-2015 DPID-IN301983 | CDSL DP ID-43000");
  }

  String get netbankfailmessage1 {
    return Intl.message(
        "These things happen. While we know its frustrating, it could be because of some credible reasons. Some of the common reasons for fund transfer failures include: \n\n 1. Insufficient account balance \n 2. Transfer of funds using third party account \n 3. Payment gateway request timed out because of delay in authentication \n 4. Invalid account details \n 5. System error due to technical issues \n 6. Validation Failure \n 7. Account disabled \n 8. Accidental click on cancel payment button \n \n Don't worry, you can still transfer using UPI, instant NEFT/RTGS/IMPS (using the account details provided on the app) or submit a cheque to your Arihant investment center.");
  }

  String get upifail1 {
    return Intl.message(
        "When trying to add funds to your trading account, the UPI transaction may fail for one of the following reasons. \n\n 1. The UPI ID (VPA) is mapped to a bank account that is not registered with Arihant. You can only add funds using this bank account linked with Arihant. \n 2. You exhausted the daily UPI transfer limit set by your bank \n 3. You entered incorrect UPI ID (VPA) \n 4. You have insufficient balance in your account that you are using for UPI transfer \n 5. You entered the wrong pin \n 6. You entered incorrect pin more than 3 times and will not be able to reset the pin for next 24 hrs \n 7. Your payment failed due to validation failure at the bank level or at the payment gateway \n 8. The payment was not compelted within 10 minutes of the time of initiation \n 9. Your bank account is blocked \n\n Don't worry, you can still transfer using the in-app Net Banking facility (its instanst transfer using payment gateway), instant NEFT/RTGS/IMPS (using the account detaild provided on the app) or submit a cheque to your Arihant investment center.");
  }

  String get upifailamounttransfer1 {
    return Intl.message(
        "As per SEBI guidelines, you can only fund your brokerage account from your own bank account, and it must be linked with your broker. This means, your bank account needs to be registered and verified before you initiate any fund transfer from it.");
  }

  String get addFundsHelpContentError4 {
    return Intl.message(
        "You can get extra buying power, without transferring cash, by using Arihant’s margin pledge facility. Through Margin Pledge you can use your existing holdings/portfolio to get an additional limit/margin. You can then use this extra margin to buy more shares. You will be charged a nominal interest rate for borrowing funds using margin pledge.");
  }

  String get addFundsNetBankingError1 {
    return Intl.message(
        "Oops, your bank is not supported for Net Banking facility!");
  }

  String get addFundsNetBankingError2 {
    return Intl.message(
        "We're sorry, your current bank is not supported for net banking facility at the moment. But don't worry, you can fund your trading account using 'UPI' or transfer via RTGS/NEFT.");
  }

  String get addFundsNetBankingHelpError1 {
    return Intl.message(
        "Why is instant payment via net banking not applicable on my bank?");
  }

  String get addFundsNetBankingHelpError2 {
    return Intl.message(
        "As per compliance guidelines, in-app Netbanking using instant payment gateway facility will only be applicable for those banks that support Third-Party Verification. If your bank does not support the verification, then you cannot use the in-app net banking facility.  \n\n However, you can use the UPI for instant cash transfer or use the digitized NETF/RTGS/IMPS facility where we create a custom account for you to transfer funds and get cash for trading within 10 minutes.");
  }

  String get addFundsNetBankingHelpError3 {
    return Intl.message(
        "Which banks are supported for in-app net banking using instant payment gateway?");
  }

  String get addFundsNetBankingHelpError4 {
    return Intl.message(
        "You can use Netbanking to transfer funds to your Arihant account from the following banks that support in-app banking facilities: \n\n");
  }

  String get addFundsNetBankingHelpError5 {
    return Intl.message(
        " 1. Axis bank \n 2. ICICI Bank \n 3. HDFC Bank \n 4. State Bank of India \n 5. Yes Bank \n 6. Indusind Bank\n");
  }

  String get addFundsNetBankingHelpError6 {
    return Intl.message(
        " 7. AU Small Finance Bank \n 8. Bank of Baroda \n 9. Bank of India \n 10. Bank of Maharashtra \n 11. Canara Bank \n 12. CSB Bank \n 13. City Union Bank \n 14. DCB Bank \n 15. Deutsche Bank \n 16. Dhanlaxmi Bank \n 17. IDFC FIRST Bank Limited \n 18. Indian Bank \n 19. indian Overseas bank  \n 20. Indusind Bank \n 21. Jammu and Kashmir Bank \n 22. Janata Sahakari Bank Ltd \n 23. Karnataka Bank \n 24. Karur Vysya Bank \n 25. Kotak Mahindra Bank \n 26. Lakshmi Vilas Bank \n 27. Punjab National Bank \n 28. Punjab & Sind Bank \n 29. RBL Bank \n 30. Saraswati Bank \n 31. Tamilnad Mercantile Bank \n 32. UCO Bank \n 33. Union Bank of India\n\n");
  }

  String get showMore {
    return Intl.message("Show more");
  }

  String get showLess {
    return Intl.message("Show less");
  }

  String get addFundsPaymentModeHelp1 {
    return Intl.message(
        "Fund your trading account instantly with net banking facility using our payment gateway.");
  }

  String get addFundsPaymentModeHelp2 {
    return Intl.message("Step 1: Enter Amount");
  }

  String get addFundsPaymentModeHelp3 {
    return Intl.message("Add the amount you would need to invest or trade.");
  }

  String get addFundsPaymentModeHelp4 {
    return Intl.message("Step 2: Choose Bank");
  }

  String get addFundsPaymentModeHelp5 {
    return Intl.message(
        "Your primary bank account is selected by default. However, if you wish to use another registered account to transfer funds, then click on > sign in primary account row. It will take you to another window with a list of all your bank accounts registered with Arihant. From this list, select the bank you want to use for transfer.");
  }

  String get addFundsPaymentModeHelp6 {
    return Intl.message("Step 3: Select \"Netbanking\" under payment methods");
  }

  String get addFundsPaymentModeHelp7 {
    return Intl.message(
        "Once your bank is chosen, now under Step 2, select the \"Netbanking\". You will be redirected to your bank's netbanking facility.");
  }

  String get addFundsPaymentModeHelp8 {
    return Intl.message("Step 4: Login to bank and transfer");
  }

  String get addFundsPaymentModeHelp9 {
    return Intl.message(
        "Simply follow your bank's instructions to complete the transaction. Basically, login to your bank account, re-check the amount, enter OTP and voila! Your account is funded, and you are all set to trade.");
  }

  String get addFundsPaymentModeHelp10 {
    return Intl.message(
        "Make sure to tranfer funds only from bank accounts registered with Arihant.");
  }

  String get addFundsPaymentModeHelp11 {
    return Intl.message("Transfer via NEFT / RTGS / IMPS");
  }

  String get addFundsPaymentModeHelp12 {
    return Intl.message(
        "Transfer funds directly from your bank account using NEFT, RTGS or IMPS facility provided by your bank.");
  }

  String get addFundsPaymentModeHelp13 {
    return Intl.message(
        "First time transferring funds to Arihant? Copy Arihant's customer bank details from NEFT/RTGS payment mode screen provided in the Add Funds section.");
  }

  String get addFundsPaymentModeHelp14 {
    return Intl.message("Go to your bank's website or mobile app and login.");
  }

  String get addFundsPaymentModeHelp15 {
    return Intl.message(
        "Add a payee by selecting the \"Add New Payee\" option availabe under Transfer Funds and enter Arihant's bank details you copied in Step 1.");
  }

  String get addFundsPaymentModeHelp16 {
    return Intl.message(
        "Once a beneficiary is added, you can \"Transfer funds\" and choose Arihant Capital as your beneficiary. Enter the amount youe wish to tranfer and authenticate the transaction using OTP.");
  }

  String get addFundsPaymentModeHelp17 {
    return Intl.message("Step 5");
  }

  String get addFundsPaymentModeHelp18 {
    return Intl.message(
        "Your funds should now get transferred soon (within 15 minutes). Open the Arihant app to get confiramtion and start trading.");
  }

  String get addFundsPaymentModeHelp19 {
    return Intl.message("Bank charges may apply.");
  }

  String get addFundsPaymentModeHelp20 {
    return Intl.message(
        "Make sure to tranfer funds only from bank accounts registered with Arihant.");
  }

  String get addFundsPaymentModeHelp21 {
    return Intl.message(
        "NEFT/RTGS/IMPS transactions usually take 3 minutes. If your amount is not credited to your Arihant wallet witin 10 minutes, contact our customer care at 0731-4217003.");
  }

  String get addFundsImpsTransaction1 {
    return Intl.message("Transfer money only from this account");
  }

  String get addFundsImpsTransaction2 {
    return Intl.message("To the following Bank account");
  }

  String get addFundsImpsTransaction3 {
    return Intl.message('Arihant Balance');
  }

  String get addFundsImpsTransaction4 {
    return Intl.message("Beneficiary Name");
  }

  String get addFundsImpsTransaction5 {
    return Intl.message("Bank Name");
  }

  String get addFundsImpsTransaction6 {
    return Intl.message("Account No");
  }

  String get addFundsImpsTransaction7 {
    return Intl.message("Account Type");
  }

  String get addFundsImpsTransaction8 {
    return Intl.message("IFSC code");
  }

  String get addFundsImpsTransaction9 {
    return Intl.message("Copied");
  }

  String get addFundsImpsTransaction10 {
    return Intl.message(
        "If your funds aren't credited to your Arihant account within 10 minutes, then contact");
  }

  String get addFundsImpsTransaction11 {
    return Intl.message(
        "Third party transfers are not permitted. If you are transferring funds from any other bank accounts, your transaction will not be accepted, and your money will be refunded to your bank account within 2-5 working days.");
  }

  String get addFundsImpsTransaction12 {
    return Intl.message("");
  }

  String get addFundsImpsTransaction13 {
    return Intl.message("");
  }

  String get addFundsImpsTransaction14 {
    return Intl.message("");
  }

  String get biometricdisabled {
    return Intl.message("Biometric Disabled");
  }

  String get biometricdisabledContent {
    return Intl.message(
        "You have reached maximum no.of wrong attempts.Biometric is disabled.Please try after some time.");
  }

  String get reKyc {
    return Intl.message("Edit");
  }

  String get editInfo {
    return Intl.message(
        "You can modify or update the personal details, Bank details and Nominee details of your ID. This process may take some time.");
  }

  String get totpDesc {
    return Intl.message(
        "Enter the text code below to the TOTP app(Google Authenticator,Microsoft Authenticator etc.)");
  }

  String get totpStep1 {
    return Intl.message("Download any authenticator application");
  }

  String get totpStep2 {
    return Intl.message('Tap on "Add account icon"');
  }

  String get totpStep3 {
    return Intl.message('Then tap on "Enter a setup key"');
  }

  String get totpStep4 {
    return Intl.message(
        'Enter the Account name and Key.Then Tap on "Add" button');
  }

  String get resetCode {
    return Intl.message("Reset code");
  }

  String get reset {
    return Intl.message("Reset");
  }

  String get copyCode {
    return Intl.message("Copy code");
  }

  String get generateotpDesc {
    return Intl.message("Tap below button to generate TOTP");
  }

  String get generateOtp {
    return Intl.message("Generate TOTP");
  }

  String get disableTotp {
    return Intl.message("Disable TOTP");
  }

  String get openingBalance {
    return Intl.message("Opening Balance");
  }

  String get closingBalance {
    return Intl.message("Closing Balance");
  }

  String get buyValue => "Buy Value";
  String get buyAvg => "Buy Avg.";
  String get sellValue => "Sell Value";
  String get sellAvg => "Sell Avg.";
  String get prevCloseval => "Prev. Closing Pr.";
  String get marketValue => "Market Val.";
  String get realized => "Realized";
  String get unrealized => "Unrealized";
  String get realizedPL => "Realized P&L";
  String get unrealizedPL => "Unrealized P&L";
  String get overallPl => "Overall P&L";
}
