class ApiPaths {
  // Base paths (no /api prefix based on OpenAPI schema)
  static const String _auth = '/auth';
  static const String _posts = '/posts';
  
  // Auth endpoints
  static const String login = '$_auth/login';
  static const String refresh = '$_auth/refresh-token';
  static const String signup = '$_auth/signup';
  
  // Posts endpoints
  static const String posts = _posts;
  static const String createPost = _posts;
  static const String getPost = '$_posts/{id}';
  static const String userPosts = '$_posts/user/{userId}';
  
  // Query examples:
  // GET /posts?userId=123
  // GET /posts?search=term (if backend supports)
}
