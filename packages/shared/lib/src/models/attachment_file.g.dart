// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'attachment_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Preparing _$PreparingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Preparing', json, ($checkedConvert) {
      final val = Preparing(
        $type: $checkedConvert('runtimeType', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'runtimeType'});

Map<String, dynamic> _$PreparingToJson(Preparing instance) => <String, dynamic>{
  'runtimeType': instance.$type,
};

InProgress _$InProgressFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InProgress', json, ($checkedConvert) {
      final val = InProgress(
        uploaded: $checkedConvert('uploaded', (v) => (v as num).toInt()),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        $type: $checkedConvert('runtimeType', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'runtimeType'});

Map<String, dynamic> _$InProgressToJson(InProgress instance) =>
    <String, dynamic>{
      'uploaded': instance.uploaded,
      'total': instance.total,
      'runtimeType': instance.$type,
    };

Success _$SuccessFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Success', json, ($checkedConvert) {
      final val = Success(
        $type: $checkedConvert('runtimeType', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'runtimeType'});

Map<String, dynamic> _$SuccessToJson(Success instance) => <String, dynamic>{
  'runtimeType': instance.$type,
};

Failed _$FailedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Failed', json, ($checkedConvert) {
      final val = Failed(
        error: $checkedConvert('error', (v) => v as String),
        $type: $checkedConvert('runtimeType', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'runtimeType'});

Map<String, dynamic> _$FailedToJson(Failed instance) => <String, dynamic>{
  'error': instance.error,
  'runtimeType': instance.$type,
};
