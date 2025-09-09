import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/posts_repository.dart';
import '../../data/models/post.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class PostListEvent {}

class PostListRequested extends PostListEvent {
  final String? search;
  final String? userId;
  final bool reset;
  PostListRequested({this.search, this.userId, this.reset = true});
}

class PostListRefreshed extends PostListEvent {}

class PostListPostCreated extends PostListEvent {}

class PostListLoadMore extends PostListEvent {}

// States
abstract class PostListState {}

class PostListInitial extends PostListState {}

class PostListLoading extends PostListState {}

class PostListLoaded extends PostListState {
  final List<Post> posts;
  final bool hasMore;
  final int page;
  final String? search;
  final String? userId;
  PostListLoaded({required this.posts, required this.hasMore, required this.page, this.search, this.userId});
}

class PostListEmpty extends PostListState {}

class PostListFailure extends PostListState {
  final String message;
  PostListFailure(this.message);
}

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final IPostsRepository _repository;
  static const int _pageSize = 20;

  PostListBloc(this._repository) : super(PostListInitial()) {
    on<PostListRequested>(_onRequested);
    on<PostListRefreshed>(_onRefreshed);
    on<PostListPostCreated>(_onPostCreated);
    on<PostListLoadMore>(_onLoadMore);
  }

  Future<void> _onRequested(PostListRequested event, Emitter<PostListState> emit) async {
    if (event.reset) {
      emit(PostListLoading());
    }
    try {
      final posts = await _repository.getAll(search: event.search, userId: event.userId, page: 1, limit: _pageSize);
      if (posts.isEmpty) {
        emit(PostListEmpty());
      } else {
        // Sort posts by createdAt in descending order (newest first)
        final sortedPosts = List<Post>.from(posts)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final hasMore = sortedPosts.length >= _pageSize;
        emit(PostListLoaded(posts: sortedPosts, hasMore: hasMore, page: 1, search: event.search, userId: event.userId));
      }
    } on AppException catch (e) {
      emit(PostListFailure(e.message));
    } catch (e) {
      emit(PostListFailure('Failed to load posts'));
    }
  }

  Future<void> _onRefreshed(PostListRefreshed event, Emitter<PostListState> emit) async {
    try {
      final posts = await _repository.getAll(page: 1, limit: _pageSize);
      if (posts.isEmpty) {
        emit(PostListEmpty());
      } else {
        // Sort posts by createdAt in descending order (newest first)
        final sortedPosts = List<Post>.from(posts)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final hasMore = sortedPosts.length >= _pageSize;
        emit(PostListLoaded(posts: sortedPosts, hasMore: hasMore, page: 1));
      }
    } on AppException catch (e) {
      emit(PostListFailure(e.message));
    } catch (e) {
      emit(PostListFailure('Failed to refresh posts'));
    }
  }

  Future<void> _onPostCreated(PostListPostCreated event, Emitter<PostListState> emit) async {
    // Refresh the list when a new post is created
    try {
      final posts = await _repository.getAll(page: 1, limit: _pageSize);
      if (posts.isEmpty) {
        emit(PostListEmpty());
      } else {
        // Sort posts by createdAt in descending order (newest first)
        final sortedPosts = List<Post>.from(posts)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final hasMore = sortedPosts.length >= _pageSize;
        emit(PostListLoaded(posts: sortedPosts, hasMore: hasMore, page: 1));
      }
    } on AppException catch (e) {
      emit(PostListFailure(e.message));
    } catch (e) {
      emit(PostListFailure('Failed to refresh posts after creation'));
    }
  }

  Future<void> _onLoadMore(PostListLoadMore event, Emitter<PostListState> emit) async {
    final current = state;
    if (current is! PostListLoaded || !current.hasMore) return;
    try {
      final nextPage = current.page + 1;
      final newPosts = await _repository.getAll(
        search: current.search,
        userId: current.userId,
        page: nextPage,
        limit: _pageSize,
      );
      if (newPosts.isEmpty) {
        emit(PostListLoaded(posts: current.posts, hasMore: false, page: current.page, search: current.search, userId: current.userId));
        return;
      }
      final combined = List<Post>.from(current.posts)..addAll(newPosts);
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final hasMore = newPosts.length >= _pageSize;
      emit(PostListLoaded(posts: combined, hasMore: hasMore, page: nextPage, search: current.search, userId: current.userId));
    } on AppException catch (e) {
      // Keep current list, but you could surface a snackbar via UI
      emit(PostListLoaded(posts: (state as PostListLoaded).posts, hasMore: (state as PostListLoaded).hasMore, page: (state as PostListLoaded).page, search: (state as PostListLoaded).search, userId: (state as PostListLoaded).userId));
    } catch (_) {
      emit(PostListLoaded(posts: (state as PostListLoaded).posts, hasMore: (state as PostListLoaded).hasMore, page: (state as PostListLoaded).page, search: (state as PostListLoaded).search, userId: (state as PostListLoaded).userId));
    }
  }
}
