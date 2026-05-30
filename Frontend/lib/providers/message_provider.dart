import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/api_service.dart';
import '../core/auth_manager.dart';
import '../core/constants.dart';
import '../models/message.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  StompClient? _stompClient;
  bool _connected = false;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get connected => _connected;

  // REST: Direkt mesaj geçmişini yükle
  Future<void> loadDirectMessages(int otherUserId) async {
    final data = await ApiService.get('${AppConstants.messages}/direct/$otherUserId');
    _messages.clear();
    _messages.addAll((data as List).map((e) => Message.fromJson(e)));
    notifyListeners();
  }

  // REST: Proje mesaj geçmişini yükle
  Future<void> loadProjectMessages(int projectId) async {
    final data = await ApiService.get('${AppConstants.messages}/project/$projectId');
    _messages.clear();
    _messages.addAll((data as List).map((e) => Message.fromJson(e)));
    notifyListeners();
  }

  // REST: Mesaj gönder (WebSocket olmadan)
  Future<void> sendMessageRest(Message msg) async {
    final data = await ApiService.post(AppConstants.messages, msg.toJson());
    _messages.add(Message.fromJson(data));
    notifyListeners();
  }

  // WebSocket: Bağlan
  Future<void> connectWebSocket({
    int? projectId,
    int? currentUserId,
  }) async {
    final token = await AuthManager.getToken();

    _stompClient = StompClient(
      config: StompConfig(
        url: AppConstants.wsEndpoint,
        onConnect: (frame) {
          _connected = true;
          notifyListeners();

          if (projectId != null) {
            _stompClient!.subscribe(
              destination: AppConstants.wsProjectTopic(projectId.toString()),
              callback: (frame) {
                if (frame.body != null) {
                  final msg = Message.fromJson(jsonDecode(frame.body!));
                  _messages.add(msg);
                  notifyListeners();
                }
              },
            );
          }

          if (currentUserId != null) {
            _stompClient!.subscribe(
              destination: AppConstants.wsUserQueue(currentUserId.toString()),
              callback: (frame) {
                if (frame.body != null) {
                  final msg = Message.fromJson(jsonDecode(frame.body!));
                  _messages.add(msg);
                  notifyListeners();
                }
              },
            );
          }
        },
        onDisconnect: (_) {
          _connected = false;
          notifyListeners();
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient!.activate();
  }

  // WebSocket: Proje mesajı gönder
  void sendProjectMessage(int projectId, String content) {
    if (_stompClient == null || !_connected) return;
    _stompClient!.send(
      destination: AppConstants.wsProjectDest,
      body: jsonEncode({
        'content': content,
        'messageType': 'PROJECT',
        'projectId': projectId,
      }),
    );
  }

  // WebSocket: Direkt mesaj gönder
  void sendDirectMessage(int receiverId, String content) {
    if (_stompClient == null || !_connected) return;
    _stompClient!.send(
      destination: AppConstants.wsDirectDest,
      body: jsonEncode({
        'content': content,
        'messageType': 'DIRECT',
        'receiverId': receiverId,
      }),
    );
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _connected = false;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
