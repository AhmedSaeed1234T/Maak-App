import 'dart:async';
import 'package:abokamall/controllers/ChatController.dart';
import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/models/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _chatController = getIt<ChatController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _connectAndLoad();
    _chatController.addListener(_onMessageReceived);
    _scrollController.addListener(_onScroll);
    _errorSubscription = _chatController.errorStream.listen((error) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'يجب كتابة رسالة قبل الإرسال',
          type: SnackBarType.warning,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 100 &&
        _chatController.hasMore &&
        !_chatController.isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final double previousScrollExtent =
        _scrollController.position.maxScrollExtent;
    final double previousScrollOffset = _scrollController.offset;

    await _chatController.loadHistory(widget.targetUserId);

    // Preserve scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double newScrollExtent =
            _scrollController.position.maxScrollExtent;
        final double delta = newScrollExtent - previousScrollExtent;
        _scrollController.jumpTo(previousScrollOffset + delta);
      }
    });
  }

  void _onMessageReceived() {
    if (mounted) {
      setState(() {}); // Refresh UI when controller notifies
      // Only scroll to bottom if we are near the bottom or it's a new message from ME
      // For now, simpler: scroll if it was NOT a loadMore update
      if (!_chatController.isLoadingMore) {
        _scrollToBottom();
      }
    }
  }

  Future<void> _connectAndLoad() async {
    // Prepare controller for this target to avoid showing previous messages
    _chatController.prepareForChat(widget.targetUserId);
    await _chatController.connect();
    await _chatController.loadHistory(widget.targetUserId, refresh: true);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatController.removeListener(_onMessageReceived);
    _scrollController.removeListener(_onScroll);
    _errorSubscription?.cancel();
    _chatController.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _chatController.sendMessage(widget.targetUserId, text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _showMessageOptions(ChatMessage msg, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('تعديل الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(msg);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  _chatController.deleteMessage(msg.id, widget.targetUserId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(ChatMessage msg) {
    final controller = TextEditingController(text: msg.content);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل الرسالة', textAlign: TextAlign.right),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty) {
                  _chatController.editMessage(
                    msg.id,
                    newContent,
                    widget.targetUserId,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Format date header for message grouping
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (_isSameDay(date, now)) {
      return 'اليوم';
    } else if (_isSameDay(date, yesterday)) {
      return 'أمس';
    } else {
      // Format as "Day, DD Month YYYY" in Arabic
      return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
    }
  }

  /// Format time for message timestamp
  String _formatMessageTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.targetUserName, style: const TextStyle(fontSize: 18)),
            ValueListenableBuilder<Set<String>>(
              valueListenable: getIt<PresenceController>().onlineUsers,
              builder: (context, onlineUsers, _) {
                final isOnline = onlineUsers.contains(widget.targetUserId);
                return Text(
                  isOnline ? 'متصل الآن' : 'غير متصل',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green[300] : Colors.grey[300],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  _chatController.messages.length +
                  (_chatController.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (_chatController.isLoadingMore && index == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final actualIndex = _chatController.isLoadingMore
                    ? index - 1
                    : index;
                final msg = _chatController.messages[actualIndex];
                final isThem = msg.senderId == widget.targetUserId;
                final isMe = msg.senderId == _chatController.myUserId;

                // Check if we need to show a date header
                // Messages are ordered oldest-to-newest, so we check if this is:
                // 1. The first message (oldest), OR
                // 2. The last message in the list (newest), OR
                // 3. The next message is from a different day
                bool showDateHeader = false;
                if (actualIndex == 0) {
                  // Always show header for the first (oldest) message
                  showDateHeader = true;
                } else if (actualIndex == _chatController.messages.length - 1) {
                  // Check if last message is from a different day than previous
                  final prevMsg = _chatController.messages[actualIndex - 1];
                  if (!_isSameDay(msg.timestamp, prevMsg.timestamp)) {
                    showDateHeader = true;
                  }
                } else {
                  // Check if next message is from a different day
                  final nextMsg = _chatController.messages[actualIndex + 1];
                  if (!_isSameDay(msg.timestamp, nextMsg.timestamp)) {
                    showDateHeader = true;
                  }
                }

                return Column(
                  children: [
                    // Date header
                    if (showDateHeader)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDateHeader(msg.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    // Message bubble
                    Align(
                      alignment: isThem
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: GestureDetector(
                        onLongPress: isMe
                            ? () => _showMessageOptions(msg, context)
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isThem ? Colors.grey[300] : Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isThem
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isThem ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMessageTime(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isThem
                                      ? Colors.black54
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
