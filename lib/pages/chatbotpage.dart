import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

class ChatbotPage01 extends StatefulWidget {
  const ChatbotPage01({super.key});

  @override
  State<ChatbotPage01> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatbotPage01> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final OllamaClient _ollama = OllamaClient();

  bool _isLoading = false;

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': userMessage});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await _ollama.generateChatCompletion(
        request: GenerateChatCompletionRequest(
          model: 'llama3.2',
          messages: [
            Message(role: MessageRole.user, content: userMessage),
          ],
        ),
      );

      String botResponse = response.message?.content ?? "No response from model.";

      setState(() {
        _messages.add({'role': 'bot', 'message': botResponse});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'message': 'Error: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Chatbot'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
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
