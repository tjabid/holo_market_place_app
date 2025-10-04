import 'package:flutter/material.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Cart Icon/Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Looks like you haven\'t added\nanything to your cart yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Start Shopping Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Optional: Quick Links
            _buildQuickLinks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      children: [
        Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickLinkChip(
              context,
              'Electronics',
              Icons.devices,
            ),
            _buildQuickLinkChip(
              context,
              'Jewelry',
              Icons.diamond_outlined,
            ),
            _buildQuickLinkChip(
              context,
              'Men\'s Clothing',
              Icons.checkroom,
            ),
            _buildQuickLinkChip(
              context,
              'Women\'s Clothing',
              Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLinkChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // TODO: Navigate to specific category
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
