// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_options_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostOptionsSettings {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostOptionsSettings);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostOptionsSettings()';
}


}

/// @nodoc
class $PostOptionsSettingsCopyWith<$Res>  {
$PostOptionsSettingsCopyWith(PostOptionsSettings _, $Res Function(PostOptionsSettings) __);
}


/// Adds pattern-matching-related methods to [PostOptionsSettings].
extension PostOptionsSettingsPatterns on PostOptionsSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Owner value)?  owner,TResult Function( Viewer value)?  viewer,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Owner() when owner != null:
return owner(_that);case Viewer() when viewer != null:
return viewer(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Owner value)  owner,required TResult Function( Viewer value)  viewer,}){
final _that = this;
switch (_that) {
case Owner():
return owner(_that);case Viewer():
return viewer(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Owner value)?  owner,TResult? Function( Viewer value)?  viewer,}){
final _that = this;
switch (_that) {
case Owner() when owner != null:
return owner(_that);case Viewer() when viewer != null:
return viewer(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValueSetter<String> onPostDelete,  ValueSetter<PostBlock> onPostEdit)?  owner,TResult Function()?  viewer,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Owner() when owner != null:
return owner(_that.onPostDelete,_that.onPostEdit);case Viewer() when viewer != null:
return viewer();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValueSetter<String> onPostDelete,  ValueSetter<PostBlock> onPostEdit)  owner,required TResult Function()  viewer,}) {final _that = this;
switch (_that) {
case Owner():
return owner(_that.onPostDelete,_that.onPostEdit);case Viewer():
return viewer();case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValueSetter<String> onPostDelete,  ValueSetter<PostBlock> onPostEdit)?  owner,TResult? Function()?  viewer,}) {final _that = this;
switch (_that) {
case Owner() when owner != null:
return owner(_that.onPostDelete,_that.onPostEdit);case Viewer() when viewer != null:
return viewer();case _:
  return null;

}
}

}

/// @nodoc


class Owner extends PostOptionsSettings {
  const Owner({required this.onPostDelete, required this.onPostEdit}): super._();
  

 final  ValueSetter<String> onPostDelete;
 final  ValueSetter<PostBlock> onPostEdit;

/// Create a copy of PostOptionsSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerCopyWith<Owner> get copyWith => _$OwnerCopyWithImpl<Owner>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Owner&&(identical(other.onPostDelete, onPostDelete) || other.onPostDelete == onPostDelete)&&(identical(other.onPostEdit, onPostEdit) || other.onPostEdit == onPostEdit));
}


@override
int get hashCode => Object.hash(runtimeType,onPostDelete,onPostEdit);

@override
String toString() {
  return 'PostOptionsSettings.owner(onPostDelete: $onPostDelete, onPostEdit: $onPostEdit)';
}


}

/// @nodoc
abstract mixin class $OwnerCopyWith<$Res> implements $PostOptionsSettingsCopyWith<$Res> {
  factory $OwnerCopyWith(Owner value, $Res Function(Owner) _then) = _$OwnerCopyWithImpl;
@useResult
$Res call({
 ValueSetter<String> onPostDelete, ValueSetter<PostBlock> onPostEdit
});




}
/// @nodoc
class _$OwnerCopyWithImpl<$Res>
    implements $OwnerCopyWith<$Res> {
  _$OwnerCopyWithImpl(this._self, this._then);

  final Owner _self;
  final $Res Function(Owner) _then;

/// Create a copy of PostOptionsSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? onPostDelete = null,Object? onPostEdit = null,}) {
  return _then(Owner(
onPostDelete: null == onPostDelete ? _self.onPostDelete : onPostDelete // ignore: cast_nullable_to_non_nullable
as ValueSetter<String>,onPostEdit: null == onPostEdit ? _self.onPostEdit : onPostEdit // ignore: cast_nullable_to_non_nullable
as ValueSetter<PostBlock>,
  ));
}


}

/// @nodoc


class Viewer extends PostOptionsSettings {
  const Viewer(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Viewer);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostOptionsSettings.viewer()';
}


}




// dart format on
