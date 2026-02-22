import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiroute.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRTestPage extends StatefulWidget {
  const SignalRTestPage({super.key});

  @override
  _SignalRTestPageState createState() => _SignalRTestPageState();
}

class _SignalRTestPageState extends State<SignalRTestPage> {
  late HubConnection hubConnection;
  final List<String> logs = [];

  @override
  void initState() {
    super.initState();

    hubConnection = HubConnectionBuilder()
        .withUrl(
          'http://localhost:5095/chatHub',
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await getIt<TokenService>().getAccessToken() ?? "",
          ),
        )
        .build();

    hubConnection.on('ReceiveMessage', (parameters, [hubConn]) {
      final senderId = parameters?[0] ?? 'unknown';
      final content = parameters?[1] ?? '';
      setState(() => logs.add('Message from $senderId: $content'));
    });

    hubConnection.on('UserStatusChanged', (parameters, [hubConn]) {
      final userId = parameters?[0] ?? 'unknown';
      final status = parameters?[1] ?? '';
      setState(() => logs.add('User $userId is $status'));
    });

    hubConnection
        .start()
        ?.then((_) {
          setState(() => logs.add('Connected to Hub'));
        })
        .catchError((error) {
          setState(() => logs.add('Connection error: $error'));
        });
  }

  void _onReceiveMessage(
    List<Object>? parameters, [
    HubConnection? connection,
  ]) {
    final senderId = parameters?[0] ?? 'unknown';
    final content = parameters?[1] ?? '';
    setState(() => logs.add('Message from $senderId: $content'));
  }

  void _onUserStatusChanged(
    List<Object>? parameters, [
    HubConnection? connection,
  ]) {
    final userId = parameters?[0] ?? 'unknown';
    final status = parameters?[1] ?? '';
    setState(() => logs.add('User $userId is $status'));
  }

  void sendTestMessage() async {
    try {
      await hubConnection.invoke(
        'SendMessage',
        args: ['receiverId', 'Hello from Flutter test'],
      );
      setState(() => logs.add('Sent test message'));
    } catch (e) {
      setState(() => logs.add('Send error: $e'));
    }
  }

  @override
  void dispose() {
    hubConnection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SignalR Test')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: sendTestMessage,
            child: Text('Send Test Message'),
          ),
          Expanded(
            child: ListView(children: logs.map((l) => Text(l)).toList()),
          ),
        ],
      ),
    );
  }
}
