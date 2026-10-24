part of '../shop.dart';

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
