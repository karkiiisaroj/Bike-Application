import 'package:flutter/material.dart';

class AtelierButton extends StatelessWidget {
  const AtelierButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(onPressed: onPressed, child: Text('$label  →')),
    );
  }
}
