import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<({String text, bool isUser})> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // No API init needed
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add((text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Local Logic
    final response = _getLocalResponse(text);

    if (mounted) {
      setState(() {
        _messages.add((text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _getLocalResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('club')) return "You can view and join clubs in the 'Clubs' tab. We have Technical, Cultural, and Sports clubs available.";
    if (lower.contains('event') || lower.contains('hackathon')) return "Check the 'Events' or 'Growth' tab for upcoming hackathons and notifications.";
    if (lower.contains('lost') || lower.contains('found')) return "Please report lost items in the 'Lost & Found' section accessible from the Home screen.";
    if (lower.contains('exam') || lower.contains('result')) return "Exam schedules and results are usually posted in the 'Vault' or 'Events' section.";
    if (lower.contains('notes') || lower.contains('syllabus')) return "Study materials and regulations (R23/R24) are available in the 'Vault' tab.";
    if (lower.contains('hello') || lower.contains('hi')) return "Hello! How can I assist you with MVGR NexUs today?";
    if (lower.contains('who are you')) return "I am Nexa, your virtual campus assistant.";
    return "I can help with Clubs, Events, Vault (Notes), and Campus Radio. Please be specific!";
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Nexa Support', style: TextStyle(fontSize: 16)),
                   Text('Virtual Assistant', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? Colors.grey[900] : Colors.deepPurple.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ask me anything about MVGR NexUs!',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.deepPurple.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Area
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _ChatBubble(
                        text: msg.text,
                        isUser: msg.isUser,
                      );
                    },
                  ),
          ),

          // Input Area
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(minHeight: 2, color: Colors.deepPurple),
            ),
            
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
