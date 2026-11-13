/// AI Coach — ChatGPT-style interface with context-aware coaching.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';
import '../../models/chat_message.dart';
import '../../providers/providers.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    _textController.clear();

    // Add user message
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      userId: profile.uid,
      content: text,
      isUser: true,
    );
    ref.read(chatMessagesProvider.notifier).addMessage(userMsg);

    setState(() => _isTyping = true);
    _scrollToBottom();

    try {
      // Get AI response
      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.chatWithCoach(text, profile);

      // Add bot message with suggestions
      final botMsg = ChatMessage(
        id: const Uuid().v4(),
        userId: profile.uid,
        content: response,
        isUser: false,
        suggestions: _getSuggestions(text),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(botMsg);
    } catch (e) {
      // Show error as bot message
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        userId: profile.uid,
        content: '⚠️ Something went wrong. Please try again.',
        isUser: false,
        suggestions: ['Try again'],
      );
      ref.read(chatMessagesProvider.notifier).addMessage(errorMsg);
    }

    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  List<String> _getSuggestions(String lastMessage) {
    final lower = lastMessage.toLowerCase();
    if (lower.contains('eat') || lower.contains('food') || lower.contains('calorie')) {
      return ['Log this meal', 'What about dinner?', 'Show nutrition summary'];
    }
    if (lower.contains('workout') || lower.contains('exercise')) {
      return ['Start today\'s workout', 'Swap an exercise', 'Show my plan'];
    }
    if (lower.contains('progress') || lower.contains('stuck') || lower.contains('plateau')) {
      return ['Show my graphs', 'Adjust my plan', 'Increase volume'];
    }
    return ['Adjust today\'s workout', 'What should I eat?', 'Show my progress'];
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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FitAI Coach', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Always online • Knows your data',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return _TypingIndicator();
                }

                final msg = messages[index];
                return _ChatBubble(
                  message: msg,
                  onSuggestionTap: (s) => _sendMessage(s),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice input button
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.textTertiary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voice input coming soon!')),
                      );
                    },
                  ),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask your coach...',
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      style: AppTextStyles.body,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: AppColors.background, size: 20),
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onSuggestionTap;

  const _ChatBubble({required this.message, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy,
                      color: AppColors.accent, size: 16),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.accent : AppColors.card,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: isUser
                          ? AppColors.background
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Suggestion chips
          if (!isUser && message.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: message.suggestions.map((s) {
                return GestureDetector(
                  onTap: () => onSuggestionTap(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(s,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy,
                color: AppColors.accent, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.5 + (i * 0.2)),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
