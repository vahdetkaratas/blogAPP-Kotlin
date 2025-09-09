import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/post_list_bloc.dart';
import '../../data/models/post.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/config/constants.dart';
import '../widgets/post_skeleton_loader.dart';

class PostsPage extends StatefulWidget {
  final String? userId;
  const PostsPage({super.key, this.userId});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostListBloc>().add(PostListRequested(userId: widget.userId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = 200.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (maxScroll - current <= threshold) {
      context.read<PostListBloc>().add(PostListLoadMore());
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<PostListBloc>().add(PostListRequested(
            search: query.isEmpty ? null : query,
            userId: widget.userId,
          ));
    });
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isUserMode = widget.userId != null;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.lightGray,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (isUserMode)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/'),
                      ),
                    Expanded(
                      child: Text(
                        isUserMode ? 'User Posts' : 'All Posts',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.darkText,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
              itemBuilder: (context) => [
                        const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Logout'),
                    ],
                  ),
                ),
              ],
                    ),
                  ],
                ),
              ),
              
              // Search Bar
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                  hintText: 'Search posts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Posts List
          Expanded(
            child: BlocBuilder<PostListBloc, PostListState>(
              builder: (context, state) {
                if (state is PostListLoading) {
                      return const PostSkeletonLoader();
                }
                
                if (state is PostListLoaded) {
                  _allPosts = state.posts;
                  if (_filteredPosts.isEmpty && _searchController.text.isEmpty) {
                    _filteredPosts = _allPosts;
                  }
                  
                  if (_filteredPosts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No posts found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.darkText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Baloo 2',
                                ),
                              ),
                            ],
                          ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () {
                      context.read<PostListBloc>().add(PostListRefreshed());
                      return Future.value();
                    },
                    child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildGradientPostCard(post, index),
                        );
                      },
                    ),
                  );
                }
                
                if (state is PostListEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isUserMode ? 'No posts from this user' : 'No posts yet',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isUserMode 
                      ? 'This user hasn\'t posted anything yet'
                      : 'Create your first post!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Baloo 2',
                              ),
                            ),
                          ],
                        ),
                  );
                }
                
                if (state is PostListFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading posts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Baloo 2',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
        ),
        floatingActionButton: isUserMode ? null : _buildAnimatedFAB(),
      ),
    );
  }

  Widget _buildGradientPostCard(Post post, int index) {
    final gradients = [
      [AppConstants.primaryYellow, AppConstants.primaryRed],
      [AppConstants.primaryRed, AppConstants.primaryGreen],
      [AppConstants.primaryGreen, AppConstants.primaryYellow],
    ];
    
    final gradient = gradients[index % gradients.length];
    
    return GestureDetector(
      onTap: () {
        context.go('/post/${post.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Image with ThinkEasy Design
                Container(
                  height: 192,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ThinkEasyPatternPainter(),
                        ),
                      ),
                      // ThinkEasy Text
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'ThinkEasy',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Blog Platform',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Baloo 2',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Post Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Baloo 2',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User ${post.authorId.substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.9),
                              fontFamily: 'Baloo 2',
                            ),
                          ),
                          Text(
                            _formatDate(post.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.9),
                              fontFamily: 'Baloo 2',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -25 * (1 - value)),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppConstants.primaryRed, AppConstants.primaryGreen],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryRed.withValues(alpha:0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => context.go('/create'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ThinkEasyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final rect = Rect.fromLTWH(x, y, spacing, spacing);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
