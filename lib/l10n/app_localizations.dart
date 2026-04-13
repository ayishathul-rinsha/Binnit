import 'package:flutter/material.dart';

/// App Translations - All strings in supported languages
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _englishStrings,
    'hi': _hindiStrings,
    'ml': _malayalamStrings,
    'kn': _kannadaStrings,
    'ta': _tamilStrings,
    'bn': _bengaliStrings,
    'te': _teluguStrings,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Common getters
  String get appName => get('appName');
  String get tagline => get('tagline');
  String get welcomeBack => get('welcomeBack');
  String get signInContinue => get('signInContinue');
  String get email => get('email');
  String get password => get('password');
  String get signIn => get('signIn');
  String get forgotPassword => get('forgotPassword');
  String get newHere => get('newHere');
  String get createAccount => get('createAccount');
  String get dashboard => get('dashboard');
  String get home => get('home');
  String get requests => get('requests');
  String get active => get('active');
  String get earnings => get('earnings');
  String get profile => get('profile');
  String get online => get('online');
  String get offline => get('offline');
  String get youAreOnline => get('youAreOnline');
  String get youAreOffline => get('youAreOffline');
  String get todaysEarnings => get('todaysEarnings');
  String get viewDetails => get('viewDetails');
  String get weekly => get('weekly');
  String get monthly => get('monthly');
  String get pickups => get('pickups');
  String get rating => get('rating');
  String get hours => get('hours');
  String get quickActions => get('quickActions');
  String get history => get('history');
  String get activePickups => get('activePickups');
  String get noActivePickups => get('noActivePickups');
  String get stayOnline => get('stayOnline');
  String get appPermissions => get('appPermissions');
  String get permissionsDesc => get('permissionsDesc');
  String get locationAccess => get('locationAccess');
  String get locationDesc => get('locationDesc');
  String get pushNotifications => get('pushNotifications');
  String get notificationDesc => get('notificationDesc');
  String get allow => get('allow');
  String get continueText => get('continueText');
  String get skipForNow => get('skipForNow');
  String get chooseLanguage => get('chooseLanguage');
  String get selectLanguage => get('selectLanguage');
  String get becomeRider => get('becomeRider');
  String get phoneVerification => get('phoneVerification');
  String get enterPhone => get('enterPhone');
  String get phoneNumber => get('phoneNumber');
  String get sendOtp => get('sendOtp');
  String get verifyOtp => get('verifyOtp');
  String get resendOtp => get('resendOtp');
  String get personalDetails => get('personalDetails');
  String get tellAboutYou => get('tellAboutYou');
  String get fullName => get('fullName');
  String get emailAddress => get('emailAddress');
  String get address => get('address');
  String get city => get('city');
  String get workDetails => get('workDetails');
  String get workPreferences => get('workPreferences');
  String get vehicleType => get('vehicleType');
  String get twoWheeler => get('twoWheeler');
  String get threeWheeler => get('threeWheeler');
  String get truck => get('truck');
  String get experience => get('experience');
  String get hasLicense => get('hasLicense');
  String get agreeTerms => get('agreeTerms');
  String get submitApplication => get('submitApplication');
  String get applicationSubmitted => get('applicationSubmitted');
  String get thankYouRegistering => get('thankYouRegistering');
  String get applicationStatus => get('applicationStatus');
  String get pendingReview => get('pendingReview');
  String get reviewTime => get('reviewTime');
  String get goToLogin => get('goToLogin');
  // Profile
  String get account => get('account');
  String get settings => get('settings');
  String get vehicleDetails => get('vehicleDetails');
  String get documents => get('documents');
  String get bankDetails => get('bankDetails');
  String get notifications => get('notifications');
  String get language => get('language');
  String get changeLanguage => get('changeLanguage');
  String get helpSupport => get('helpSupport');
  String get privacyPolicy => get('privacyPolicy');
  String get logout => get('logout');
  String get notAdded => get('notAdded');
  String get uploaded => get('uploaded');
  String get notUploaded => get('notUploaded');
  String get workingHours => get('workingHours');
  String get todaysHours => get('todaysHours');
  String get recentActivity => get('recentActivity');
  String get sessionTrackingComingSoon => get('sessionTrackingComingSoon');
  // Earnings
  String get withdraw => get('withdraw');
  String get withdrawFunds => get('withdrawFunds');
  String get enterWithdrawAmount => get('enterWithdrawAmount');
  String get amount => get('amount');
  String get noTransactions => get('noTransactions');
  String get recentTransactions => get('recentTransactions');
  String get pending => get('pending');
  String get received => get('received');
  String get today => get('today');
  String get invalidAmount => get('invalidAmount');
  String get withdrawRequested => get('withdrawRequested');
  String get withdrawFailed => get('withdrawFailed');
  // Pickups
  String get assignedToYou => get('assignedToYou');
  String get noAssignedPickups => get('noAssignedPickups');
  String get noAssignedSubtitle => get('noAssignedSubtitle');
  String get refresh => get('refresh');
  String get reject => get('reject');
  String get rejectPickup => get('rejectPickup');
  String get rejectPickupConfirm => get('rejectPickupConfirm');
  String get cancel => get('cancel');
  String get acceptPickup => get('acceptPickup');
  String get pickupAccepted => get('pickupAccepted');
  String get failedAccept => get('failedAccept');
  String get failedReject => get('failedReject');
  String get pickupReturnedAdmin => get('pickupReturnedAdmin');
  String get timeExpired => get('timeExpired');
  String get call => get('call');
  String get navigate => get('navigate');
  String get clearAll => get('clearAll');
  String get completed => get('completed');
  String get onTheWay => get('onTheWay');
  String get reached => get('reached');
  String get pickedUp => get('pickedUp');
  String get imOnTheWay => get('imOnTheWay');
  String get iveReached => get('iveReached');
  String get startPickup => get('startPickup');
  String get completePickup => get('completePickup');
  String get updateStatus => get('updateStatus');
  String get statusUpdated => get('statusUpdated');
  String get failedUpdateStatus => get('failedUpdateStatus');
  String get failedUploadProof => get('failedUploadProof');
  String get pickupHistory => get('pickupHistory');
  String get noHistoryYet => get('noHistoryYet');
  String get historySubtitle => get('historySubtitle');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ml', 'kn', 'ta', 'bn', 'te']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English
