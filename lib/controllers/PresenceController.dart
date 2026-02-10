import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/apiclient.dart';

class PresenceController extends ChangeNotifier {
  final TokenService _tokenService = getIt<TokenService>();
  final ApiClient _apiClient = getIt<ApiClient>();
  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Expose online users set as a ValueNotifier for easy UI binding
  final ValueNotifier<Set<String>> onlineUsers = ValueNotifier({});

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _tokenService.getAccessToken();
    if (token == null) return;

    // 1. Initial Fetch of online users
    await _fetchInitialOnlineUsers();

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

    // 2. Listen for real-time updates (matching backend: UserStatusChanged)
    _hubConnection?.on("UserStatusChanged", (args) {
      if (args != null && args.length >= 2) {
        final userId = args[0]?.toString();
        final status = args[1]?.toString();
        if (userId != null && status != null) {
          final set = {...onlineUsers.value};
          if (status.toLowerCase() == 'online') {
            set.add(userId);
          } else {
            set.remove(userId);
          }
          onlineUsers.value = set;
          notifyListeners();
        }
      }
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      notifyListeners();
    });

    try {
      await _hubConnection?.start();
      _isConnected = true;

      // ✅ Explicitly mark current user as online locally
      final myId = await _tokenService.getUserId();
      debugPrint("Presence: Connection successful. Fetched myId: $myId");
      if (myId != null) {
        final set = {...onlineUsers.value};
        set.add(myId);
        onlineUsers.value = set;
        debugPrint(
          "Presence: Added self to onlineUsers set. Current set: ${onlineUsers.value}",
        );
      }

      notifyListeners();
      debugPrint("Presence SignalR Connected (myId=$myId)");
    } catch (e) {
      debugPrint('PresenceHub connect error: $e');
    }
  }

  Future<void> _fetchInitialOnlineUsers() async {
    try {
      final response = await _apiClient.get("/Chat/online-users");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        onlineUsers.value = data.map((e) => e.toString()).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching initial online users: $e");
    }
  }

  bool isUserOnline(dynamic userId) {
    if (userId == null) return false;
    final idStr = userId.toString();
    if (idStr.isEmpty) return false;
    return onlineUsers.value.contains(idStr);
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
    } catch (_) {}
    _isConnected = false;
    notifyListeners();
  }
}
