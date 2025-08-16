// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get friendlyName => '한국어';

  @override
  String get localeTitle => '로케일';

  @override
  String get defaultLocale => '기본 로케일';

  @override
  String get loading => '로딩 중...';

  @override
  String get loadModel => '모델 불러오기';

  @override
  String get downloadModel => '모델 다운로드';

  @override
  String get noModelSelected => '선택된 모델 없음';

  @override
  String get noModelLoaded => '로드된 모델 없음';

  @override
  String get localModels => '로컬 모델';

  @override
  String get size => '크기';

  @override
  String get parameters => '매개변수';

  @override
  String get delete => '삭제';

  @override
  String get select => '선택';

  @override
  String get import => '가져오기';

  @override
  String get export => '내보내기';

  @override
  String get edit => '편집';

  @override
  String get regenerate => '재생성';

  @override
  String get chatsTitle => '채팅';

  @override
  String get newChat => '새 채팅';

  @override
  String get anErrorOccurred => '오류가 발생했습니다';

  @override
  String get errorTitle => '오류';

  @override
  String get key => '키';

  @override
  String get value => '값';

  @override
  String get ok => '확인';

  @override
  String get proceed => '계속 진행';

  @override
  String get done => '완료';

  @override
  String get close => '닫기';

  @override
  String get save => '저장';

  @override
  String saveLabel(String label) {
    return '$label 저장';
  }

  @override
  String get selectTag => '태그 선택';

  @override
  String get next => '다음';

  @override
  String get previous => '이전';

  @override
  String get contentShared => '콘텐츠 공유됨';

  @override
  String get setUserImage => '사용자 이미지 설정';

  @override
  String get setAssistantImage => '어시스턴트 이미지 설정';

  @override
  String get loadUserImage => '사용자 이미지 불러오기';

  @override
  String get loadAssistantImage => '어시스턴트 이미지 불러오기';

  @override
  String get userName => '사용자 이름';

  @override
  String get assistantName => '어시스턴트 이름';

  @override
  String get user => '사용자';

  @override
  String get assistant => '어시스턴트';

  @override
  String get cancel => '취소';

  @override
  String get aiEcosystem => 'AI 생태계';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP 모델';

  @override
  String get remoteModel => '원격 모델';

  @override
  String get refreshRemoteModels => '원격 모델 새로고침';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => '로컬 네트워크 검색';

  @override
  String get localNetworkSearchTitle => '로컬 네트워크 검색';

  @override
  String get localNetworkSearchContent =>
      '이 기능을 사용하려면 Ollama 인스턴스를 검색하기 위한 추가 권한이 필요합니다.';

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
  String get modelParameters => '모델 매개변수';

  @override
  String get addParameter => '매개변수 추가';

  @override
  String get removeParameter => '매개변수 제거';

  @override
  String get saveParameters => '매개변수 저장';

  @override
  String get importParameters => '매개변수 가져오기';

  @override
  String get exportParameters => '매개변수 내보내기';

  @override
  String get selectAiEcosystem => 'AI 생태계 선택';

  @override
  String get selectRemoteModel => '원격 모델 선택';

  @override
  String get selectThemeMode => '앱 테마 모드 선택';

  @override
  String get themeMode => '테마 모드';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get themeSeedColor => '테마 기본 색상';

  @override
  String get editMessage => '메시지 편집';

  @override
  String get settingsTitle => '설정';

  @override
  String aiSettings(String aiType) {
    return '$aiType 설정';
  }

  @override
  String get userSettings => '사용자 설정';

  @override
  String get assistantSettings => '어시스턴트 설정';

  @override
  String get systemSettings => '시스템 설정';

  @override
  String get systemPrompt => '시스템 프롬프트';

  @override
  String get clearChats => '채팅 기록 삭제';

  @override
  String get resetSettings => '설정 초기화';

  @override
  String get clearCache => '캐시 삭제';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutContent =>
      'Maid는 로컬에서 llama.cpp 모델과 원격에서 Ollama, Mistral, Google Gemini 및 OpenAI 모델을 사용할 수 있는 크로스플랫폼 무료 오픈 소스 애플리케이션입니다. Maid는 Sillytavern 캐릭터 카드를 지원하여 좋아하는 캐릭터와 상호 작용할 수 있습니다. Maid는 Hugging Face에서 직접 큐레이션된 모델 목록을 앱 내에서 다운로드할 수 있도록 지원합니다. Maid는 MIT 라이선스로 배포되며, 명시적이거나 암시적인 어떠한 보증도 제공되지 않습니다. Maid는 Hugging Face, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft 또는 이 애플리케이션과 호환되는 모델을 제공하는 다른 회사와 제휴하지 않습니다.';

  @override
  String get leadMaintainer => '수석 유지 관리자';

  @override
  String get apiKey => 'API 키';

  @override
  String get baseUrl => '기본 URL';

  @override
  String get resourceName => '리소스 이름';

  @override
  String get deploymentName => '배포 이름';

  @override
  String get apiVersion => 'API 버전';

  @override
  String get scrollToRecent => '최근 메시지로 스크롤';

  @override
  String get clearPrompt => '프롬프트 삭제';

  @override
  String get submitPrompt => '프롬프트 제출';

  @override
  String get stopPrompt => '프롬프트 중지';

  @override
  String get typeMessage => '메시지를 입력하세요...';

  @override
  String get code => '코드';

  @override
  String copyLabel(String label) {
    return '$label 복사';
  }

  @override
  String labelCopied(String label) {
    return '$label이(가) 클립보드에 복사되었습니다!';
  }

  @override
  String get debugTitle => '디버그';

  @override
  String get warning => '경고';

  @override
  String get nsfwWarning =>
      '이 모델은 NSFW(부적절한 콘텐츠)를 생성하도록 의도적으로 설계되었습니다. 여기에는 고문, 강간, 살인 및/또는 성적으로 일탈된 행동과 관련된 노골적인 성적 또는 폭력적인 콘텐츠가 포함될 수 있습니다. 이러한 주제에 민감하시거나 해당 주제에 대한 논의가 현지 법률을 위반하는 경우, 진행하지 마십시오.';

  @override
  String get login => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get register => '가입하기';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get resetCode => '재설정 코드';

  @override
  String get resetCodeSent => '재설정 코드가 이메일로 전송되었습니다.';

  @override
  String get sendResetCode => '재설정 코드 전송';

  @override
  String get sendAgain => '다시 보내기';

  @override
  String get required => '필수';

  @override
  String get invalidEmail => '유효한 이메일을 입력하세요';

  @override
  String get invalidUserName => '3-24자, 영문자, 숫자 또는 밑줄만 사용 가능';

  @override
  String get invalidPasswordLength => '최소 8자';

  @override
  String get invalidPassword => '대문자, 소문자, 숫자 및 기호를 포함하세요';

  @override
  String get passwordNoMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get createAccount => '계정 생성';

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get backToLogin => '로그인으로 돌아가기';

  @override
  String get alreadyHaveAccount => '이미 계정이 있습니다';

  @override
  String get success => '성공';

  @override
  String get registrationSuccess => '등록이 성공적으로 완료되었습니다';

  @override
  String get resetSuccess => '비밀번호가 성공적으로 재설정되었습니다.';

  @override
  String get emailVerify => '확인을 위해 이메일을 확인하세요.';
}