const Map<String, String> _englishStrings = {
  'appName': 'Emptyko',
  'tagline': 'Cleaner streets, greener planet',
  'welcomeBack': 'Welcome back',
  'signInContinue': 'Sign in to continue',
  'email': 'Email',
  'password': 'Password',
  'signIn': 'Sign In',
  'forgotPassword': 'Forgot password?',
  'newHere': 'New here?',
  'createAccount': 'Create an Account',
  'dashboard': 'Dashboard',
  'home': 'Home',
  'requests': 'Requests',
  'active': 'Active',
  'earnings': 'Earnings',
  'profile': 'Profile',
  'online': 'Online',
  'offline': 'Offline',
  'youAreOnline': 'You are online',
  'youAreOffline': 'You are offline',
  'todaysEarnings': "Today's Earnings",
  'viewDetails': 'View details',
  'weekly': 'Weekly',
  'monthly': 'Monthly',
  'pickups': 'Pickups',
  'rating': 'Rating',
  'hours': 'Hours',
  'quickActions': 'Quick Actions',
  'history': 'History',
  'activePickups': 'Active Pickups',
  'noActivePickups': 'No active pickups',
  'stayOnline': 'Stay online to receive new pickup requests',
  'appPermissions': 'App Permissions',
  'permissionsDesc':
      'We need a few permissions to provide you the best experience',
  'locationAccess': 'Location Access',
  'locationDesc':
      'Required to find nearby pickup requests and navigate to locations',
  'pushNotifications': 'Push Notifications',
  'notificationDesc':
      'Get notified about new pickup requests and important updates',
  'allow': 'Allow',
  'continueText': 'Continue',
  'skipForNow': 'Skip for now',
  'chooseLanguage': 'Choose Language',
  'selectLanguage': 'Select your preferred language for the app',
  'becomeRider': 'Become a Rider',
  'phoneVerification': 'Phone Verification',
  'enterPhone': 'Enter your phone number to get started',
  'phoneNumber': 'Phone Number',
  'sendOtp': 'Send OTP',
  'verifyOtp': 'Verify OTP',
  'resendOtp': 'Resend OTP',
  'personalDetails': 'Personal Details',
  'tellAboutYou': 'Tell us about yourself',
  'fullName': 'Full Name',
  'emailAddress': 'Email Address',
  'address': 'Address',
  'city': 'City',
  'workDetails': 'Work Details',
  'workPreferences': 'Tell us about your work preferences',
  'vehicleType': 'Vehicle Type',
  'twoWheeler': 'Two Wheeler',
  'threeWheeler': 'Three Wheeler',
  'truck': 'Truck',
  'experience': 'Years of Experience',
  'hasLicense': 'I have a valid driving license',
  'agreeTerms': 'I agree to the Terms & Conditions',
  'submitApplication': 'Submit Application',
  'applicationSubmitted': 'Application Submitted!',
  'thankYouRegistering':
      'Thank you for registering as a rider.\nYour application is under review.',
  'applicationStatus': 'Application Status',
  'pendingReview': 'Pending Review',
  'reviewTime':
      "We'll notify you once your application is approved. This usually takes 1-2 business days.",
  'goToLogin': 'Go to Login',
  'userTypeTitle': 'Welcome!',
  'userTypeSubtitle': 'Are you new here or already have an account?',
  'newUser': 'New User',
  'newUserDesc': 'Register as a waste collector and start earning',
  'existingUser': 'Existing User',
  'existingUserDesc': 'Sign in to your existing account',
  // Profile
  'account': 'Account',
  'settings': 'Settings',
  'vehicleDetails': 'Vehicle Details',
  'documents': 'Documents',
  'bankDetails': 'Bank Details',
  'notifications': 'Notifications',
  'language': 'Language',
  'changeLanguage': 'Change app language',
  'helpSupport': 'Help & Support',
  'privacyPolicy': 'Privacy Policy',
  'logout': 'Log Out',
  'notAdded': 'Not added',
  'uploaded': 'Uploaded',
  'notUploaded': 'Not uploaded',
  'workingHours': 'Working Hours',
  'todaysHours': "Today's Hours",
  'recentActivity': 'Recent Activity',
  'sessionTrackingComingSoon': 'Detailed Session Tracking\nComing Soon!',
  // Earnings
  'withdraw': 'Withdraw',
  'withdrawFunds': 'Withdraw Funds',
  'enterWithdrawAmount': 'Enter amount to withdraw',
  'amount': 'Amount',
  'noTransactions': 'No transactions yet',
  'recentTransactions': 'Recent Transactions',
  'pending': 'Pending',
  'received': 'Received',
  'today': 'Today',
  'invalidAmount': 'Please enter a valid amount',
  'withdrawRequested': 'Withdrawal request submitted!',
  'withdrawFailed': 'Failed to submit withdrawal',
  // Pickups
  'assignedToYou': 'Assigned to You',
  'noAssignedPickups': 'No Assigned Pickups',
  'refresh': 'Refresh',
  'reject': 'Reject',
  'rejectPickup': 'Reject Pickup?',
  'rejectPickupConfirm': 'The admin will need to assign this to another collector.',
  'cancel': 'Cancel',
  'acceptPickup': 'Accept Pickup',
  'pickupAccepted': 'Pickup accepted! Head to the location.',
  'failedAccept': 'Failed to accept pickup',
  'failedReject': 'Failed to reject pickup',
  'pickupReturnedAdmin': 'Pickup returned to admin',
  'timeExpired': 'Time expired — pickup returned to admin',
  'call': 'Call',
  'navigate': 'Navigate',
  'clearAll': 'Clear All',
  'completed': 'Completed',
  'onTheWay': 'On the Way',
  'reached': 'Reached',
  'pickedUp': 'Picked Up',
  'imOnTheWay': "I'm On the Way",
  'iveReached': "I've Reached",
  'startPickup': 'Start Pickup',
  'completePickup': 'Complete Pickup',
  'updateStatus': 'Update Status',
  'statusUpdated': 'Status Updated',
  'failedUpdateStatus': 'Failed to update status',
  'failedUploadProof': 'Failed to upload proof photo.',
  'pickupHistory': 'Pickup History',
  'noHistoryYet': 'No history yet',
  'historySubtitle': 'Your completed pickups will appear here',
};

