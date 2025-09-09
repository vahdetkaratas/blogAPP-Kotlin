import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/posts_repository.dart';
import '../../data/models/new_post_request.dart';
import '../../data/models/post.dart';
import '../../../../core/error/failures.dart';

// States
abstract class PostCreateState {}

class PostCreateInitial extends PostCreateState {}

class PostCreateSubmitting extends PostCreateState {}

class PostCreateSuccess extends PostCreateState {
  final Post post;
  PostCreateSuccess(this.post);
}

class PostCreateFailure extends PostCreateState {
  final String message;
  PostCreateFailure(this.message);
}

class PostCreateCubit extends Cubit<PostCreateState> {
  final IPostsRepository _repository;

  PostCreateCubit(this._repository) : super(PostCreateInitial());

  Future<void> submit(NewPostRequest request) async {
    emit(PostCreateSubmitting());
    try {
      final post = await _repository.create(request);
      emit(PostCreateSuccess(post));
    } on AppException catch (e) {
      emit(PostCreateFailure(e.message));
    } catch (e) {
      emit(PostCreateFailure('Failed to create post'));
    }
  }

  void reset() {
    emit(PostCreateInitial());
  }
}
