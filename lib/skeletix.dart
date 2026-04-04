library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ============================================================================
// PUBLIC API
// ============================================================================

/// A widget that automatically overlays a skeletal layout loader or an error
/// view based on the provided [child] widget's structural design.
///
/// [SkeletiX] uses an advanced [RenderObject] interception strategy. Rather than
/// applying a blanket color filter over the widget, it iterates down the real
/// render layout. It perfectly maps and draws precision-placed grey rectangles
/// and circles directly over leaf semantics (like [Text], [Image], or [CircleAvatar]),
/// preserving your original background shapes, paddings, and card structures.
///
/// ### Example Usage
/// ```dart
/// SkeletiX(
///   loading: _isLoading,
///   error: _errorMessage, // If not null, replacing content with an error view.
///   child: const UserProfileCard(),
/// )
/// ```
class SkeletiX extends StatelessWidget {
  /// Defines whether the skeleton loading state should be overlayed onto the [child].
  ///
  /// When set to `true`, the internal renderer intercepts drawing paths to create
  /// grey blocks over content-bearing widgets.
  final bool loading;

  /// The error to display when an operation fails.
  ///
  /// If [error] is not null, the [child] widget is removed from the visible tree
  /// and replaced automatically with an error fallback view.
  final Object? error;

  /// Optional callback to trigger a retry request.
  /// If provided, a "Retry" button automatically appears in the default error view.
  final VoidCallback? onRetry;

  /// A completely custom error widget that instantly replaces the default error layout.
  final Widget? customErrorWidget;

  /// The original widget that should be rendered precisely when [loading] is false
  /// and [error] is null.
  ///
  /// During the [loading] state, this widget serves as the "stencil" to generate
  /// the automatic skeleton layout.
  final Widget child;

  /// Creates a [SkeletiX] automatic loading wrapper.
  const SkeletiX({
    super.key,
    required this.loading,
    this.error,
    this.onRetry,
    this.customErrorWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorState(context);
    }

    if (loading) {
      return _SkeletixShimmer(
        child: IgnorePointer(
          ignoring:
              true, // Prevents all scrolling and button clipping while loading
          child: _SkeletixRenderWidget(child: child),
        ),
      );
    }

    return child;
  }

