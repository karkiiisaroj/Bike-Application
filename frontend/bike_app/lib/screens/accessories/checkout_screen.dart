import 'package:bike_app/models/accessory_model.dart';
import 'package:bike_app/providers/cart_provider.dart';
import 'package:bike_app/screens/accessories/order_confirmation_screen.dart';
import 'package:bike_app/theme/theme.dart';
import 'package:bike_app/widgets/accessory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bike_app/services/accessory_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _paymentMethod = 'cod';
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(CartProvider cart) async {
    if (!_formKey.currentState!.validate() || cart.items.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final result = await AccessoryApi.placeOrder(
        customerName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        items: cart.items
            .map(
              (i) => {'accessory_id': i.accessory.id, 'quantity': i.quantity},
            )
            .toList(),
      );
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            orderNumber: result['order_number'] as String,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not place order: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHECKOUT',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AppColors.brass,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Field(
                        controller: _nameCtrl,
                        label: 'Full name',
                        validator: _required,
                      ),
                      _Field(
                        controller: _phoneCtrl,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      _Field(
                        controller: _emailCtrl,
                        label: 'Email (optional)',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _Field(
                        controller: _addressCtrl,
                        label: 'Delivery address',
                        validator: _required,
                      ),
                      _Field(
                        controller: _cityCtrl,
                        label: 'City',
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PAYMENT METHOD',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.brass,
                        ),
                      ),
                      _PaymentOption(
                        label: 'Cash on Delivery',
                        value: 'cod',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      _PaymentOption(
                        label: 'eSewa',
                        value: 'esewa',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      _PaymentOption(
                        label: 'Khalti',
                        value: 'khalti',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brass,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitting ? null : () => _submit(cart),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Text(
                      'PLACE ORDER',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: AppColors.cream,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            color: AppColors.muted,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.line),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.brass),
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.brass,
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: AppColors.cream,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
