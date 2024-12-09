import 'package:neo4j_http_client/neo4j_http_client.dart';

class Neo4jConnection {
  static const String protocol = 'http'; // or 'https'
  static const String host = 'localhost';
  static const int port = 7474; // Typical HTTP port
  static const String database = 'neo4j'; // Default database name
  static const String username = 'neo4j';
  static const String password = 'KarlPogi5758';

  // Method to create and return the Neo4j client
  static Client getClient() {
    final uri = Uri.parse('$protocol://$host:$port/db/data');
    return Client(
      url: uri,
      database: database,
      username: username,
      password: password,
    );
  }
}
