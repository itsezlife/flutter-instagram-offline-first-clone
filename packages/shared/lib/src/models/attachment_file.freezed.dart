// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
UploadState _$UploadStateFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'preparing':
          return Preparing.fromJson(
            json
          );
                case 'inProgress':
          return InProgress.fromJson(
            json
          );
                case 'success':
          return Success.fromJson(
            json
          );
                case 'failed':
          return Failed.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'UploadState',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$UploadState {



  /// Serializes this UploadState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadState);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UploadState()';
}


}

/// @nodoc
class $UploadStateCopyWith<$Res>  {
$UploadStateCopyWith(UploadState _, $Res Function(UploadState) __);
}


/// Adds pattern-matching-related methods to [UploadState].
extension UploadStatePatterns on UploadState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Preparing value)?  preparing,TResult Function( InProgress value)?  inProgress,TResult Function( Success value)?  success,TResult Function( Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing(_that);case InProgress() when inProgress != null:
return inProgress(_that);case Success() when success != null:
return success(_that);case Failed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Preparing value)  preparing,required TResult Function( InProgress value)  inProgress,required TResult Function( Success value)  success,required TResult Function( Failed value)  failed,}){
final _that = this;
switch (_that) {
case Preparing():
return preparing(_that);case InProgress():
return inProgress(_that);case Success():
return success(_that);case Failed():
return failed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Preparing value)?  preparing,TResult? Function( InProgress value)?  inProgress,TResult? Function( Success value)?  success,TResult? Function( Failed value)?  failed,}){
final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing(_that);case InProgress() when inProgress != null:
return inProgress(_that);case Success() when success != null:
return success(_that);case Failed() when failed != null:
return failed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  preparing,TResult Function( int uploaded,  int total)?  inProgress,TResult Function()?  success,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing();case InProgress() when inProgress != null:
return inProgress(_that.uploaded,_that.total);case Success() when success != null:
return success();case Failed() when failed != null:
return failed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  preparing,required TResult Function( int uploaded,  int total)  inProgress,required TResult Function()  success,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case Preparing():
return preparing();case InProgress():
return inProgress(_that.uploaded,_that.total);case Success():
return success();case Failed():
return failed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  preparing,TResult? Function( int uploaded,  int total)?  inProgress,TResult? Function()?  success,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing();case InProgress() when inProgress != null:
return inProgress(_that.uploaded,_that.total);case Success() when success != null:
return success();case Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class Preparing extends UploadState {
  const Preparing({final  String? $type}): $type = $type ?? 'preparing',super._();
  factory Preparing.fromJson(Map<String, dynamic> json) => _$PreparingFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$PreparingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preparing);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UploadState.preparing()';
}


}




/// @nodoc
@JsonSerializable()

class InProgress extends UploadState {
  const InProgress({required this.uploaded, required this.total, final  String? $type}): $type = $type ?? 'inProgress',super._();
  factory InProgress.fromJson(Map<String, dynamic> json) => _$InProgressFromJson(json);

 final  int uploaded;
 final  int total;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of UploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InProgressCopyWith<InProgress> get copyWith => _$InProgressCopyWithImpl<InProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InProgress&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uploaded,total);

@override
String toString() {
  return 'UploadState.inProgress(uploaded: $uploaded, total: $total)';
}


}

/// @nodoc
abstract mixin class $InProgressCopyWith<$Res> implements $UploadStateCopyWith<$Res> {
  factory $InProgressCopyWith(InProgress value, $Res Function(InProgress) _then) = _$InProgressCopyWithImpl;
@useResult
$Res call({
 int uploaded, int total
});




}
/// @nodoc
class _$InProgressCopyWithImpl<$Res>
    implements $InProgressCopyWith<$Res> {
  _$InProgressCopyWithImpl(this._self, this._then);

  final InProgress _self;
  final $Res Function(InProgress) _then;

/// Create a copy of UploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uploaded = null,Object? total = null,}) {
  return _then(InProgress(
uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class Success extends UploadState {
  const Success({final  String? $type}): $type = $type ?? 'success',super._();
  factory Success.fromJson(Map<String, dynamic> json) => _$SuccessFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$SuccessToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UploadState.success()';
}


}




/// @nodoc
@JsonSerializable()

class Failed extends UploadState {
  const Failed({required this.error, final  String? $type}): $type = $type ?? 'failed',super._();
  factory Failed.fromJson(Map<String, dynamic> json) => _$FailedFromJson(json);

 final  String error;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of UploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedCopyWith<Failed> get copyWith => _$FailedCopyWithImpl<Failed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FailedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failed&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UploadState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailedCopyWith<$Res> implements $UploadStateCopyWith<$Res> {
  factory $FailedCopyWith(Failed value, $Res Function(Failed) _then) = _$FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$FailedCopyWithImpl<$Res>
    implements $FailedCopyWith<$Res> {
  _$FailedCopyWithImpl(this._self, this._then);

  final Failed _self;
  final $Res Function(Failed) _then;

/// Create a copy of UploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
