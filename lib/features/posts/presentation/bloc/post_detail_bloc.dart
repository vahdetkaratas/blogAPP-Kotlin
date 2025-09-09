import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/posts_repository.dart';
import '../../data/models/post.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class PostDetailEvent {}

class PostDetailRequested extends PostDetailEvent {
  final String postId;
  PostDetailRequested(this.postId);
}

// States
abstract class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  final Post post;
  PostDetailLoaded(this.post);
}

class PostDetailFailure extends PostDetailState {
  final String message;
  PostDetailFailure(this.message);
}

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final IPostsRepository _repository;

  PostDetailBloc(this._repository) : super(PostDetailInitial()) {
    on<PostDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(PostDetailRequested event, Emitter<PostDetailState> emit) async {
    emit(PostDetailLoading());
    try {
      final post = await _repository.getPost(event.postId);
      emit(PostDetailLoaded(post));
    } on AppException catch (e) {
      emit(PostDetailFailure(e.message));
    } catch (e) {
      emit(PostDetailFailure('Failed to load post details'));
    }
  }
}