// Hindi
const Map<String, String> _hindiStrings = {
  'appName': 'Emptyko',
  'tagline': 'स्वच्छ सड़कें, हरा ग्रह',
  'welcomeBack': 'वापसी पर स्वागत है',
  'signInContinue': 'जारी रखने के लिए साइन इन करें',
  'email': 'ईमेल',
  'password': 'पासवर्ड',
  'signIn': 'साइन इन करें',
  'forgotPassword': 'पासवर्ड भूल गए?',
  'newHere': 'नए हैं?',
  'createAccount': 'खाता बनाएं',
  'dashboard': 'डैशबोर्ड',
  'home': 'होम',
  'requests': 'अनुरोध',
  'active': 'सक्रिय',
  'earnings': 'कमाई',
  'profile': 'प्रोफ़ाइल',
  'online': 'ऑनलाइन',
  'offline': 'ऑफ़लाइन',
  'youAreOnline': 'आप ऑनलाइन हैं',
  'youAreOffline': 'आप ऑफ़लाइन हैं',
  'todaysEarnings': 'आज की कमाई',
  'viewDetails': 'विवरण देखें',
  'weekly': 'साप्ताहिक',
  'monthly': 'मासिक',
  'pickups': 'पिकअप',
  'rating': 'रेटिंग',
  'hours': 'घंटे',
  'quickActions': 'त्वरित कार्य',
  'history': 'इतिहास',
  'activePickups': 'सक्रिय पिकअप',
  'noActivePickups': 'कोई सक्रिय पिकअप नहीं',
  'stayOnline': 'नए पिकअप अनुरोध प्राप्त करने के लिए ऑनलाइन रहें',
  'appPermissions': 'ऐप अनुमतियाँ',
  'permissionsDesc': 'सर्वोत्तम अनुभव के लिए हमें कुछ अनुमतियाँ चाहिए',
  'locationAccess': 'लोकेशन एक्सेस',
  'locationDesc': 'नज़दीकी पिकअप खोजने के लिए आवश्यक',
  'pushNotifications': 'पुश नोटिफिकेशन',
  'notificationDesc': 'नए अनुरोधों की सूचना प्राप्त करें',
  'allow': 'अनुमति दें',
  'continueText': 'जारी रखें',
  'skipForNow': 'अभी छोड़ें',
  'chooseLanguage': 'भाषा चुनें',
  'selectLanguage': 'ऐप के लिए अपनी पसंदीदा भाषा चुनें',
  'becomeRider': 'राइडर बनें',
  'phoneVerification': 'फोन सत्यापन',
  'enterPhone': 'शुरू करने के लिए अपना फोन नंबर दर्ज करें',
  'phoneNumber': 'फोन नंबर',
  'sendOtp': 'OTP भेजें',
  'verifyOtp': 'OTP सत्यापित करें',
  'resendOtp': 'OTP पुनः भेजें',
  'personalDetails': 'व्यक्तिगत विवरण',
  'tellAboutYou': 'अपने बारे में बताएं',
  'fullName': 'पूरा नाम',
  'emailAddress': 'ईमेल पता',
  'address': 'पता',
  'city': 'शहर',
  'workDetails': 'कार्य विवरण',
  'workPreferences': 'अपनी कार्य प्राथमिकताएं बताएं',
  'vehicleType': 'वाहन प्रकार',
  'twoWheeler': 'दोपहिया',
  'threeWheeler': 'तिपहिया',
  'truck': 'ट्रक',
  'experience': 'अनुभव के वर्ष',
  'hasLicense': 'मेरे पास वैध ड्राइविंग लाइसेंस है',
  'agreeTerms': 'मैं नियम और शर्तों से सहमत हूं',
  'submitApplication': 'आवेदन जमा करें',
  'applicationSubmitted': 'आवेदन जमा हो गया!',
  'thankYouRegistering':
      'राइडर के रूप में पंजीकरण के लिए धन्यवाद।\nआपका आवेदन समीक्षाधीन है।',
  'applicationStatus': 'आवेदन स्थिति',
  'pendingReview': 'समीक्षा लंबित',
  'reviewTime':
      'आवेदन स्वीकृत होने पर हम आपको सूचित करेंगे। इसमें आमतौर पर 1-2 कार्य दिवस लगते हैं।',
  'goToLogin': 'लॉगिन पर जाएं',
  'userTypeTitle': 'स्वागत है!',
  'userTypeSubtitle': 'क्या आप नए हैं या पहले से खाता है?',
  'newUser': 'नया उपयोगकर्ता',
  'newUserDesc': 'कचरा संग्रहकर्ता के रूप में पंजीकरण करें और कमाई शुरू करें',
  'existingUser': 'मौजूदा उपयोगकर्ता',
  'existingUserDesc': 'अपने मौजूदा खाते में साइन इन करें',
  'account': 'खाता',
  'settings': 'सेटिंग्स',
  'vehicleDetails': 'वाहन विवरण',
  'documents': 'दस्तावेज़',
  'bankDetails': 'बैंक विवरण',
  'notifications': 'सूचनाएं',
  'language': 'भाषा',
  'changeLanguage': 'ऐप की भाषा बदलें',
  'helpSupport': 'सहायता और समर्थन',
  'privacyPolicy': 'गोपनीयता नीति',
  'logout': 'लॉग आउट',
  'notAdded': 'नहीं जोड़ा गया',
  'uploaded': 'अपलोड हो गया',
  'notUploaded': 'अपलोड नहीं हुआ',
  'workingHours': 'काम के घंटे',
  'todaysHours': 'आज के घंटे',
  'recentActivity': 'हाल की गतिविधि',
  'sessionTrackingComingSoon': 'विस्तृत सत्र ट्रैकिंग\nजल्द आ रहा है!',
};

// Malayalam
const Map<String, String> _malayalamStrings = {
  'appName': 'Emptyko',
  'tagline': 'വൃത്തിയുള്ള തെരുവുകൾ, പച്ച ഗ്രഹം',
  'welcomeBack': 'തിരികെ സ്വാഗതം',
  'signInContinue': 'തുടരാൻ സൈൻ ഇൻ ചെയ്യുക',
  'email': 'ഇമെയിൽ',
  'password': 'പാസ്‌വേഡ്',
  'signIn': 'സൈൻ ഇൻ',
  'forgotPassword': 'പാസ്‌വേഡ് മറന്നോ?',
  'newHere': 'പുതിയതാണോ?',
  'createAccount': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
  'dashboard': 'ഡാഷ്‌ബോർഡ്',
  'home': 'ഹോം',
  'requests': 'അഭ്യർത്ഥനകൾ',
  'active': 'സജീവം',
  'earnings': 'വരുമാനം',
  'profile': 'പ്രൊഫൈൽ',
  'online': 'ഓൺലൈൻ',
  'offline': 'ഓഫ്‌ലൈൻ',
  'youAreOnline': 'നിങ്ങൾ ഓൺലൈനാണ്',
  'youAreOffline': 'നിങ്ങൾ ഓഫ്‌ലൈനാണ്',
  'todaysEarnings': 'ഇന്നത്തെ വരുമാനം',
  'viewDetails': 'വിശദാംശങ്ങൾ കാണുക',
  'weekly': 'പ്രതിവാരം',
  'monthly': 'പ്രതിമാസം',
  'pickups': 'പിക്കപ്പുകൾ',
  'rating': 'റേറ്റിംഗ്',
  'hours': 'മണിക്കൂറുകൾ',
  'quickActions': 'ദ്രുത പ്രവർത്തനങ്ങൾ',
  'history': 'ചരിത്രം',
  'activePickups': 'സജീവ പിക്കപ്പുകൾ',
  'noActivePickups': 'സജീവ പിക്കപ്പുകൾ ഇല്ല',
  'stayOnline': 'പുതിയ അഭ്യർത്ഥനകൾ ലഭിക്കാൻ ഓൺലൈനായിരിക്കുക',
  'appPermissions': 'ആപ്പ് അനുമതികൾ',
  'permissionsDesc': 'മികച്ച അനുഭവത്തിന് ചില അനുമതികൾ ആവശ്യമാണ്',
  'locationAccess': 'ലൊക്കേഷൻ ആക്‌സസ്',
  'locationDesc': 'അടുത്തുള്ള പിക്കപ്പുകൾ കണ്ടെത്താൻ ആവശ്യമാണ്',
  'pushNotifications': 'പുഷ് നോട്ടിഫിക്കേഷനുകൾ',
  'notificationDesc': 'പുതിയ അഭ്യർത്ഥനകളെക്കുറിച്ച് അറിയിപ്പ് നേടുക',
  'allow': 'അനുവദിക്കുക',
  'continueText': 'തുടരുക',
  'skipForNow': 'ഇപ്പോൾ ഒഴിവാക്കുക',
  'chooseLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
  'selectLanguage': 'ആപ്പിനായി നിങ്ങളുടെ ഇഷ്ട ഭാഷ തിരഞ്ഞെടുക്കുക',
  'becomeRider': 'റൈഡർ ആകുക',
  'phoneVerification': 'ഫോൺ സ്ഥിരീകരണം',
  'enterPhone': 'ആരംഭിക്കാൻ നിങ്ങളുടെ ഫോൺ നമ്പർ നൽകുക',
  'phoneNumber': 'ഫോൺ നമ്പർ',
  'sendOtp': 'OTP അയയ്ക്കുക',
  'verifyOtp': 'OTP സ്ഥിരീകരിക്കുക',
  'resendOtp': 'OTP വീണ്ടും അയയ്ക്കുക',
  'personalDetails': 'വ്യക്തിഗത വിവരങ്ങൾ',
  'tellAboutYou': 'നിങ്ങളെക്കുറിച്ച് പറയുക',
  'fullName': 'മുഴുവൻ പേര്',
  'emailAddress': 'ഇമെയിൽ വിലാസം',
  'address': 'വിലാസം',
  'city': 'നഗരം',
  'workDetails': 'ജോലി വിവരങ്ങൾ',
  'workPreferences': 'നിങ്ങളുടെ ജോലി മുൻഗണനകൾ പറയുക',
  'vehicleType': 'വാഹന തരം',
  'twoWheeler': 'ഇരുചക്രവാഹനം',
  'threeWheeler': 'മുച്ചക്രവാഹനം',
  'truck': 'ട്രക്ക്',
  'experience': 'അനുഭവ വർഷങ്ങൾ',
  'hasLicense': 'എനിക്ക് സാധുവായ ഡ്രൈവിംഗ് ലൈസൻസ് ഉണ്ട്',
  'agreeTerms': 'ഞാൻ നിബന്ധനകൾ അംഗീകരിക്കുന്നു',
  'submitApplication': 'അപേക്ഷ സമർപ്പിക്കുക',
  'applicationSubmitted': 'അപേക്ഷ സമർപ്പിച്ചു!',
  'thankYouRegistering':
      'റൈഡറായി രജിസ്റ്റർ ചെയ്തതിന് നന്ദി।\nനിങ്ങളുടെ അപേക്ഷ പരിശോധനയിലാണ്।',
  'applicationStatus': 'അപേക്ഷ നില',
  'pendingReview': 'പരിശോധന തീർപ്പിലാണ്',
  'reviewTime':
      'അപേക്ഷ അംഗീകരിക്കുമ്പോൾ ഞങ്ങൾ നിങ്ങളെ അറിയിക്കും। ഇത് സാധാരണയായി 1-2 പ്രവൃത്തി ദിവസം എടുക്കും।',
  'goToLogin': 'ലോഗിനിലേക്ക് പോകുക',
  'userTypeTitle': 'സ്വാഗതം!',
  'userTypeSubtitle': 'നിങ്ങൾ പുതിയതാണോ അതോ ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ?',
  'newUser': 'പുതിയ ഉപയോക്താവ്',
  'newUserDesc': 'മാലിന്യ ശേഖരണക്കാരനായി രജിസ്റ്റർ ചെയ്ത് സമ്പാദിക്കാൻ തുടങ്ങൂ',
  'existingUser': 'നിലവിലുള്ള ഉപയോക്താവ്',
  'existingUserDesc': 'നിലവിലുള്ള അക്കൗണ്ടിൽ സൈൻ ഇൻ ചെയ്യുക',
  'account': 'അക്കൗണ്ട്',
  'settings': 'ക്രമീകരണങ്ങൾ',
  'vehicleDetails': 'വാഹന വിശദാംശങ്ങൾ',
  'documents': 'രേഖകൾ',
  'bankDetails': 'ബാങ്ക് വിശദാംശങ്ങൾ',
  'notifications': 'അറിയിപ്പുകൾ',
  'language': 'ഭാഷ',
  'changeLanguage': 'ആപ്പ് ഭാഷ മാറ്റുക',
  'helpSupport': 'സഹായം & പിന്തുണ',
  'privacyPolicy': 'സ്വകാര്യതാ നയം',
  'logout': 'ലോഗ് ഔട്ട്',
  'notAdded': 'ചേർത്തിട്ടില്ല',
  'uploaded': 'അപ്‌ലോഡ് ചെയ്‌തു',
  'notUploaded': 'അപ്‌ലോഡ് ചെയ്‌തിട്ടില്ല',
  'workingHours': 'ജോലി സമയം',
  'todaysHours': 'ഇന്നത്തെ മണിക്കൂറുകൾ',
  'recentActivity': 'സമീപകാല പ്രവർത്തനം',
  'sessionTrackingComingSoon': 'വിശദമായ സെഷൻ ട്രാക്കിംഗ്\nഉടൻ വരുന്നു!',
};

