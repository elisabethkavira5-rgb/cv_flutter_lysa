import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../models/family_member.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/api-test/public',
  );
  final http.Client _client;
  Uri _uri(String path) => Uri.parse('$baseUrl/$path');

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Réponse invalide du serveur.');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true) {
      final errors = body['errors'];
      final detail = errors is Map ? errors.values.join('\n') : null;
      throw ApiException(
        detail?.isNotEmpty == true
            ? detail!
            : body['message']?.toString() ??
                  'Erreur API (${response.statusCode}).',
      );
    }
    return body;
  }

  Future<void> login(String email, String password) async {
    final response = await _client
        .post(
          _uri('accounts/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));
    _decode(response);
  }

  Future<void> register(String email, String password) async {
    final response = await _client
        .post(
          _uri('accounts/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));
    _decode(response);
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    final response = await _client
        .get(_uri('famille-membres'))
        .timeout(const Duration(seconds: 15));
    final data = _decode(response)['data'];
    if (data is! List) throw const ApiException('Liste des membres invalide.');
    return data
        .map(
          (item) =>
              FamilyMember.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> createFamilyMember(
    FamilyMember member, {
    PlatformFile? image,
  }) async {
    final response = image == null
        ? await _client
              .post(
                _uri('famille-membres'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(member.toJson()),
              )
              .timeout(const Duration(seconds: 15))
        : await _sendMultipart('famille-membres', member, image);
    _decode(response);
  }

  Future<void> updateFamilyMember(
    FamilyMember member, {
    PlatformFile? image,
  }) async {
    final response = image == null
        ? await _client
              .put(
                _uri('famille-membres/${member.id}'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(member.toJson()),
              )
              .timeout(const Duration(seconds: 15))
        : await _sendMultipart('famille-membres/${member.id}', member, image);
    _decode(response);
  }

  Future<http.Response> _sendMultipart(
    String path,
    FamilyMember member,
    PlatformFile image,
  ) async {
    final bytes = await image.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      throw const ApiException('L’image ne doit pas dépasser 2 Mo.');
    }
    final request = http.MultipartRequest('POST', _uri(path))
      ..fields.addAll(member.toJson())
      ..files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: image.name),
      );
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    return http.Response.fromStream(streamed);
  }

  Future<void> deleteFamilyMember(int id) async {
    final response = await _client
        .delete(_uri('famille-membres/$id'))
        .timeout(const Duration(seconds: 15));
    _decode(response);
  }

  void close() => _client.close();
}
