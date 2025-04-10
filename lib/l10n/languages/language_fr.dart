import 'package:palm_analysis/l10n/languages/app_language.dart';

class LanguageFr implements AppLanguage {
  @override
  String get appName => 'Analyse de Chiromancie';
  
  @override
  String get appDescription => 'Découvrez votre avenir à partir des lignes de votre main';
  
  // Types de lignes de la main
  @override
  String get heartLine => 'Ligne de Coeur';
  
  @override
  String get headLine => 'Ligne de Tete';
  
  @override
  String get lifeLine => 'Ligne de Vie';
  
  @override
  String get fateLine => 'Ligne de Destin';
  
  @override
  String get sunLine => 'Ligne de Soleil';
  
  @override
  String get marriageLine => 'Ligne de Mariage';
  
  @override
  String get wealthLine => 'Ligne de Richesse';
  
  // Descriptions des lignes de la main
  @override
  Map<String, String> get lineDescriptions => {
    heartLine: 'La ligne de coeur montre votre vie émotionnelle, vos relations et votre santé émotionnelle.',
    headLine: 'La ligne de tête représente votre style de pensée, vos capacités mentales et votre style de communication.',
    lifeLine: 'La ligne de vie montre votre santé générale, votre énergie vitale et les événements importants de votre vie.',
    fateLine: 'La ligne de destin représente votre parcours professionnel, vos réalisations et votre but dans la vie.',
    sunLine: 'La ligne de soleil montre votre renommée, votre succès et votre potentiel créatif.',
    marriageLine: 'La ligne de mariage représente vos relations amoureuses significatives et leur qualité.',
    wealthLine: 'La ligne de richesse montre votre prospérité matérielle et votre potentiel de richesse.',
  };
  
  // Textes de l'écran d'accueil
  @override
  List<Map<String, String>> get onboardingContent => [
    {
      'title': 'Découvrez les Lignes de Votre Main',
      'description': 'Découvrez votre personnalité, votre passé et votre avenir à partir des lignes de votre main.',
    },
    {
      'title': 'Prenez une Photo',
      'description': 'Prenez une photo claire de votre paume ou importez-en une depuis la galerie.',
    },
    {
      'title': 'Analyse par IA',
      'description': 'La technologie d\'IA analyse vos lignes et fournit des interprétations personnalisées.',
    },
    {
      'title': 'Illuminez Votre Vie',
      'description': 'Découvrez les informations cachées dans vos lignes d\'amour, de carrière, de santé et de richesse.',
    },
  ];
  
  // Messages d'erreur
  @override
  String get errorTitle => 'Une Erreur s\'est Produite';
  
  @override
  String get generalError => 'Quelque chose s\'est mal passé. Veuillez réessayer.';
  
  @override
  String get tryAgain => 'Réessayer';
  
  @override
  String get appStartError => 'Échec du démarrage de l\'application';
  
  @override
  String get uiLoadError => 'Échec du chargement de l\'interface';
  
  @override
  String get contactDeveloper => 'Veuillez redémarrer l\'application ou contacter le développeur.';
  
  // Écran principal
  @override
  String get takePicture => 'Prendre une Photo';
  
  @override
  String get selectFromGallery => 'Sélectionner depuis la Galerie';
  
  @override
  String get analyzeHand => 'Analysez Votre Main';
  
  @override
  String get analysisHistory => 'Historique des Analyses';
  
  @override
  String get settings => 'Paramètres';
  
  // Écran d'analyse
  @override
  String get analyzing => 'Analyse en cours...';
  
  @override
  String get analysisComplete => 'Analyse Terminée';
  
  @override
  String get analysisError => 'Échec de l\'Analyse';
  
  @override
  String get saveAnalysis => 'Enregistrer l\'Analyse';
  
  @override
  String get shareAnalysis => 'Partager l\'Analyse';
  
  // Écran des paramètres
  @override
  String get settingsTitle => 'Paramètres';
  
