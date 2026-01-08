import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  String _selectedPlan = 'silver';
  double _savingsEstimation = 500;
  bool _autoRenew = true;
  bool _newsletter = false;

  final List<Map<String, dynamic>> _benefits = [
    {'icon': Icons.local_shipping, 'title': 'Free Delivery', 'id': 'benefit_shipping'},
    {'icon': Icons.movie, 'title': 'Priority Support', 'id': 'benefit_support'},
    {'icon': Icons.percent, 'title': 'Extra 5% Off', 'id': 'benefit_discount'},
    {'icon': Icons.flash_on, 'title': 'Early Access', 'id': 'benefit_early'},
  ];

  @override
  void initState() {
    super.initState();
    AppNinja.track('membership_page_viewed', properties: {'source': 'profile_tab'});
  }

  void _selectPlan(String plan, double price) {
    setState(() => _selectedPlan = plan);
    AppNinja.track('membership_plan_selected', properties: {
      'plan_name': plan,
      'plan_price': price,
      'previous_plan': 'none'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('bbStar Membership', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Plan Selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                   _buildPlanCard('Silver', '₹299/mo', Colors.grey, 'silver'),
                   const SizedBox(width: 12),
                   _buildPlanCard('Gold', '₹499/mo', Colors.amber, 'gold'),
                   const SizedBox(width: 12),
                   _buildPlanCard('Platinum', '₹999/mo', Colors.black, 'platinum'),
                ],
              ),
            ),

            const Divider(),

            // 2. Savings Calculator (Slider)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimate your savings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Monthly Spend: ₹${_savingsEstimation.toInt()}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                  EmbedWidgetWrapper(
                    id: 'savings_slider',
                    child: Slider(
                      value: _savingsEstimation,
                      min: 500,
                      max: 20000,
                      divisions: 20,
                      activeColor: Colors.green,
                      label: _savingsEstimation.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _savingsEstimation = value;
                        });
                      },
                      onChangeEnd: (value) {
                         AppNinja.track('savings_calculator_used', properties: {'input_spend': value});
                      },
                    ),
                  ),
                  Text('You save ₹${(_savingsEstimation * 0.15).toInt()} per month with Gold!', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            // 3. Benefits Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: EmbedWidgetWrapper(
                id: 'benefits_grid',
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, mainAxisSpacing: 12, crossAxisSpacing: 12),
                  itemCount: _benefits.length,
                  itemBuilder: (context, index) {
                    final benefit = _benefits[index];
                    return EmbedWidgetWrapper(
                      id: benefit['id'], // Granular IDs
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                             Icon(benefit['icon'], color: Colors.purple),
                             const SizedBox(width: 8),
                             Expanded(child: Text(benefit['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Preferences (Toggles)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  EmbedWidgetWrapper(
                    id: 'autorenew_switch_row',
                    child: SwitchListTile(
                      title: const Text('Auto-Renew Subscription'),
                      subtitle: const Text('Cancel anytime'),
                      value: _autoRenew,
                      activeColor: Colors.green,
                      onChanged: (val) {
                         setState(() => _autoRenew = val);
                         AppNinja.track('preference_toggled', properties: {'pref': 'auto_renew', 'value': val});
                      },
                    ),
                  ),
                  const Divider(),
                  EmbedWidgetWrapper(
                    id: 'newsletter_switch_row',
                    child: SwitchListTile(
                      title: const Text('Email Newsletter'),
                      subtitle: const Text('Get weekly exclusive deals'),
                      value: _newsletter,
                      activeColor: Colors.green,
                      onChanged: (val) {
                         setState(() => _newsletter = val);
                         AppNinja.track('preference_toggled', properties: {'pref': 'newsletter', 'value': val});
                      },
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. Hero Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EmbedWidgetWrapper(
                id: 'activate_membership_btn',
                child: SizedBox(
                   width: double.infinity,
                   height: 56,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.black87,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       elevation: 8,
                     ),
                     onPressed: () {
                        AppNinja.track('membership_activated', properties: {
                           'plan': _selectedPlan,
                           'term': 'monthly',
                           'auto_renew': _autoRenew,
                           'savings_estimated': (_savingsEstimation * 0.15).toInt()
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to the Club!')));
                     },
                     child: const Text('ACTIVATE MEMBERSHIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                   ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, Color color, String id) {
    bool isSelected = _selectedPlan == id;
    Color displayColor = isSelected ? color : Colors.grey.shade400; // Dim if not selected
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectPlan(id, 299),
        child: EmbedWidgetWrapper(
          id: 'plan_card_$id',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.white,
              border: Border.all(color: displayColor, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.star, color: displayColor, size: 32),
                const SizedBox(height: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? Colors.black : Colors.grey)),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 16)
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
