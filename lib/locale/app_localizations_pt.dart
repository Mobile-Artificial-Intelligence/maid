// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get friendlyName => 'Português';

  @override
  String get localeTitle => 'Local';

  @override
  String get defaultLocale => 'Local Padrão';

  @override
  String get loading => 'Carregando...';

  @override
  String get loadModel => 'Carregar Modelo';

  @override
  String get downloadModel => 'Baixar Modelo';

  @override
  String get noModelSelected => 'Nenhum Modelo Selecionado';

  @override
  String get noModelLoaded => 'Nenhum Modelo Carregado';

  @override
  String get localModels => 'Modelos Locais';

  @override
  String get size => 'Tamanho';

  @override
  String get parameters => 'Parametros';

  @override
  String get delete => 'Apagar';

  @override
  String get select => 'Selecionar';

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get edit => 'Editar';

  @override
  String get regenerate => 'Re-gerar';

  @override
  String get chatsTitle => 'Conversas';

  @override
  String get newChat => 'Nova Conversa';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String get errorTitle => 'Erro';

  @override
  String get key => 'Chave';

  @override
  String get value => 'Valor';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Proceed';

  @override
  String get done => 'Feito';

  @override
  String get close => 'Fechar';

  @override
  String get save => 'Salvar';

  @override
  String saveLabel(String label) {
    return 'Salvar $label';
  }

  @override
  String get selectTag => 'Selecionar Tag';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get contentShared => 'Conteúdo Compartilhado';

  @override
  String get setUserImage => 'Definir Imagem do Usuário';

  @override
  String get setAssistantImage => 'Definir Imagem do Assistente';

  @override
  String get loadUserImage => 'Carregar Imagem do Usuário';

  @override
  String get loadAssistantImage => 'Carregar Imagem do Assistente';

  @override
  String get userName => 'Nome do Usuário';

  @override
  String get assistantName => 'Nome do Assistente';

  @override
  String get user => 'Usuário';

  @override
  String get assistant => 'Assistente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get aiEcosystem => 'Ecosistema da IA';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Modelo do Llama CPP';

  @override
  String get remoteModel => 'Modelo Remoto';

  @override
  String get refreshRemoteModels => 'Atualizar Modelos Remotos';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Procurar na Rede Local';

  @override
  String get localNetworkSearchTitle => 'Busca na Rede Local';

  @override
  String get localNetworkSearchContent => 'Esta função requer permissões adicionais para procurar na sua rede local por instâncias do Ollama.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Parametros do Modelo';

  @override
  String get addParameter => 'Adicionar Parametros';

  @override
  String get removeParameter => 'Remover Parametro';

  @override
  String get saveParameters => 'Salvar Parametros';

  @override
  String get importParameters => 'Importar Parametros';

  @override
  String get exportParameters => 'Exportar Parametros';

  @override
  String get selectAiEcosystem => 'Selecionar Ecosistema de IA';

  @override
  String get selectRemoteModel => 'Selecionar Modelo Remoto';

  @override
  String get selectThemeMode => 'Selecionar Tema do APP';

  @override
  String get themeMode => 'Modo do Tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeSeedColor => 'Cor primária do tema';

  @override
  String get editMessage => 'Editar Mensagem';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String aiSettings(String aiType) {
    return 'Configurações do $aiType ';
  }

  @override
  String get userSettings => 'Configurações do Usuário';

  @override
  String get assistantSettings => 'Configurações do Assistente';

  @override
  String get systemSettings => 'Configurações do Sistema';

  @override
  String get systemPrompt => 'Prompt do Sistema';

  @override
  String get clearChats => 'Apagar Conversas';

  @override
  String get resetSettings => 'Voltar a Configuração Padrão';

  @override
  String get clearCache => 'Apagar Cache';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutContent => 'Maid é um aplicativo gratuito e de código aberto, multiplataforma, para interagir com modelos do llama.cpp localmente, e com os modelos da Ollama, Mistral e OpenAI de forma remota. O Maid é compatível com os cartões de personagens do SillyTavern, permitindo que você interaja com todos os seus personagens favoritos. Ele também permite o download, direto pelo aplicativo, de uma lista selecionada de modelos hospedados no Hugging Face.';

  @override
  String get leadMaintainer => 'Responsável Principal pelo Projeto';

  @override
  String get apiKey => 'Chave da API';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get scrollToRecent => 'Scroll to Recent';

  @override
  String get clearPrompt => 'Apagar Prompt';

  @override
  String get submitPrompt => 'Enviar Prompt';

  @override
  String get stopPrompt => 'Pagar Prompt';

  @override
  String get typeMessage => 'Escreva uma Mensagem...';

  @override
  String get code => 'Código';

  @override
  String copyLabel(String label) {
    return 'Copiar $label';
  }

  @override
  String labelCopied(String label) {
    return '$label Copiado para a Área de Transferência!';
  }

  @override
  String get debugTitle => 'Depurar';

  @override
  String get warning => 'Aviso';

  @override
  String get nsfwWarning => 'Este modelo foi intencionalmente projetado para gerar conteúdo impróprio (NSFW). Isso pode incluir conteúdo sexual ou violento explícito envolvendo tortura, estupro, assassinato e/ou comportamentos sexualmente desviantes. Se você for sensível a esses temas ou se a discussão desses temas violar leis locais, NÃO PROSSIGA.';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get register => 'Resgistre-se';

  @override
  String get email => 'Email';

  @override
  String get password => 'Senha';

  @override
  String get confirmPassword => 'Confirme a Senha';

  @override
  String get resetCode => 'Código de recuperação';

  @override
  String get resetCodeSent => 'Um Código de Reinicio foi enviado para o seu email.';

  @override
  String get sendResetCode => 'Enviar código de redefinição';

  @override
  String get sendAgain => 'Enviar De Novo';

  @override
  String get required => 'Obrigatório';

  @override
  String get invalidEmail => 'Por favor digite um email válido';

  @override
  String get invalidUserName => 'Deve ter de 3 a 24 caracteres, alfanumérico e underline';

  @override
  String get invalidPasswordLength => 'Mínimo de 8 Caracteres';

  @override
  String get invalidPassword => 'Inclua Letras Minúsculas, Maiúsculas, Números e Símbolos';

  @override
  String get passwordNoMatch => 'As senhas estão diferentes';

  @override
  String get createAccount => 'Crie uma conta';

  @override
  String get resetPassword => 'Esqueci a Senha';

  @override
  String get backToLogin => 'Voltar ao Login';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get success => 'Sucesso';

  @override
  String get registrationSuccess => 'Resgistrado com Sucesso';

  @override
  String get resetSuccess => 'Sua senha foi reiniciada com sucesso.';

  @override
  String get emailVerify => 'Por favor verifique o seu email para concluir a verificação.';
}
