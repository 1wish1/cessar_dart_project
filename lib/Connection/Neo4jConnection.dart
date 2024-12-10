import 'package:neo4j_http_client/neo4j_http_client.dart';

class Neo4jConnection {
  static const String protocol = 'http'; 
  static const String host = 'localhost';
  static const int port = 7474; 
  static const String database = 'neo4j'; 
  static const String username = 'neo4j';
  static const String password = 'KarlPogi5758';

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
