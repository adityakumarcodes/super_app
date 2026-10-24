import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

part 'shop/shop_data.dart';
part 'shop/product_card.dart';
part 'shop/product_details.dart';
part 'shop/shop_widgets.dart';
part 'shop/cart_screen.dart';

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
