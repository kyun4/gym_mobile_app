import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get dbUrl => dotenv.env['DB_URL'] ?? "";
  static String get emailServerPass => dotenv.env['GMAIL_SERVER_PASS'] ?? "";
  static String get emailServer => dotenv.env['GMAIL_SERVER'] ?? "";
}
