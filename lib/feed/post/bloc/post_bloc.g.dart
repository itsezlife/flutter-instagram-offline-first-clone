// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'post_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostState _$PostStateFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PostState',
  json,
  ($checkedConvert) {
    final val = PostState(
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$PostStatusEnumMap, v),
      ),
      likes: $checkedConvert('likes', (v) => (v as num).toInt()),
      likers: $checkedConvert(
        'likers',
        (v) => (v as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      commentsCount: $checkedConvert(
        'comments_count',
        (v) => (v as num).toInt(),
      ),
      isLiked: $checkedConvert('is_liked', (v) => v as bool),
      isOwner: $checkedConvert('is_owner', (v) => v as bool),
      likersInFollowings: $checkedConvert(
        'likers_in_followings',
        (v) => (v as List<dynamic>?)
            ?.map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      isFollowed: $checkedConvert('is_followed', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'commentsCount': 'comments_count',
    'isLiked': 'is_liked',
    'isOwner': 'is_owner',
    'likersInFollowings': 'likers_in_followings',
    'isFollowed': 'is_followed',
  },
);

Map<String, dynamic> _$PostStateToJson(PostState instance) => <String, dynamic>{
  'status': _$PostStatusEnumMap[instance.status]!,
  'likes': instance.likes,
  'likers': instance.likers.map((e) => e.toJson()).toList(),
  'likers_in_followings': ?instance.likersInFollowings
      ?.map((e) => e.toJson())
      .toList(),
  'comments_count': instance.commentsCount,
  'is_liked': instance.isLiked,
  'is_owner': instance.isOwner,
  'is_followed': ?instance.isFollowed,
};

const _$PostStatusEnumMap = {
  PostStatus.initial: 'initial',
  PostStatus.loading: 'loading',
  PostStatus.success: 'success',
  PostStatus.failure: 'failure',
};
