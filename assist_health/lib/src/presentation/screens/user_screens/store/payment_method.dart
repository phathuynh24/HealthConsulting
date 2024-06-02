import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentMethodSelection extends StatelessWidget {
  final ValueNotifier<int> selectedPaymentMethodNotifier;

  PaymentMethodSelection({
    required this.selectedPaymentMethodNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            selectedPaymentMethodNotifier.value = 1;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/vnpay_logo.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'VNPay',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: selectedPaymentMethodNotifier,
                builder: (context, value, child) {
                  return Radio<int>(
                    value: 1,
                    groupValue: value,
                    onChanged: (value) {
                      selectedPaymentMethodNotifier.value = value!;
                    },
                  );
                },
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            selectedPaymentMethodNotifier.value = 2;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/ship_cod_logo.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Ship COD',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: selectedPaymentMethodNotifier,
                builder: (context, value, child) {
                  return Radio<int>(
                    value: 2,
                    groupValue: value,
                    onChanged: (value) {
                      selectedPaymentMethodNotifier.value = value!;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
