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
  String get noModelSelected => 'Model Seçilmedi';

  @override
  String get noModelLoaded => 'Model Yüklenmedi';

  @override
  String get delete => 'Sil';

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
  String get done => 'Bitti';

  @override
  String get close => 'Kapat';

  @override
  String save(String label) {
    return '$label Kaydet';
  }

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
  String get localNetworkSearchContent => 'Bu özellik, yerel ağınızda Ollama örneklerini aramak için ek izinler gerektirir.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get googleGemini => 'Google Gemini';

  @override
  String get selectAiEcosystem => 'Yapay Zeka Ekosistemini Seç';

  @override
  String get selectOverrideType => 'Geçersiz Kılma Türünü Seç';

  @override
  String get selectRemoteModel => 'Uzak Modeli Seç';

  @override
  String get selectThemeMode => 'Uygulama Tema Modunu Seç';

  @override
  String get overrideTypeString => 'Dize';

  @override
  String get overrideTypeInteger => 'Tamsayı';

  @override
  String get overrideTypeDouble => 'Ondalık';

  @override
  String get overrideTypeBoolean => 'Bool';

  @override
  String get inferanceOverrides => 'Çıkarım Geçersiz Kılmaları';

  @override
  String get addOverride => 'Geçersiz Kılma Ekle';

  @override
  String get saveOverride => 'Geçersiz Kılmayı Kaydet';

  @override
  String get deleteOverride => 'Geçersiz Kılmayı Sil';

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
  String aiSettings(String aiControllerType) {
    return '$aiControllerType Ayarları';
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
  String get aboutContent => 'Maid, llama.cpp modelleriyle yerel olarak ve Ollama, Mistral ve OpenAI modelleriyle uzaktan etkileşim kurmak için çapraz platformlu, ücretsiz ve açık kaynaklı bir uygulamadır. Maid, sillytavern karakter kartlarını destekleyerek favori karakterlerinizle etkileşim kurmanızı sağlar. Maid, huggingface’ten doğrudan uygulama içinde küratörlü bir model listesini indirmeyi destekler. Maid, MIT lisansı altında dağıtılır ve herhangi bir garanti olmaksızın, açık veya zımni olarak sunulur. Maid, Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft veya bu uygulama ile uyumlu bir model sağlayan herhangi bir şirketle bağlantılı değildir.';

  @override
  String get leadMaintainer => 'Baş Sorumlu';

  @override
  String get apiKey => 'API Anahtarı';

  @override
  String get baseUrl => 'Temel URL';

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
}
