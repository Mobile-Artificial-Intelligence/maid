// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get friendlyName => 'Tiếng Việt';

  @override
  String get localeTitle => 'Ngôn ngữ';

  @override
  String get defaultLocale => 'Ngôn ngữ mặc định';

  @override
  String get loading => 'Đang tải...';

  @override
  String get loadModel => 'Tải Mô hình';

  @override
  String get downloadModel => 'Tải xuống Mô hình';

  @override
  String get noModelSelected => 'Chưa chọn Mô hình';

  @override
  String get noModelLoaded => 'Chưa tải Mô hình';

  @override
  String get localModels => 'Mô hình nội bộ';

  @override
  String get size => 'Kích thước';

  @override
  String get parameters => 'Tham số';

  @override
  String get delete => 'Xóa';

  @override
  String get select => 'Chọn';

  @override
  String get import => 'Nhập';

  @override
  String get export => 'Xuất';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get regenerate => 'Tạo lại';

  @override
  String get chatsTitle => 'Trò chuyện';

  @override
  String get newChat => 'Trò chuyện mới';

  @override
  String get anErrorOccurred => 'Đã xảy ra lỗi';

  @override
  String get errorTitle => 'Lỗi';

  @override
  String get key => 'Khóa';

  @override
  String get value => 'Giá trị';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Tiếp tục';

  @override
  String get done => 'Hoàn tất';

  @override
  String get close => 'Đóng';

  @override
  String get save => 'Lưu';

  @override
  String saveLabel(String label) {
    return 'Lưu $label';
  }

  @override
  String get selectTag => 'Chọn thẻ';

  @override
  String get next => 'Tiếp';

  @override
  String get previous => 'Trước';

  @override
  String get contentShared => 'Nội dung đã chia sẻ';

  @override
  String get setUserImage => 'Đặt ảnh người dùng';

  @override
  String get setAssistantImage => 'Đặt ảnh trợ lý';

  @override
  String get loadUserImage => 'Tải ảnh người dùng';

  @override
  String get loadAssistantImage => 'Tải ảnh trợ lý';

  @override
  String get userName => 'Tên người dùng';

  @override
  String get assistantName => 'Tên trợ lý';

  @override
  String get user => 'Người dùng';

  @override
  String get assistant => 'Trợ lý';

  @override
  String get cancel => 'Hủy';

  @override
  String get aiEcosystem => 'Hệ sinh thái AI';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Mô hình Llama CPP';

  @override
  String get remoteModel => 'Mô hình từ xa';

  @override
  String get refreshRemoteModels => 'Làm mới mô hình từ xa';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Tìm trong mạng nội bộ';

  @override
  String get localNetworkSearchTitle => 'Tìm kiếm mạng nội bộ';

  @override
  String get localNetworkSearchContent =>
      'Tính năng này yêu cầu thêm quyền để tìm kiếm Ollama trong mạng nội bộ của bạn.';

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
  String get modelParameters => 'Tham số mô hình';

  @override
  String get addParameter => 'Thêm tham số';

  @override
  String get removeParameter => 'Xóa tham số';

  @override
  String get saveParameters => 'Lưu tham số';

  @override
  String get importParameters => 'Nhập tham số';

  @override
  String get exportParameters => 'Xuất tham số';

  @override
  String get selectAiEcosystem => 'Chọn hệ sinh thái AI';

  @override
  String get selectRemoteModel => 'Chọn mô hình từ xa';

  @override
  String get selectThemeMode => 'Chọn giao diện ứng dụng';

  @override
  String get themeMode => 'Chế độ giao diện';

  @override
  String get themeModeSystem => 'Hệ thống';

  @override
  String get themeModeLight => 'Sáng';

  @override
  String get themeModeDark => 'Tối';

  @override
  String get themeSeedColor => 'Màu chủ đạo';

  @override
  String get editMessage => 'Chỉnh sửa tin nhắn';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String aiSettings(String aiType) {
    return 'Cài đặt $aiType';
  }

  @override
  String get userSettings => 'Cài đặt người dùng';

  @override
  String get assistantSettings => 'Cài đặt trợ lý';

  @override
  String get systemSettings => 'Cài đặt hệ thống';

  @override
  String get systemPrompt => 'Lời nhắc hệ thống';

  @override
  String get clearChats => 'Xóa cuộc trò chuyện';

  @override
  String get resetSettings => 'Đặt lại cài đặt';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutContent =>
      'Maid là một ứng dụng đa nền tảng mã nguồn mở miễn phí để tương tác với các mô hình llama.cpp nội bộ và từ xa với các mô hình Ollama, Mistral và OpenAI. Maid hỗ trợ các thẻ nhân vật sillytavern để bạn tương tác với các nhân vật yêu thích. Maid cho phép tải xuống các mô hình được tuyển chọn trực tiếp từ Huggingface ngay trong ứng dụng. Maid được phân phối theo giấy phép MIT và không có bảo đảm nào, dù rõ ràng hay ngụ ý. Maid không liên quan đến Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft hoặc bất kỳ công ty nào khác cung cấp mô hình tương thích với ứng dụng này.';

  @override
  String get leadMaintainer => 'Người bảo trì chính';

  @override
  String get apiKey => 'Khóa API';

  @override
  String get baseUrl => 'URL cơ sở';

  @override
  String get resourceName => 'Tên tài nguyên';

  @override
  String get deploymentName => 'Tên triển khai';

  @override
  String get apiVersion => 'Phiên bản API';

  @override
  String get scrollToRecent => 'Cuộn đến tin nhắn gần đây';

  @override
  String get clearPrompt => 'Xóa lời nhắc';

  @override
  String get submitPrompt => 'Gửi lời nhắc';

  @override
  String get stopPrompt => 'Dừng lời nhắc';

  @override
  String get typeMessage => 'Nhập tin nhắn...';

  @override
  String get code => 'Mã';

  @override
  String copyLabel(String label) {
    return 'Sao chép $label';
  }

  @override
  String labelCopied(String label) {
    return 'Đã sao chép $label vào bộ nhớ tạm!';
  }

  @override
  String get debugTitle => 'Gỡ lỗi';

  @override
  String get warning => 'Cảnh báo';

  @override
  String get nsfwWarning =>
      'Mô hình này được thiết kế có chủ đích để tạo ra nội dung NSFW. Điều này có thể bao gồm nội dung tình dục hoặc bạo lực rõ ràng liên quan đến tra tấn, hiếp dâm, giết người và/hoặc hành vi lệch lạc tình dục. Nếu bạn nhạy cảm với những chủ đề như vậy hoặc việc thảo luận những chủ đề này vi phạm pháp luật địa phương, VUI LÒNG KHÔNG TIẾP TỤC.';

  @override
  String get login => 'Đăng nhập';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get resetCode => 'Mã đặt lại';

  @override
  String get resetCodeSent => 'Một mã đặt lại đã được gửi đến email của bạn.';

  @override
  String get sendResetCode => 'Gửi mã đặt lại';

  @override
  String get sendAgain => 'Gửi lại';

  @override
  String get required => 'Bắt buộc';

  @override
  String get invalidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get invalidUserName =>
      'Phải có từ 3 đến 24 ký tự, chữ, số hoặc gạch dưới';

  @override
  String get invalidPasswordLength => 'Tối thiểu 8 ký tự';

  @override
  String get invalidPassword => 'Bao gồm chữ hoa, chữ thường, số và ký hiệu';

  @override
  String get passwordNoMatch => 'Mật khẩu không khớp';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get resetPassword => 'Đặt lại mật khẩu';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get alreadyHaveAccount => 'Tôi đã có tài khoản';

  @override
  String get success => 'Thành công';

  @override
  String get registrationSuccess => 'Đăng ký thành công';

  @override
  String get resetSuccess => 'Mật khẩu của bạn đã được đặt lại thành công.';

  @override
  String get emailVerify => 'Vui lòng kiểm tra email của bạn để xác nhận.';
}
