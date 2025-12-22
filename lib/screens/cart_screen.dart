import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'checkout_screen.dart'; // We will create this next

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock Cart Items
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Farm Fresh Onion', 'qty': '1 kg', 'price': 25.0, 'image': 'https://via.placeholder.com/150'},
    {'name': 'Amul Taaza Milk', 'qty': '500 ml', 'price': 27.0, 'image': 'https://via.placeholder.com/150'},
    {'name': 'Fortune Oil', 'qty': '1 L', 'price': 145.0, 'image': 'https://via.placeholder.com/150'},
  ];

  @override
  void initState() {
    super.initState();
    // 🚩 TRACK: Cart Viewed
    AppNinja.track('cart_viewed', properties: {
      'total_items': _cartItems.length,
      'total_value': _calculateTotal(),
      'currency': 'INR',
      'avg_item_price': _cartItems.isEmpty ? 0 : _calculateTotal() / _cartItems.length,
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] as double));
  }

  void _proceedToCheckout() {
    // 🚩 TRACK: Checkout Started
    AppNinja.track('checkout_started', properties: {
      'total_value': _calculateTotal(),
      'item_count': _cartItems.length,
      'currency': 'INR',
      'coupon_applied': false
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return InkWell(
                  onTap: () {
                     AppNinja.track('cart_item_clicked', properties: {
                       'name': item['name'],
                       'price': item['price'],
                       'qty': item['qty'],
                       'stock_status': 'In Stock',
                       'position_in_cart': index
                     });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item['qty'], style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Bill Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹${_calculateTotal()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF689F38))),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF689F38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('PROCEED TO PAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
