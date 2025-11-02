import 'dart:async';
import 'dart:convert';

import 'package:chats_repository/chats_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'chat_bloc.g.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required String chatId, required ChatsRepository chatsRepository})
    : _chatId = chatId,
      _chatsRepository = chatsRepository,
      super(const ChatState.initial()) {
    on<ChatMessageChanged>(_onMessageChanged);
    on<ChatMessagesFetchRequested>(_onMessagesFetchRequested);
    on<ChatSendMessageRequested>(_onSendMessageRequested);
    on<ChatMessageDeleteRequested>(_onMessageDeleteRequested);
    on<ChatMessageSeen>(_onMessageSeen);
    on<ChatMessageEditRequested>(_onChatMessageEditRequested);

    _messagesRealtimeChannel = _chatsRepository.messagesUpdates(
      conversationId: _chatId,
      callback: _onMessageUpdated,
    );
  }

  RealtimeChannel? _messagesRealtimeChannel;

  void _onMessageUpdated(
    ({Map<String, dynamic> newRecord, Map<String, dynamic> oldRecord}) payload,
  ) => isClosed ? null : add(ChatMessageChanged(payload));

  final String _chatId;
  final ChatsRepository _chatsRepository;

  final _pageSize = 10;
  int _currentPage = 0;
  int _shiftOffset = 0;

  Future<List<Message>> _onData({
    required ({Map<String, dynamic> newRecord, Map<String, dynamic> oldRecord})
    payload,
  }) async {
    final messages = [...state.messages];
    final data = payload.newRecord;
    final oldRecord = payload.oldRecord;
    assert(
      data.isNotEmpty || oldRecord.isNotEmpty,
      'Both data and oldRecord cannot be empty',
    );
    if (data.isEmpty && oldRecord.isNotEmpty) {
      final index = messages.indexWhere((msg) => msg.id == oldRecord['id']);
      if (index == -1) return messages;

      messages.removeAt(index);
      _shiftOffset--;

      try {
        final hasReplyMessage = messages[index].replyMessageId != null;
        if (hasReplyMessage) {
          final messageReplyId = messages[index].replyMessageId;
          final replyMessages = messages
              .where((msg) => msg.id == messageReplyId)
              .toList();
          for (final message in replyMessages) {
            messages
                .firstWhere((msg) => msg.id == message.id)
                .copyWith(
                  repliedMessage: Message.empty,
                  replyMessageId: '',
                );
          }
        }
      } catch (_) {
        /// Safe to ignore error here. It can be thrown only if the message by
        /// [index] is not found.
      }
      return messages;
    }
    Message message;
    if (data['shared_post_id'] == null || data['shared_post_media'] == null) {
      message = Message.fromRow(data);
    } else {
      final resultMedia =
          (jsonDecode(data['shared_post_media'] as String) as List<dynamic>)
              .cast<Map<String, dynamic>>();
      final media = resultMedia.map(Media.fromJson).toList();
      message = Message.fromRow(data, media: media);
    }
    final index = messages.indexWhere((msg) => msg.id == message.id);
    if (index != -1) {
      messages[index] = message;
    } else {
      messages.insert(0, message);
      _shiftOffset++;
    }
    return messages;
  }

  Future<void> _onMessageChanged(
    ChatMessageChanged event,
    Emitter<ChatState> emit,
  ) async {
    final messages = await _onData(payload: event.payload);
    emit(state.copyWith(messages: messages));
  }

  Future<void> _onMessagesFetchRequested(
    ChatMessagesFetchRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (!state.hasMore) return;
      // final from = _pageSize * _currentPage;
      // final to = ((_currentPage * _pageSize) + _pageSize) - from + 1;
      final data = await _chatsRepository.getMessages(
        chatId: _chatId,
        limit: _pageSize,
        offset: (_pageSize * _currentPage) + _shiftOffset,
      );

      _currentPage++;

      emit(
        state.copyWith(
          hasMore: data.length >= _pageSize,
          messages: [...state.messages, ...data],
          status: ChatStatus.success,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onSendMessageRequested(
    ChatSendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.sendMessage(
        chatId: _chatId,
        sender: event.sender,
        receiver: event.receiver,
        message: event.message,
      );
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onMessageDeleteRequested(
    ChatMessageDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.deleteMessage(messageId: event.messageId);
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onMessageSeen(
    ChatMessageSeen event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.readMessage(messageId: event.messageId);
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onChatMessageEditRequested(
    ChatMessageEditRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.editMessage(
        oldMessage: event.oldMessage,
        newMessage: event.newMessage,
      );
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _messagesRealtimeChannel?.unsubscribe();
    return super.close();
  }
}