  /// Builds the default error fallback state when [error] is provided.
  Widget _buildErrorState(BuildContext context) {
    if (customErrorWidget != null) {
      return customErrorWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade900,
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// RENDERING CORE
// ============================================================================

/// The core [RenderObjectWidget] that delegates painting to a specialized ProxyBox.
/// This widget never changes the physical UI layout hierarchy; it acts as an invisible
/// interceptor perfectly sized to its enclosed [child].
class _SkeletixRenderWidget extends SingleChildRenderObjectWidget {
  const _SkeletixRenderWidget({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSkeletix();
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSkeletix renderObject) {}
}

/// A lightweight data class holding the exact spatial geometry and corner rounding
/// of an intercepted render target (like an Avatar or Text bounds).
class _SkeletonBox {
  /// The exact bounds shifted to the layout offset.
  final Rect rect;

  /// Determines whether to paint a strict circle or rectangle layout.
  final BoxShape shape;

  /// Border radii copied directly from identically shaped original widgets.
  final BorderRadius? borderRadius;

  const _SkeletonBox(
    this.rect, {
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });
}

/// The intercepting [RenderProxyBox] manipulating the canvas painting phase.
class _RenderSkeletix extends RenderProxyBox {
  _RenderSkeletix();

  @override
  void paint(PaintingContext context, Offset offset) {
    // 1. Paint the original layout hierarchy untouched.
    // This maintains original backgrounds, borders, padding and shadows perfectly.
    super.paint(context, offset);

    // 2. Map and structurally outline target components for skeletonizing.
    final List<_SkeletonBox> boxes = [];

    // Recursive advanced widget tree analyzer to discover ANY content leaves.
    // Tree graph is strictly directed and acyclic natively in Flutter
    void collectBoxes(RenderObject node) {
      bool handled = false;

      // Type-promotion to RenderBox granting physical geometry access.
      if (node is RenderBox && node.hasSize) {
        final String typeName = node.runtimeType.toString();

        // 1. Precise Corner/Shape Mappings for known major content:
        if (node is RenderParagraph) {
          final transform = node.getTransformTo(this);
          var rect = MatrixUtils.transformRect(
            transform,
            Offset.zero & node.size,
          );

          // Advanced automatic empty string placeholder resolution
          double w = rect.width <= 0 ? 120.0 : rect.width;
          double h = rect.height <= 0 ? 16.0 : rect.height;

          rect = Rect.fromLTWH(rect.left, rect.top, w, h);
          boxes.add(
            _SkeletonBox(
              rect.shift(offset),
              borderRadius: BorderRadius.circular(4),
            ),
          );
          handled = true;
        } else if (typeName == 'RenderImage' || node is RenderImage) {
          final transform = node.getTransformTo(this);
          final rect = MatrixUtils.transformRect(
            transform,
            Offset.zero & node.size,
          );
          if (rect.width > 0 && rect.height > 0) {
            boxes.add(
              _SkeletonBox(
                rect.shift(offset),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }
          handled = true;
        } else if (node is RenderDecoratedBox) {
          final boxDeco = node.decoration;
          final transform = node.getTransformTo(this);
          final rect = MatrixUtils.transformRect(
            transform,
            Offset.zero & node.size,
          );

          if (boxDeco is BoxDecoration) {
            if (boxDeco.shape == BoxShape.circle) {
              boxes.add(
                _SkeletonBox(rect.shift(offset), shape: BoxShape.circle),
              );
              handled = true;
            } else if (boxDeco.color != null && rect.height < 500) {
              BorderRadius? br = (boxDeco.borderRadius is BorderRadius)
                  ? boxDeco.borderRadius as BorderRadius
                  : null;
              boxes.add(
                _SkeletonBox(
                  rect.shift(offset),
                  borderRadius: br ?? BorderRadius.circular(4),
                ),
              );
              handled = true;
            }
          } else if (boxDeco is ShapeDecoration) {
            // CircleAvatar heavily uses ShapeDecoration!
            if (boxDeco.shape is CircleBorder) {
              boxes.add(
                _SkeletonBox(rect.shift(offset), shape: BoxShape.circle),
              );
              handled = true;
            } else if (boxDeco.color != null) {
              boxes.add(_SkeletonBox(rect.shift(offset)));
              handled = true;
            }
          }
        } else if (node is RenderPhysicalShape || node is RenderPhysicalModel) {
          final transform = node.getTransformTo(this);
          final rect = MatrixUtils.transformRect(
            transform,
            Offset.zero & node.size,
          );
          // ElevatedButtons, OutlinedButtons, and Chips rely on RenderPhysicalShape/Model.
          // We limit this to standard interactive heights (<= 65) to mask buttons perfectly into grey blocks
          // without accidentally masking giant screen-sized or tall list cards.
          if (rect.width > 0 && rect.height > 0 && rect.height <= 65) {
            boxes.add(
              _SkeletonBox(
                rect.shift(offset),
                borderRadius: BorderRadius.circular(8),
              ),
            );
            handled = true;
          }
        } else if (typeName == '_RenderColoredBox') {
          final transform = node.getTransformTo(this);
          final rect = MatrixUtils.transformRect(
            transform,
            Offset.zero & node.size,
          );
          // High thresholds allow parsing very large background block panels
          if (rect.width > 0 && rect.height > 0 && rect.height < 600) {
            boxes.add(
              _SkeletonBox(
                rect.shift(offset),
                borderRadius: BorderRadius.circular(4),
              ),
            );
            handled = true;
          }
        }

        // 2. ADVANCED GLOBAL LEAF DETECTION ALGORITHM
        // If not explicitly handled above, we check if it's the very bottom of the widget tree (a leaf).
        if (!handled) {
          bool isLeaf = true;
          node.visitChildren((child) {
            isLeaf = false;
          });

          // If this node has NO children, it's a leaf!
          // We must draw a skeleton over it IF it's a visual drawing node (like SVG, Checkbox, Slider, CustomPaint)
          // and NOT just a transparent invisible layout spacer (like SizedBox, Padding, Align).
          if (isLeaf) {
            final bool isTransparentStructuralBox =
                typeName.contains('RenderConstrainedBox') ||
                typeName.contains('RenderPadding') ||
                typeName.contains('RenderPositionedBox') ||
                typeName.contains('RenderFlex') ||
                typeName.contains('RenderProxyBox') ||
                typeName.contains('RenderPointerListener') ||
                typeName.contains('RenderSemanticsAnnotations');

            if (!isTransparentStructuralBox) {
              final transform = node.getTransformTo(this);
              final rect = MatrixUtils.transformRect(
                transform,
                Offset.zero & node.size,
              );

              if (rect.width > 0 && rect.height > 0) {
                boxes.add(
                  _SkeletonBox(
                    rect.shift(offset),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
                handled = true;
              }
            }
          }
        }
      }

      // If we didn't paint a skeleton box over this node, dive deeper into its children recursively.
      if (!handled) {
        node.visitChildren((child) {
          collectBoxes(child);
        });
      }
    }

    if (child != null) {
      collectBoxes(child!);
    }

    // 3. Render precision geometries replacing the detected target areas.
    final paint = Paint()..color = const Color(0xFFE0E0E0);
    for (var box in boxes) {
      if (box.shape == BoxShape.circle) {
        context.canvas.drawCircle(box.rect.center, box.rect.width / 2, paint);
      } else {
        if (box.borderRadius != null) {
          // Applies the exact physical corner radiuses cloned from the inner widget.
          context.canvas.drawRRect(box.borderRadius!.toRRect(box.rect), paint);
        } else {
          context.canvas.drawRRect(
            RRect.fromRectAndRadius(box.rect, const Radius.circular(4)),
            paint,
          );
        }
      }
    }
  }
}

// ============================================================================
// ANIMATION OVERLAYS
// ============================================================================

/// A structural wrapper overlaying a synchronized, high-performance visual Shimmer.
/// This runs using a purely GPU-accelerated [ShaderMask] instead of rebuilding layout.
class _SkeletixShimmer extends StatefulWidget {
  final Widget child;

  const _SkeletixShimmer({required this.child});

  @override
  State<_SkeletixShimmer> createState() => _SkeletixShimmerState();
}

class _SkeletixShimmerState extends State<_SkeletixShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // Generates the sweeping frosty beam of light translating across contents
            final gradient = LinearGradient(
              colors: [
                Colors.white.withAlpha(0),
                Colors.white.withAlpha(102), // 0.4 mapped to alpha
                Colors.white.withAlpha(0),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            );
            return gradient.createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Computes the exact translational offset of the light beam on the X axis, mapping
/// the [0.0, 1.0] [slidePercent] uniformly across rendering bounds.
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Scales the animation to cross completely from out-of-bounds left to out-of-bounds right
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1.0),
      0.0,
      0.0,
    );
  }
}

// ============================================================================
// QUALITY OF LIFE HELPERS
// ============================================================================

/// A drop-in replacement for [Image.network] that natively handles null strings
/// without crushing operations.
///
/// If the string is null/empty during loading operations, it gracefully returns
/// a transparent [Container] precisely matched to your provided properties that
/// [SkeletiX]'s advanced RenderObject map natively catches and skeletonizes.
class SkeletixImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isAsset;

  const SkeletixImage.network(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
  }) : isAsset = false;

  /// Safely resolves local asset images.
  const SkeletixImage.asset(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
  }) : isAsset = true;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        width: width ?? 50,
        height: height ?? 50,
        color: Colors.transparent, // Natively detected by global leaf analysis!
      );
    }

    if (isAsset) {
      return Image.asset(url!, width: width, height: height, fit: fit);
    }

    return Image.network(url!, width: width, height: height, fit: fit);
  }
}
