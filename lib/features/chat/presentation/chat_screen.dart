import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/chat_service.dart';
import '../models/chat_models.dart';

class ChatScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  const ChatScreen({
    super.key,
    required this.trainerId,
    required this.trainerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentUserId = "user_123";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? "Sporcu";
    _currentUserId = name.replaceAll(' ', '').toLowerCase();
    
    try {
      final history = await ChatService().getMessages(widget.trainerId, _currentUserId);
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      senderId: _currentUserId,
      receiverId: widget.trainerId,
      content: text,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    final success = await ChatService().sendMessage(newMessage);
    if (!success) {
      debugPrint("Failed to send message to API");
    } else {
      _simulateTrainerReply();
    }
  }

  void _simulateTrainerReply() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final reply = ChatMessage(
        senderId: widget.trainerId,
        receiverId: _currentUserId,
        content: "İletini aldım şampiyon! Antrenmana tam gaz devam et, takipteyim. 🥊🔥",
        timestamp: DateTime.now().toIso8601String(),
      );

      setState(() {
        _messages.add(reply);
      });
      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.tealAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${widget.trainerName} hocandan mesaj var!",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E24),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trainerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Colors.tealAccent),
                SizedBox(width: 6),
                Text("Çevrimiçi (Hoca)", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _buildChatBubble(msg, isMe, isDark);
                    },
                  ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg, bool isMe, bool isDark) {
    final bubbleColor = isMe
        ? Colors.tealAccent
        : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[300]);
    final textColor = isMe ? Colors.black87 : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          msg.content,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    final fieldBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fieldBg,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Hocana mesaj yaz...",
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.tealAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
