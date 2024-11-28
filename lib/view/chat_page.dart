import 'package:flutter/material.dart';
import 'package:despesa_digital/utils/app_colors.dart';
import 'package:despesa_digital/utils/app_text_styles.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:despesa_digital/controller/gemini_serviceChat.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  final GeminiServiceChat _geminiServiceChat = GeminiServiceChat();

  void _sendMessage(String message) async {
    setState(() {
      _messages.add({"sender": "Você", "message": message});
    });

    String response = await _geminiServiceChat.handleFinanceQuestion(message);

    setState(() {
      _messages.add({"sender": "IA", "message": response});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient header
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(500, 30),
                  bottomRight: Radius.elliptical(500, 30),
                ),
              ),
              height: 120.h,
            ),
          ),
          // Header label
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 60.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 32.h),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat de Finanças',
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          // Chat body
          Positioned(
            top: 162.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        bool isUserMessage = message['sender'] == "Você";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Align(
                            alignment:
                            isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? AppColors.purpledarkOne
                                    : AppColors.purpledarkOne,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: _buildMessageText(
                                  message['message'] ?? "", isUserMessage),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Digite sua pergunta sobre finanças...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: AppColors.purplelightMain),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            FocusScope.of(context).unfocus();
                            _sendMessage(_controller.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(String message, bool isUserMessage) {
    final parts = message.split(RegExp(r'(\*\*[^*]+\*\*)'));

    return RichText(
      text: TextSpan(
        children: parts.map((part) {
          if (part.startsWith('**') && part.endsWith('**')) {
            return TextSpan(
              text: part.replaceAll('**', ''),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            );
          } else {
            return TextSpan(
              text: part,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
