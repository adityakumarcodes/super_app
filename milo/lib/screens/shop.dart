import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Grocery';
  String _searchQuery = '';
  bool _showingWishlist = false;
  final Set<int> _wishlist = {};
  final Map<int, int> _cart = {};
  late final TabController _categoryController;

  @override
  void initState() {
    super.initState();
    _categoryController = TabController(
      length: _categories.length + 1,
      initialIndex: _categories.indexWhere(
        (category) => category.name == _selectedCategory,
      ),
      vsync: this,
    );
    _categoryController.addListener(_selectCategory);
  }

  void _selectCategory() {
    final index = _categoryController.index;
    final showingWishlist = index == _categories.length;
    final category = showingWishlist ? null : _categories[index];
    if (_showingWishlist == showingWishlist &&
        (category == null || _selectedCategory == category.name)) {
      return;
    }
    setState(() {
      _showingWishlist = showingWishlist;
      if (category != null) _selectedCategory = category.name;
    });
  }

  @override
  void dispose() {
    _categoryController
      ..removeListener(_selectCategory)
      ..dispose();
    super.dispose();
  }

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

  void _pushPage(WidgetBuilder builder) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push<void>(MaterialPageRoute<void>(builder: builder)).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openProduct(ShopProduct product) {
    _pushPage(
      (_) => ProductDetailsScreen(
        product: product,
        isWishlisted: _wishlist.contains(product.id),
        onWishlistToggle: () => _toggleWishlist(product),
        onAddToCart: _addToCart,
      ),
    );
  }

  void _openCart() {
    _pushPage(
      (_) => CartScreen(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final products = _showingWishlist
        ? _products
              .where(
                (product) =>
                    _wishlist.contains(product.id) &&
                    product.name.toLowerCase().contains(
                      _searchQuery.trim().toLowerCase(),
                    ),
              )
              .toList()
        : _filteredProducts;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
        elevation: 2,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
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
            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textInputAction: TextInputAction.search,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(LucideIcons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () => setState(() => _searchQuery = ''),
                            icon: const Icon(LucideIcons.x),
                          ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Material(
                color: colorScheme.surface,
                child: TabBar(
                  controller: _categoryController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  tabs:
                      _categories
                          .map(
                            (category) => Tab(
                              icon: Icon(category.icon),
                              text: category.name,
                            ),
                          )
                          .toList()
                        ..add(
                          const Tab(
                            icon: Icon(LucideIcons.heart),
                            text: 'Wishlist',
                          ),
                        ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            if (products.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyState(
                  icon: _showingWishlist
                      ? LucideIcons.heart
                      : LucideIcons.searchX,
                  title: _showingWishlist ? null : 'No products found',
                  message: _showingWishlist
                      ? 'Tap the heart on anything you would like to keep.'
                      : 'Try another category or a different search.',
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
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
                      color: colorScheme.surfaceContainerHighest,
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
                        icon: LucideIcons.heart,
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
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            LucideIcons.arrowUpRight,
                            color: colorScheme.onSurfaceVariant,
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: const Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 2,
              pinned: true,
              foregroundColor: colorScheme.onSurface,
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              centerTitle: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(color: colorScheme.outlineVariant),
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
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    product.weight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '₹${product.price}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.star,
                        color: colorScheme.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(${product.reviews})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 21),
                    child: Divider(
                      color: colorScheme.outlineVariant,
                      height: 1,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Details',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          product.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quantity',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
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
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
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
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.outline),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
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
  final String? title;
  final String message;

  const _EmptyState({required this.icon, required this.message, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: icon == LucideIcons.heart
                  ? Colors.red
                  : colorScheme.onSurfaceVariant,
              size: 36,
            ),
            if (title != null) ...[
              const SizedBox(height: 12),
              Text(title!, style: theme.textTheme.titleMedium),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = widget.products
        .where((product) => (_cart[product.id] ?? 0) > 0)
        .toList();
    final total = items.fold<int>(
      0,
      (sum, product) => sum + product.price * (_cart[product.id] ?? 0),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Cart'),
        centerTitle: true,
        elevation: 2,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: items.isEmpty
          ? const _EmptyState(
              icon: LucideIcons.shoppingBag,
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
                          color: colorScheme.surfaceContainerLow,
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 82,
                                height: 82,
                                color: colorScheme.surfaceContainerHighest,
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹${product.price}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
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
                              icon: Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
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
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subtotal',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              '₹$total',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
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
                                    'Checkout will be available soon.',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Continue to checkout',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
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
