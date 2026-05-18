import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chat_cubit.dart';

// @AETHER: EngagementChatWidget for real-time global chat.
// Designed with a reversed ListView so new messages appear at the bottom.

/// Displays the real-time global chat.
class EngagementChatWidget extends StatefulWidget {
  const EngagementChatWidget({required this.userId, super.key});
  
  final String userId;

  @override
  State<EngagementChatWidget> createState() => _EngagementChatWidgetState();
}

class _EngagementChatWidgetState extends State<EngagementChatWidget> {
  late final String _sessionUsername;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use the real userId to generate a consistent short name for now
    final String shortId = widget.userId.length >= 4 ? widget.userId.substring(0, 4) : widget.userId;
    _sessionUsername = 'Agent_$shortId';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(
          userId: widget.userId,
          username: _sessionUsername,
          content: text,
        );
    
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorPalette.divider),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.forum_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'GLOBAL COMM LINK',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (BuildContext context, ChatState state) {
                if (state is ChatActive && state.sendError != null && state.sendError!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.sendError!),
                      backgroundColor: ColorPalette.statusError,
                    ),
                  );
                }
              },
              builder: (BuildContext context, ChatState state) {
                if (state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is ChatActive) {
                  // We reverse the list for the ListView, so newest is at the bottom
                  final List<ChatMessage> displayMessages = state.messages.reversed.toList();
                  
                  if (displayMessages.isEmpty) {
                    return const Center(
                      child: Text(
                        'Comms channel open. Awaiting signals...',
                        style: TextStyle(color: ColorPalette.textDisabled),
                      ),
                    );
                  }

                  return ListView.separated(
                    reverse: true, // Newest at bottom
                    padding: const EdgeInsets.all(16),
                    itemCount: displayMessages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final ChatMessage msg = displayMessages[index];
                      final bool isMe = msg.userId == widget.userId;
                      
                      return _buildMessageBubble(context, msg, isMe);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ColorPalette.divider),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Transmit message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: ColorPalette.neonCyan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? ColorPalette.neonPurple.withValues(alpha: 0.2) : ColorPalette.abyssElevated,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : null,
            bottomLeft: !isMe ? const Radius.circular(4) : null,
          ),
          border: Border.all(
            color: isMe ? ColorPalette.neonPurple.withValues(alpha: 0.5) : ColorPalette.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!isMe) ...<Widget>[
              Text(
                msg.username,
                style: const TextStyle(
                  color: ColorPalette.neonCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              msg.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
