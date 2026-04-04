# SkeletiX 🚀

An absolute **Set-and-Forget**, highly performant, auto-analyzing skeleton loading engine for Flutter. 

Unlike traditional skeleton packages that force you to manually rewrite "dummy" blocks mapping out your UI, **SkeletiX climbs into your Native Render Tree natively**. It intercepts `Text`, `CircleAvatar`, `Image`, Material `Cards`, and `ElevatedButton` leaf nodes geometrically and precisely masks them with beautifully animated Shimmer blocks without requiring **ANY** additional `_isLoading` layout changes from you!

Build your UI exactly once structurally using dummy Strings, wrap it in `<SkeletiX>`, and never think about loaders again.

<img src="https://raw.githubusercontent.com/manish/skeletix/main/demo.gif" height="400"/>

---

## 🌟 Why use SkeletiX?
1. **100% Purely Declarative:** No more `_isLoading ? SkeletonBlock() : RealLayout()` everywhere. Just pass `loading: true` onto the parent wrapper.
2. **True Geometric Analysis:** Intercepts low-level Flutter geometries (`RenderDecoratedBox`, `RenderPhysicalShape`, `ShapeDecoration`) via `SingleChildRenderObjectWidget` to trace exactly what is on the screen without touching layout spaces, paddings, or grid ratios natively.
3. **Scroll-Locked Safety:** Natively injects `IgnorePointer` during load phases. Completely blocks all touch events and viewport scrolling natively so users cannot accidentally click buttons or tear screen offsets before data stabilizes.
4. **Instant Network Protections:** Shipped alongside `SkeletixImage`, explicitly designed to prevent standard `Image.network(null)` crashes before URLs are fetched.
5. **Built-in Error Handling:** Seamlessly intercepts loading routines into full error views, supplying customizable `onRetry` buttons and totally custom Screen-swaps explicitly.

---

## 🔧 Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  skeletix: ^1.0.0
```

---

## 🛠️ Usage

### 1. Simple Drop-In
Wrap your pre-existing view entirely inside the `SkeletiX` engine.

```dart
SkeletiX(
  loading: _isLoading,
  error: _hasError ? "Failed to verify connection" : null,
  onRetry: () => _fetchData(), // Automatically renders a Try Again button!
  child: _buildMyComplexLayout(),
)
```

### 2. Handling Network Images Crash-Free
Standard `Image.network` natively throws unrecoverable Render Exceptions if passed a `null` URL before data hits. 

Simply replace it with `SkeletixImage`! If the URL is `null`, it gracefully drops a transparent block which the `SkeletiX` Engine natively reads and turns into a precision-cut generic Skeleton Loader image box!

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: SkeletixImage.network(
    product.imageUrl, // Perfectly safe if null!
    width: 200,
    fit: BoxFit.cover,
  ),
)
```

### 3. Dummy Data Sizing Rule 
To generate structurally beautiful grid or list skeletons, the UI **must physically take up layout space**. If you supply `Text(null ?? '')`, Flutter collapses its width to `0.0`, resulting in a tiny, empty box.

Supply standard mock strings/arrays while waiting for actual server data:
```dart
// The string 'Loading Title...' ensures the grid-card naturally keeps its padded layout shape!
final List<Product> _products = apiData?.products ?? List.generate(4, (_) => Product('Loading Title...', null));

...

Text(_products[index].title ?? '');
```

---

## 🎨 API Properties

| Parameter | Type | Description |
|-----------|------|-------------|
| `loading` | `bool` | Instantly replaces textual leaves, avatars, and images with sweeping, frosty geometric shimmers. Locks all user touch/scroll events. |
| `error` | `Object?` | Replaces the view with a natively supplied Red Icon/Text error state. Instantly stops shimmer execution. |
| `onRetry` | `VoidCallback?` | Drops an automatic standard "Try Again" widget below your error string. |
| `customErrorWidget`| `Widget?` | Completely overrides the native string error view above. Take full customized control layout of failure states. |
| `child` | `Widget` | Your native, gorgeous, real screen layout logic requiring mapping! |

---

## 👨‍💻 Maintainers
Maintained with ❤️ by [Your Name]. Feel free to open issues or PRs!
