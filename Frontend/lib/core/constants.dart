import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Çalışılan platforma göre otomatik URL seçimi
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Users
  static const String users = '/users';
  static const String usersSearch = '/users/search';

  // Projects
  static const String projects = '/projects';
  static const String myProjects = '/projects/mine';

  // Universities
  static const String universities = '/universities';

  // Skills
  static const String skills = '/skills';

  // Messages
  static const String messages = '/messages';

  // WebSocket
  static String get wsEndpoint {
    if (kIsWeb) return 'ws://localhost:8080/ws/chat/websocket';
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:8080/ws/chat/websocket';
    } catch (_) {}
    return 'ws://localhost:8080/ws/chat/websocket';
  }
  static const String wsDirectDest = '/app/chat.direct';
  static const String wsProjectDest = '/app/chat.project';
  static String wsUserQueue(String userId) => '/user/$userId/queue/messages';
  static String wsProjectTopic(String projectId) => '/topic/project/$projectId';
}
