// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get friendlyName => 'Türkçe';

  @override
  String get localeTitle => 'Yerel Ayar';

  @override
  String get defaultLocale => 'Varsayılan Yerel Ayar';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get loadModel => 'Modeli Yükle';

  @override
  String get downloadModel => 'Modeli İndir';

  @override
  String get noModelSelected => 'Model Seçilmedi';

  @override
  String get noModelLoaded => 'Model Yüklenmedi';

  @override
  String get localModels => 'Yerel Modeller';

  @override
  String get size => 'Boyut';

  @override
  String get parameters => 'Parametreler';

  @override
  String get delete => 'Sil';

  @override
  String get select => 'Seç';

  @override
  String get import => 'İçe Aktar';

  @override
  String get export => 'Dışa Aktar';

  @override
  String get edit => 'Düzenle';

  @override
  String get regenerate => 'Yeniden Oluştur';

  @override
  String get chatsTitle => 'Sohbetler';

  @override
  String get newChat => 'Yeni Sohbet';

  @override
  String get anErrorOccurred => 'Bir hata oluştu';

  @override
  String get errorTitle => 'Hata';

  @override
  String get key => 'Anahtar';

  @override
  String get value => 'Değer';

  @override
  String get ok => 'Tamam';

  @override
  String get proceed => 'Devam Et';

  @override
  String get done => 'Bitti';

  @override
  String get close => 'Kapat';

  @override
  String get save => 'Kaydet';

  @override
  String saveLabel(String label) {
    return '$label Kaydet';
  }

  @override
  String get selectTag => 'Etiket Seç';

  @override
  String get next => 'Sonraki';

  @override
  String get previous => 'Önceki';

  @override
  String get contentShared => 'İçerik Paylaşıldı';

  @override
  String get setUserImage => 'Kullanıcı Resmini Ayarla';

  @override
  String get setAssistantImage => 'Asistan Resmini Ayarla';

  @override
  String get loadUserImage => 'Kullanıcı Resmini Yükle';

  @override
  String get loadAssistantImage => 'Asistan Resmini Yükle';

  @override
  String get userName => 'Kullanıcı Adı';

  @override
  String get assistantName => 'Asistan Adı';

  @override
  String get user => 'Kullanıcı';

  @override
  String get assistant => 'Asistan';

  @override
  String get cancel => 'İptal';

  @override
  String get aiEcosystem => 'Yapay Zeka Ekosistemi';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP Modeli';

  @override
  String get remoteModel => 'Uzak Model';

  @override
  String get refreshRemoteModels => 'Uzak Modelleri Yenile';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Yerel Ağı Ara';

  @override
  String get localNetworkSearchTitle => 'Yerel Ağ Arama';

  @override
  String get localNetworkSearchContent =>
      'Bu özellik, yerel ağınızda Ollama örneklerini aramak için ek izinler gerektirir.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get azureOpenAI => 'Azure OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Model Parametreleri';

  @override
  String get addParameter => 'Parametre Ekle';

  @override
  String get removeParameter => 'Parametreyi Kaldır';

  @override
  String get saveParameters => 'Parametreleri Kaydet';

  @override
  String get importParameters => 'Parametreleri İçe Aktar';

  @override
  String get exportParameters => 'Parametreleri Dışa Aktar';

  @override
  String get selectAiEcosystem => 'Yapay Zeka Ekosistemini Seç';

  @override
  String get selectRemoteModel => 'Uzak Modeli Seç';

  @override
  String get selectThemeMode => 'Uygulama Tema Modunu Seç';

  @override
  String get themeMode => 'Tema Modu';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Açık';

  @override
  String get themeModeDark => 'Koyu';

  @override
  String get themeSeedColor => 'Tema Tohum Rengi';

  @override
  String get editMessage => 'Mesajı Düzenle';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String aiSettings(String aiType) {
    return '$aiType Ayarları';
  }

  @override
  String get userSettings => 'Kullanıcı Ayarları';

  @override
  String get assistantSettings => 'Asistan Ayarları';

  @override
  String get systemSettings => 'Sistem Ayarları';

  @override
  String get systemPrompt => 'Sistem İstemi';

  @override
  String get clearChats => 'Sohbetleri Temizle';

  @override
  String get resetSettings => 'Ayarları Sıfırla';

  @override
  String get clearCache => 'Önbelleği Temizle';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String get aboutContent =>
      'Maid, llama.cpp modelleriyle yerel olarak ve Ollama, Mistral ve OpenAI modelleriyle uzaktan etkileşim kurmak için çapraz platformlu, ücretsiz ve açık kaynaklı bir uygulamadır. Maid, sillytavern karakter kartlarını destekleyerek favori karakterlerinizle etkileşim kurmanızı sağlar. Maid, huggingface’ten doğrudan uygulama içinde küratörlü bir model listesini indirmeyi destekler. Maid, MIT lisansı altında dağıtılır ve herhangi bir garanti olmaksızın, açık veya zımni olarak sunulur. Maid, Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft veya bu uygulama ile uyumlu bir model sağlayan herhangi bir şirketle bağlantılı değildir.';

  @override
  String get leadMaintainer => 'Baş Sorumlu';

  @override
  String get apiKey => 'API Anahtarı';

  @override
  String get baseUrl => 'Temel URL';

  @override
  String get scrollToRecent => 'Son Mesajlara Kaydır';

  @override
  String get clearPrompt => 'İstemi Temizle';

  @override
  String get submitPrompt => 'İstemi Gönder';

  @override
  String get stopPrompt => 'İstemi Durdur';

  @override
  String get typeMessage => 'Bir mesaj yazın...';

  @override
  String get code => 'Kod';

  @override
  String copyLabel(String label) {
    return '$label Kopyala';
  }

  @override
  String labelCopied(String label) {
    return '$label panoya kopyalandı!';
  }

  @override
  String get debugTitle => 'Debug';

  @override
  String get warning => 'Uyarı';

  @override
  String get nsfwWarning =>
      'Bu model, NSFW (uygunsuz) içerik üretmek üzere kasıtlı olarak tasarlanmıştır. Bu, işkence, tecavüz, cinayet ve/veya cinsel sapkın davranışlar içeren açık cinsel veya şiddet içeriğini kapsayabilir. Bu tür konulara karşı hassassanız veya bu konuların tartışılması yerel yasalara aykırıysa, DEVAM ETMEYİN.';

  @override
  String get login => 'Giriş Yap';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get resetCode => 'Sıfırlama Kodu';

  @override
  String get resetCodeSent =>
      'E-posta adresinize bir sıfırlama kodu gönderildi.';

  @override
  String get sendResetCode => 'Sıfırlama Kodunu Gönder';

  @override
  String get sendAgain => 'Tekrar Gönder';

  @override
  String get required => 'Gerekli';

  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get invalidUserName =>
      '3-24 karakter olmalı, alfanümerik veya alt çizgi';

  @override
  String get invalidPasswordLength => 'Minimum 8 karakter';

  @override
  String get invalidPassword =>
      'Büyük harf, küçük harf, rakam ve sembol içermelidir';

  @override
  String get passwordNoMatch => 'Şifreler eşleşmiyor';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get resetPassword => 'Şifreyi Sıfırla';

  @override
  String get backToLogin => 'Girişe Geri Dön';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabım var';

  @override
  String get success => 'Başarılı';

  @override
  String get registrationSuccess => 'Kayıt Başarılı';

  @override
  String get resetSuccess => 'Şifreniz başarıyla sıfırlandı.';

  @override
  String get emailVerify =>
      'Lütfen doğrulama için e-posta adresinizi kontrol edin.';
}
