import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_state.dart';

enum AppLanguage { en, hi, gu }

class AppLocalizations {
  AppLocalizations._();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Mewad Maheshwari Samaj Nadiad',
      'splashSubtitle': 'Connect with your community',
      'loginTitle': 'Welcome Back!',
      'loginDescription': 'Enter your phone number to continue',
      'phoneNumber': 'Phone Number',
      'phoneHint': 'Enter your phone number',
      'continue': 'Continue',
      'register': 'Register',
      'createAccount': 'Create Account',
      'fullName': 'Full Name',
      'fullNameHint': 'e.g. Mohit Soni',
      'verifyOtpTitle': 'Verify OTP',
      'verifyPhone': 'Verify Your Phone',
      'enter6DigitCode': 'Enter the 6-digit code sent to\n',
      'didntReceiveCode': 'Didn\'t receive the code? ',
      'resend': 'Resend',
      'introMeetCommunity': 'Meet Our Community',
      'settingsTitle': 'Settings',
      'settingsLanguage': 'Language',
      'languageEnglish': 'English',
      'languageHindi': 'Hindi',
      'languageGujarati': 'Gujarati',
      'drawerPeople': 'Community Leaders',
    },
    'hi': {
      'appName': 'मेवाड़ माहेश्वरी समाज नडियाद',
      'splashSubtitle': 'अपने समुदाय से जुड़ें',
      'loginTitle': 'वापस स्वागत है!',
      'loginDescription': 'जारी रखने के लिए अपना मोबाइल नंबर दर्ज करें',
      'phoneNumber': 'मोबाइल नंबर',
      'phoneHint': 'अपना मोबाइल नंबर दर्ज करें',
      'continue': 'जारी रखें',
      'register': 'पंजीकरण करें',
      'createAccount': 'खाता बनाएँ',
      'fullName': 'पूरा नाम',
      'fullNameHint': 'जैसे - मोहित सोनी',
      'verifyOtpTitle': 'OTP सत्यापित करें',
      'verifyPhone': 'अपना मोबाइल सत्यापित करें',
      'enter6DigitCode': 'भेजा गया 6 अंकों का कोड दर्ज करें\n',
      'didntReceiveCode': 'कोड नहीं मिला? ',
      'resend': 'फिर से भेजें',
      'introMeetCommunity': 'हमारे समुदाय के सदस्य',
      'settingsTitle': 'सेटिंग्स',
      'settingsLanguage': 'भाषा',
      'languageEnglish': 'अंग्रेज़ी',
      'languageHindi': 'हिन्दी',
      'languageGujarati': 'गुजराती',
      'drawerPeople': 'समुदाय के पदाधिकारी',
    },
    'gu': {
      'appName': 'મેવાડ મહેશ્વરી સમાજ નડિયાદ',
      'splashSubtitle': 'તમારા સમાજ સાથે જોડાઓ',
      'loginTitle': 'પાછા આવવા સ્વાગત!',
      'loginDescription': 'આગળ વધવા માટે તમારો મોબાઇલ નંબર દાખલ કરો',
      'phoneNumber': 'મોબાઇલ નંબર',
      'phoneHint': 'તમારો મોબાઇલ નંબર દાખલ કરો',
      'continue': 'આગળ વધો',
      'register': 'રજીસ્ટર કરો',
      'createAccount': 'ખાતું બનાવો',
      'fullName': 'પૂર્ણ નામ',
      'fullNameHint': 'જેમ કે - મોહિત સોની',
      'verifyOtpTitle': 'OTP ચકાસો',
      'verifyPhone': 'તમારો મોબાઇલ ચકાસો',
      'enter6DigitCode': 'મોકલેલ 6 અંકોનો કોડ દાખલ કરો\n',
      'didntReceiveCode': 'કોડ મળ્યો નથી? ',
      'resend': 'ફરી મોકલો',
      'introMeetCommunity': 'અમારા સમાજના સભ્યો',
      'settingsTitle': 'સેટિંગ્સ',
      'settingsLanguage': 'ભાષા',
      'languageEnglish': 'અંગ્રેજી',
      'languageHindi': 'હિન્દી',
      'languageGujarati': 'ગુજરાતી',
      'drawerPeople': 'સમાજના પદાધિકારી',
    },
  };

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

  static String text(BuildContext context, String key) {
    final code = _langCode(context);
    return _localizedValues[code]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}


