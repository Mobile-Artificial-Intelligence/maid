part of 'package:maid/main.dart';

class ArtificialIntelligenceContext {
  String? model;
  Map<String, dynamic> overrides;

  ArtificialIntelligenceContext({
    this.model, 
    Map<String, dynamic>? overrides
  }) : overrides = overrides ?? {};

  factory ArtificialIntelligenceContext.fromMap(Map<String, dynamic> map) => ArtificialIntelligenceContext(
    model: map['model'],
    overrides: map['overrides'],
  );

  Map<String, dynamic> toMap() => {
    'model': model,
    'overrides': overrides,
  };

  Future<void> save(ArtificialIntelligenceEcosystem ecosystem) async {
    final prefs = await SharedPreferences.getInstance();

    final key = ecosystem.name;

    final contextString = jsonEncode(toMap());

    prefs.setString(key, contextString);
  }

  static Future<ArtificialIntelligenceContext?> load(ArtificialIntelligenceEcosystem ecosystem) async {
    final prefs = await SharedPreferences.getInstance();

    final key = ecosystem.name;

    final contextString = prefs.getString(key);

    if (contextString == null) return null;

    final contextMap = jsonDecode(contextString);

    return ArtificialIntelligenceContext.fromMap(contextMap);
  }
}

class RemoteArtificialIntelligenceContext extends ArtificialIntelligenceContext {
  String? baseUrl;
  String? apiKey;

  RemoteArtificialIntelligenceContext({
    this.baseUrl, 
    this.apiKey, 
    super.model, 
    super.overrides
  });

  factory RemoteArtificialIntelligenceContext.fromMap(Map<String, dynamic> map) => RemoteArtificialIntelligenceContext(
    model: map['model'],
    overrides: map['overrides'],
    baseUrl: map['base_url'],
    apiKey: map['api_key'],
  );

  @override
  Map<String, dynamic> toMap() => {
    'model': model,
    'overrides': overrides,
    'base_url': baseUrl,
    'api_key': apiKey,
  };

  @override
  Future<void> save(ArtificialIntelligenceEcosystem ecosystem) async {
    final prefs = await SharedPreferences.getInstance();

    final key = ecosystem.name;

    final contextString = jsonEncode(toMap());

    prefs.setString(key, contextString);
  }

  static Future<RemoteArtificialIntelligenceContext?> load(ArtificialIntelligenceEcosystem ecosystem) async {
    final prefs = await SharedPreferences.getInstance();

    final key = ecosystem.name;

    final contextString = prefs.getString(key);

    if (contextString == null) return null;

    final contextMap = jsonDecode(contextString);

    return RemoteArtificialIntelligenceContext.fromMap(contextMap);
  }
}