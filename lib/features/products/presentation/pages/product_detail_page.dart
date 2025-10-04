import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_icon_badge.dart';

// Responsive constants for ProductDetailPage
class _ProductDetailConstants {
  // Responsive heights based on screen size
  static double imageContainerHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight > 900) return 500; // Tablet/Large phone
    if (screenHeight > 700) return 400; // Normal phone
    return 350; // Small phone
  }
  
  static double imageHeight(BuildContext context) {
    return imageContainerHeight(context) * 0.875; // 87.5% of container
  }
  
  static double titleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 28; // Tablet
    return 24; // Phone
  }
  
  static double bodyFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 16; // Tablet
    return 14; // Phone
  }
  
  // Minimum tap target for accessibility
  static const double minTapTarget = 48.0;
}

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  static const routeName = '/product-detail';

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorite = false;
  String selectedSize = 'M';
  final List<String> sizes = ['S', 'M', 'L', 'XL'];

  // Helper to determine if size selector should be shown
  bool get _shouldShowSizeSelector {
    final category = widget.product.category.toLowerCase();
    return category.contains('clothing') || 
           category.contains('apparel') ||
           category.contains("women's clothing") ||
           category.contains("men's clothing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  _buildProductImage(),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.product.title,
                          style: TextStyle(
                            fontSize: _ProductDetailConstants.titleFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating
                        _buildRating(),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: _ProductDetailConstants.bodyFontSize(context),
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Choose Size - Only show for clothing items
                        if (_shouldShowSizeSelector) ...[
                          Text(
                            'Choose size',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Size Options
                          _buildSizeOptions(),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar - Price and Add to Cart
          _buildBottomBar(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: Semantics(
        label: 'Go back to product list',
        button: true,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Details',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      
      actions: const [
        CartIconBadge(),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _buildProductImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cache the image height calculation to avoid repeated computation
    final imageHeight = _ProductDetailConstants.imageHeight(context);
    final cacheSize = (imageHeight * MediaQuery.of(context).devicePixelRatio).toInt();
    
    return Container(
      width: double.infinity,
      height: _ProductDetailConstants.imageContainerHeight(context),
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Stack(
        children: [
          // Product Image
          Center(
            child: CachedNetworkImage(
              imageUrl: widget.product.image,
              fit: BoxFit.contain,
              height: imageHeight,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              errorWidget: (context, url, error) {
                // Log error for debugging
                debugPrint('Failed to load product image: $error');
                
                final isDarkError = Theme.of(context).brightness == Brightness.dark;
                
                return Container(
                  color: isDarkError ? Colors.grey[900] : Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: isDarkError ? Colors.grey[600] : Colors.grey[400],
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: isDarkError ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {}); // Trigger rebuild to retry loading
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          'Retry',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              // Cache optimization
              memCacheHeight: cacheSize,
              maxHeightDiskCache: cacheSize,
            ),
          ),

          // Favorite Button with accessibility
          Positioned(
            top: 20,
            right: 20,
            child: Semantics(
              label: isFavorite 
                ? 'Remove ${widget.product.title} from favorites' 
                : 'Add ${widget.product.title} to favorites',
              button: true,
              hint: 'Double tap to toggle favorite',
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                  
                  // Show feedback for accessibility
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite 
                          ? 'Added to favorites' 
                          : 'Removed from favorites',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  // Ensure minimum tap target for accessibility
                  constraints: const BoxConstraints(
                    minWidth: _ProductDetailConstants.minTapTarget,
                    minHeight: _ProductDetailConstants.minTapTarget,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Theme.of(context).iconTheme.color,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Semantics(
      label: 'Average rating: ${widget.product.rating} out of 5 stars, '
             'based on ${widget.product.ratingCount} customer reviews',
      excludeSemantics: true,
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.product.rating}/5',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${widget.product.ratingCount} reviews)',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: sizes.map((size) {
        final isSelected = selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSize = size;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.grey[800] : Colors.white),
              border: Border.all(
                color: isSelected 
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.grey[600]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              size,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price with accessibility
            Expanded(
              flex: 2,
              child: Semantics(
                label: 'Price: ${widget.product.price.toStringAsFixed(2)} dollars',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add to Cart Button with accessibility
            Expanded(
              flex: 3,
              child: Semantics(
                label: 'Add ${widget.product.title} to cart for ${widget.product.price.toStringAsFixed(2)} dollars',
                button: true,
                hint: 'Double tap to add item to shopping cart',
                child: ElevatedButton(
                  onPressed: () {
                    // Add to cart using CartCubit
                    context.read<CartCubit>().addToCart(
                      widget.product,
                      selectedSize: _shouldShowSizeSelector ? selectedSize : null,
                    );
                    _showAddedToCartSnackBar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 22, color: isDark ? Colors.black : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedToCartSnackBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 12),
            Text('Added to cart successfully!', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}