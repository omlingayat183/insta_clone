
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import 'carousel_widget.dart';
import 'pinch_zoom.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_heartAnimController);
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    ref.read(feedProvider.notifier).toggleLike(widget.post.id);
    setState(() => _showHeart = true);
    _heartAnimController.forward(from: 0).then((_) {
      setState(() => _showHeart = false);
    });
  }

  void _showUnimplementedSnackbar(String feature) {

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature coming soon! 🚀'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
 
    final isLiked = ref.watch(
      feedProvider.select((s) => s.likedPosts[widget.post.id] ?? false),
    );
    final isSaved = ref.watch(
      feedProvider.select((s) => s.savedPosts[widget.post.id] ?? false),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildImageSection(isLiked),
        _buildActionBar(isLiked, isSaved),
        _buildLikeCount(isLiked),
        _buildCaption(),
        _buildCommentPreview(),
        _buildTimestamp(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFCAF45), Color(0xFFFF3860), Color(0xFF833AB4)],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.post.user.profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF3A3A3A)),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.white38, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Row(
              children: [
                Text(
                  widget.post.user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
                if (widget.post.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: Color(0xFF0095F6),
                  ),
                ],
              ],
            ),
          ),

          GestureDetector(
            onTap: () => _showUnimplementedSnackbar('Post options'),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_horiz, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isLiked) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.post.imageUrls.length > 1
              ? CarouselWidget(imageUrls: widget.post.imageUrls)
              : PinchZoom(
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrls.first,
                    width: double.infinity,
                    height: 375,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFF262626), height: 375),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF262626),
                      height: 375,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.white30, size: 40),
                      ),
                    ),
                  ),
                ),

          if (_showHeart)
            ScaleTransition(
              scale: _heartScale,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 80,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildActionBar(bool isLiked, bool isSaved) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AnimatedLikeButton(
            isLiked: isLiked,
            onTap: () =>
                ref.read(feedProvider.notifier).toggleLike(widget.post.id),
          ),
          const SizedBox(width: 14),

          GestureDetector(
            onTap: () => _showUnimplementedSnackbar('Comments'),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: Colors.white, size: 24),
                const SizedBox(width: 5),
                Text(
                  _formatCount(widget.post.commentCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          GestureDetector(
            onTap: () => _showUnimplementedSnackbar('Repost'),
            child: Row(
              children: [
                const Icon(Icons.repeat, color: Colors.white, size: 24),
                const SizedBox(width: 5),
                Text(
                  _formatCount((widget.post.commentCount * 0.45).round()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          GestureDetector(
            onTap: () => _showUnimplementedSnackbar('Share'),
            child: const Icon(Icons.send_outlined, color: Colors.white, size: 22),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () =>
                ref.read(feedProvider.notifier).toggleSave(widget.post.id),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey(isSaved),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeCount(bool isLiked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${_formatCount(widget.post.likeCount)} likes',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          children: [
            TextSpan(
              text: widget.post.user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: '  '),
            TextSpan(text: widget.post.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview() {
    if (widget.post.commentCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: GestureDetector(
        onTap: () => _showUnimplementedSnackbar('Comments'),
        child: Text(
          'View all ${_formatCount(widget.post.commentCount)} comments',
          style: const TextStyle(
            color: Color(0xFF8E8E8E),
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Text(
        widget.post.timeAgo,
        style: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}


class _AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const _AnimatedLikeButton({required this.isLiked, required this.onTap});

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.isLiked ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(widget.isLiked),
            color: widget.isLiked ? Colors.red : Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}