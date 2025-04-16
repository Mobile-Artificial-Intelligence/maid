// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get friendlyName => 'Français';

  @override
  String get localeTitle => 'Langue';

  @override
  String get defaultLocale => 'Langue par défaut';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadModel => 'Charger le modèle';

  @override
  String get downloadModel => 'Télécharger le modèle';

  @override
  String get noModelSelected => 'Aucun modèle sélectionné';

  @override
  String get noModelLoaded => 'Aucun modèle chargé';

  @override
  String get localModels => 'Modèles locaux';

  @override
  String get size => 'Taille';

  @override
  String get parameters => 'Paramètres';

  @override
  String get delete => 'Supprimer';

  @override
  String get select => 'Sélectionner';

  @override
  String get import => 'Importer';

  @override
  String get export => 'Exporter';

  @override
  String get edit => 'Modifier';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get anErrorOccurred => 'Une erreur est survenue';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get key => 'Clé';

  @override
  String get value => 'Valeur';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Procéder';

  @override
  String get done => 'Terminé';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String saveLabel(String label) {
    return 'Enregistrer $label';
  }

  @override
  String get selectTag => 'Choisir une étiquette';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get contentShared => 'Contenu partagé';

  @override
  String get setUserImage => 'Définir l\'image de l\'utilisateur';

  @override
  String get setAssistantImage => 'Définir l\'image de l\'assistant';

  @override
  String get loadUserImage => 'Charger l\'image de l\'utilisateur';

  @override
  String get loadAssistantImage => 'Charger l\'image de l\'assistant';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get assistantName => 'Nom de l\'assistant';

  @override
  String get user => 'Utilisateur';

  @override
  String get assistant => 'Assistant';

  @override
  String get cancel => 'Annuler';

  @override
  String get aiEcosystem => 'Écosystème IA';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Modèle Llama CPP';

  @override
  String get remoteModel => 'Modèle distant';

  @override
  String get refreshRemoteModels => 'Rafraîchir les modèles distants';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Rechercher sur le réseau local';

  @override
  String get localNetworkSearchTitle => 'Recherche sur le réseau local';

  @override
  String get localNetworkSearchContent => 'Cette fonctionnalité nécessite des permissions supplémentaires pour rechercher des instances Ollama sur votre réseau local.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Paramètres du modèle';

  @override
  String get addParameter => 'Ajouter un paramètre';

  @override
  String get removeParameter => 'Supprimer le paramètre';

  @override
  String get saveParameters => 'Enregistrer les paramètres';

  @override
  String get importParameters => 'Importer les paramètres';

  @override
  String get exportParameters => 'Exporter les paramètres';

  @override
  String get selectAiEcosystem => 'Sélectionner l\'écosystème IA';

  @override
  String get selectRemoteModel => 'Sélectionner un modèle distant';

  @override
  String get selectThemeMode => 'Sélectionner le mode du thème';

  @override
  String get themeMode => 'Mode du thème';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeSeedColor => 'Couleur de base du thème';

  @override
  String get editMessage => 'Modifier le message';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String aiSettings(String aiType) {
    return 'Paramètres de $aiType';
  }

  @override
  String get userSettings => 'Paramètres utilisateur';

  @override
  String get assistantSettings => 'Paramètres de l\'assistant';

  @override
  String get systemSettings => 'Paramètres système';

  @override
  String get systemPrompt => 'Prompt système';

  @override
  String get clearChats => 'Effacer les discussions';

  @override
  String get resetSettings => 'Réinitialiser les paramètres';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutContent => 'Maid est une application multiplateforme gratuite et open-source permettant d\'interagir avec les modèles Llama.cpp en local et à distance avec Ollama, Mistral, Google Gemini et OpenAI. Maid prend en charge les cartes de personnages Sillytavern pour interagir avec vos personnages préférés. Vous pouvez télécharger une liste de modèles sélectionnés directement depuis Huggingface. Maid est distribuée sous la licence MIT et est fournie sans aucune garantie, explicite ou implicite. Maid n\'est affiliée à Huggingface, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft ou toute autre entreprise proposant un modèle compatible avec cette application.';

  @override
  String get leadMaintainer => 'Responsable principal';

  @override
  String get apiKey => 'Clé API';

  @override
  String get baseUrl => 'URL de base';

  @override
  String get clearPrompt => 'Effacer le prompt';

  @override
  String get submitPrompt => 'Envoyer le prompt';

  @override
  String get stopPrompt => 'Arrêter le prompt';

  @override
  String get typeMessage => 'Tapez un message...';

  @override
  String get code => 'Code';

  @override
  String copyLabel(String label) {
    return 'Copier $label';
  }

  @override
  String labelCopied(String label) {
    return '$label copié dans le presse-papiers!';
  }

  @override
  String get debugTitle => 'Débogage';

  @override
  String get warning => 'Avertissement';

  @override
  String get nsfwWarning => 'Ce modèle a été intentionnellement conçu pour produire du contenu NSFW. Cela peut inclure du contenu sexuel explicite ou violent impliquant de la torture, du viol, du meurtre et/ou des comportements sexuellement déviants. Si vous êtes sensible à ces sujets, ou si leur discussion enfreint les lois locales, NE CONTINUEZ PAS.';

  @override
  String get login => 'Se connecter';

  @override
  String get logout => 'Déconnexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get resetCode => 'Code de réinitialisation';

  @override
  String get resetCodeSent => 'Un code de réinitialisation a été envoyé à votre email.';

  @override
  String get sendResetCode => 'Envoyer le code de réinitialisation';

  @override
  String get sendAgain => 'Renvoyer';

  @override
  String get required => 'Requis';

  @override
  String get invalidEmail => 'Veuillez entrer un email valide';

  @override
  String get invalidUserName => 'Doit contenir 3 à 24 caractères, alphanumériques ou soulignés';

  @override
  String get invalidPasswordLength => 'Minimum 8 caractères';

  @override
  String get invalidPassword => 'Inclure majuscules, minuscules, chiffres et symboles';

  @override
  String get passwordNoMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get success => 'Succès';

  @override
  String get registrationSuccess => 'Inscription réussie';

  @override
  String get resetSuccess => 'Votre mot de passe a été réinitialisé avec succès.';

  @override
  String get emailVerify => 'Veuillez vérifier votre email pour la vérification.';
}
