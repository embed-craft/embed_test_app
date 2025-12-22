import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import '../main.dart'; // To navigate back home

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _selectedPayment = 'UPI';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AppNinja.track('checkout_viewed', properties: {
      'cart_total': 197.0, // Hardcoded for demo
      'item_count': 3,
      'step': 1
    });
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // 🚩 TRACK: Order Completed
    // This is a CRITICAL conversion event!
    await AppNinja.track('order_completed', properties: {
      'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'total_value': 197.0, // Hardcoded from cart for demo
      'currency': 'INR',
      'payment_method': _selectedPayment,
      'items_count': 3,
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text('Order Placed!'),
            ],
          ),
          content: const Text('Your order has been successfully placed. Thank you for shopping with BigBasket!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const NinjaApp(child: HomeScreen())),
                  (route) => false,
                );
              },
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter full address, landmark, PIN code...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Section
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentOption('UPI (GooglePay / PhonePe/ Paytm)'),
            _buildPaymentOption('Credit / Debit Card'),
            _buildPaymentOption('Cash on Delivery'),

            const SizedBox(height: 32),

            // Order Summary Mock
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total To Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹197.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689F38),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('PLACE ORDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String name) {
    return RadioListTile<String>(
      title: Text(name),
      value: name.split(' ')[0], 
      groupValue: _selectedPayment,
      activeColor: const Color(0xFF689F38),
      onChanged: (val) {
        setState(() => _selectedPayment = val!);
        AppNinja.track('payment_method_selected', properties: {'method': val});
      },
    );
  }
}
