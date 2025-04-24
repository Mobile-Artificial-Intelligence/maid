// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get friendlyName => 'العربية';

  @override
  String get localeTitle => 'اللغة';

  @override
  String get defaultLocale => 'اللغة الافتراضية';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get loadModel => 'تحميل النموذج';

  @override
  String get downloadModel => 'تنزيل النموذج';

  @override
  String get noModelSelected => 'لم يتم اختيار نموذج';

  @override
  String get noModelLoaded => 'لم يتم تحميل نموذج';

  @override
  String get localModels => 'النماذج المحلية';

  @override
  String get size => 'الحجم';

  @override
  String get parameters => 'المعلمات';

  @override
  String get delete => 'حذف';

  @override
  String get select => 'اختيار';

  @override
  String get import => 'استيراد';

  @override
  String get export => 'تصدير';

  @override
  String get edit => 'تعديل';

  @override
  String get regenerate => 'إعادة التوليد';

  @override
  String get chatsTitle => 'الدردشات';

  @override
  String get newChat => 'دردشة جديدة';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get key => 'المفتاح';

  @override
  String get value => 'القيمة';

  @override
  String get ok => 'موافق';

  @override
  String get proceed => 'متابعة';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get save => 'حفظ';

  @override
  String saveLabel(String label) {
    return 'حفظ $label';
  }

  @override
  String get selectTag => 'اختيار وسم';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get contentShared => 'تمت مشاركة المحتوى';

  @override
  String get setUserImage => 'تعيين صورة المستخدم';

  @override
  String get setAssistantImage => 'تعيين صورة المساعد';

  @override
  String get loadUserImage => 'تحميل صورة المستخدم';

  @override
  String get loadAssistantImage => 'تحميل صورة المساعد';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get assistantName => 'اسم المساعد';

  @override
  String get user => 'المستخدم';

  @override
  String get assistant => 'المساعد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get aiEcosystem => 'نظام الذكاء الاصطناعي';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'نموذج Llama CPP';

  @override
  String get remoteModel => 'النموذج البعيد';

  @override
  String get refreshRemoteModels => 'تحديث النماذج البعيدة';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'البحث في الشبكة المحلية';

  @override
  String get localNetworkSearchTitle => 'بحث في الشبكة المحلية';

  @override
  String get localNetworkSearchContent => 'تتطلب هذه الميزة أذونات إضافية للبحث عن مثيلات Ollama في شبكتك المحلية.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'معلمات النموذج';

  @override
  String get addParameter => 'إضافة معلمة';

  @override
  String get removeParameter => 'إزالة معلمة';

  @override
  String get saveParameters => 'حفظ المعلمات';

  @override
  String get importParameters => 'استيراد المعلمات';

  @override
  String get exportParameters => 'تصدير المعلمات';

  @override
  String get selectAiEcosystem => 'اختيار نظام الذكاء الاصطناعي';

  @override
  String get selectRemoteModel => 'اختيار النموذج البعيد';

  @override
  String get selectThemeMode => 'اختيار وضع السمة';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeSeedColor => 'لون السمة الأساسي';

  @override
  String get editMessage => 'تعديل الرسالة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String aiSettings(String aiType) {
    return 'إعدادات $aiType';
  }

  @override
  String get userSettings => 'إعدادات المستخدم';

  @override
  String get assistantSettings => 'إعدادات المساعد';

  @override
  String get systemSettings => 'إعدادات النظام';

  @override
  String get systemPrompt => 'موجه النظام';

  @override
  String get clearChats => 'مسح الدردشات';

  @override
  String get resetSettings => 'إعادة ضبط الإعدادات';

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get aboutTitle => 'حول';

  @override
  String get aboutContent => 'Maid هو تطبيق مجاني ومفتوح المصدر متعدد المنصات للتعامل مع نماذج llama.cpp محليًا ومع نماذج Ollama وMistral وOpenAI عن بُعد. يدعم Maid بطاقات شخصيات Sillytavern للتفاعل مع جميع شخصياتك المفضلة. يتيح Maid تنزيل قائمة مختارة من النماذج مباشرة من Hugging Face داخل التطبيق. يتم توزيع Maid بموجب ترخيص MIT ويتم توفيره بدون أي ضمان من أي نوع، صريح أو ضمني. Maid غير مرتبط بـ Hugging Face أو Meta (Facebook) أو MistralAI أو OpenAI أو Google أو Microsoft أو أي شركة أخرى تقدم نموذجًا متوافقًا مع هذا التطبيق.';

  @override
  String get leadMaintainer => 'المسؤول الرئيسي';

  @override
  String get apiKey => 'مفتاح API';

  @override
  String get baseUrl => 'عنوان URL الأساسي';

  @override
  String get scrollToRecent => 'التمرير إلى الأحدث';

  @override
  String get clearPrompt => 'مسح الموجه';

  @override
  String get submitPrompt => 'إرسال الموجه';

  @override
  String get stopPrompt => 'إيقاف الموجه';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get code => 'كود';

  @override
  String copyLabel(String label) {
    return 'نسخ $label';
  }

  @override
  String labelCopied(String label) {
    return 'تم نسخ $label إلى الحافظة!';
  }

  @override
  String get debugTitle => 'تصحيح الأخطاء';

  @override
  String get warning => 'تحذير';

  @override
  String get nsfwWarning => 'تم تصميم هذا النموذج عمدًا لإنتاج محتوى غير مناسب (NSFW). قد يشمل ذلك محتوى جنسيًا صريحًا أو عنيفًا يتضمن التعذيب أو الاغتصاب أو القتل و/أو السلوك الجنسي المنحرف. إذا كنت حساسًا لمثل هذه الموضوعات، أو إذا كان مناقشة هذه الموضوعات ينتهك القوانين المحلية، فلا تتابع.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get register => 'تسجيل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get resetCode => 'رمز إعادة التعيين';

  @override
  String get resetCodeSent => 'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني.';

  @override
  String get sendResetCode => 'إرسال رمز إعادة التعيين';

  @override
  String get sendAgain => 'إعادة الإرسال';

  @override
  String get required => 'مطلوب';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get invalidUserName => 'يجب أن يكون بين 3-24 حرفًا، أبجديًا رقميًا أو شرطة سفلية';

  @override
  String get invalidPasswordLength => 'الحد الأدنى 8 أحرف';

  @override
  String get invalidPassword => 'يجب أن يحتوي على أحرف كبيرة وصغيرة وأرقام ورموز';

  @override
  String get passwordNoMatch => 'كلمات المرور غير متطابقة';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get success => 'نجاح';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح';

  @override
  String get resetSuccess => 'تمت إعادة تعيين كلمة المرور بنجاح.';

  @override
  String get emailVerify => 'يرجى التحقق من بريدك الإلكتروني للتحقق.';
}