  @override
  String get languageSettings => 'Paramètres de Langue';
  
  @override
  String get themeSettings => 'Paramètres de Thème';
  
  @override
  String get notificationSettings => 'Paramètres de Notification';
  
  @override
  String get aboutApp => 'À Propos de l\'Application';
  
  @override
  String get privacyPolicy => 'Politique de Confidentialité';
  
  @override
  String get termsOfService => 'Conditions d\'Utilisation';
  
  @override
  String get lightTheme => 'Thème Clair';
  
  @override
  String get darkTheme => 'Thème Sombre';
  
  @override
  String get systemTheme => 'Thème du Système';
  
  // Sélection de langue
  @override
  String get selectLanguage => 'Sélectionner la Langue';
  
  @override
  String get turkish => 'Turc';
  
  @override
  String get english => 'Anglais';
  
  @override
  String get german => 'Allemand';
  
  @override
  String get french => 'Français';
  
  @override
  String get spanish => 'Espagnol';
  
  // Camera guide overlay
  @override
  String get handDetection => 'Détection de la Main';
  
  @override
  String get handPosition => 'Position de la Main';
  
  @override
  String get lightLevel => 'Niveau de Lumière';
  
  @override
  String get placeYourHand => 'Placez votre paume dans cette zone';
  
  // History screen
  @override
  String get historyTitle => 'Historique des Analyses';
  
  @override
  String get noAnalysisYet => 'Aucune analyse pour le moment';
  
  @override
  String get analyzeHandFromHome => 'Retournez à l\'accueil pour analyser votre paume';
  
  @override
  String get goToHome => 'Retour à l\'Accueil';
  
  @override
  String get deleteAllAnalyses => 'Supprimer Toutes les Analyses';
  
  @override
  String get deleteAllConfirmation => 'Toutes vos analyses seront supprimées. Cette action ne peut pas être annulée. Voulez-vous continuer?';
  
  @override
  String get cancel => 'Annuler';
  
  @override
  String get deleteAll => 'Tout Supprimer';
  
  @override
  String get analysisSaved => 'Analyse enregistrée';
  
  @override
  String get analysisDetail => 'Détails de l\'Analyse';
  
  @override
  String get palmReadingAnalysis => 'Analyse de Chiromancie';
  
  // Message système pour les requêtes API Claude
  @override
  String get systemPrompt => '''
Vous êtes un expert en chiromancie qui peut analyser les lignes de la main. Analysez l'image de la paume que je vous envoie et fournissez des informations sur ces lignes :

1. Ligne de Coeur : Informations sur la vie émotionnelle, les relations et la santé émotionnelle
2. Ligne de Tete : Style de pensée, capacités mentales et style de communication
3. Ligne de Vie : Santé générale, énergie vitale et événements importants de la vie
4. Ligne de Destin : Carrière, réalisations et but dans la vie
5. Ligne de Mariage : Relations amoureuses significatives
6. Ligne de Richesse : Prospérité matérielle et potentiel de richesse

Analysez chaque ligne en détail et faites des interprétations personnalisées pour la personne. Votre réponse devrait comporter entre 300 et 500 mots et sembler personnalisée.

Interprétez avec une perspective mystique plutôt que scientifique. Formatez votre réponse en Markdown avec des titres pour chaque section. Si l\'utilisateur envoie une image autre qu\'une image de paume, donnez une réponse humoristique, dites-lui de quoi il s\'agit et demandez-lui de prendre une image de paume !

IMPORTANT : Même si la photo n\'est pas parfaitement claire, essayez de commenter ce que vous pouvez voir. Même si vous ne pouvez pas voir clairement certaines lignes, fournissez un commentaire aussi détaillé que possible sur les lignes que vous pouvez voir. Essayez de fournir une analyse basée sur les lignes que vous pouvez voir même si la qualité de l\'image de la paume est faible. Ne suggérez à l\'utilisateur de prendre une photo plus claire que si vous ne pouvez voir aucune ligne du tout.
''';
}
