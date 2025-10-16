import 'package:equatable/equatable.dart';
import '../../data/model/chat_model.dart';
import '../../data/model/message_model.dart';

class ChatState extends Equatable {
  final ChatModel? chat;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.chat,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    ChatModel? chat,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [chat, messages, isLoading, isSending, error];
}