part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

@JsonSerializable()
class ChatState extends Equatable {
  const ChatState({
    required this.status,
    required this.messages,
    required this.hasMore,
  });

  factory ChatState.fromJson(Map<String, dynamic> json) =>
      _$ChatStateFromJson(json);

  const ChatState.initial()
    : this(status: ChatStatus.initial, messages: const [], hasMore: true);

  final ChatStatus status;
  final bool hasMore;
  final List<Message> messages;

  @override
  List<Object> get props => [status, messages, hasMore];

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    bool? hasMore,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  Map<String, dynamic> toJson() => _$ChatStateToJson(this);
}
