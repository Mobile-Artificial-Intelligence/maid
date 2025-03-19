// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get friendlyName => 'हिंदी';

  @override
  String get localeTitle => 'स्थान';

  @override
  String get defaultLocale => 'डिफ़ॉल्ट स्थान';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get loadModel => 'मॉडल लोड करें';

  @override
  String get noModelSelected => 'कोई मॉडल चयनित नहीं';

  @override
  String get noModelLoaded => 'कोई मॉडल लोड नहीं हुआ';

  @override
  String get delete => 'हटाएं';

  @override
  String get import => 'आयात करें';

  @override
  String get export => 'निर्यात करें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get regenerate => 'पुनः उत्पन्न करें';

  @override
  String get chatsTitle => 'चैट्स';

  @override
  String get newChat => 'नई चैट';

  @override
  String get anErrorOccurred => 'एक त्रुटि हुई';

  @override
  String get errorTitle => 'त्रुटि';

  @override
  String get key => 'कुंजी';

  @override
  String get value => 'मान';

  @override
  String get ok => 'ठीक है';

  @override
  String get done => 'समाप्त';

  @override
  String get close => 'बंद करें';

  @override
  String save(String label) {
    return '$label सहेजें';
  }

  @override
  String get next => 'अगला';

  @override
  String get previous => 'पिछला';

  @override
  String get contentShared => 'सामग्री साझा की गई';

  @override
  String get setUserImage => 'उपयोगकर्ता छवि सेट करें';

  @override
  String get setAssistantImage => 'सहायक छवि सेट करें';

  @override
  String get loadUserImage => 'उपयोगकर्ता छवि लोड करें';

  @override
  String get loadAssistantImage => 'सहायक छवि लोड करें';

  @override
  String get userName => 'उपयोगकर्ता नाम';

  @override
  String get assistantName => 'सहायक नाम';

  @override
  String get user => 'उपयोगकर्ता';

  @override
  String get assistant => 'सहायक';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get aiEcosystem => 'एआई इकोसिस्टम';

  @override
  String get llamaCpp => 'लामा सीपीपी';

  @override
  String get llamaCppModel => 'लामा सीपीपी मॉडल';

  @override
  String get remoteModel => 'रिमोट मॉडल';

  @override
  String get refreshRemoteModels => 'रिमोट मॉडल्स को ताज़ा करें';

  @override
  String get ollama => 'ओल्लामा';

  @override
  String get searchLocalNetwork => 'स्थानीय नेटवर्क खोजें';

  @override
  String get localNetworkSearchTitle => 'स्थानीय नेटवर्क खोज';

  @override
  String get localNetworkSearchContent => 'इस सुविधा को आपके स्थानीय नेटवर्क में ओल्लामा इंस्टेंस खोजने के लिए अतिरिक्त अनुमतियों की आवश्यकता है।';

  @override
  String get openAI => 'ओपनएआई';

  @override
  String get mistral => 'मिस्ट्रल';

  @override
  String get anthropic => 'एंथ्रोपिक';

  @override
  String get googleGemini => 'Google Gemini';

  @override
  String get selectAiEcosystem => 'एआई इकोसिस्टम चुनें';

  @override
  String get selectOverrideType => 'ओवरराइड प्रकार चुनें';

  @override
  String get selectRemoteModel => 'रिमोट मॉडल चुनें';

  @override
  String get selectThemeMode => 'ऐप थीम मोड चुनें';

  @override
  String get overrideTypeString => 'स्ट्रिंग';

  @override
  String get overrideTypeInteger => 'पूर्णांक';

  @override
  String get overrideTypeDouble => 'डबल';

  @override
  String get overrideTypeBoolean => 'बूल';

  @override
  String get inferanceOverrides => 'अनुमान ओवरराइड्स';

  @override
  String get addOverride => 'ओवरराइड जोड़ें';

  @override
  String get saveOverride => 'ओवरराइड सहेजें';

  @override
  String get deleteOverride => 'ओवरराइड हटाएं';

  @override
  String get themeMode => 'थीम मोड';

  @override
  String get themeModeSystem => 'सिस्टम';

  @override
  String get themeModeLight => 'हल्का';

  @override
  String get themeModeDark => 'गहरा';

  @override
  String get themeSeedColor => 'थीम सीड रंग';

  @override
  String get editMessage => 'संदेश संपादित करें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String aiSettings(String aiControllerType) {
    return '$aiControllerType सेटिंग्स';
  }

  @override
  String get userSettings => 'उपयोगकर्ता सेटिंग्स';

  @override
  String get assistantSettings => 'सहायक सेटिंग्स';

  @override
  String get systemSettings => 'सिस्टम सेटिंग्स';

  @override
  String get systemPrompt => 'सिस्टम प्रॉम्प्ट';

  @override
  String get clearChats => 'चैट्स साफ़ करें';

  @override
  String get resetSettings => 'सेटिंग्स रीसेट करें';

  @override
  String get clearCache => 'कैश साफ़ करें';

  @override
  String get aboutTitle => 'बारे में';

  @override
  String get aboutContent => 'Maid एक क्रॉस-प्लेटफ़ॉर्म मुक्त और ओपन-सोर्स एप्लिकेशन है जो स्थानीय रूप से llama.cpp मॉडल और दूरस्थ रूप से Ollama, Mistral, और OpenAI मॉडल से इंटरफ़ेस करने के लिए डिज़ाइन किया गया है। Maid सिल्लीटैवर्न चरित्र कार्ड का समर्थन करता है जिससे आप अपने पसंदीदा पात्रों के साथ संवाद कर सकते हैं। Maid ऐप के भीतर सीधे Hugging Face से क्यूरेटेड मॉडल की सूची डाउनलोड करने की सुविधा देता है। Maid को MIT लाइसेंस के तहत वितरित किया जाता है और इसे किसी भी प्रकार की गारंटी के बिना प्रदान किया जाता है, चाहे वह व्यक्त हो या निहित। Maid का Hugging Face, Meta (Facebook), Mistral AI, OpenAI, Google, Microsoft या किसी अन्य कंपनी से कोई संबंध नहीं है जो इस एप्लिकेशन के साथ संगत मॉडल प्रदान करती है।';

  @override
  String get leadMaintainer => 'प्रधान अनुरक्षक';

  @override
  String get apiKey => 'एपीआई कुंजी';

  @override
  String get baseUrl => 'बेस यूआरएल';

  @override
  String get clearPrompt => 'प्रॉम्प्ट साफ़ करें';

  @override
  String get submitPrompt => 'प्रॉम्प्ट सबमिट करें';

  @override
  String get stopPrompt => 'प्रॉम्प्ट रोकें';

  @override
  String get typeMessage => 'एक संदेश टाइप करें...';

  @override
  String get code => 'कोड';

  @override
  String copyLabel(String label) {
    return '$label कॉपी करें';
  }

  @override
  String labelCopied(String label) {
    return '$label क्लिपबोर्ड पर कॉपी किया गया!';
  }
}
