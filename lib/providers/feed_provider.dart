
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../services/post_repository.dart';


final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});


class FeedState {
  final List<PostModel> posts;
  final bool isLoadingInitial;   
  final bool isLoadingMore;     
  final bool hasReachedEnd;     
  final int currentPage;
  final Map<String, bool> likedPosts;   
  final Map<String, bool> savedPosts;   

  const FeedState({
    this.posts = const [],
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.likedPosts = const {},
    this.savedPosts = const {},
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    Map<String, bool>? likedPosts,
    Map<String, bool>? savedPosts,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      likedPosts: likedPosts ?? this.likedPosts,
      savedPosts: savedPosts ?? this.savedPosts,
    );
  }
}


class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _repository;


  FeedNotifier(this._repository) : super(const FeedState()) {
   
    loadInitialFeed();
  }

  Future<void> loadInitialFeed() async {
   
    if (!state.isLoadingInitial) {
      state = state.copyWith(isLoadingInitial: true, currentPage: 0, posts: []);
    }
    try {
      final posts = await _repository.fetchPosts(page: 0);
      state = state.copyWith(
        posts: posts,
        isLoadingInitial: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingInitial: false);
    }
  }


  Future<void> loadMorePosts() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final newPosts = await _repository.fetchPosts(page: state.currentPage);

    
      if (state.currentPage >= 5) {
        state = state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
        );
        return;
      }

      state = state.copyWith(
    
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }


  void toggleLike(String postId) {
    final isLiked = state.likedPosts[postId] ?? false;
   
    final updatedLikes = Map<String, bool>.from(state.likedPosts);
    updatedLikes[postId] = !isLiked;

 
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(likedPosts: updatedLikes, posts: updatedPosts);
  }


  void toggleSave(String postId) {
    final isSaved = state.savedPosts[postId] ?? false;
    final updatedSaves = Map<String, bool>.from(state.savedPosts);
    updatedSaves[postId] = !isSaved;
    state = state.copyWith(savedPosts: updatedSaves);
  }
}


final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return FeedNotifier(repository);
});


final storiesProvider = FutureProvider<List<StoryModel>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchStories();
});
