import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/models/ChatMessage.dart';
import 'package:abokamall/helpers/apiroute.dart';

class ChatController extends ChangeNotifier {
  final TokenService _tokenService = getIt<TokenService>();
  final ApiClient _apiClient = getIt<ApiClient>();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  final List<ChatMessage> _messages = [];
  String? _targetUserId;
  String? myUserId;

  bool isLoadingMore = false;
  bool hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 50;

  final StreamController<String> _errorController =
      StreamController.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  List<ChatMessage> get messages => _messages;

  bool get isConnected => _isConnected;

  /// Prepare controller for a new chat target
  void prepareForChat(String targetUserId) {
    _messages.clear();
    _currentPage = 1;
    hasMore = true;
    _targetUserId = targetUserId;
    notifyListeners();
  }

  /// Connect to SignalR Hub
  Future<void> connect() async {
    if (_isConnected) return;

    myUserId = await _tokenService.getUserId();
    if (myUserId == null) {
      _errorController.add('User ID not found');
      return;
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          chatHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                (await _tokenService.getAccessToken()) ?? '',
            transport: HttpTransportType.WebSockets,
            skipNegotiation: false,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Listen for incoming messages
    _hubConnection?.on("ReceiveMessage", (args) {
      if (args != null && args.length >= 3) {
        final senderId = args[0].toString();
        final content = args[1].toString();
        final messageId = args[2].toString();
        if (_targetUserId != null &&
            (senderId == _targetUserId || senderId == myUserId)) {
          _messages.insert(
            0,
            ChatMessage(
              id: messageId,
              senderId: senderId,
              receiverId: senderId == myUserId
                  ? _targetUserId!
                  : myUserId!, // sender->receiver logic
              content: content,
              timestamp: DateTime.now(),
            ),
          );

          notifyListeners();
        }
      }
    });

    // ✅ Listen for sent message confirmation (when YOU send a message)
    _hubConnection?.on("MessageSent", (args) {
      if (args != null && args.length >= 3) {
        final messageId = args[0].toString();
        final receiverId = args[1].toString();
        final content = args[2].toString();

        // Add your own sent message to the list immediately
        if (_targetUserId == receiverId && myUserId != null) {
          _messages.insert(
            0,
            ChatMessage(
              id: messageId,
              senderId: myUserId!,
              receiverId: receiverId,
              content: content,
              timestamp: DateTime.now(),
            ),
          );

          notifyListeners();
        }
      }
    });

    // Listen for message updates
    _hubConnection?.on("MessageEdited", (args) {
      if (args != null && args.length >= 2) {
        final messageId = args[0].toString();
        final newContent = args[1].toString();
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(content: newContent);
          notifyListeners();
        }
      }
    });

    _hubConnection?.on("MessageDeleted", (args) {
      if (args != null && args.isNotEmpty) {
        final messageId = args[0].toString();
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
      }
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      notifyListeners();
    });

    try {
      await _hubConnection?.start();
      _isConnected = true;
      notifyListeners();
      debugPrint('ChatController: SignalR connected (myUserId=$myUserId)');
    } catch (e) {
      _errorController.add('SignalR connection error: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
    } catch (_) {}
    _isConnected = false;
    notifyListeners();
  }

  /// Send a new message
  Future<void> sendMessage(String targetUserId, String content) async {
    if (!_isConnected || myUserId == null) {
      _errorController.add('Not connected or user ID missing');
      return;
    }

    if (content.trim().isEmpty) {
      _errorController.add('Cannot send empty message');
      return;
    }

    try {
      await _hubConnection?.invoke(
        "SendMessage",
        args: [targetUserId, content],
      );
    } catch (e) {
      _errorController.add('Error sending message: $e');
    }
  }

  /// Edit a message
  Future<void> editMessage(
    String messageId,
    String newContent,
    String targetUserId,
  ) async {
    if (!_isConnected || myUserId == null) {
      _errorController.add('Not connected or user ID missing');
      return;
    }

    try {
      await _hubConnection?.invoke(
        "EditMessage",
        args: [messageId, newContent, targetUserId],
      );
    } catch (e) {
      _errorController.add('Error editing message: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId, String targetUserId) async {
    if (!_isConnected || myUserId == null) {
      _errorController.add('Not connected or user ID missing');
      return;
    }

    try {
      await _hubConnection?.invoke(
        "DeleteMessage",
        args: [messageId, targetUserId],
      );
    } catch (e) {
      _errorController.add('Error deleting message: $e');
    }
  }

  /// Load chat history with pagination
  Future<void> loadHistory(String targetUserId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore = true;
      _messages.clear();
    }

    if (!hasMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '/Chat/history/$targetUserId?pageNumber=$_currentPage&pageSize=$_pageSize',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((m) => ChatMessage.fromJson(m)).toList();
        if (messages.length < _pageSize) hasMore = false;
        _messages.addAll(messages);
        _currentPage++;
      } else {
        _errorController.add('Failed to load history');
      }
    } catch (e) {
      _errorController.add('Error loading history: $e');
    }

    isLoadingMore = false;
    notifyListeners();
  }
}
