import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';

class ChatScreen extends StatefulWidget {
  final int? projectId;
  final int? directUserId;
  final String title;

  const ChatScreen({
    super.key,
    this.projectId,
    this.directUserId,
    this.title = 'Sohbet',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<MessageProvider>();
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id;

    // Geçmiş mesajları yükle
    if (widget.projectId != null) {
      await provider.loadProjectMessages(widget.projectId!);
    } else if (widget.directUserId != null) {
      await provider.loadDirectMessages(widget.directUserId!);
    }

    // WebSocket bağlantısı
    await provider.connectWebSocket(
      projectId: widget.projectId,
      currentUserId: currentUserId,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<MessageProvider>();

    if (provider.connected) {
      // WebSocket üzerinden gönder
      if (widget.projectId != null) {
        provider.sendProjectMessage(widget.projectId!, text);
      } else if (widget.directUserId != null) {
        provider.sendDirectMessage(widget.directUserId!, text);
      }
    } else {
      // REST fallback
      final auth = context.read<AuthProvider>();
      provider.sendMessageRest(Message(
        id: 0,
        content: text,
        messageType: widget.projectId != null ? 'PROJECT' : 'DIRECT',
        senderId: auth.currentUser?.id ?? 0,
        senderName: auth.currentUser?.name ?? '',
        projectId: widget.projectId,
        receiverId: widget.directUserId,
      ));
    }

    _msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    context.read<MessageProvider>()
      ..disconnect()
      ..clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final myId = auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Consumer<MessageProvider>(
            builder: (_, provider, __) => Icon(
              Icons.circle,
              size: 12,
              color: provider.connected ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (_, provider, __) {
                final msgs = provider.messages;
                if (msgs.isEmpty) {
                  return const Center(
                    child: Text('Henüz mesaj yok. İlk mesajı sen gönder!',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final msg = msgs[i];
                    final isMe = msg.senderId == myId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // Mesaj input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sendMessage,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
