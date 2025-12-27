import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_state.dart';

enum AppLanguage { en, hi, gu }

class AppLocalizations {
  AppLocalizations._();

  // Core translations map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Name
      'appName': 'Mewad Maheshwari Samaj Nadiad',
      
      // Splash & Intro
      'splashSubtitle': 'Connect with your community',
      'introMeetCommunity': 'Meet Our Community',
      
      // Authentication
      'loginTitle': 'Welcome Back!',
      'loginDescription': 'Enter your phone number to continue',
      'phoneNumber': 'Phone Number',
      'phoneHint': 'Enter your phone number',
      'continue': 'Continue',
      'register': 'Register',
      'createAccount': 'Create Account',
      'fullName': 'Full Name',
      'fullNameHint': 'e.g. Mohit Soni',
      
      // OTP Verification
      'verifyOtpTitle': 'Verify OTP',
      'verifyPhone': 'Verify Your Phone',
      'enter6DigitCode': 'Enter the 6-digit code sent to\n',
      'didntReceiveCode': 'Didn\'t receive the code? ',
      'resend': 'Resend',
      
      // Navigation
      'home': 'Home',
      'announcement': 'Announcement',
      'society': 'Society',
      'profile': 'Profile',
      
      // Settings
      'settingsTitle': 'Settings',
      'settingsLanguage': 'Language',
      'languageEnglish': 'English',
      'languageHindi': 'Hindi',
      'languageGujarati': 'Gujarati',
      
      // Profile
      'personalInformation': 'Personal Information',
      'familyMembers': 'Family Members',
      'actions': 'Actions',
      'phone': 'Phone',
      'email': 'Email',
      'occupation': 'Occupation',
      'societyName': 'Society',
      'area': 'Area',
      'address': 'Address',
      'nativePlace': 'Native Place',
      'dateOfBirth': 'Date of Birth',
      'education': 'Education',
      'relation': 'Relation',
      'occupationAddress': 'Occupation Address',
      
      // Actions
      'addFamilyMember': 'Add Family Member',
      'addFamilyMemberSubtitle': 'Add new family member to your profile',
      'addFamily': 'Add Family',
      'addFamilySubtitle': 'Add new family in Samaj',
      'editDetails': 'Edit Details',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'viewAll': 'View All',
      'retry': 'Retry',
      'ok': 'OK',
      
      // Family
      'familyDirectory': 'Family Directory',
      'headOfFamily': 'Head of Family',
      'totalMembers': 'Total Members',
      'members': 'members',
      'noFamilyMembers': 'No Other Family Members',
      'onlyHeadRegistered': 'Only the head of family is registered',
      'familyOverview': 'Family Overview',
      'completeFamilyInfo': 'Complete family information',
      
      // Announcements
      'announcements': 'Announcements',
      'addAnnouncement': 'Add Announcement',
      'title': 'Title',
      'description': 'Description',
      'fullContent': 'Full Content',
      'date': 'Date',
      'image': 'Image',
      'attachPdf': 'Attach PDF',
      'sendTo': 'Send To',
      'allMembers': 'All Members',
      'allHeads': 'All Heads',
      'specificSociety': 'Specific Society',
      'selectSocieties': 'Select Societies',
      'noAnnouncementsYet': 'No announcements yet',
      'checkBackLater': 'Check back later for updates',
      
      // Society
      'societies': 'Societies',
      'noSocietiesFound': 'No societies found',
      'searchSociety': 'Search society...',
      'families': 'families',
      
      // Common UI
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'failed': 'Failed',
      'submit': 'Submit',
      'update': 'Update',
      'close': 'Close',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      
      // Messages
      'noChangesToUpdate': 'No changes to update',
      'profileUpdatedSuccessfully': 'Profile updated successfully',
      'failedToUpdate': 'Failed to update',
      'announcementSent': 'Announcement sent successfully',
      'familyRegisteredSuccessfully': 'Family Registered Successfully',
      'failedToSubmit': 'Failed to Submit',
      'pleaseSelectFamilyEditor': 'Please select a family editor',
      'selectAtLeastOneSociety': 'Select at least one society',
      'thisFieldIsRequired': 'This field is required',
      'pleaseEnterValidPhone': 'Please enter a valid 10-digit phone number',
      
