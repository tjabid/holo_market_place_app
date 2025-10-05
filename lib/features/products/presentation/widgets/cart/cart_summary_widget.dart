import 'package:flutter/material.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';

class CartSummaryWidget extends StatelessWidget {
  final Cart cart;

  const CartSummaryWidget({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Subtotal
          _buildSummaryRow(
            context,
            'Subtotal',
            '\$${cart.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),

          // Shipping
          _buildSummaryRow(
            context,
            'Shipping',
            cart.shippingCost > 0
                ? '\$${cart.shippingCost.toStringAsFixed(2)}'
                : 'FREE',
            isShipping: cart.shippingCost == 0,
          ),
          const SizedBox(height: 6),

          // // Tax
          // _buildSummaryRow(
          //   context,
          //   'Tax (${(cart.taxRate * 100).toStringAsFixed(0)}%)',
          //   '\$${cart.tax.toStringAsFixed(2)}',
          // ),

          // // Discount (if applied)
          // if (cart.discount > 0) ...[
          //   const SizedBox(height: 8),
          //   _buildSummaryRow(
          //     context,
          //     'Discount${cart.promoCode != null ? " (${cart.promoCode})" : ""}',
          //     '-\$${cart.discount.toStringAsFixed(2)}',
          //     isDiscount: true,
          //   ),
          // ],

          const Divider(height: 24),

          // Total
          _buildSummaryRow(
            context,
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),

          const SizedBox(height: 12),

          // Estimated Delivery
          _buildEstimatedDelivery(context),

          // const SizedBox(height: 12),

          // // Payment Methods
          // _buildPaymentMethods(context),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
    bool isShipping = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedDelivery(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Estimated delivery: 3-5 business days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
