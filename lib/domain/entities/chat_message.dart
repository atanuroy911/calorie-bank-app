import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant, system }

enum ChatMessageStatus { sending, sent, error }

class ChatMessage extends Equatable {
  final String id;
  final String sessionId;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final ChatMessageStatus status;
  final bool hasFoodLog; // did this message create a food entry?
  final bool hasExerciseLog;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
    this.hasFoodLog = false,
    this.hasExerciseLog = false,
  });

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;

  ChatMessage copyWith({
    ChatMessageStatus? status,
    bool? hasFoodLog,
    bool? hasExerciseLog,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
      hasFoodLog: hasFoodLog ?? this.hasFoodLog,
      hasExerciseLog: hasExerciseLog ?? this.hasExerciseLog,
    );
  }

  @override
  List<Object?> get props => [id, role, content, status];
}

class AiResponse {
  final String message;
  final String action; // food_log | exercise_log | bank_withdraw | clarify | none
  final Map<String, dynamic>? data;

  const AiResponse({
    required this.message,
    required this.action,
    this.data,
  });

  bool get isFoodLog => action == 'food_log';
  bool get isExerciseLog => action == 'exercise_log';
  bool get isBankWithdraw => action == 'bank_withdraw';
  bool get isClarify => action == 'clarify';
}
