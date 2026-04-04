import 'package:flutter/material.dart';
import 'package:skeletix/skeletix.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================================
// DATA MODELS
// ============================================================================

class BannerAd {
  final String? imageUrl;
  BannerAd(this.imageUrl);
}

class Category {
  final String? title;
  final String? iconUrl;
  Category(this.title, this.iconUrl);
}

class Product {
  final String? title;
  final String? imageUrl;
  final String? price;
  Product(this.title, this.imageUrl, this.price);
}

class EcomData {
  final List<BannerAd> banners;
  final List<Category> categories;
  final List<Product> products;

  EcomData({
    required this.banners,
    required this.categories,
    required this.products,
  });
}

// ============================================================================
// APP ENTRY
// ============================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkeletiX E-commerce Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EcomHomePage(),
    );
  }
}

class EcomHomePage extends StatefulWidget {
  const EcomHomePage({super.key});

  @override
  State<EcomHomePage> createState() => _EcomHomePageState();
}

class _EcomHomePageState extends State<EcomHomePage> {
  bool _isLoading = true;
  String? _error;
  EcomData? _data;

  @override
  void initState() {
    super.initState();
    _fetchApiData();
  }

  void _fetchApiData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _data = null;
    });

    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _data = EcomData(
          banners: [
            BannerAd(
              'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=1000&q=80',
            ),
          ],
          categories: [
            Category('Clothing', 'https://picsum.photos/seed/clothing/150'),
            Category(
              'Electronics',
              'https://picsum.photos/seed/electronics/150',
            ),
            Category('Home', 'https://picsum.photos/seed/home/150'),
            Category('Beauty', 'https://picsum.photos/seed/beauty/150'),
          ],
          products: [
            Product(
              'Wireless Headphones',
              'https://picsum.photos/seed/headphone/400',
              '\$299.99',
            ),
            Product(
              'Smart Watch Series 8',
              'https://picsum.photos/seed/watch/400',
              '\$399.00',
            ),
            Product(
              'Minimalist Desk Lamp',
              'https://picsum.photos/seed/lamp/400',
              '\$45.50',
            ),
            Product(
              'Ergonomic Chair',
              'https://picsum.photos/seed/chair/400',
              '\$199.99',
            ),
          ],
        );
      });
    }
  }

  void _simulateError() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _data = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = "Network Failed: Could not connect to the store servers.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SkeletiX Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchApiData,
            tooltip: "Retry Connection",
          ),
          IconButton(
            icon: const Icon(Icons.error_outline),
            onPressed: _simulateError,
            tooltip: "Fail Connection",
          ),
          const IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: null,
          ),
        ],
      ),
      body: SkeletiX(
        loading: _isLoading,
        error: _error,
        onRetry: () => _fetchApiData(),
        //customErrorWidget: const Center(child: Text('Custom Error Widget')),
        child: _buildEcomLayout(),
      ),
    );
  }

  /// ABSOLUTE PURE DECLARATIVE LAYOUT!
  /// Notice there is ZERO "_isLoading" logic anywhere inside this method.
  /// SkeletiX inherently understands how to structurally map our data gaps!
  Widget _buildEcomLayout() {
    // 1. Array Fallbacks
    // When _data is null during loading, we temporarily yield arrays of nulls.
    final banners = _data?.banners ?? List.generate(1, (_) => BannerAd(null));
    final categories =
        _data?.categories ??
        List.generate(4, (_) => Category('Category', null));
    final products =
        _data?.products ??
        List.generate(
          4,
          (_) => Product('Loading Product Title...', null, '\$00.00'),
        );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // --- PROMO BANNERS ---
        SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SkeletixImage.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // --- CATEGORIES ---
        const Text(
          'Shop by Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.transparent,
                      backgroundImage: category.iconUrl != null
                          ? NetworkImage(category.iconUrl!)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // --- TRENDING PRODUCTS ---
        const Text(
          'Trending Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              color: const Color(0xFFF8F9FA),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Safe Image Container
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SkeletixImage.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Safe Texts
                    Text(
                      product.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.price ?? '',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Framework buttons are inherently structurally analyzed!
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