      // Logout & Account
      'logout': 'Logout',
      'logoutSubtitle': 'Sign out of your account',
      'deleteAccount': 'Delete Account',
      'deleteAccountSubtitle': 'Permanently remove your account and data',
      'deleteAccountConfirm': 'Are you sure you want to delete your account? This action cannot be undone.',
      
      // Contact & Support
      'contactUs': 'Contact Us',
      'getInTouch': 'Get in Touch',
      'contactDescription': 'For any queries, feedback, or community-related assistance, please reach out to us using the details below.',
      'developmentTeam': 'Development Team',
      'weValueYourFeedback': 'We value your feedback 🙏',
      
      // Drawer Menu
      'drawerPeople': 'Community Leaders',
      'organization': 'Organization',
      'termsAndConditions': 'Terms & Conditions',
      'privacyPolicy': 'Privacy Policy',
      'settings': 'Settings',
      
      // Admin
      'adminMode': 'Admin Mode',
      'adminModeDescription': 'You can edit or delete this announcement',
      'superAdminActions': 'Super Admin Actions',
      
      // Search & Empty States
      'noFamiliesFound': 'No families found',
      'tryDifferentKeywords': 'Try searching with different keywords',
      'noMembersFound': 'No members found',
      'errorLoadingData': 'Error loading data',
      
      // Dialog Titles
      'whatWouldYouLikeToDo': 'What would you like to do?',
      'call': 'Call',
      'family': 'Family',
      'exitApplication': 'Exit Application?',
      'exitConfirm': 'Are you sure you want to close the app?',
      'exit': 'Exit',
      
      // Date Formats
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'daysAgo': 'days ago',
      'inDays': 'In',
      
      // Form Labels
      'optional': 'Optional',
      'required': 'Required',
      'selectOption': 'Select Option',
      'chooseFromGallery': 'Choose from Gallery',
      'takePhoto': 'Take Photo',
      'uploadPhoto': 'Upload Photo',
      'addPhoto': 'Add Photo',
      'selectPdf': 'Select PDF',
      'noPdfSelected': 'No PDF selected',
      
      // Family Form
      'familyRegistration': 'Family Registration',
      'headDetails': 'Head of Family',
      'memberDetails': 'Member Details',
      'selectFamilyEditor': 'Select Family Editor',
      'chooseFamilyEditor': 'Choose who can edit family data',
      'addMember': 'Add Family Member',
      'removeMember': 'Remove member',
      'member': 'Member',
      
