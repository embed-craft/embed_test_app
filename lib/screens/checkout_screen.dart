import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPaymentMethod = 'credit_card';
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 📍 Track page navigation (generates new navigation token)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNinja.trackPage('checkout', context);
    });
    
    // Track custom events
    AppNinja.track('checkout_flow_started', properties: {'cart_value': 450.0});
    _trackStep(0, 'address_selection');
  }

  void _trackStep(int step, String name) {
    AppNinja.track('Checkout Step Viewed', properties: {
      'step_number': step + 1,
      'step_name': name
    });
  }

  void _placeOrder() {
    AppNinja.track('order_placed', properties: {
      'amount': 420.0,
      'payment_method': _selectedPaymentMethod,
      'promo_applied': _promoController.text.isNotEmpty ? _promoController.text : null
    });

    // EmbedWidgetWrapper cleanup is handled automatically by the widget tree disposals

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: const Text('Order Placed Successfully!', textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () { 
              Navigator.pop(context);
              Navigator.pop(context);
            }, 
            child: const Text('Back to Home')
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          // Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepIndicator(0, 'Address'),
                _buildLine(),
                _buildStepIndicator(1, 'Payment'),
                _buildLine(),
                _buildStepIndicator(2, 'Summary'),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                           const Icon(Icons.location_on, color: Colors.blue),
                           const SizedBox(width: 12),
                           const Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                                 Text('123, Green Park, Bangalore\n560001', style: TextStyle(color: Colors.grey, fontSize: 13)),
                               ],
                             ),
                           ),
                           EmbedWidgetWrapper(
                             id: 'checkout_change_address_btn',
                             child: TextButton(
                               onPressed: () {
                                 AppNinja.track('change_address_clicked');
                               }, 
                               child: const Text('CHANGE')
                             )
                           )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Payment Section
                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPaymentOption('Credit Card', Icons.credit_card, 'credit_card'),
                        _buildPaymentOption('UPI', Icons.qr_code, 'upi'),
                        _buildPaymentOption('Cash', Icons.money, 'cash'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Promo Code
                  EmbedWidgetWrapper(
                    id: 'checkout_promo_section',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.percent, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: const InputDecoration.collapsed(hintText: 'Enter Promo Code'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                               AppNinja.track('promo_applied', properties: {'code': _promoController.text});
                            }, 
                            child: const Text('APPLY')
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary
                  const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildSummaryRow('Item Total', '₹450'),
                        _buildSummaryRow('Delivery Fee', '₹30'),
                        _buildSummaryRow('Discount', '-₹60', isGreen: true),
                        const Divider(height: 24),
                        _buildSummaryRow('To Pay', '₹420', isBold: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: EmbedWidgetWrapper(
            id: 'checkout_pay_btn',
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('PLACE ORDER • ₹420', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? Colors.green : Colors.grey[300],
          child: isActive ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${step + 1}', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 10, 
          color: isActive ? Colors.black : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )),
      ],
    );
  }

  Widget _buildLine() {
    return Container(width: 30, height: 1, color: Colors.grey[300]);
  }

  Widget _buildPaymentOption(String label, IconData icon, String value) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = value);
        AppNinja.track('payment_method_selected', properties: {'method': value});
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.green.shade900 : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
            fontSize: isBold ? 16 : 14,
            color: isGreen ? Colors.green : Colors.black87
          )),
        ],
      ),
    );
  }
}
