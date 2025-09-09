// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_post_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewPostRequest _$NewPostRequestFromJson(Map<String, dynamic> json) {
  return _NewPostRequest.fromJson(json);
}

/// @nodoc
mixin _$NewPostRequest {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this NewPostRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewPostRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewPostRequestCopyWith<NewPostRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewPostRequestCopyWith<$Res> {
  factory $NewPostRequestCopyWith(
    NewPostRequest value,
    $Res Function(NewPostRequest) then,
  ) = _$NewPostRequestCopyWithImpl<$Res, NewPostRequest>;
  @useResult
  $Res call({String title, String content});
}

/// @nodoc
class _$NewPostRequestCopyWithImpl<$Res, $Val extends NewPostRequest>
    implements $NewPostRequestCopyWith<$Res> {
  _$NewPostRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewPostRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? content = null}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NewPostRequestImplCopyWith<$Res>
    implements $NewPostRequestCopyWith<$Res> {
  factory _$$NewPostRequestImplCopyWith(
    _$NewPostRequestImpl value,
    $Res Function(_$NewPostRequestImpl) then,
  ) = __$$NewPostRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String content});
}

/// @nodoc
class __$$NewPostRequestImplCopyWithImpl<$Res>
    extends _$NewPostRequestCopyWithImpl<$Res, _$NewPostRequestImpl>
    implements _$$NewPostRequestImplCopyWith<$Res> {
  __$$NewPostRequestImplCopyWithImpl(
    _$NewPostRequestImpl _value,
    $Res Function(_$NewPostRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewPostRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? content = null}) {
    return _then(
      _$NewPostRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NewPostRequestImpl implements _NewPostRequest {
  const _$NewPostRequestImpl({required this.title, required this.content});

  factory _$NewPostRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewPostRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String content;

  @override
  String toString() {
    return 'NewPostRequest(title: $title, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewPostRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, content);

  /// Create a copy of NewPostRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewPostRequestImplCopyWith<_$NewPostRequestImpl> get copyWith =>
      __$$NewPostRequestImplCopyWithImpl<_$NewPostRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NewPostRequestImplToJson(this);
  }
}

abstract class _NewPostRequest implements NewPostRequest {
  const factory _NewPostRequest({
    required final String title,
    required final String content,
  }) = _$NewPostRequestImpl;

  factory _NewPostRequest.fromJson(Map<String, dynamic> json) =
      _$NewPostRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get content;

  /// Create a copy of NewPostRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewPostRequestImplCopyWith<_$NewPostRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
