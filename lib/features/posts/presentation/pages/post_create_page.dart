import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/post_create_cubit.dart';
import '../bloc/post_list_bloc.dart';
import '../../data/models/new_post_request.dart';
import '../../../../core/config/constants.dart';

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key});

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleCreatePost() {
    if (_formKey.currentState!.validate()) {
      final request = NewPostRequest(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );
      
      context.read<PostCreateCubit>().submit(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryYellow,
      body: BlocListener<PostCreateCubit, PostCreateState>(
        listener: (context, state) {
          if (state is PostCreateSuccess) {
            // Refresh the post list to show the new post
            context.read<PostListBloc>().add(PostListPostCreated());
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Post created successfully'),
                backgroundColor: AppConstants.primaryRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
            context.go('/');
          } else if (state is PostCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.primaryRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Animated Background Circles
            Expanded(
              child: Stack(
                children: [
                  // Background circles
                  Positioned(
                    top: -80,
                    left: -80,
                    child: _buildAnimatedCircle(
                      AppConstants.primaryRed,
                      size: 192,
                      delay: 0,
                    ),
                  ),
                  Positioned(
                    bottom: -96,
                    right: -64,
                    child: _buildAnimatedCircle(
                      AppConstants.primaryGreen,
                      size: 256,
                      delay: 1000,
                    ),
                  ),
                  
                  // Main Content
                  Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              // Back Button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  onPressed: () => context.go('/'),
                                ),
                              ),
                              
                              // Title
                              const Expanded(
                                child: Text(
                                  'Create Post',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              // Decorative Icon
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.9, end: 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Form Content
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(36),
                              topRight: Radius.circular(36),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Title Field
                                  _buildTitleField(),
                                  const SizedBox(height: 16),
                                  
                                  // Content Field
                                  Expanded(
                                    child: _buildContentField(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Publish Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: BlocBuilder<PostCreateCubit, PostCreateState>(
                  builder: (context, state) {
                    final isSubmitting = state is PostCreateSubmitting;
                    return Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 480),
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryRed,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryRed.withValues(alpha:0.5),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: isSubmitting ? null : _handleCreatePost,
                          child: Center(
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Publish',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle(Color color, {required double size, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween(begin: 1.0, end: 1.1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleField() {
    return Stack(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextFormField(
            controller: _titleController,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: const InputDecoration(
              hintText: 'Post Title',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontFamily: 'Plus Jakarta Sans',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              if (value.length > AppConstants.maxTitleLength) {
                return 'Title must be less than ${AppConstants.maxTitleLength} characters';
              }
              return null;
            },
          ),
        ),
        
        // Decorative Circle
        Positioned(
          top: -8,
          right: -8,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.9, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextFormField(
            controller: _contentController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: const InputDecoration(
              hintText: 'Write your post here...',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontFamily: 'Plus Jakarta Sans',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter content';
              }
              if (value.length > AppConstants.maxContentLength) {
                return 'Content must be less than ${AppConstants.maxContentLength} characters';
              }
              return null;
            },
          ),
        ),
        
        // Decorative Circle
        Positioned(
          bottom: -8,
          left: -8,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.9, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