// Kannada
const Map<String, String> _kannadaStrings = {
  'appName': 'Emptyko',
  'tagline': 'ಸ್ವಚ್ಛ ಬೀದಿಗಳು, ಹಸಿರು ಗ್ರಹ',
  'welcomeBack': 'ಮರಳಿ ಸ್ವಾಗತ',
  'signInContinue': 'ಮುಂದುವರಿಸಲು ಸೈನ್ ಇನ್ ಮಾಡಿ',
  'email': 'ಇಮೇಲ್',
  'password': 'ಪಾಸ್‌ವರ್ಡ್',
  'signIn': 'ಸೈನ್ ಇನ್',
  'forgotPassword': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?',
  'newHere': 'ಹೊಸಬರೇ?',
  'createAccount': 'ಖಾತೆ ರಚಿಸಿ',
  'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
  'home': 'ಮುಖಪುಟ',
  'requests': 'ವಿನಂತಿಗಳು',
  'active': 'ಸಕ್ರಿಯ',
  'earnings': 'ಗಳಿಕೆ',
  'profile': 'ಪ್ರೊಫೈಲ್',
  'online': 'ಆನ್‌ಲೈನ್',
  'offline': 'ಆಫ್‌ಲೈನ್',
  'youAreOnline': 'ನೀವು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ',
  'youAreOffline': 'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ',
  'todaysEarnings': 'ಇಂದಿನ ಗಳಿಕೆ',
  'viewDetails': 'ವಿವರಗಳನ್ನು ನೋಡಿ',
  'weekly': 'ವಾರದ',
  'monthly': 'ಮಾಸಿಕ',
  'pickups': 'ಪಿಕಪ್‌ಗಳು',
  'rating': 'ರೇಟಿಂಗ್',
  'hours': 'ಗಂಟೆಗಳು',
  'quickActions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
  'history': 'ಇತಿಹಾಸ',
  'activePickups': 'ಸಕ್ರಿಯ ಪಿಕಪ್‌ಗಳು',
  'noActivePickups': 'ಸಕ್ರಿಯ ಪಿಕಪ್‌ಗಳಿಲ್ಲ',
  'stayOnline': 'ಹೊಸ ವಿನಂತಿಗಳನ್ನು ಪಡೆಯಲು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿರಿ',
  'appPermissions': 'ಅಪ್ಲಿಕೇಶನ್ ಅನುಮತಿಗಳು',
  'permissionsDesc': 'ಉತ್ತಮ ಅನುಭವಕ್ಕಾಗಿ ಕೆಲವು ಅನುಮತಿಗಳು ಬೇಕು',
  'locationAccess': 'ಸ್ಥಳ ಪ್ರವೇಶ',
  'locationDesc': 'ಹತ್ತಿರದ ಪಿಕಪ್‌ಗಳನ್ನು ಹುಡುಕಲು',
  'pushNotifications': 'ಪುಶ್ ಅಧಿಸೂಚನೆಗಳು',
  'notificationDesc': 'ಹೊಸ ವಿನಂತಿಗಳ ಅಧಿಸೂಚನೆ ಪಡೆಯಿರಿ',
  'allow': 'ಅನುಮತಿಸಿ',
  'continueText': 'ಮುಂದುವರಿಸಿ',
  'skipForNow': 'ಈಗ ಬಿಟ್ಟುಬಿಡಿ',
  'chooseLanguage': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
  'selectLanguage': 'ಅಪ್ಲಿಕೇಶನ್‌ಗಾಗಿ ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
  'becomeRider': 'ರೈಡರ್ ಆಗಿ',
  'phoneVerification': 'ಫೋನ್ ಪರಿಶೀಲನೆ',
  'enterPhone': 'ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಫೋನ್ ನಂಬರ್ ನಮೂದಿಸಿ',
  'phoneNumber': 'ಫೋನ್ ನಂಬರ್',
  'sendOtp': 'OTP ಕಳುಹಿಸಿ',
  'verifyOtp': 'OTP ಪರಿಶೀಲಿಸಿ',
  'resendOtp': 'OTP ಮರುಕಳುಹಿಸಿ',
  'personalDetails': 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು',
  'tellAboutYou': 'ನಿಮ್ಮ ಬಗ್ಗೆ ಹೇಳಿ',
  'fullName': 'ಪೂರ್ಣ ಹೆಸರು',
  'emailAddress': 'ಇಮೇಲ್ ವಿಳಾಸ',
  'address': 'ವಿಳಾಸ',
  'city': 'ನಗರ',
  'workDetails': 'ಕೆಲಸದ ವಿವರಗಳು',
  'workPreferences': 'ನಿಮ್ಮ ಕೆಲಸದ ಆದ್ಯತೆಗಳನ್ನು ಹೇಳಿ',
  'vehicleType': 'ವಾಹನ ಪ್ರಕಾರ',
  'twoWheeler': 'ದ್ವಿಚಕ್ರ',
  'threeWheeler': 'ಮೂರು ಚಕ್ರ',
  'truck': 'ಟ್ರಕ್',
  'experience': 'ಅನುಭವದ ವರ್ಷಗಳು',
  'hasLicense': 'ನನಗೆ ಮಾನ್ಯ ಚಾಲನಾ ಪರವಾನಗಿ ಇದೆ',
  'agreeTerms': 'ನಿಯಮಗಳನ್ನು ಒಪ್ಪುತ್ತೇನೆ',
  'submitApplication': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಿ',
  'applicationSubmitted': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲಾಗಿದೆ!',
  'thankYouRegistering':
      'ರೈಡರ್ ಆಗಿ ನೋಂದಾಯಿಸಿದ್ದಕ್ಕೆ ಧನ್ಯವಾದಗಳು।\nನಿಮ್ಮ ಅರ್ಜಿ ಪರಿಶೀಲನೆಯಲ್ಲಿದೆ।',
  'applicationStatus': 'ಅರ್ಜಿ ಸ್ಥಿತಿ',
  'pendingReview': 'ಪರಿಶೀಲನೆ ಬಾಕಿ',
  'reviewTime':
      'ಅರ್ಜಿ ಅನುಮೋದಿಸಿದಾಗ ನಾವು ನಿಮಗೆ ತಿಳಿಸುತ್ತೇವೆ। ಇದು ಸಾಮಾನ್ಯವಾಗಿ 1-2 ಕೆಲಸದ ದಿನಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳುತ್ತದೆ।',
  'goToLogin': 'ಲಾಗಿನ್‌ಗೆ ಹೋಗಿ',
  'userTypeTitle': 'ಸ್ವಾಗತ!',
  'userTypeSubtitle': 'ನೀವು ಹೊಸಬರೇ ಅಥವಾ ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ?',
  'newUser': 'ಹೊಸ ಬಳಕೆದಾರ',
  'newUserDesc': 'ತ್ಯಾಜ್ಯ ಸಂಗ್ರಾಹಕರಾಗಿ ನೋಂದಾಯಿಸಿ ಮತ್ತು ಗಳಿಸಲು ಪ್ರಾರಂಭಿಸಿ',
  'existingUser': 'ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ಬಳಕೆದಾರ',
  'existingUserDesc': 'ನಿಮ್ಮ ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ಖಾತೆಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
  'account': 'ಖಾತೆ',
  'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
  'vehicleDetails': 'ವಾಹನ ವಿವರಗಳು',
  'documents': 'ದಾಖಲೆಗಳು',
  'bankDetails': 'ಬ್ಯಾಂಕ್ ವಿವರಗಳು',
  'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
  'language': 'ಭಾಷೆ',
  'changeLanguage': 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ ಬದಲಾಯಿಸಿ',
  'helpSupport': 'ಸಹಾಯ & ಬೆಂಬಲ',
  'privacyPolicy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
  'logout': 'ಲಾಗ್ ಔಟ್',
  'notAdded': 'ಸೇರಿಸಿಲ್ಲ',
  'uploaded': 'ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ',
  'notUploaded': 'ಅಪ್‌ಲೋಡ್ ಆಗಿಲ್ಲ',
  'workingHours': 'ಕೆಲಸದ ಗಂಟೆಗಳು',
  'todaysHours': 'ಇಂದಿನ ಗಂಟೆಗಳು',
  'recentActivity': 'ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ',
  'sessionTrackingComingSoon': 'ವಿವರವಾದ ಸೆಶನ್ ಟ್ರ್ಯಾಕಿಂಗ್\nಶೀಘ್ರದಲ್ಲೇ!',

  'withdraw': 'ಹಿಂಪಡೆಯಿರಿ',
  'withdrawFunds': 'ಹಗರು ಹಿಂಪಡೆಯಿರಿ',
  'enterWithdrawAmount': 'ಹಿಂಪಡೆಯಲು ಮೊತ್ತ ನಮೂದಿಸಿ',
  'amount': 'ಮೊತ್ತ',
  'noTransactions': 'ಇನ್ನೂ ವ್ಯವಹಾರಗಳಿಲ್ಲ',
  'recentTransactions': 'ಇತ್ತೀಚಿನ ವ್ಯವಹಾರಗಳು',
  'pending': 'ಬಾಕಿ',
  'received': 'ಸ್ವೀಕರಿಸಲಾಗಿದೆ',
  'today': 'ಇಂದು',
  'invalidAmount': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಮೊತ್ತ ನಮೂದಿಸಿ',
  'withdrawRequested': 'ಹಿಂಪಡೆಯುವ ವಿನಂತಿ ಸಲ್ಲಿಸಲಾಗಿದೆ!',
  'withdrawFailed': 'ಹಿಂಪಡೆಯುವಿಕೆ ಸಲ್ಲಿಸಲು ವಿಫಲ',
  'assignedToYou': 'ನಿಮಗೆ ನಿಯೋಜಿಸಲಾಗಿದೆ',
  'noAssignedPickups': 'ನಿಯೋಜಿಸಿದ ಪಿಕ್ಅಪ್ಗಳಿಲ್ಲ',
  'noAssignedSubtitle': 'ಅಡ್ಮಿನ್ ನಿಮಗೆ ಪಿಕ್ಅಪ್ ನಿಯೋಜಿಸಿದಾಗ ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತದೆ.',
  'refresh': 'ರಿಫ್ರೆಶ್',
  'reject': 'ತಿರಸ್ಕರಿಸಿ',
  'rejectPickup': 'ಪಿಕ್ಅಪ್ ತಿರಸ್ಕರಿಸಬೇಕೇ?',
  'rejectPickupConfirm': 'ಅಡ್ಮಿನ್ ಇದನ್ನು ಮತ್ತೊಬ್ಬ ಸಂಗ್ರಾಹಕರಿಗೆ ನಿಯೋಜಿಸಬೇಕಾಗುತ್ತದೆ.',
  'cancel': 'ರದ್ದುಮಾಡಿ',
  'acceptPickup': 'ಪಿಕ್ಅಪ್ ಸ್ವೀಕರಿಸಿ',
  'pickupAccepted': 'ಪಿಕ್ಅಪ್ ಸ್ವೀಕರಿಸಲಾಗಿದೆ! ಸ್ಥಳಕ್ಕೆ ಹೋಗಿ.',
  'failedAccept': 'ಪಿಕ್ಅಪ್ ಸ್ವೀಕರಿಸಲು ವಿಫಲ',
  'failedReject': 'ಪಿಕ್ಅಪ್ ತಿರಸ್ಕರಿಸಲು ವಿಫಲ',
  'pickupReturnedAdmin': 'ಪಿಕ್ಅಪ್ ಅಡ್ಮಿನ್‌ಗೆ ಹಿಂತಿರುಗಿಸಲಾಗಿದೆ',
  'timeExpired': 'ಸಮಯ ಮೀರಿತು — ಪಿಕ್ಅಪ್ ಅಡ್ಮಿನ್‌ಗೆ ಹಿಂತಿರಿದೆ',
  'call': 'ಕರೆ',
  'navigate': 'ನ್ಯಾವಿಗೇಟ್',
  'clearAll': 'ೆಲ್ಫ್ ತೆರವುಮಾಡಿ',
  'completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
  'onTheWay': 'ದಾರಿಯಲ್ಲಿ',
  'reached': 'ತಲುಪಿದ್ದೇನೆ',
  'pickedUp': 'ತೆಗೆದುಕೊಂಡಿದೇನೆ',
  'imOnTheWay': 'ನಾನು ದಾರಿಯಲ್ಲಿದ್ದೇನೆ',
  'iveReached': 'ನಾನು ತಲುಪಿದ್ದೇನೆ',
  'startPickup': 'ಪಿಕ್ಅಪ್ ಪ್ರಾರಂಭಿಸಿ',
  'completePickup': 'ಪಿಕ್ಅಪ್ ಪೂರ್ಣಗೊಳಿಸಿ',
  'updateStatus': 'ಸ್ಥಿತಿ ನವೀಕರಿಸಿ',
  'statusUpdated': 'ಸ್ಥಿತಿ ನವೀಕರಿಸಲಾಗಿದೆ',
  'failedUpdateStatus': 'ಸ್ಥಿತಿ ನವೀಕರಿಸಲು ವಿಫಲ',
  'failedUploadProof': 'ಪುರಾವೆ ಫೋಟೋ ಅಪ್ಲೋಡ್ ಮಾಡಲು ವಿಫಲ.',
  'pickupHistory': 'ಪಿಕ್ಅಪ್ ಇತಿಹಾಸ',
  'noHistoryYet': 'ಇನ್ನೂ ಇತಿಹಾಸ ಇಲ್ಲ',
  'historySubtitle': 'ನಿಮ್ಮ ಪೂರ್ಣಗೊಂಡ ಪಿಕ್ಅಪ್ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ',
};

