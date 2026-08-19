import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/providers/cart_provider.dart';
import 'package:bike_app/screens/accessories/checkout_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/accessory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BackBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                  child: Text(
                    'YOUR CART',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.brass,
                    ),
                  ),
                ),
                Expanded(
                  child: cart.items.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty.',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: AppColors.line, height: 32),
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return _CartRow(item: item, cart: cart);
                          },
                        ),
                ),
                if (cart.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '₹${formatRupees(cart.total)}',
                              style: const TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brass,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brass,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            ),
                            child: const Text(
                              'CHECKOUT',
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;

  const _CartRow({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.panel,
              border: Border.all(color: AppColors.line),
            ),
            child: AccessoryImage(url: item.accessory.imageUrl),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.accessory.name,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${formatRupees(item.accessory.price)} × ${item.quantity}',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.muted),
          onPressed: () =>
              cart.updateQuantity(item.accessory.id, item.quantity - 1),
        ),
        Text(
          '${item.quantity}',
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            color: AppColors.cream,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.muted),
          onPressed: () =>
              cart.updateQuantity(item.accessory.id, item.quantity + 1),
        ),
      ],
    );
  }
}
