import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/usecase.dart';
import '../../domain/usecases/watch_messages.dart';

// ── State ────────────────────────────────────────────────────────────────────

/// State of the [ChatCubit].
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial loading state.
final class ChatInitial extends ChatState {}

/// Active chat state with messages.
final class ChatActive extends ChatState {
  const ChatActive({
    required this.messages,
    this.sendError,
  });

  final List<ChatMessage> messages;
  final String? sendError;

  @override
  List<Object?> get props => <Object?>[messages, sendError];

  ChatActive copyWith({
    List<ChatMessage>? messages,
    String? sendError,
  }) {
    return ChatActive(
      messages: messages ?? this.messages,
      sendError: sendError ?? this.sendError,
    );
  }
}

/// Error state if the initial stream fails.
final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ── Cubit ────────────────────────────────────────────────────────────────────

/// {@template chat_cubit}
/// Manages the real-time global chat state.
/// {@endtemplate}
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required WatchMessagesUseCase watchMessages,
    required SendMessageUseCase sendMessage,
  })  : _watchMessages = watchMessages,
        _sendMessage = sendMessage,
        super(ChatInitial()) {
    _startWatching();
  }

  final WatchMessagesUseCase _watchMessages;
  final SendMessageUseCase _sendMessage;
  StreamSubscription<List<ChatMessage>>? _subscription;

  void _startWatching() {
    _subscription = _watchMessages(const NoParams()).listen(
      (List<ChatMessage> messages) {
        if (state is ChatActive) {
          emit((state as ChatActive).copyWith(messages: messages));
        } else {
          emit(ChatActive(messages: messages));
        }
      },
      onError: (Object error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> sendMessage({
    required String userId,
    required String username,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;
    
    // Clear any previous errors
    if (state is ChatActive) {
      emit((state as ChatActive).copyWith(sendError: ''));
    }

    try {
      await _sendMessage(SendMessageParams(
        userId: userId,
        username: username,
        content: content,
      ));
    } on Failure catch (e) {
      if (state is ChatActive) {
        emit((state as ChatActive).copyWith(sendError: e.message));
      }
    } catch (e) {
      if (state is ChatActive) {
        emit((state as ChatActive).copyWith(sendError: 'Failed to send message'));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