// Tamil
const Map<String, String> _tamilStrings = {
  'appName': 'Emptyko',
  'tagline': 'சுத்தமான தெருக்கள், பசுமையான கிரகம்',
  'welcomeBack': 'மீண்டும் வரவேற்கிறோம்',
  'signInContinue': 'தொடர உள்நுழையவும்',
  'email': 'மின்னஞ்சல்',
  'password': 'கடவுச்சொல்',
  'signIn': 'உள்நுழைக',
  'forgotPassword': 'கடவுச்சொல் மறந்துவிட்டதா?',
  'newHere': 'புதியவரா?',
  'createAccount': 'கணக்கை உருவாக்கு',
  'dashboard': 'டாஷ்போர்டு',
  'home': 'முகப்பு',
  'requests': 'கோரிக்கைகள்',
  'active': 'செயலில்',
  'earnings': 'வருவாய்',
  'profile': 'சுயவிவரம்',
  'online': 'ஆன்லைன்',
  'offline': 'ஆஃப்லைன்',
  'youAreOnline': 'நீங்கள் ஆன்லைனில் உள்ளீர்கள்',
  'youAreOffline': 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள்',
  'todaysEarnings': 'இன்றைய வருவாய்',
  'viewDetails': 'விவரங்களைக் காண்க',
  'weekly': 'வாராந்திர',
  'monthly': 'மாதாந்திர',
  'pickups': 'பிக்அப்கள்',
  'rating': 'மதிப்பீடு',
  'hours': 'மணி நேரம்',
  'quickActions': 'விரைவு செயல்கள்',
  'history': 'வரலாறு',
  'activePickups': 'செயலில் உள்ள பிக்அப்கள்',
  'noActivePickups': 'செயலில் உள்ள பிக்அப்கள் இல்லை',
  'stayOnline': 'புதிய கோரிக்கைகளைப் பெற ஆன்லைனில் இருங்கள்',
  'appPermissions': 'ஆப் அனுமதிகள்',
  'permissionsDesc': 'சிறந்த அனுபவத்திற்கு சில அனுமதிகள் தேவை',
  'locationAccess': 'இருப்பிட அணுகல்',
  'locationDesc': 'அருகிலுள்ள பிக்அப்களைக் கண்டறிய',
  'pushNotifications': 'புஷ் அறிவிப்புகள்',
  'notificationDesc': 'புதிய கோரிக்கைகள் பற்றிய அறிவிப்பைப் பெறுங்கள்',
  'allow': 'அனுமதி',
  'continueText': 'தொடரவும்',
  'skipForNow': 'இப்போது தவிர்க்கவும்',
  'chooseLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
  'selectLanguage': 'ஆப்பிற்கான உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
  'becomeRider': 'ரைடராக ஆகுங்கள்',
  'phoneVerification': 'தொலைபேசி சரிபார்ப்பு',
  'enterPhone': 'தொடங்க உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்',
  'phoneNumber': 'தொலைபேசி எண்',
  'sendOtp': 'OTP அனுப்பு',
  'verifyOtp': 'OTP சரிபார்',
  'resendOtp': 'OTP மீண்டும் அனுப்பு',
  'personalDetails': 'தனிப்பட்ட விவரங்கள்',
  'tellAboutYou': 'உங்களைப் பற்றி சொல்லுங்கள்',
  'fullName': 'முழு பெயர்',
  'emailAddress': 'மின்னஞ்சல் முகவரி',
  'address': 'முகவரி',
  'city': 'நகரம்',
  'workDetails': 'பணி விவரங்கள்',
  'workPreferences': 'உங்கள் பணி விருப்பங்களைச் சொல்லுங்கள்',
  'vehicleType': 'வாகன வகை',
  'twoWheeler': 'இருசக்கர வாகனம்',
  'threeWheeler': 'மூன்று சக்கர வாகனம்',
  'truck': 'டிரக்',
  'experience': 'அனுபவ ஆண்டுகள்',
  'hasLicense': 'என்னிடம் செல்லுபடியான ஓட்டுநர் உரிமம் உள்ளது',
  'agreeTerms': 'விதிமுறைகளை ஏற்கிறேன்',
  'submitApplication': 'விண்ணப்பத்தை சமர்ப்பிக்கவும்',
  'applicationSubmitted': 'விண்ணப்பம் சமர்ப்பிக்கப்பட்டது!',
  'thankYouRegistering':
      'ரைடராக பதிவு செய்ததற்கு நன்றி।\nஉங்கள் விண்ணப்பம் ஆய்வில் உள்ளது।',
  'applicationStatus': 'விண்ணப்ப நிலை',
  'pendingReview': 'ஆய்வு நிலுவையில்',
  'reviewTime':
      'விண்ணப்பம் அங்கீகரிக்கப்படும்போது நாங்கள் உங்களுக்குத் தெரிவிப்போம்। இது பொதுவாக 1-2 வணிக நாட்கள் ஆகும்।',
  'goToLogin': 'உள்நுழைவுக்குச் செல்லவும்',
  'userTypeTitle': 'வரவேற்கிறோம்!',
  'userTypeSubtitle': 'நீங்கள் புதியவரா அல்லது ஏற்கனவே கணக்கு உள்ளதா?',
  'newUser': 'புதிய பயனர்',
  'newUserDesc': 'கழிவு சேகரிப்பாளராக பதிவு செய்து சம்பாதிக்கத் தொடங்குங்கள்',
  'existingUser': 'ஏற்கனவே உள்ள பயனர்',
  'existingUserDesc': 'உங்கள் ஏற்கனவே உள்ள கணக்கில் உள்நுழையுங்கள்',
  'account': 'கணக்கு',
  'settings': 'அமைப்புகள்',
  'vehicleDetails': 'வாகன விவரங்கள்',
  'documents': 'ஆவணங்கள்',
  'bankDetails': 'வங்கி விவரங்கள்',
  'notifications': 'அறிவிப்புகள்',
  'language': 'மொழி',
  'changeLanguage': 'ஆப் மொழியை மாற்றவும்',
  'helpSupport': 'உதவி & ஆதரவு',
  'privacyPolicy': 'தனியுரிமை கொள்கை',
  'logout': 'வெளியேறு',
  'notAdded': 'சேர்க்கப்படவில்லை',
  'uploaded': 'பதிவேற்றப்பட்டது',
  'notUploaded': 'பதிவேற்றப்படவில்லை',
  'workingHours': 'பணி நேரம்',
  'todaysHours': 'இன்றைய மணி நேரம்',
  'recentActivity': 'சமீபத்திய செயல்பாடு',
  'sessionTrackingComingSoon': 'விரிவான அமர்வு கண்காணிப்பு\nவிரைவில் வருகிறது!',
};

