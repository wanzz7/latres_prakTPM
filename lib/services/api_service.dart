// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // Endpoint mapping
  static String _endpointFor(String type) {
    switch (type) {
      case 'news':
        return 'articles';
      case 'blog':
        return 'blogs';
      case 'report':
        return 'reports';
      default:
        return 'articles';
    }
  }

  /// Fetch list of articles/blogs/reports
  static Future<List<Article>> fetchList(String type, {int limit = 10}) async {
    final endpoint = _endpointFor(type);
    final url = Uri.parse('$_baseUrl/$endpoint/?limit=$limit');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }

  /// Fetch detail by id
  static Future<Article> fetchDetail(String type, int id) async {
    final endpoint = _endpointFor(type);
    final url = Uri.parse('$_baseUrl/$endpoint/$id/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Article.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail: ${response.statusCode}');
    }
  }
}
