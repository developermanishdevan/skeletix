# SkeletiX 🚀

An absolute **Set-and-Forget**, highly performant, auto-analyzing skeleton loading engine for Flutter. 

Unlike traditional skeleton packages that force you to manually rewrite "dummy" blocks mapping out your UI, **SkeletiX climbs into your Native Render Tree natively**. It intercepts `Text`, `CircleAvatar`, `Image`, Material `Cards`, and `ElevatedButton` leaf nodes geometrically and precisely masks them with beautifully animated Shimmer blocks without requiring **ANY** additional `_isLoading` layout changes from you!

Build your UI exactly once structurally using dummy Strings, wrap it in `<SkeletiX>`, and never think about loaders again.

<img src="https://raw.githubusercontent.com/developermanishdevan/skeletix/main/skeletix1_demo.gif" height="400"/>

---

## 🌟 Why use SkeletiX?
1. **100% Purely Declarative:** No more `_isLoading ? SkeletonBlock() : RealLayout()` everywhere. Just pass `loading: true` onto the parent wrapper.
2. **True Geometric Analysis:** Intercepts low-level Flutter geometries (`RenderDecoratedBox`, `RenderPhysicalShape`, `ShapeDecoration`) via `SingleChildRenderObjectWidget` to trace exactly what is on the screen without touching layout spaces, paddings, or grid ratios natively.
3. **Automatic Theme-Awareness:** Intelligently detects **Light and Dark mode** brightness. Applies polished, mode-specific defaults for skeletons and shimmers out-of-the-box.
4. **Scroll-Locked Safety:** Natively injects `IgnorePointer` during load phases. Completely blocks all touch events and viewport scrolling natively so users cannot accidentally click buttons or tear screen offsets before data stabilizes.
5. **Instant Network Protections:** Shipped alongside `SkeletixImage`, explicitly designed to prevent standard `Image.network(null)` crashes before URLs are fetched.

---

## 🔧 Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  skeletix: ^1.1.0
```

---

## 🛠️ Usage

### 1. Global Configuration (Recommended)
You can define your brand's loading aesthetic once in your `main()` function for both Light and Dark modes. **SkeletiX** will automatically switch between these based on the system theme.

```dart
void main() {
  SkeletixTheme.configure(
    // Light Mode
    skeletonColor: const Color(0xFFF0F0F0),
    shimmerColor: Colors.white70,
    // Dark Mode
    darkSkeletonColor: const Color(0xFF242424),
    darkShimmerColor: Colors.white12,
  );

  runApp(const MyApp());
}
```

### 2. Simple Drop-In
Wrap your pre-existing view entirely inside the `SkeletiX` engine.

```dart
SkeletiX(
  loading: _isLoading,
  error: _hasError ? "Failed to verify connection" : null,
  onRetry: () => _fetchData(), // Automatically renders a Try Again button!
  child: _buildMyComplexLayout(),
)
```

### 3. Handling Network Images Crash-Free
Simply replace standard network images with `SkeletixImage`! 

```dart
SkeletixImage.network(
  product.imageUrl, // Perfectly safe if null!
  width: 200,
  fit: BoxFit.cover,
)
```

---

## 🎨 API Properties

### `SkeletixTheme.configure()` (Global)

| Parameter | Type | Description |
|-----------|------|-------------|
| `skeletonColor` | `Color?` | Base color for skeletons in Light Mode. |
| `shimmerColor` | `Color?` | Animation sweep color in Light Mode. |
| `darkSkeletonColor` | `Color?` | Base color for skeletons in Dark Mode. |
| `darkShimmerColor` | `Color?` | Animation sweep color in Dark Mode. |

### `SkeletiX` (Widget)

| Parameter | Type | Description |
|-----------|------|-------------|
| `loading` | `bool` | Instantly replaces textual leaves, avatars, and images with shimmers. |
| `error` | `Object?` | Replaces the view with a simple Error state. |
| `skeletonColor` | `Color?` | Local override for the base skeleton color. |
| `shimmerColor` | `Color?` | Local override for the shimmer sweep color. |
| `onRetry` | `VoidCallback?` | Adds an automatic "Try Again" button below your error string. |
| `customErrorWidget`| `Widget?` | Completely overrides the native string error view. |
| `child` | `Widget` | Your real screen layout logic. |

---

## 👨‍💻 Maintainers
Maintained with ❤️ by [Manishdevan D]. Feel free to open issues or PRs!
