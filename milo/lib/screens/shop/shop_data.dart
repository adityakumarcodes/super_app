part of '../shop.dart';

const Color _ink = Color(0xFF2F2D2D);
const Color _muted = Color(0xFF77716C);
const Color _accent = Color(0xFFFFB45C);

class ShopProduct {
  final int id;
  final String name;
  final int price;
  final String image;
  final String category;
  final String weight;
  final String description;
  final double rating;
  final int reviews;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.weight = '500g',
    this.description =
        'Fresh, carefully selected produce with excellent quality and flavor.',
    this.rating = 4.9,
    this.reviews = 118,
  });
}

/// Temporary data. Replace with products from the Aloha API when connected.
const List<ShopProduct> _products = [
  ShopProduct(
    id: 1,
    name: 'Organic Heirloom Tomatoes',
    price: 120,
    image: 'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/tomato.jpg',
    category: 'Grocery',
    weight: '500g',
    description: 'Juicy heirloom tomatoes with vibrant colors and rich flavor. Perfect for salads, pasta sauces, and everyday cooking.',
  ),
  ShopProduct(
    id: 2,
    name: 'Fresh Cauliflower',
    price: 60,
    image: 'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/cauliflower.jpg',
    category: 'Grocery',
    weight: '1 piece',
    description:
        'Fresh cauliflower, ideal for curries, roasting, and everyday meals.',
  ),
  ShopProduct(
    id: 3,
    name: 'Green Beans',
    price: 80,
    image: 'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/beans.jpg',
    category: 'Grocery',
    weight: '500g',
    description: 'Crisp green beans selected for freshness and flavor.',
  ),
  ShopProduct(
    id: 4,
    name: 'Fresh Tomatoes',
    price: 45,
    image: 'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/tomato.jpg',
    category: 'Grocery',
    weight: '500g',
    description: 'Fresh everyday tomatoes for salads and home cooking.',
  ),
];

class _ShopCategory {
  final String name;
  final IconData icon;

  const _ShopCategory(this.name, this.icon);
}

const List<_ShopCategory> _categories = [
  _ShopCategory('Electronics', LucideIcons.monitor),
  _ShopCategory('Grocery', LucideIcons.carrot),
  _ShopCategory('Gifts & Flowers', LucideIcons.rose),
  _ShopCategory('Beauty', LucideIcons.sparkle),
  _ShopCategory('Fashion', LucideIcons.shirt),
  _ShopCategory('Baby', LucideIcons.baby),
  _ShopCategory('Brands', LucideIcons.tags),
  _ShopCategory('Food', LucideIcons.utensils),
  _ShopCategory('Travel', LucideIcons.plane),
];
