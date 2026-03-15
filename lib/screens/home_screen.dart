
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/story_tray.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_feed.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final triggerPoint = position.maxScrollExtent - 600;
    if (position.pixels >= triggerPoint) {
      ref.read(feedProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: feedState.isLoadingInitial
                  ? _buildShimmerView()
                  : _buildFeed(feedState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const StoryTray(),
          const Divider(height: 0.5, color: Color(0xFF262626)),
          const ShimmerFeed(),
        ],
      ),
    );
  }

  Widget _buildFeed(FeedState feedState) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xFF262626),
      onRefresh: () => ref.read(feedProvider.notifier).loadInitialFeed(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const SliverToBoxAdapter(child: StoryTray()),
          const SliverToBoxAdapter(
            child: Divider(height: 0.5, color: Color(0xFF262626)),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Column(
                children: [
                  PostCard(post: feedState.posts[index]),
                  const Divider(height: 0.5, color: Color(0xFF262626)),
                ],
              ),
              childCount: feedState.posts.length,
            ),
          ),
          SliverToBoxAdapter(child: _buildBottomIndicator(feedState)),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator(FeedState feedState) {
    if (feedState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white38),
            ),
          ),
        ),
      );
    }
    if (feedState.hasReachedEnd) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            "You're all caught up! ✓",
            style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 13),
          ),
        ),
      );
    }
    return const SizedBox(height: 20);
  }
}


class _TopBar extends StatelessWidget {
  const _TopBar();

  void _showFeedFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: context,
      position: position,
      color: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem(
          child: _MenuOption(
            icon: Icons.people_outline,
            label: 'Following',
            onTap: () => Navigator.pop(context),
          ),
        ),
        PopupMenuItem(
          child: _MenuOption(
            icon: Icons.star_border,
            label: 'Favorites',
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
       
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create coming soon!'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF262626),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),

          const Spacer(),

          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _showFeedFilterMenu(ctx),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Instagram',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications coming soon! 🔔'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF262626),
              ),
            ),
            child: const Icon(Icons.favorite_border, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF262626), width: 0.5)),
        color: Colors.black,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
             
              GestureDetector(
                onTap: () => onTap(0),
                child: Icon(
                  selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: Colors.white, size: 28,
                ),
              ),

              GestureDetector(
                onTap: () => onTap(1),
                child: Icon(
                  selectedIndex == 1 ? Icons.smart_display : Icons.smart_display_outlined,
                  color: Colors.white, size: 26,
                ),
              ),
            
              GestureDetector(
                onTap: () => onTap(2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      selectedIndex == 2 ? Icons.send : Icons.send_outlined,
                      color: Colors.white, size: 26,
                    ),
                    Positioned(
                      right: -3,
                      bottom: 0,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3860),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
              GestureDetector(
                onTap: () => onTap(3),
                child: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
           
              GestureDetector(
                onTap: () => onTap(4),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: selectedIndex == 4
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}