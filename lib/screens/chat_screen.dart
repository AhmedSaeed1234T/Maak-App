import 'dart:async';
import 'package:abokamall/controllers/ChatController.dart';
import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/models/ChatMessage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserImage;

  const ChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserImage,
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
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= (maxScroll - 100) &&
          _chatController.hasMore &&
          !_chatController.isLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    // In reverse mode, adding items to the end (top) doesn't require scroll adjustment
    // as long as we are not at the very top (which we aren't, we trigger before)
    // However, since offset is from Bottom, adding more items increases maxScrollExtent
    // but current offset stays same (distance from bottom), so we stay at same message.
    await _chatController.loadHistory(widget.targetUserId);
  }

  void _onMessageReceived() {
    if (mounted) {
      setState(() {}); // Refresh UI when controller notifies
      // If we are at the bottom (newest), scroll to 0 to show new message
      if (_scrollController.hasClients && _scrollController.offset < 100) {
        _scrollToBottom();
      }
    }
  }

  Future<void> _connectAndLoad() async {
    _chatController.prepareForChat(widget.targetUserId);
    await _chatController.connect();
    await _chatController.loadHistory(widget.targetUserId, refresh: true);
    // No need to scroll, it starts at 0 (Bottom/Newest) by default in reverse list
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // 0 is bottom in reverse list
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF13A9F6)),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('تعديل الرسالة', textAlign: TextAlign.right),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
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
              child: const Text(
                'حفظ',
                style: TextStyle(color: Color(0xFF13A9F6)),
              ),
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
      return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
    }
  }

  /// Format time for message timestamp
  String _formatMessageTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[100],
                backgroundImage:
                    widget.targetUserImage != null &&
                        widget.targetUserImage!.isNotEmpty
                    ? CachedNetworkImageProvider(widget.targetUserImage!)
                    : null,
                child:
                    widget.targetUserImage == null ||
                        widget.targetUserImage!.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[400], size: 24)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.targetUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: getIt<PresenceController>().onlineUsers,
                    builder: (context, onlineUsers, _) {
                      final isOnline = onlineUsers.contains(
                        widget.targetUserId,
                      );
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'متصل الآن' : 'غير متصل',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOnline ? Colors.green : Colors.grey[400],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount:
                  _chatController.messages.length +
                  (_chatController.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // If loading, show indicator at the END (Top in reverse)
                if (_chatController.isLoadingMore &&
                    index == _chatController.messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                // If loading, and we are not the loader, normal index
                final actualIndex = index;
                final msg = _chatController.messages[actualIndex];
                final isThem = msg.senderId == widget.targetUserId;
                final isMe = msg.senderId == _chatController.myUserId;

                // Date Header Logic for [Newest ... Oldest] list in Reverse View
                // Show header if this message is the LAST one (Oldest)
                // OR if the NEXT message (index + 1, Older) is from a different day
                bool showDateHeader = false;
                final isLastMessage =
                    actualIndex == _chatController.messages.length - 1;

                if (isLastMessage) {
                  showDateHeader = true;
                } else {
                  final nextMsg = _chatController.messages[actualIndex + 1];
                  if (!_isSameDay(msg.timestamp, nextMsg.timestamp)) {
                    showDateHeader = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateHeader)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDateHeader(msg.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    Align(
                      alignment: isThem
                          ? Alignment
                                .centerRight // RTL: Right is start (them)
                          : Alignment.centerLeft, // RTL: Left is end (me)
                      child: GestureDetector(
                        onLongPress: isMe
                            ? () => _showMessageOptions(msg, context)
                            : null,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? primary : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(20),
                              bottomRight: isMe
                                  ? const Radius.circular(20)
                                  : const Radius.circular(0),
                            ),
                            boxShadow: isMe
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                            border: isMe
                                ? null
                                : Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 0.5,
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isMe ? Colors.white : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatMessageTime(msg.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[500],
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ],
                                ],
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
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "اكتب رسالة...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
