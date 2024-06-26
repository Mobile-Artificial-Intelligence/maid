import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:maid/classes/static/logger.dart';

class HuggingfaceModel {
  final String name;
  final String family;
  final String series;
  final String template;
  final String repo;
  final String branch;
  final Map<String, String> tags;

  HuggingfaceModel({
    required this.name,
    required this.family,
    required this.series,
    required this.template,
    required this.repo,
    required this.branch,
    required this.tags,
  });

  factory HuggingfaceModel.fromJson(Map<String, dynamic> json) {
    return HuggingfaceModel(
      name: json['name'],
      family: json['family'],
      series: json['series'],
      template: json['template'],
      repo: json['repo'],
      branch: json['branch'],
      tags: Map<String, String>.from(json['tags']),
    );
  }

  static Future<List<HuggingfaceModel>> getAll() async {
    try {
      final jsonString = await rootBundle.loadString('assets/huggingface_models.json');

      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((e) => HuggingfaceModel.fromJson(e)).toList();
    } 
    catch (e) {
      Logger.log('Error loading models: $e');
      return [];
    }
  }
}