// Bengali
const Map<String, String> _bengaliStrings = {
  'appName': 'Emptyko',
  'tagline': 'পরিষ্কার রাস্তা, সবুজ গ্রহ',
  'welcomeBack': 'স্বাগতম',
  'signInContinue': 'চালিয়ে যেতে সাইন ইন করুন',
  'email': 'ইমেল',
  'password': 'পাসওয়ার্ড',
  'signIn': 'সাইন ইন',
  'forgotPassword': 'পাসওয়ার্ড ভুলে গেছেন?',
  'newHere': 'নতুন?',
  'createAccount': 'অ্যাকাউন্ট তৈরি করুন',
  'dashboard': 'ড্যাশবোর্ড',
  'home': 'হোম',
  'requests': 'অনুরোধ',
  'active': 'সক্রিয়',
  'earnings': 'উপার্জন',
  'profile': 'প্রোফাইল',
  'online': 'অনলাইন',
  'offline': 'অফলাইন',
  'youAreOnline': 'আপনি অনলাইনে আছেন',
  'youAreOffline': 'আপনি অফলাইনে আছেন',
  'todaysEarnings': 'আজকের উপার্জন',
  'viewDetails': 'বিস্তারিত দেখুন',
  'weekly': 'সাপ্তাহিক',
  'monthly': 'মাসিক',
  'pickups': 'পিকআপ',
  'rating': 'রেটিং',
  'hours': 'ঘন্টা',
  'quickActions': 'দ্রুত কর্ম',
  'history': 'ইতিহাস',
  'activePickups': 'সক্রিয় পিকআপ',
  'noActivePickups': 'কোন সক্রিয় পিকআপ নেই',
  'stayOnline': 'নতুন অনুরোধ পেতে অনলাইনে থাকুন',
  'appPermissions': 'অ্যাপ অনুমতি',
  'permissionsDesc': 'সেরা অভিজ্ঞতার জন্য কয়েকটি অনুমতি প্রয়োজন',
  'locationAccess': 'লোকেশন অ্যাক্সেস',
  'locationDesc': 'কাছাকাছি পিকআপ খুঁজতে',
  'pushNotifications': 'পুশ নোটিফিকেশন',
  'notificationDesc': 'নতুন অনুরোধের বিজ্ঞপ্তি পান',
  'allow': 'অনুমতি দিন',
  'continueText': 'চালিয়ে যান',
  'skipForNow': 'এখন এড়িয়ে যান',
  'chooseLanguage': 'ভাষা বেছে নিন',
  'selectLanguage': 'অ্যাপের জন্য আপনার পছন্দের ভাষা নির্বাচন করুন',
  'becomeRider': 'রাইডার হন',
  'phoneVerification': 'ফোন যাচাই',
  'enterPhone': 'শুরু করতে আপনার ফোন নম্বর লিখুন',
  'phoneNumber': 'ফোন নম্বর',
  'sendOtp': 'OTP পাঠান',
  'verifyOtp': 'OTP যাচাই করুন',
  'resendOtp': 'OTP পুনরায় পাঠান',
  'personalDetails': 'ব্যক্তিগত বিবরণ',
  'tellAboutYou': 'আপনার সম্পর্কে বলুন',
  'fullName': 'পুরো নাম',
  'emailAddress': 'ইমেল ঠিকানা',
  'address': 'ঠিকানা',
  'city': 'শহর',
  'workDetails': 'কাজের বিবরণ',
  'workPreferences': 'আপনার কাজের পছন্দ বলুন',
  'vehicleType': 'গাড়ির ধরন',
  'twoWheeler': 'দুই চাকার',
  'threeWheeler': 'তিন চাকার',
  'truck': 'ট্রাক',
  'experience': 'অভিজ্ঞতার বছর',
  'hasLicense': 'আমার বৈধ ড্রাইভিং লাইসেন্স আছে',
  'agreeTerms': 'আমি শর্তাবলীতে সম্মত',
  'submitApplication': 'আবেদন জমা দিন',
  'applicationSubmitted': 'আবেদন জমা হয়েছে!',
  'thankYouRegistering':
      'রাইডার হিসেবে নিবন্ধনের জন্য ধন্যবাদ।\nআপনার আবেদন পর্যালোচনাধীন।',
  'applicationStatus': 'আবেদনের অবস্থা',
  'pendingReview': 'পর্যালোচনা মুলতুবি',
  'reviewTime':
      'আবেদন অনুমোদিত হলে আমরা আপনাকে জানাব। এটি সাধারণত 1-2 কার্যদিবস সময় নেয়।',
  'goToLogin': 'লগইনে যান',
  'userTypeTitle': 'স্বাগতম!',
  'userTypeSubtitle': 'আপনি কি নতুন নাকি ইতিমধ্যে অ্যাকাউন্ট আছে?',
  'newUser': 'নতুন ব্যবহারকারী',
  'newUserDesc': 'বর্জ্য সংগ্রাহক হিসেবে নিবন্ধন করুন এবং আয় শুরু করুন',
  'existingUser': 'বিদ্যমান ব্যবহারকারী',
  'existingUserDesc': 'আপনার বিদ্যমান অ্যাকাউন্টে সাইন ইন করুন',
  'account': 'অ্যাকাউন্ট',
  'settings': 'সেটিংস',
  'vehicleDetails': 'যানবাহন বিবরণ',
  'documents': 'নথিপত্র',
  'bankDetails': 'ব্যাংক বিবরণ',
  'notifications': 'বিজ্ঞপ্তি',
  'language': 'ভাষা',
  'changeLanguage': 'অ্যাপের ভাষা পরিবর্তন করুন',
  'helpSupport': 'সাহায্য ও সহায়তা',
  'privacyPolicy': 'গোপনীয়তা নীতি',
  'logout': 'লগ আউট',
  'notAdded': 'যোগ করা হয়নি',
  'uploaded': 'আপলোড হয়েছে',
  'notUploaded': 'আপলোড হয়নি',
  'workingHours': 'কাজের সময়',
  'todaysHours': 'আজকের ঘন্টা',
  'recentActivity': 'সাম্প্রতিক কার্যকলাপ',
  'sessionTrackingComingSoon': 'বিস্তারিত সেশন ট্র্যাকিং\nশীঘ্রই আসছে!',
};

