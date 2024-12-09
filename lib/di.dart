import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health_management/Connection/Neo4jConnection.dart';
import 'package:health_management/Service/TokenService.dart';
import 'package:health_management/Service/UserService.dart';


final GetIt sl = GetIt.instance;

void setupDI() {
  sl.registerLazySingleton(() => Neo4jConnection.getClient());

  // Register the UserService and inject Neo4jConnection
  sl.registerLazySingleton<UserService>(() => UserService());
  sl.registerLazySingleton<TokenService>(() => TokenService());
}
