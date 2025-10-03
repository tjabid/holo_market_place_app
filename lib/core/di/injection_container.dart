import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../network/api_client.dart';
final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());
  
}
