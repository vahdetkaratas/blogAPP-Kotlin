import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thinkeasy_mini/features/posts/data/posts_repository.dart';
import 'package:thinkeasy_mini/features/posts/data/models/post.dart';
import 'package:thinkeasy_mini/features/posts/presentation/bloc/post_list_bloc.dart';
import 'package:thinkeasy_mini/core/error/failures.dart';

class MockPostsRepository extends Mock implements IPostsRepository {}

void main() {
  group('PostListBloc', () {
    late MockPostsRepository mockPostsRepository;
    late PostListBloc postListBloc;

    setUp(() {
      mockPostsRepository = MockPostsRepository();
      postListBloc = PostListBloc(mockPostsRepository);
    });

    tearDown(() {
      postListBloc.close();
    });

    group('PostListRequested', () {
      final mockPosts = [
        Post(
          id: '1',
          authorId: '1',
          title: 'Test Post 1',
          content: 'This is test content 1',
          published: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Post(
          id: '2',
          authorId: '2',
          title: 'Test Post 2',
          content: 'This is test content 2',
          published: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      blocTest<PostListBloc, PostListState>(
        'emits [PostListLoading, PostListLoaded] when posts are fetched successfully',
        build: () {
          when(() => mockPostsRepository.getAll(
                search: any(named: 'search'),
                userId: any(named: 'userId'),
              )).thenAnswer((_) async => mockPosts);
          return postListBloc;
        },
        act: (bloc) => bloc.add(PostListRequested()),
        expect: () => [
          isA<PostListLoading>(),
          isA<PostListLoaded>(),
        ],
        verify: (_) {
          verify(() => mockPostsRepository.getAll(
                search: null,
                userId: null,
              )).called(1);
        },
      );

      blocTest<PostListBloc, PostListState>(
        'emits [PostListLoading, PostListEmpty] when no posts are returned',
        build: () {
          when(() => mockPostsRepository.getAll(
                search: any(named: 'search'),
                userId: any(named: 'userId'),
              )).thenAnswer((_) async => <Post>[]);
          return postListBloc;
        },
        act: (bloc) => bloc.add(PostListRequested()),
        expect: () => [
          isA<PostListLoading>(),
          isA<PostListEmpty>(),
        ],
        verify: (_) {
          verify(() => mockPostsRepository.getAll(
                search: null,
                userId: null,
              )).called(1);
        },
      );

      blocTest<PostListBloc, PostListState>(
        'emits [PostListLoading, PostListFailure] when repository throws AppException',
        build: () {
          when(() => mockPostsRepository.getAll(
                search: any(named: 'search'),
                userId: any(named: 'userId'),
              )).thenThrow(const AppException('Network error'));
          return postListBloc;
        },
        act: (bloc) => bloc.add(PostListRequested()),
        expect: () => [
          isA<PostListLoading>(),
          isA<PostListFailure>(),
        ],
        verify: (_) {
          verify(() => mockPostsRepository.getAll(
                search: null,
                userId: null,
              )).called(1);
        },
      );
    });
  });
}
