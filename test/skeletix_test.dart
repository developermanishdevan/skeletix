import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletix/skeletix.dart';

void main() {
  group('SkeletiX Widget Tests', () {
    testWidgets('Renders original child when loading is false and no error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletiX(loading: false, child: Text('Original Content')),
          ),
        ),
      );

      expect(find.text('Original Content'), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // Just ensuring no default loaders
    });

    testWidgets('Renders Shimmer when loading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletiX(loading: true, child: Text('Original Content')),
          ),
        ),
      );

      // The child is still in the tree (for structural mapping) but it's wrapped
      // inside _SkeletixRenderWidget and _SkeletixShimmer.
      // _SkeletixShimmer uses a ShaderMask to create the animation.
      expect(find.text('Original Content'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('Renders default error view when error is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletiX(
              loading: false,
              error: 'Something went wrong',
              child: Text('Original Content'),
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        find.text('Original Content'),
        findsNothing,
      ); // Child is completely replaced
    });

    testWidgets('Renders retry button and triggers callback', (
      WidgetTester tester,
    ) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletiX(
              loading: false,
              error: 'Failed to load',
              onRetry: () {
                retryClicked = true;
              },
              child: const Text('Original Content'),
            ),
          ),
        ),
      );

      final retryButton = find.text('Try Again');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      expect(retryClicked, isTrue);
    });

    testWidgets('Renders custom error widget when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletiX(
              loading: false,
              error: 'Error',
              customErrorWidget: Center(child: Text('Custom Error Widget')),
              child: Text('Original Content'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Widget'), findsOneWidget);
      expect(find.text('Original Content'), findsNothing);
      expect(
        find.byIcon(Icons.error_outline),
        findsNothing,
      ); // Default error icon should be absent
    });
  });

  group('SkeletixImage Tests', () {
    testWidgets(
      'SkeletixImage.network with null url renders transparent Container',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SkeletixImage.network(null, width: 100, height: 100),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, equals(Colors.transparent));
      },
    );

    testWidgets(
      'SkeletixImage.asset with null url renders transparent Container',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SkeletixImage.asset(null, width: 100, height: 100),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, equals(Colors.transparent));
      },
    );
  });
}
