
class StoryModel {
  final String id;
  final String username;
  final String profileImageUrl;
  final bool isViewed;   
  final bool isOwn;      

  const StoryModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    this.isViewed = false,
    this.isOwn = false,
  });
}
