import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentMethodSelection extends StatelessWidget {
  final ValueNotifier<int> selectedPaymentMethodNotifier;

  const PaymentMethodSelection({
    super.key,
    required this.selectedPaymentMethodNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              'assets/ship_cod_logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 20),
            const Text(
              'Ship COD',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
