class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFavorite;

  const Product(
      {this.description,
      this.id,
      this.imageUrl,
      this.isFavorite,
      this.price,
      this.title});
}
