/// A class that represents a product item in the marketplace.
class SampleItem {
  const SampleItem({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final double rating;
  final String imageUrl;
}
