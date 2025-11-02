// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'section_header_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectionHeaderBlock _$SectionHeaderBlockFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SectionHeaderBlock', json, ($checkedConvert) {
      final val = SectionHeaderBlock(
        sectionType: $checkedConvert(
          'section_type',
          (v) => $enumDecode(_$SectionHeaderBlockTypeEnumMap, v),
        ),
        action: $checkedConvert(
          'action',
          (v) =>
              const BlockActionConverter().fromJson(v as Map<String, dynamic>?),
        ),
        type: $checkedConvert(
          'type',
          (v) => v as String? ?? SectionHeaderBlock.identifier,
        ),
      );
      return val;
    }, fieldKeyMap: const {'sectionType': 'section_type'});

Map<String, dynamic> _$SectionHeaderBlockToJson(SectionHeaderBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'section_type': _$SectionHeaderBlockTypeEnumMap[instance.sectionType]!,
      'action': ?const BlockActionConverter().toJson(instance.action),
    };

const _$SectionHeaderBlockTypeEnumMap = {
  SectionHeaderBlockType.suggested: 'suggested',
};
