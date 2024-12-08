import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Neo4jConnectionConfig {
  static const String protocol = 'http'; // or 'https'
  static const String host = 'localhost';
  static const int port = 7474; // Typical HTTP port
  static const String database = 'neo4j'; // Default database name
  static const String username = 'neo4j';
  static const String password = 'KarlPogi5758';
}

class Neo4jConnectionHelper {
  // Singleton instance
  static final Neo4jConnectionHelper _instance = Neo4jConnectionHelper._internal();
  factory Neo4jConnectionHelper() => _instance;
  Neo4jConnectionHelper._internal();

  // Construct full URL dynamically
  String get _baseUrl {
    return '${Neo4jConnectionConfig.protocol}://'
           '${Neo4jConnectionConfig.host}:'
           '${Neo4jConnectionConfig.port}'
           '/db/${Neo4jConnectionConfig.database}/tx/commit';
  }

  // Generate headers with careful encoding
  Map<String, String> get _headers {
    final credentials = '${Neo4jConnectionConfig.username}:${Neo4jConnectionConfig.password}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Basic $encodedCredentials',
      HttpHeaders.acceptHeader: 'application/json',
      // Additional headers to prevent parsing issues
      'Connection': 'Keep-Alive',
      'User-Agent': 'Flutter Neo4j Client',
    };
  }

  // Comprehensive query execution method with advanced error handling
  Future<dynamic> executeQuery({
    required String cypherQuery,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Detailed logging
      print('Executing Query URL: $_baseUrl');
      print('Cypher Query: $cypherQuery');
      print('Parameters: $parameters');

      // Create request body
      final requestBody = jsonEncode({
        'statements': [
          {
            'statement': cypherQuery,
            'parameters': parameters ?? {},
            'resultDataContents': ['row', 'graph']
          }
        ]
      });

      // Execute request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: requestBody,
      );

      // Log response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Comprehensive error handling
      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('Neo4j Connection Error: $e');
      print('Detailed Error: $stackTrace');
      rethrow;
    }
  }

  // Advanced response handling
  dynamic _handleResponse(http.Response response) {
    // Successful response
    if (response.statusCode == 200) {
      try {
        final responseBody = jsonDecode(response.body);
        
        // Check for Neo4j specific errors
        if (responseBody.containsKey('errors') && 
            (responseBody['errors'] as List).isNotEmpty) {
          throw Exception('Neo4j Query Error: ${responseBody['errors']}');
        }

        // Parse results
        return _parseNeo4jResponse(responseBody);
      } catch (e) {
        throw Exception('Failed to parse Neo4j response: $e');
      }
    }

    // Handle different HTTP error codes
    switch (response.statusCode) {
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: Check your credentials');
      case 403:
        throw Exception('Forbidden: Insufficient permissions');
      case 404:
        throw Exception('Not Found: Check your Neo4j endpoint');
      case 500:
        throw Exception('Internal Server Error: ${response.body}');
      default:
        throw Exception('Unexpected error: ${response.statusCode} - ${response.body}');
    }
  }

  // Enhanced response parsing
  dynamic _parseNeo4jResponse(Map<String, dynamic> responseBody) {
    final List results = responseBody['results'] ?? [];
    
    if (results.isEmpty) return null;

    final columns = results[0]['columns'] ?? [];
    final data = results[0]['data'] ?? [];

    final parsedResults = data.map((row) {
      final Map<String, dynamic> rowData = {};
      for (int i = 0; i < columns.length; i++) {
        rowData[columns[i]] = row['row'][i];
      }
      return rowData;
    }).toList();

    return parsedResults;
  }

  // Connection test method
  Future<bool> testConnection() async {
    try {
      final result = await executeQuery(
        cypherQuery: 'RETURN 1 as test',
      );
      print('Connection Test Successful: $result');
      return true;
    } catch (e) {
      print('Connection Test Failed: $e');
      return false;
    }
  }
}