      // Notification
      'notificationPermission': 'Notification Permission',
      'enableNotifications': 'Enable notifications to stay updated',
      'notificationEnabled': 'Notifications enabled',
    },
    
    // Hindi Translations
    'hi': {
      // App Name
      'appName': 'मेवाड़ माहेश्वरी समाज नडियाद',
      
      // Splash & Intro
      'splashSubtitle': 'अपने समुदाय से जुड़ें',
      'introMeetCommunity': 'हमारे समुदाय के सदस्य',
      
      // Authentication
      'loginTitle': 'वापस स्वागत है!',
      'loginDescription': 'जारी रखने के लिए अपना मोबाइल नंबर दर्ज करें',
      'phoneNumber': 'मोबाइल नंबर',
      'phoneHint': 'अपना मोबाइल नंबर दर्ज करें',
      'continue': 'जारी रखें',
      'register': 'पंजीकरण करें',
      'createAccount': 'खाता बनाएँ',
      'fullName': 'पूरा नाम',
      'fullNameHint': 'जैसे - मोहित सोनी',
      
      // OTP Verification
      'verifyOtpTitle': 'OTP सत्यापित करें',
      'verifyPhone': 'अपना मोबाइल सत्यापित करें',
      'enter6DigitCode': 'भेजा गया 6 अंकों का कोड दर्ज करें\n',
      'didntReceiveCode': 'कोड नहीं मिला? ',
      'resend': 'फिर से भेजें',
      
      // Navigation
      'home': 'होम',
      'announcement': 'घोषणा',
      'society': 'सोसाइटी',
      'profile': 'प्रोफ़ाइल',
      
      // Settings
      'settingsTitle': 'सेटिंग्स',
      'settingsLanguage': 'भाषा',
      'languageEnglish': 'अंग्रेज़ी',
      'languageHindi': 'हिन्दी',
      'languageGujarati': 'गुजराती',
      
      // Profile
      'personalInformation': 'व्यक्तिगत जानकारी',
      'familyMembers': 'परिवार के सदस्य',
      'actions': 'क्रियाएँ',
      'phone': 'फोन',
      'email': 'ईमेल',
      'occupation': 'व्यवसाय',
      'societyName': 'सोसाइटी',
      'area': 'क्षेत्र',
      'address': 'पता',
      'nativePlace': 'मूल निवास',
      'dateOfBirth': 'जन्म तिथि',
      'education': 'शिक्षा',
      'relation': 'संबंध',
      'occupationAddress': 'व्यवसाय का पता',
      
      // Actions
      'addFamilyMember': 'परिवार सदस्य जोड़ें',
      'addFamilyMemberSubtitle': 'अपनी प्रोफ़ाइल में नया परिवार सदस्य जोड़ें',
      'addFamily': 'परिवार जोड़ें',
      'addFamilySubtitle': 'समाज में नया परिवार जोड़ें',
      'editDetails': 'विवरण संपादित करें',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'viewAll': 'सभी देखें',
      'retry': 'पुन: प्रयास करें',
      'ok': 'ठीक है',
      
      // Family
      'familyDirectory': 'परिवार निर्देशिका',
      'headOfFamily': 'परिवार के मुखिया',
      'totalMembers': 'कुल सदस्य',
      'members': 'सदस्य',
      'noFamilyMembers': 'कोई अन्य परिवार सदस्य नहीं',
      'onlyHeadRegistered': 'केवल परिवार के मुखिया पंजीकृत हैं',
      'familyOverview': 'परिवार का विवरण',
      'completeFamilyInfo': 'पूर्ण परिवार जानकारी',
      
      // Announcements
      'announcements': 'घोषणाएँ',
      'addAnnouncement': 'घोषणा जोड़ें',
      'title': 'शीर्षक',
      'description': 'विवरण',
      'fullContent': 'पूर्ण सामग्री',
      'date': 'तारीख',
      'image': 'चित्र',
      'attachPdf': 'PDF संलग्न करें',
      'sendTo': 'भेजें',
      'allMembers': 'सभी सदस्य',
      'allHeads': 'सभी मुखिया',
      'specificSociety': 'विशिष्ट सोसाइटी',
      'selectSocieties': 'सोसाइटी चुनें',
      'noAnnouncementsYet': 'अभी तक कोई घोषणा नहीं',
      'checkBackLater': 'बाद में अपडेट के लिए जांचें',
      
      // Society
      'societies': 'सोसाइटियाँ',
      'noSocietiesFound': 'कोई सोसाइटी नहीं मिली',
      'searchSociety': 'सोसाइटी खोजें...',
      'families': 'परिवार',
      
      // Common UI
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'failed': 'विफल',
      'submit': 'जमा करें',
      'update': 'अपडेट करें',
      'close': 'बंद करें',
      'search': 'खोजें',
      'filter': 'फ़िल्टर',
      'sort': 'क्रमबद्ध करें',
      
      // Messages
      'noChangesToUpdate': 'अपडेट करने के लिए कोई परिवर्तन नहीं',
      'profileUpdatedSuccessfully': 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुआ',
      'failedToUpdate': 'अपडेट विफल',
      'announcementSent': 'घोषणा सफलतापूर्वक भेजी गई',
      'familyRegisteredSuccessfully': 'परिवार सफलतापूर्वक पंजीकृत',
      'failedToSubmit': 'जमा करने में विफल',
      'pleaseSelectFamilyEditor': 'कृपया परिवार संपादक चुनें',
      'selectAtLeastOneSociety': 'कम से कम एक सोसाइटी चुनें',
      'thisFieldIsRequired': 'यह फ़ील्ड आवश्यक है',
      'pleaseEnterValidPhone': 'कृपया मान्य 10 अंकों का फोन नंबर दर्ज करें',
      
      // Logout & Account
      'logout': 'लॉगआउट',
      'logoutSubtitle': 'अपने खाते से साइन आउट करें',
      'deleteAccount': 'खाता हटाएं',
      'deleteAccountSubtitle': 'स्थायी रूप से अपना खाता और डेटा हटाएं',
      'deleteAccountConfirm': 'क्या आप वाकई अपना खाता हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।',
      
      // Contact & Support
      'contactUs': 'संपर्क करें',
      'getInTouch': 'संपर्क में रहें',
      'contactDescription': 'किसी भी प्रश्न, प्रतिक्रिया या समुदाय संबंधी सहायता के लिए, कृपया नीचे दिए गए विवरण का उपयोग करके हमसे संपर्क करें।',
      'developmentTeam': 'विकास टीम',
      'weValueYourFeedback': 'हम आपकी प्रतिक्रिया की सराहना करते हैं 🙏',
      
      // Drawer Menu
      'drawerPeople': 'समुदाय के पदाधिकारी',
      'organization': 'संगठन',
      'termsAndConditions': 'नियम और शर्तें',
      'privacyPolicy': 'गोपनीयता नीति',
      'settings': 'सेटिंग्स',
      
      // Admin
      'adminMode': 'प्रशासक मोड',
      'adminModeDescription': 'आप इस घोषणा को संपादित या हटा सकते हैं',
      'superAdminActions': 'सुपर प्रशासक क्रियाएँ',
      
      // Search & Empty States
      'noFamiliesFound': 'कोई परिवार नहीं मिला',
      'tryDifferentKeywords': 'विभिन्न कीवर्ड के साथ खोजने का प्रयास करें',
      'noMembersFound': 'कोई सदस्य नहीं मिला',
      'errorLoadingData': 'डेटा लोड करने में त्रुटि',
      
      // Dialog Titles
      'whatWouldYouLikeToDo': 'आप क्या करना चाहेंगे?',
      'call': 'कॉल करें',
      'family': 'परिवार',
      'exitApplication': 'एप्लिकेशन बंद करें?',
      'exitConfirm': 'क्या आप वाकई ऐप बंद करना चाहते हैं?',
      'exit': 'बाहर निकलें',
      
      // Date Formats
      'today': 'आज',
      'yesterday': 'कल',
      'tomorrow': 'कल',
      'daysAgo': 'दिन पहले',
      'inDays': 'में',
      
      // Form Labels
      'optional': 'वैकल्पिक',
      'required': 'आवश्यक',
      'selectOption': 'विकल्प चुनें',
      'chooseFromGallery': 'गैलरी से चुनें',
      'takePhoto': 'फोटो लें',
      'uploadPhoto': 'फोटो अपलोड करें',
      'addPhoto': 'फोटो जोड़ें',
      'selectPdf': 'PDF चुनें',
      'noPdfSelected': 'कोई PDF नहीं चुनी गई',
      
      // Family Form
      'familyRegistration': 'परिवार पंजीकरण',
      'headDetails': 'परिवार के मुखिया',
      'memberDetails': 'सदस्य विवरण',
      'selectFamilyEditor': 'परिवार संपादक चुनें',
      'chooseFamilyEditor': 'चुनें कौन परिवार डेटा संपादित कर सकता है',
      'addMember': 'परिवार सदस्य जोड़ें',
      'removeMember': 'सदस्य हटाएं',
      'member': 'सदस्य',
      
      // Notification
      'notificationPermission': 'सूचना अनुमति',
      'enableNotifications': 'अपडेट रहने के लिए सूचनाएं सक्षम करें',
      'notificationEnabled': 'सूचनाएं सक्षम',
    },
    
    // Gujarati Translations
    'gu': {
      // App Name
      'appName': 'મેવાડ મહેશ્વરી સમાજ નડિયાદ',
      
      // Splash & Intro
      'splashSubtitle': 'તમારા સમાજ સાથે જોડાઓ',
      'introMeetCommunity': 'અમારા સમાજના સભ્યો',
      
      // Authentication
      'loginTitle': 'પાછા આવવા સ્વાગત!',
      'loginDescription': 'આગળ વધવા માટે તમારો મોબાઇલ નંબર દાખલ કરો',
      'phoneNumber': 'મોબાઇલ નંબર',
      'phoneHint': 'તમારો મોબાઇલ નંબર દાખલ કરો',
      'continue': 'આગળ વધો',
      'register': 'રજીસ્ટર કરો',
      'createAccount': 'ખાતું બનાવો',
      'fullName': 'પૂર્ણ નામ',
      'fullNameHint': 'જેમ કે - મોહિત સોની',
      
      // OTP Verification
      'verifyOtpTitle': 'OTP ચકાસો',
      'verifyPhone': 'તમારો મોબાઇલ ચકાસો',
      'enter6DigitCode': 'મોકલેલ 6 અંકોનો કોડ દાખલ કરો\n',
      'didntReceiveCode': 'કોડ મળ્યો નથી? ',
      'resend': 'ફરી મોકલો',
      
      // Navigation
      'home': 'હોમ',
      'announcement': 'જાહેરાત',
      'society': 'સોસાયટી',
      'profile': 'પ્રોફાઇલ',
      
      // Settings
      'settingsTitle': 'સેટિંગ્સ',
      'settingsLanguage': 'ભાષા',
      'languageEnglish': 'અંગ્રેજી',
      'languageHindi': 'હિન્દી',
      'languageGujarati': 'ગુજરાતી',
      
      // Profile
      'personalInformation': 'વ્યક્તિગત માહિતી',
      'familyMembers': 'પરિવારના સભ્યો',
      'actions': 'ક્રિયાઓ',
      'phone': 'ફોન',
      'email': 'ઈમેઇલ',
      'occupation': 'વ્યવસાય',
      'societyName': 'સોસાયટી',
      'area': 'વિસ્તાર',
      'address': 'સરનામું',
      'nativePlace': 'વતન',
      'dateOfBirth': 'જન્મ તારીખ',
      'education': 'શિક્ષણ',
      'relation': 'સંબંધ',
      'occupationAddress': 'વ્યવસાયનું સરનામું',
      
      // Actions
      'addFamilyMember': 'પરિવાર સભ્ય ઉમેરો',
      'addFamilyMemberSubtitle': 'તમારી પ્રોફાઇલમાં નવો પરિવાર સભ્ય ઉમેરો',
      'addFamily': 'પરિવાર ઉમેરો',
      'addFamilySubtitle': 'સમાજમાં નવો પરિવાર ઉમેરો',
      'editDetails': 'વિગતો સંપાદિત કરો',
      'save': 'સાચવો',
      'cancel': 'રદ કરો',
      'delete': 'કાઢી નાખો',
      'edit': 'સંપાદિત કરો',
      'viewAll': 'બધા જુઓ',
      'retry': 'ફરી પ્રયાસ કરો',
      'ok': 'બરાબર',
      
      // Family
      'familyDirectory': 'પરિવાર નિર્દેશિકા',
      'headOfFamily': 'પરિવારના વડા',
      'totalMembers': 'કુલ સભ્યો',
      'members': 'સભ્યો',
      'noFamilyMembers': 'અન્ય કોઈ પરિવાર સભ્યો નથી',
      'onlyHeadRegistered': 'માત્ર પરિવારના વડા નોંધાયેલા છે',
      'familyOverview': 'પરિવારની વિગત',
      'completeFamilyInfo': 'સંપૂર્ણ પરિવાર માહિતી',
      
      // Announcements
      'announcements': 'જાહેરાતો',
      'addAnnouncement': 'જાહેરાત ઉમેરો',
      'title': 'શીર્ષક',
      'description': 'વર્ણન',
      'fullContent': 'સંપૂર્ણ સામગ્રી',
      'date': 'તારીખ',
      'image': 'છબી',
      'attachPdf': 'PDF જોડો',
      'sendTo': 'મોકલો',
      'allMembers': 'બધા સભ્યો',
      'allHeads': 'બધા વડાઓ',
      'specificSociety': 'ચોક્કસ સોસાયટી',
      'selectSocieties': 'સોસાયટી પસંદ કરો',
      'noAnnouncementsYet': 'હજી સુધી કોઈ જાહેરાત નથી',
      'checkBackLater': 'અપડેટ માટે પછી તપાસો',
      
      // Society
      'societies': 'સોસાયટીઓ',
      'noSocietiesFound': 'કોઈ સોસાયટી મળી નથી',
      'searchSociety': 'સોસાયટી શોધો...',
      'families': 'પરિવારો',
      
      // Common UI
      'loading': 'લોડ થઈ રહ્યું છે...',
      'error': 'ભૂલ',
      'success': 'સફળતા',
      'failed': 'નિષ્ફળ',
      'submit': 'સબમિટ કરો',
      'update': 'અપડેટ કરો',
      'close': 'બંધ કરો',
      'search': 'શોધો',
      'filter': 'ફિલ્ટર',
      'sort': 'ક્રમમાં ગોઠવો',
      
      // Messages
      'noChangesToUpdate': 'અપડેટ કરવા માટે કોઈ ફેરફાર નથી',
      'profileUpdatedSuccessfully': 'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ',
      'failedToUpdate': 'અપડેટ નિષ્ફળ',
      'announcementSent': 'જાહેરાત સફળતાપૂર્વક મોકલાઈ',
      'familyRegisteredSuccessfully': 'પરિવાર સફળતાપૂર્વક નોંધાયો',
      'failedToSubmit': 'સબમિટ કરવામાં નિષ્ફળ',
      'pleaseSelectFamilyEditor': 'કૃપા કરીને પરિવાર સંપાદક પસંદ કરો',
      'selectAtLeastOneSociety': 'ઓછામાં ઓછી એક સોસાયટી પસંદ કરો',
      'thisFieldIsRequired': 'આ ફીલ્ડ જરૂરી છે',
      'pleaseEnterValidPhone': 'કૃપા કરીને માન્ય 10 અંકનો ફોન નંબર દાખલ કરો',
      
      // Logout & Account
      'logout': 'લૉગઆઉટ',
      'logoutSubtitle': 'તમારા ખાતામાંથી સાઇન આઉટ કરો',
      'deleteAccount': 'ખાતું કાઢી નાખો',
      'deleteAccountSubtitle': 'તમારું ખાતું અને ડેટા કાયમ માટે કાઢી નાખો',
      'deleteAccountConfirm': 'શું તમે ખરેખર તમારું ખાતું કાઢી નાખવા માંગો છો? આ ક્રિયા પાછી ન કરી શકાય.',
      
      // Contact & Support
      'contactUs': 'અમારો સંપર્ક કરો',
      'getInTouch': 'સંપર્કમાં રહો',
      'contactDescription': 'કોઈપણ પ્રશ્નો, પ્રતિક્રિયા અથવા સમુદાય સંબંધિત સહાય માટે, કૃપા કરીને નીચેની વિગતોનો ઉપયોગ કરીને અમારો સંપર્ક કરો.',
      'developmentTeam': 'વિકાસ ટીમ',
      'weValueYourFeedback': 'અમે તમારી પ્રતિક્રિયાની કદર કરીએ છીએ 🙏',
      
      // Drawer Menu
      'drawerPeople': 'સમાજના પદાધિકારી',
      'organization': 'સંગઠન',
      'termsAndConditions': 'નિયમો અને શરતો',
      'privacyPolicy': 'ગોપનીયતા નીતિ',
      'settings': 'સેટિંગ્સ',
      
      // Admin
      'adminMode': 'એડમિન મોડ',
      'adminModeDescription': 'તમે આ જાહેરાત સંપાદિત અથવા કાઢી શકો છો',
      'superAdminActions': 'સુપર એડમિન ક્રિયાઓ',
      
      // Search & Empty States
      'noFamiliesFound': 'કોઈ પરિવાર મળ્યા નથી',
      'tryDifferentKeywords': 'વિવિધ કીવર્ડ્સ સાથે શોધવાનો પ્રયાસ કરો',
      'noMembersFound': 'કોઈ સભ્યો મળ્યા નથી',
      'errorLoadingData': 'ડેટા લોડ કરવામાં ભૂલ',
      
      // Dialog Titles
      'whatWouldYouLikeToDo': 'તમે શું કરવા માગો છો?',
      'call': 'કૉલ કરો',
      'family': 'પરિવાર',
      'exitApplication': 'એપ્લિકેશન બંધ કરીએ?',
      'exitConfirm': 'શું તમે ખરેખર એપ બંધ કરવા માગો છો?',
      'exit': 'બહાર નીકળો',
      
      // Date Formats
      'today': 'આજે',
      'yesterday': 'ગઈકાલે',
      'tomorrow': 'કાલે',
      'daysAgo': 'દિવસ પહેલાં',
      'inDays': 'માં',
      
      // Form Labels
      'optional': 'વૈકલ્પિક',
      'required': 'જરૂરી',
      'selectOption': 'વિકલ્પ પસંદ કરો',
      'chooseFromGallery': 'ગેલેરીમાંથી પસંદ કરો',
      'takePhoto': 'ફોટો લો',
      'uploadPhoto': 'ફોટો અપલોડ કરો',
      'addPhoto': 'ફોટો ઉમેરો',
      'selectPdf': 'PDF પસંદ કરો',
      'noPdfSelected': 'કોઈ PDF પસંદ નથી',
      
      // Family Form
      'familyRegistration': 'પરિવાર નોંધણી',
      'headDetails': 'પરિવારના વડા',
      'memberDetails': 'સભ્ય વિગતો',
      'selectFamilyEditor': 'પરિવાર સંપાદક પસંદ કરો',
      'chooseFamilyEditor': 'પસંદ કરો કોણ પરિવાર ડેટા સંપાદિત કરી શકે',
      'addMember': 'પરિવાર સભ્ય ઉમેરો',
      'removeMember': 'સભ્ય દૂર કરો',
      'member': 'સભ્ય',
      
      // Notification
      'notificationPermission': 'સૂચના પરવાનગી',
      'enableNotifications': 'અપડેટ રહેવા માટે સૂચનાઓ સક્ષમ કરો',
      'notificationEnabled': 'સૂચનાઓ સક્ષમ',
    },
  };

  // Relation translations
  static const Map<String, Map<String, String>> _relationTranslations = {
    'en': {
      'Wife': 'Wife',
      'Father': 'Father',
      'Mother': 'Mother',
      'Son': 'Son',
      'Daughter': 'Daughter',
      'Brother': 'Brother',
      'Sister': 'Sister',
      'Grandfather': 'Grandfather',
      'Grandmother': 'Grandmother',
      'Grandson': 'Grandson',
      'Granddaughter': 'Granddaughter',
      'Paternal Uncle': 'Paternal Uncle',
      'Paternal Aunt': 'Paternal Aunt',
      'Maternal Uncle': 'Maternal Uncle',
      'Maternal Aunt': 'Maternal Aunt',
      'Father-in-law': 'Father-in-law',
      'Mother-in-law': 'Mother-in-law',
      'Son-in-law': 'Son-in-law',
      'Daughter-in-law': 'Daughter-in-law',
      'Brother-in-law': 'Brother-in-law',
      'Sister-in-law': 'Sister-in-law',
      'Nephew': 'Nephew',
      'Niece': 'Niece',
    },
    'hi': {
      'Wife': 'पत्नी',
      'Father': 'पिता',
      'Mother': 'माता',
      'Son': 'पुत्र',
      'Daughter': 'पुत्री',
      'Brother': 'भाई',
      'Sister': 'बहन',
      'Grandfather': 'दादा',
      'Grandmother': 'दादी',
      'Grandson': 'पोता',
      'Granddaughter': 'पोती',
      'Paternal Uncle': 'चाचा',
      'Paternal Aunt': 'बुआ',
      'Maternal Uncle': 'मामा',
      'Maternal Aunt': 'मौसी',
      'Father-in-law': 'ससुर',
      'Mother-in-law': 'सास',
      'Son-in-law': 'दामाद',
      'Daughter-in-law': 'बहू',
      'Brother-in-law': 'जीजा/देवर',
      'Sister-in-law': 'साली/भाभी',
      'Nephew': 'भतीजा',
      'Niece': 'भतीजी',
    },
    'gu': {
      'Wife': 'પત્ની',
      'Father': 'પિતા',
      'Mother': 'માતા',
      'Son': 'પુત્ર',
      'Daughter': 'પુત્રી',
      'Brother': 'ભાઈ',
      'Sister': 'બહેન',
      'Grandfather': 'દાદા',
      'Grandmother': 'દાદી',
      'Grandson': 'પૌત્ર',
      'Granddaughter': 'પૌત્રી',
      'Paternal Uncle': 'કાકા',
      'Paternal Aunt': 'ફોઈ',
      'Maternal Uncle': 'મામા',
      'Maternal Aunt': 'મામી',
      'Father-in-law': 'સસરા',
      'Mother-in-law': 'સાસુ',
      'Son-in-law': 'જમાઈ',
      'Daughter-in-law': 'વહુ',
      'Brother-in-law': 'સાળો/જેઠ',
      'Sister-in-law': 'સાળી/ભાભી',
      'Nephew': 'ભત્રીજો',
      'Niece': 'ભત્રીજી',
    },
  };

  // Get language code from context
  static String _langCode(BuildContext context) {
    final appState = AppState.of(context, listen: false);
    switch (appState.language) {
      case AppLanguage.hi:
        return 'hi';
      case AppLanguage.gu:
        return 'gu';
      case AppLanguage.en:
      default:
        return 'en';
    }
  }

  // Get language code without context (for direct enum conversion)
  static String getCurrentLangCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.hi:
        return 'hi';
      case AppLanguage.gu:
        return 'gu';
      case AppLanguage.en:
      default:
        return 'en';
    }
  }

  // Main translation method
  static String text(BuildContext context, String key) {
    final code = _langCode(context);
    return _localizedValues[code]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Translate relation from API (English) to current language
  static String translateRelation(String englishRelation, BuildContext context) {
    final code = _langCode(context);
    return _relationTranslations[code]?[englishRelation] ?? englishRelation;
  }

  // Get all localized relations for dropdown
  static List<String> getLocalizedRelations(BuildContext context) {
    final code = _langCode(context);
    return _relationTranslations[code]?.values.toList() ?? [];
  }

  // Convert localized relation back to English for API
  static String getEnglishRelation(String localizedRelation, BuildContext context) {
    final code = _langCode(context);
    final relations = _relationTranslations[code] ?? {};
    
    // Find the English key for this value
    for (var entry in relations.entries) {
      if (entry.value == localizedRelation) {
        return entry.key;
      }
    }
    
    return localizedRelation; 
  }
}