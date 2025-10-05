import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holo_market_place_app/features/products/presentation/cubit/cart/cart_cubit.dart';
import 'package:holo_market_place_app/features/products/presentation/cubit/cart/cart_state.dart';
import 'package:holo_market_place_app/features/products/presentation/widgets/cart/cart_item_widget.dart';
import 'package:holo_market_place_app/features/products/presentation/widgets/cart/cart_summary_widget.dart';
import 'package:holo_market_place_app/features/products/presentation/widgets/cart/empty_cart_widget.dart';

import '../widgets/cart/promo_code_section.dart';
import '../widgets/common/buttom_button.dart';
import '../widgets/common/error_view.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartEmpty) {
            return const EmptyCartWidget();
          }

          if (state is CartError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<CartCubit>().loadCart(),
            );
          }

          if (state is CartLoaded) {
            return _buildCartContent(context, state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'My Cart',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoaded && state.cart.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear Cart',
                onPressed: () => _showClearCartDialog(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.cart.items.length,
            itemBuilder: (context, index) {
              final cartItem = state.cart.items[index];
              return CartItemWidget(cartItem: cartItem);
            },
          ),
        ),

        // Promo Code Section
        const PromoCodeSection(),

        // Cart Summary
        CartSummaryWidget(cart: state.cart),

        // Checkout Button
        BottomButton(
          textButton:
              'Proceed to Checkout \$${state.cart.total.toStringAsFixed(2)}',
          iconButton: Icons.lock_outline,
          onPressed: () {
            _handleCheckout(context, state);
          },
        )
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartLoaded state) {
    // TODO: Implement checkout navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Proceeding to checkout with ${state.cart.itemCount} items',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
