
class PostModel {
  final String id;
  final UserModel user;
  final List<String> imageUrls;
  final String caption;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  final bool isVerified;


  const PostModel({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    this.isVerified = false,
  });


  PostModel copyWith({
    String? id,
    UserModel? user,
    List<String>? imageUrls,
    String? caption,
    int? likeCount,
    int? commentCount,
    String? timeAgo,
    bool? isVerified,
  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      timeAgo: timeAgo ?? this.timeAgo,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class UserModel {
  final String id;
  final String username;
  final String profileImageUrl;

  const UserModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
  });
}
