import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_post_request.freezed.dart';
part 'new_post_request.g.dart';

@freezed
class NewPostRequest with _$NewPostRequest {
  const factory NewPostRequest({
    required String title,
    required String content,
  }) = _NewPostRequest;

  factory NewPostRequest.fromJson(Map<String, dynamic> json) =>
      _$NewPostRequestFromJson(json);
}