// Telugu
const Map<String, String> _teluguStrings = {
  'appName': 'Emptyko',
  'tagline': 'శుభ్రమైన వీధులు, పచ్చని గ్రహం',
  'welcomeBack': 'తిరిగి స్వాగతం',
  'signInContinue': 'కొనసాగించడానికి సైన్ ఇన్ చేయండి',
  'email': 'ఇమెయిల్',
  'password': 'పాస్‌వర్డ్',
  'signIn': 'సైన్ ఇన్',
  'forgotPassword': 'పాస్‌వర్డ్ మర్చిపోయారా?',
  'newHere': 'కొత్తగా వచ్చారా?',
  'createAccount': 'ఖాతా సృష్టించండి',
  'dashboard': 'డాష్‌బోర్డ్',
  'home': 'హోమ్',
  'requests': 'అభ్యర్థనలు',
  'active': 'యాక్టివ్',
  'earnings': 'సంపాదన',
  'profile': 'ప్రొఫైల్',
  'online': 'ఆన్‌లైన్',
  'offline': 'ఆఫ్‌లైన్',
  'youAreOnline': 'మీరు ఆన్‌లైన్‌లో ఉన్నారు',
  'youAreOffline': 'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు',
  'todaysEarnings': 'ఈ రోజు సంపాదన',
  'viewDetails': 'వివరాలు చూడండి',
  'weekly': 'వారపు',
  'monthly': 'నెలవారీ',
  'pickups': 'పికప్‌లు',
  'rating': 'రేటింగ్',
  'hours': 'గంటలు',
  'quickActions': 'త్వరిత చర్యలు',
  'history': 'చరిత్ర',
  'activePickups': 'యాక్టివ్ పికప్‌లు',
  'noActivePickups': 'యాక్టివ్ పికప్‌లు లేవు',
  'stayOnline': 'కొత్త అభ్యర్థనలు పొందడానికి ఆన్‌లైన్‌లో ఉండండి',
  'appPermissions': 'యాప్ అనుమతులు',
  'permissionsDesc': 'మెరుగైన అనుభవానికి కొన్ని అనుమతులు అవసరం',
  'locationAccess': 'లొకేషన్ యాక్సెస్',
  'locationDesc': 'సమీపంలోని పికప్‌లను కనుగొనడానికి',
  'pushNotifications': 'పుష్ నోటిఫికేషన్లు',
  'notificationDesc': 'కొత్త అభ్యర్థనల నోటిఫికేషన్ పొందండి',
  'allow': 'అనుమతించండి',
  'continueText': 'కొనసాగించండి',
  'skipForNow': 'ప్రస్తుతం వదిలేయండి',
  'chooseLanguage': 'భాష ఎంచుకోండి',
  'selectLanguage': 'యాప్ కోసం మీ ఇష్టమైన భాషను ఎంచుకోండి',
  'becomeRider': 'రైడర్ అవండి',
  'phoneVerification': 'ఫోన్ ధృవీకరణ',
  'enterPhone': 'ప్రారంభించడానికి మీ ఫోన్ నంబర్ ఇవ్వండి',
  'phoneNumber': 'ఫోన్ నంబర్',
  'sendOtp': 'OTP పంపండి',
  'verifyOtp': 'OTP ధృవీకరించండి',
  'resendOtp': 'OTP మళ్ళీ పంపండి',
  'personalDetails': 'వ్యక్తిగత వివరాలు',
  'tellAboutYou': 'మీ గురించి చెప్పండి',
  'fullName': 'పూర్తి పేరు',
  'emailAddress': 'ఇమెయిల్ చిరునామా',
  'address': 'చిరునామా',
  'city': 'నగరం',
  'workDetails': 'పని వివరాలు',
  'workPreferences': 'మీ పని ప్రాధాన్యతలు చెప్పండి',
  'vehicleType': 'వాహన రకం',
  'twoWheeler': 'టూ వీలర్',
  'threeWheeler': 'త్రీ వీలర్',
  'truck': 'ట్రక్',
  'experience': 'అనుభవ సంవత్సరాలు',
  'hasLicense': 'నాకు చెల్లుబాటు అయ్యే డ్రైవింగ్ లైసెన్స్ ఉంది',
  'agreeTerms': 'నేను నిబంధనలకు అంగీకరిస్తున్నాను',
  'submitApplication': 'దరఖాస్తు సమర్పించండి',
  'applicationSubmitted': 'దరఖాస్తు సమర్పించబడింది!',
  'thankYouRegistering':
      'రైడర్‌గా నమోదు చేసుకున్నందుకు ధన్యవాదాలు।\nమీ దరఖాస్తు సమీక్షలో ఉంది।',
  'applicationStatus': 'దరఖాస్తు స్థితి',
  'pendingReview': 'సమీక్ష పెండింగ్',
  'reviewTime':
      'దరఖాస్తు ఆమోదించినప్పుడు మేము మీకు తెలియజేస్తాము। ఇది సాధారణంగా 1-2 వ్యాపార దినాలు పడుతుంది।',
  'goToLogin': 'లాగిన్‌కి వెళ్ళండి',
  'userTypeTitle': 'స్వాగతం!',
  'userTypeSubtitle': 'మీరు కొత్తగా వచ్చారా లేదా ఇప్పటికే ఖాతా ఉందా?',
  'newUser': 'కొత్త వినియోగదారు',
  'newUserDesc': 'వ్యర్థ సేకరణదారుగా నమోదు చేసుకొని సంపాదించడం ప్రారంభించండి',
  'existingUser': 'ఇప్పటికే ఉన్న వినియోగదారు',
  'existingUserDesc': 'మీ ఇప్పటికే ఉన్న ఖాతాలో సైన్ ఇన్ చేయండి',
  'account': 'ఖాతా',
  'settings': 'సెట్టింగ్లు',
  'vehicleDetails': 'వాహన వివరాలు',
  'documents': 'పత్రాలు',
  'bankDetails': 'బ్యాంకు వివరాలు',
  'notifications': 'నోటిఫికేషన్లు',
  'language': 'భాష',
  'changeLanguage': 'యాప్ భాషను మార్చండి',
  'helpSupport': 'సహాయం & మద్దతు',
  'privacyPolicy': 'గోప్యతా విధానం',
  'logout': 'లాగ్ అవుట్',
  'notAdded': 'చేర్చబడలేదు',
  'uploaded': 'అప్‌లోడ్ చేయబడింది',
  'notUploaded': 'అప్‌లోడ్ చేయబడలేదు',
  'workingHours': 'పని గంటలు',
  'todaysHours': 'నేటి గంటలు',
  'recentActivity': 'ఇటీవలి కార్యకలాపం',
  'sessionTrackingComingSoon': 'వివరమైన సెషన్ ట్రాకింగ్\nత్వరలో వస్తుంది!',
};
