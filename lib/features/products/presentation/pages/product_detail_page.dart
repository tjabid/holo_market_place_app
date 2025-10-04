import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_icon_badge.dart';
import '../widgets/floating_action_button.dart';

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
    if (screenWidth > 600) return 22; // Tablet
    return 18; // Phone
  }

  static double bodyFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 14; // Tablet
    return 12; // Phone
  }
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
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Product Image with floating buttons on top
                      _buildProductImage(),

                      // Favorite button
                      Positioned(
                        bottom: -24, // Half of button height (48/2 = 24)
                        right: 20,
                        child: CustomFloatingActionButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });

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
                          semanticLabel: isFavorite
                              ? 'Remove ${widget.product.title} from favorites'
                              : 'Add ${widget.product.title} to favorites',
                          semanticHint: 'Double tap to toggle favorite',
                          iconColor: isFavorite ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.product.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                textAlign: TextAlign.right,
                                "\$ ${widget.product.price}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Align(
                            //     alignment: Alignment.centerRight,
                            //     child: IconButton(
                            //       icon: Icon(
                            //         isFavorite
                            //             ? Icons.favorite
                            //             : Icons.favorite_border,
                            //         color:
                            //             isFavorite ? Colors.red : Colors.grey[600],
                            //         size: 24,
                            //       ),
                            //       onPressed: () {
                            //         setState(() {
                            //           isFavorite = !isFavorite;
                            //         });

                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(
                            //             content: Text(
                            //               isFavorite
                            //                   ? 'Added to favorites'
                            //                   : 'Removed from favorites',
                            //             ),
                            //             duration: const Duration(seconds: 1),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Separator
                        Divider(
                          color: Colors.grey[200],
                          thickness: 0.5,
                          height: 1,
                        ),

                        const SizedBox(height: 20),

                        // Description
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize:
                                _ProductDetailConstants.bodyFontSize(context),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Separator
                        Divider(
                          color: Colors.grey[200],
                          thickness: 0.5,
                          height: 1,
                        ),
                        const SizedBox(height: 20),

                        // Rating
                        _buildRating(),

                        const SizedBox(height: 20),
                        // Separator
                        Divider(
                          color: Colors.grey[200],
                          thickness: 0.5,
                          height: 1,
                        ),
                        const SizedBox(height: 20),

                        // Choose Size - Only show for clothing items
                        if (_shouldShowSizeSelector) ...[
                          const Text(
                            'Choose size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Semantics(
        label: 'Go back to product list',
        button: true,
        child: Positioned(
          top: 50,
          left: 20,
          child: CustomFloatingActionButton(
            padding: 0,
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
            semanticLabel: 'Go back to product list',
            semanticHint: 'Go back to product list',
          ),
        ),
      ),
      actions: const [
        CartIconBadge(),
        SizedBox(width: 24),
      ],
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Favorite Button
          Positioned(
            top: 50,
            right: 20,
            child: CustomFloatingActionButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              onTap: () {
                setState(() {
                  isFavorite = !isFavorite;
                });

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
              semanticLabel: isFavorite
                  ? 'Remove ${widget.product.title} from favorites'
                  : 'Add ${widget.product.title} to favorites',
              semanticHint: 'Double tap to toggle favorite',
              iconColor: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Cache the image height calculation to avoid repeated computation
    final imageHeight = _ProductDetailConstants.imageHeight(context);
    final cacheSize =
        (imageHeight * MediaQuery.of(context).devicePixelRatio).toInt();

    return Container(
      width: double.infinity,
      height: _ProductDetailConstants.imageContainerHeight(context) +
          statusBarHeight,
      padding: EdgeInsets.only(top: statusBarHeight),
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Stack(
        children: [
          // back button
          // Positioned(
          //   top: 20,
          //   left: 20,
          //   child: CustomFloatingActionButton(
          //     icon: Icons.arrow_back,
          //     onTap: () => Navigator.pop(context),
          //     semanticLabel: 'Go back to product list',
          //     semanticHint: 'Go back to product list',
          //   ),
          // ),

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

                final isDarkError =
                    Theme.of(context).brightness == Brightness.dark;

                return Container(
                  color: isDarkError ? Colors.grey[900] : Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color:
                            isDarkError ? Colors.grey[600] : Colors.grey[400],
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color:
                              isDarkError ? Colors.grey[400] : Colors.grey[600],
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
          // Positioned(
          //   top: 20,
          //   right: 20,
          //   child: CustomFloatingActionButton(
          //     icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          //     onTap: () {
          //       setState(() {
          //         isFavorite = !isFavorite;
          //       });

          //       // Show feedback for accessibility
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text(
          //             isFavorite
          //                 ? 'Added to favorites'
          //                 : 'Removed from favorites',
          //           ),
          //           duration: const Duration(seconds: 1),
          //         ),
          //       );
          //     },
          //     semanticLabel: isFavorite
          //         ? 'Remove ${widget.product.title} from favorites'
          //         : 'Add ${widget.product.title} to favorites',
          //     semanticHint: 'Double tap to toggle favorite',
          //     iconColor: isFavorite ? Colors.red : null,
          //   ),
          // ),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${widget.product.ratingCount} reviews)',
            style: const TextStyle(
              fontSize: 12,
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
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.black : Colors.white),
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
                fontSize: 14,
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

    return GestureDetector(
      onTap: () {
        context.read<CartCubit>().addToCart(
              widget.product,
              selectedSize: _shouldShowSizeSelector ? selectedSize : null,
            );
        _showAddedToCartSnackBar(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 22, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
            Icon(Icons.check_circle,
                color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 12),
            Text('Added to cart successfully!',
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
