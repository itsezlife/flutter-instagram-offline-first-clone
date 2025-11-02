// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'chat_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatState _$ChatStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatState', json, ($checkedConvert) {
      final val = ChatState(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ChatStatusEnumMap, v),
        ),
        messages: $checkedConvert(
          'messages',
          (v) => (v as List<dynamic>)
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        hasMore: $checkedConvert('has_more', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'hasMore': 'has_more'});

Map<String, dynamic> _$ChatStateToJson(ChatState instance) => <String, dynamic>{
  'status': _$ChatStatusEnumMap[instance.status]!,
  'has_more': instance.hasMore,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};

const _$ChatStatusEnumMap = {
  ChatStatus.initial: 'initial',
  ChatStatus.loading: 'loading',
  ChatStatus.success: 'success',
  ChatStatus.failure: 'failure',
};
