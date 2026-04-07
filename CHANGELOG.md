## 1.1.0

*   **Global Theme Static Configuration! 🎨**
    *   Introduced `SkeletixTheme.configure(...)` to set brand-wide defaults once in `main()`.
    *   Added **Dual-Mode Support**: Configure separate `skeletonColor` and `shimmerColor` for Light and Dark modes globally.
    *   **Automatic Theme-Awareness**: SkeletiX now intelligently detects the current `Theme.of(context).brightness` and applies appropriate polished defaults if no config is provided.
    *   **Simplified API**: Removed the need for the `SkeletixTheme` InheritedWidget, making the package truly "set-and-forget".

## 1.0.2

* **Analysis Optimization! 📈**
* Resolved `pub.dev` score issue by shortening the package description to recommended length.
* Optimized metadata for a perfect 160/160 pub points score.

## 1.0.1

* **Metadata Optimization! 🚀**
* Integrated `topics` for better discoverability on `pub.dev`.
* Updated `pubspec.yaml` with explicit `repository` and `issue_tracker` links.
* Updated standard `README.md` with correct raw Demo GIF animation URLs.
* Enhanced package description for official publishing.

## 1.0.0

* **Initial Production Release! 🎉**
* Introduced `SkeletiX` global layout wrapper utilizing advanced `RenderObject` topology mapping.
* Natively intercepts structural UI leaf shapes (`RenderParagraph`, `RenderDecoratedBox`, `RenderPhysicalShape`, `RenderImage`, and `ShapeDecoration`) to paint absolute precision geometrical placeholders.
* Handled full declarative parameter sets including `error` states, customizable `onRetry` callbacks, and `customErrorWidget` overrides.
* Injected structural layout protections (`IgnorePointer`) that automatically lock viewport physics and interaction scrolling safely during dummy data loads.
* Shipped `SkeletixImage` helper component to explicitly disable and rescue standard `NetworkImage` stream crashes against `null` URL values.
* Stripped nested recursive `widgetDepth` limit dependencies, allowing pure infinite layout scanning gracefully.
* Removed deprecated `SkeletixAvatar` and `SkeletixText` in favor of promoting standard `CircleAvatar` / `Text` implementations.
