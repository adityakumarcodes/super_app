import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const Color _ink = Color(0xFF2F2D2D);
const Color _paper = Color(0xFFF8F6F2);
const Color _surface = Color(0xFFF2F0ED);
const Color _muted = Color(0xFF77716C);
const Color _line = Color(0xFFE3DED8);
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

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _selectedCategory = 'Grocery';
  String _searchQuery = '';
  final Set<int> _wishlist = {};
  final Map<int, int> _cart = {};

  List<ShopProduct> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory = product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(ShopProduct product, int quantity) {
    setState(() {
      _cart.update(
        product.id,
        (current) => current + quantity,
        ifAbsent: () => quantity,
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} added to your bag'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: _accent,
            onPressed: () {
              setState(() {
                final remaining = (_cart[product.id] ?? 0) - quantity;
                if (remaining <= 0) {
                  _cart.remove(product.id);
                } else {
                  _cart[product.id] = remaining;
                }
              });
            },
          ),
        ),
      );
  }

  void _toggleWishlist(ShopProduct product) {
    setState(() {
      if (!_wishlist.add(product.id)) _wishlist.remove(product.id);
    });
  }

  void _openProduct(ShopProduct product) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailsScreen(
              product: product,
              isWishlisted: _wishlist.contains(product.id),
              onWishlistToggle: () => _toggleWishlist(product),
              onAddToCart: _addToCart,
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  void _openWishlist() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => WishlistScreen(
              products: _products
                  .where((product) => _wishlist.contains(product.id))
                  .toList(),
              onProductTap: _openProduct,
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  void _openCart() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CartScreen(
              products: _products,
              cart: Map<int, int>.from(_cart),
              onQuantityChanged: (id, quantity) {
                setState(() {
                  if (quantity <= 0) {
                    _cart.remove(id);
                  } else {
                    _cart[id] = quantity;
                  }
                });
              },
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCart,
        tooltip: 'Cart',
        child: const Icon(LucideIcons.shoppingBag),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A considered collection',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Find your good thing.',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: LucideIcons.heart,
                      onTap: _openWishlist,
                    ),
                  ],
                ),
              ),
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: _ink, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    hintStyle: const TextStyle(color: _muted, fontSize: 14),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: _muted,
                      size: 19,
                    ),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () => setState(() => _searchQuery = ''),
                            icon: const Icon(
                              LucideIcons.x,
                              size: 17,
                              color: _muted,
                            ),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _ink, width: 1.2),
                    ),
                  ),
                ),
              ),
            ),

            // Editorial promotion
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E5D8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE EVERYDAY EDIT',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 10,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Good things,\nchosen with care.',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.9,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Little finds. Better everyday.',
                              style: TextStyle(color: _muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 82,
                        height: 82,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE7D5C2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.shoppingBasket,
                          color: _ink,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Browse categories',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _CategoryItem(
                            category: category,
                            selected: _selectedCategory == category.name,
                            onTap: () => setState(
                              () => _selectedCategory = category.name,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product section heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCategory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: _ink,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length} ${products.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            if (products.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyState(
                  icon: LucideIcons.searchX,
                  title: 'No products found',
                  message: 'Try another category or a different search.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      isWishlisted: _wishlist.contains(product.id),
                      onTap: () => _openProduct(product),
                      onWishlistTap: () => _toggleWishlist(product),
                    );
                  }, childCount: products.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final _ShopCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: IconButton(
        tooltip: category.name,
        onPressed: onTap,
        icon: Icon(category.icon, size: 28),
        color: _ink,
        style: IconButton.styleFrom(
          fixedSize: const Size(56, 56),
          backgroundColor: selected ? _accent : Colors.white,
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: const CircleBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopProduct product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: _surface,
                      padding: const EdgeInsets.all(12),
                      child: _ProductImage(
                        url: product.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: _RoundIconButton(
                        icon: isWishlisted
                            ? LucideIcons.heart
                            : LucideIcons.heart,
                        filled: isWishlisted,
                        tooltip: isWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                        onTap: onWishlistTap,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: _muted,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _ink,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '₹${product.price}',
                              style: const TextStyle(
                                fontSize: 17,
                                color: _ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.arrowUpRight,
                            size: 17,
                            color: _muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final ShopProduct product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final void Function(ShopProduct product, int quantity) onAddToCart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.isWishlisted;
  }

  void _toggleWishlist() {
    widget.onWishlistToggle();
    setState(() => _isWishlisted = !_isWishlisted);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: _paper,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              title: const Text(
                'Product details',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _HeaderIconButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _HeaderIconButton(
                    icon: LucideIcons.heart,
                    isActive: _isWishlisted,
                    onTap: _toggleWishlist,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: _surface,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _ProductImage(
                    url: product.image,
                    fit: BoxFit.contain,
                    padding: const EdgeInsets.all(22),
                    iconSize: 60,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE4D9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.1,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    product.weight,
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${product.price}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: _ink,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const Icon(LucideIcons.star, color: _ink, size: 17),
                      const SizedBox(width: 5),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(${product.reviews})',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 21),
                    child: Divider(color: _line, height: 1),
                  ),
                  const Text(
                    'ABOUT THIS ITEM',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 14,
                            color: _ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _QuantityStepper(
                        quantity: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.packageCheck, size: 21, color: _ink),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thoughtfully delivered',
                                style: TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Delivery estimates will be confirmed at checkout.',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onAddToCart(product, _quantity);
                        Navigator.pop(context);
                      },
                      icon: const Icon(LucideIcons.shoppingBag, size: 19),
                      label: Text(
                        'Add to bag  ·  ₹${product.price * _quantity}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _toggleWishlist,
                      icon: Icon(
                        _isWishlisted ? LucideIcons.heart : LucideIcons.heart,
                        size: 18,
                      ),
                      label: Text(
                        _isWishlisted ? 'Saved to wishlist' : 'Save for later',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease quantity',
            visualDensity: VisualDensity.compact,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(LucideIcons.minus, size: 15),
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(LucideIcons.plus, size: 15),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final bool isActive;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  }) : badge = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: _line)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 19,
                color: isActive ? Colors.red.shade700 : _ink,
              ),
              if (badge > 0)
                Positioned(
                  top: -3,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final String tooltip;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 35,
            height: 35,
            child: Icon(
              icon,
              size: 17,
              color: filled ? Colors.red.shade700 : _ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  const _ProductImage({
    required this.url,
    required this.fit,
    this.padding = EdgeInsets.zero,
    this.iconSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 1.7, color: _muted),
          ),
        );
      },
      errorBuilder: (_, _, _) => Center(
        child: Padding(
          padding: padding,
          child: Icon(LucideIcons.imageOff, size: iconSize, color: _muted),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _muted, size: 27),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  final List<ShopProduct> products;
  final ValueChanged<ShopProduct> onProductTap;

  const WishlistScreen({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        title: const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
        ),
        shape: const Border(bottom: BorderSide(color: _line)),
      ),
      body: products.isEmpty
          ? const _EmptyState(
              icon: LucideIcons.heart,
              title: 'Nothing saved yet',
              message: 'Tap the heart on anything you would like to keep.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductListTile(
                  product: product,
                  onTap: () => onProductTap(product),
                );
              },
            ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final ShopProduct product;
  final VoidCallback onTap;

  const _ProductListTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: _surface,
                  padding: const EdgeInsets.all(5),
                  child: _ProductImage(url: product.image, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '₹${product.price}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: _muted, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<ShopProduct> products;
  final Map<int, int> cart;
  final void Function(int id, int quantity) onQuantityChanged;

  const CartScreen({
    super.key,
    required this.products,
    required this.cart,
    required this.onQuantityChanged,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<int, int> _cart;

  @override
  void initState() {
    super.initState();
    _cart = Map<int, int>.from(widget.cart);
  }

  void _changeQuantity(int id, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = quantity;
      }
    });
    widget.onQuantityChanged(id, quantity);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.products
        .where((product) => (_cart[product.id] ?? 0) > 0)
        .toList();
    final total = items.fold<int>(
      0,
      (sum, product) => sum + product.price * (_cart[product.id] ?? 0),
    );

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
        elevation: 2,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: items.isEmpty
          ? const _EmptyState(
              icon: LucideIcons.shoppingBag,
              title: 'Your bag is empty',
              message: 'Find something good in the shop.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      final quantity = _cart[product.id] ?? 0;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _line),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 82,
                                height: 82,
                                color: _surface,
                                padding: const EdgeInsets.all(5),
                                child: _ProductImage(
                                  url: product.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹${product.price}',
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  _QuantityStepper(
                                    quantity: quantity,
                                    onChanged: (value) =>
                                        _changeQuantity(product.id, value),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove item',
                              onPressed: () => _changeQuantity(product.id, 0),
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: _line)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Subtotal',
                                style: TextStyle(color: _muted, fontSize: 14),
                              ),
                            ),
                            Text(
                              '₹$total',
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Checkout will be available when connected to Aloha.',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Continue to checkout',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
