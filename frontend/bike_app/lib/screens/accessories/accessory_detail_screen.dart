import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/providers/cart_provider.dart';
import 'package:bike_app/screens/accessories/checkout_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/accessory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bike_app/services/accessory_service.dart';

class AccessoryDetailScreen extends StatefulWidget {
  final String slug;

  const AccessoryDetailScreen({super.key, required this.slug});

  @override
  State<AccessoryDetailScreen> createState() => _AccessoryDetailScreenState();
}

class _AccessoryDetailScreenState extends State<AccessoryDetailScreen> {
  late Future<Accessory> _future;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _future = AccessoryApi.fetchAccessoryDetail(widget.slug);
  }

  void _retry() {
    setState(() {
      _future = AccessoryApi.fetchAccessoryDetail(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: FutureBuilder<Accessory>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brass),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return AccessoriesErrorState(onRetry: _retry);
            }
            return _DetailBody(
              accessory: snapshot.data!,
              quantity: _quantity,
              onQuantityChange: (q) => setState(() => _quantity = q),
            );
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder<Accessory>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.inStock)
            return const SizedBox.shrink();
          final accessory = snapshot.data!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.brass),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        context.read<CartProvider>().add(
                          accessory,
                          quantity: _quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${accessory.name} to cart'),
                          ),
                        );
                      },
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                          color: AppColors.brass,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brass,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        context.read<CartProvider>().add(
                          accessory,
                          quantity: _quantity,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'BUY NOW',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Accessory accessory;
  final int quantity;
  final ValueChanged<int> onQuantityChange;

  const _DetailBody({
    required this.accessory,
    required this.quantity,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        accessoryCategoryLabels[accessory.category] ?? accessory.category;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackBar(),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: AccessoryImage(url: accessory.imageUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryLabel.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppColors.brass,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      accessory.name,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${formatRupees(accessory.price)}',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brass,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accessory.inStock
                          ? '${accessory.stock} in stock'
                          : 'Out of stock',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 13,
                        color: accessory.inStock
                            ? AppColors.muted
                            : Colors.redAccent,
                      ),
                    ),
                    if (accessory.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        accessory.description,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    if (accessory.compatibleBikes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'FITS',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.brass,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: accessory.compatibleBikes
                            .map(
                              (b) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 12,
                                    color: AppColors.cream,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (accessory.inStock) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'QTY',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.brass,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _QuantityStepper(
                            quantity: quantity,
                            max: accessory.stock,
                            onChanged: onQuantityChange,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 100), // clear the bottom action bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: quantity < max ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap == null ? AppColors.line : AppColors.brass,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? AppColors.mutedDark : AppColors.brass,
        ),
      ),
    );
  }
}
