import 'package:dio/dio.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/error/failures.dart';
import 'models/post.dart';
import 'models/new_post_request.dart';

abstract class IPostsRepository {
  Future<List<Post>> getAll({String? search, String? userId, int page = 1, int limit = 20});
  Future<Post> create(NewPostRequest req);
  Future<Post> getPost(String id);
}

class PostsRepository implements IPostsRepository {
  final Dio _dio;

  PostsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Post>> getAll({String? search, String? userId, int page = 1, int limit = 20}) async {
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (userId != null) query['userId'] = userId;
      query['page'] = page;
      query['limit'] = limit;

      final response = await _dio.get(ApiPaths.posts, queryParameters: query);
      final dynamic data = response.data;
      final List<dynamic> postsJson = data is Map<String, dynamic>
          ? (data['data'] as List<dynamic>? ?? [])
          : (data as List<dynamic>? ?? []);
      return postsJson.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw const AppException('Unexpected error occurred');
    }
  }

  @override
  Future<Post> create(NewPostRequest req) async {
    try {
      final response = await _dio.post(
        ApiPaths.posts,
        data: req.toJson(),
      );
      final dynamic data = response.data;
      final Map<String, dynamic> json =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
      return Post.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw const AppException('Unexpected error occurred');
    }
  }


  @override
  Future<Post> getPost(String id) async {
    try {
      final response = await _dio.get(ApiPaths.getPost.replaceAll('{id}', id));
      final dynamic data = response.data;
      final Map<String, dynamic> json =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
      return Post.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw const AppException('Unexpected error occurred');
    }
  }

}
