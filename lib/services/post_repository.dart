
import '../models/post_model.dart';
import '../models/story_model.dart';

class PostRepository {
 
  static const _photos = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=800',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800',
    'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=800',
    'https://images.unsplash.com/photo-1504700610630-ac6aba3536d3?w=800',
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800',
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=800',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
  ];

  static const _avatars = [
    'https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6?w=150',
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
  ];

  static const _usernames = [
    'alex.adventures', 'nature_vibes', 'travel.with.mia',
    'peak_explorer', 'forest.frames', 'ocean.soul',
    'wanderlust_kai', 'golden.hour.pics',
  ];

  static const _captions = [
    'Not all those who wander are lost 🌿 #travel #nature',
    'The mountains are calling and I must go 🏔️ #hiking #adventure',
    'Chasing sunsets and good vibes only ☀️ #sunset #photography',
    'Lost in the right direction 🌊 #ocean #explore',
    'Every mountain top is within reach if you just keep climbing 🌲',
    'Life is short, buy the plane ticket ✈️ #wanderlust',
    'Find me where the wild things are 🦋 #nature #wildlife',
    'Golden hour hits different up here 🌅 #goldenhour #travel',
  ];


  Future<List<PostModel>> fetchPosts({int page = 0}) async {

    await Future.delayed(const Duration(milliseconds: 1500));

  
    return List.generate(10, (index) {
      final globalIndex = page * 10 + index;
      final userIndex = globalIndex % _usernames.length;
      final photoIndex = globalIndex % _photos.length;

   
      final isCarousel = globalIndex % 3 == 2;
      final imageUrls = isCarousel
          ? [
              _photos[photoIndex % _photos.length],
              _photos[(photoIndex + 1) % _photos.length],
              _photos[(photoIndex + 2) % _photos.length],
            ]
          : [_photos[photoIndex]];

      return PostModel(
        id: 'post_${globalIndex}_${page}',
        user: UserModel(
          id: 'user_$userIndex',
          username: _usernames[userIndex],
          profileImageUrl: _avatars[userIndex % _avatars.length],
        ),
        imageUrls: imageUrls,
        caption: _captions[globalIndex % _captions.length],
        likeCount: 1200 + (globalIndex * 137) % 50000,
        commentCount: 45 + (globalIndex * 23) % 500,
        timeAgo: _timeAgo(globalIndex),
        isVerified: globalIndex % 4 == 0,
      );
    });
  }

    Future<List<StoryModel>> fetchStories() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      
      const StoryModel(
        id: 'own',
        username: 'Your story',
        profileImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        isOwn: true,
      ),
      ...List.generate(7, (i) {
        return StoryModel(
          id: 'story_$i',
          username: _usernames[i % _usernames.length],
          profileImageUrl: _avatars[i % _avatars.length],
          isViewed: i > 4, 
        );
      }),
    ];
  }

  String _timeAgo(int index) {
    final options = ['2m', '15m', '1h', '3h', '6h', '12h', '1d', '2d'];
    return options[index % options.length];
  }
}
