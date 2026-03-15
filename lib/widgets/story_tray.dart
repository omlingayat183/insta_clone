
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';
import '../providers/feed_provider.dart';

class StoryTray extends ConsumerWidget {
  const StoryTray({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      loading: () => _buildShimmerRow(),

      error: (err, stack) => const SizedBox.shrink(),

      data: (stories) => SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            return _StoryItem(story: stories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 6,
        itemBuilder: (context, _) => const _ShimmerStoryItem(),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final StoryModel story;

  const _StoryItem({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
       
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${story.username}'s story"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF262626),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatarWithRing(),
            const SizedBox(height: 4),
            SizedBox(
              width: 64,
              child: Text(
                story.isOwn ? 'Your story' : story.username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithRing() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
  
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.isViewed
                ? const LinearGradient(
                    colors: [Color(0xFF555555), Color(0xFF555555)],
                  )
                : story.isOwn
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFCAF45), 
                          Color(0xFFFF3860), 
                          Color(0xFF833AB4), 
                        ],
                      ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black, 
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: story.profileImageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF262626)),
                errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white30),
              ),
            ),
          ),
        ),

        if (story.isOwn)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0095F6),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
      ],
    );
  }
}

class _ShimmerStoryItem extends StatelessWidget {
  const _ShimmerStoryItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFF3A3A3A),
            ),
          ),
        ],
      ),
    );
  }
}
