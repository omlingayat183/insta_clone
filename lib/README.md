# 📱 Instagram Feed Clone — Flutter Assignment

A pixel-perfect, polished replication of the Instagram Home Feed built with Flutter.

---

## 🏗️ Architecture Overview

```
lib/
├── main.dart                    # App entry + ProviderScope
├── models/
│   ├── post_model.dart          # PostModel, UserModel (immutable data)
│   └── story_model.dart         # StoryModel (immutable data)
├── services/
│   └── post_repository.dart     # Data layer — mock API with 1.5s delay
├── providers/
│   └── feed_provider.dart       # Riverpod StateNotifier — all business logic
├── widgets/
│   ├── post_card.dart           # Individual post (header, image, actions, caption)
│   ├── story_tray.dart          # Horizontal stories strip
│   ├── carousel_widget.dart     # Multi-image PageView with dots
│   ├── pinch_zoom.dart          # Pinch-to-zoom via Overlay
│   └── shimmer_feed.dart        # Skeleton loading placeholders
└── screens/
    └── home_screen.dart         # Full screen with CustomScrollView + infinite scroll
```

---

## 🧠 State Management: Riverpod

**Why Riverpod over setState / Provider / Bloc?**

| | setState | Provider | Bloc | Riverpod |
|---|---|---|---|---|
| Compile-safe | ❌ | ❌ | ✅ | ✅ |
| Testable | ❌ | ✅ | ✅ | ✅ |
| Auto-dispose | ❌ | Manual | Manual | ✅ |
| No BuildContext needed | ❌ | ❌ | ❌ | ✅ |
| Boilerplate | Low | Medium | High | Low |

Riverpod was chosen because:
1. **Compile-safe**: Providers are top-level constants — typos are caught at compile time, not runtime.
2. **No context needed**: You can read providers anywhere, not just in `build()`.
3. **`.select()`**: Widgets can subscribe to *specific fields* of state, minimizing rebuilds.
4. **`FutureProvider`**: Gives `AsyncValue<T>` (loading/data/error) for free — no boilerplate.

### Key Providers

```dart
// One-shot async data (stories)
final storiesProvider = FutureProvider<List<StoryModel>>((ref) { ... });

// Stateful feed (posts, pagination, like/save)
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) { ... });
```

---

## ✨ Features Implemented

### ✅ UI Fidelity
- Top bar: Instagram wordmark, notification bell with badge, messages icon
- Story tray: gradient ring (unseen), grey ring (seen), own-story `+` button
- Post card: avatar ring, verified badge, triple-dot menu, caption, like count, timestamp

### ✅ Shimmer Loading
- Full skeleton layout for both story tray and posts
- 1.5-second simulated API latency
- Shimmer shapes exactly mirror real content layout

### ✅ Carousel + Dots
- `PageView.builder` for horizontal swipe
- `AnimatedSmoothIndicator` synced with `PageController`
- Page counter ("2/3") in top-right corner

### ✅ Pinch-to-Zoom
- `GestureDetector` `onScale` events
- `OverlayEntry` positions floating image above all UI
- `AnimationController` animates scale + offset back to origin on release

### ✅ Stateful Like & Save
- Like: animated heart button + double-tap image to like
- Save: animated bookmark toggle
- Like count updates in real-time (optimistic UI)

### ✅ Infinite Scroll Pagination
- `ScrollController` triggers `loadMorePosts()` when 600px from bottom (≈2 posts)
- Guard clauses prevent duplicate requests
- `isLoadingMore` spinner shown at bottom
- "You're all caught up!" message at end

### ✅ Pull-to-Refresh
- Swipe down to reload the feed from page 0

### ✅ Error Handling
- Broken images: shows `broken_image` icon with "Image unavailable"
- Unimplemented buttons: custom styled `SnackBar` with 3-second duration

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/instagram_feed.git
cd instagram_feed

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or simulator
flutter run

# 4. Run on specific platform
flutter run -d ios
flutter run -d android
flutter run -d chrome  # Web (pinch-zoom uses mouse scale gesture)
```

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `cached_network_image` | ^3.3.1 | Network image caching |
| `shimmer` | ^3.0.0 | Skeleton loading effect |
| `smooth_page_indicator` | ^1.1.0 | Carousel dot indicators |

---

## 🎥 Demo Recording

> [Loom Link Placeholder]

Shows:
1. Shimmer loading state (1.5s on cold start)
2. Smooth infinite scrolling with pagination spinner
3. Pinch-to-zoom with animated return
4. Like (button + double-tap) and Save toggles
5. Pull-to-refresh

---

## 🧪 Architecture Decisions & Trade-offs

**Images via URL (not bundled):**  
Per assignment — `cached_network_image` handles memory/disk caching via `DefaultCacheManager`. Images persist across app restarts.

**`CustomScrollView` + Slivers:**  
Using `SliverList` instead of `Column + ListView` ensures the entire feed scrolls as one unit (story tray + posts), which is essential for the Instagram layout.

**Optimistic UI for Likes:**  
Like count updates instantly in the UI without waiting for an API response. In production, we'd revert on API failure.

**`OverlayEntry` for Pinch-Zoom:**  
The zoomed image needs to appear ABOVE other UI elements. Using `Overlay` (which sits above the `Navigator`) achieves this without `Stack` z-index complexity.
