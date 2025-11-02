// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Comment',
  json,
  ($checkedConvert) {
    final val = Comment(
      id: $checkedConvert('id', (v) => v as String),
      postId: $checkedConvert('post_id', (v) => v as String),
      author: $checkedConvert(
        'author',
        (v) => PostAuthor.fromJson(v as Map<String, dynamic>),
      ),
      content: $checkedConvert('content', (v) => v as String),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      repliedToCommentId: $checkedConvert(
        'replied_to_comment_id',
        (v) => v as String?,
      ),
      replies: $checkedConvert('replies', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'postId': 'post_id',
    'createdAt': 'created_at',
    'repliedToCommentId': 'replied_to_comment_id',
  },
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'author': instance.author.toJson(),
  'replied_to_comment_id': ?instance.repliedToCommentId,
  'replies': ?instance.replies,
  'content': instance.content,
  'created_at': instance.createdAt.toIso8601String(),
};
