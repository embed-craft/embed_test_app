import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final List<String> _ingredients = [
    '2 cups Basmati Rice',
    '500g Chicken Thighs',
    '2 onions, finely sliced',
    '1 tbsp Ginger-Garlic paste',
    '1 cup Plain Yogurt',
    'Saffron strands soaked in milk',
    'Fresh Coriander & Mint'
  ];
  
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    // 📍 Track page navigation (generates new navigation token)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNinja.trackPage('recipe_detail', context);
    });
    
    // Track custom event
    AppNinja.track('recipe_viewed', properties: {
      'recipe_name': 'Hyderabadi Chicken Biryani',
      'category': 'Main Course',
      'difficulty': 'Medium'
    });
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_checkedIngredients.contains(index)) {
        _checkedIngredients.remove(index);
      } else {
        _checkedIngredients.add(index);
        // 2. Track Interaction
        AppNinja.track('ingredient_checked', properties: {
          'ingredient': _ingredients[index],
          'total_checked': _checkedIngredients.length + 1
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with Hero Image
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Chicken Biryani', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))]
                  )
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: Colors.orange.shade800),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Metadata Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildMetaItem(Icons.timer, '45 mins'),
                   _buildMetaItem(Icons.local_fire_department, '650 kCal'),
                   _buildMetaItem(Icons.restaurant, 'Serves 4'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),

          // Ingredients Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ingredients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('${_ingredients.length} items', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),

          // Ingredients List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ingredient = _ingredients[index];
                final isChecked = _checkedIngredients.contains(index);
                return EmbedWidgetWrapper(
                  id: 'ingredient_item_$index',
                  child: CheckboxListTile(
                    value: isChecked,
                    onChanged: (val) => _toggleIngredient(index),
                    title: Text(
                      ingredient,
                      style: TextStyle(
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    activeColor: Colors.orange,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                );
              },
              childCount: _ingredients.length,
            ),
          ),

          // Instructions Header
          const SliverToBoxAdapter(
             child: Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Text('Instructions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),

          // Simple Instructions Text
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStep(1, 'Marinate the chicken with yogurt and spices for 30 mins.'),
                  _buildStep(2, 'Cook the rice until 70% done.'),
                  _buildStep(3, 'Layer chicken and rice in a heavy pot.'),
                  _buildStep(4, 'Seal and cook on low heat (Dum) for 20 mins.'),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: EmbedWidgetWrapper(
        id: 'recipe_fab',
        child: FloatingActionButton.extended(
          onPressed: () {
            AppNinja.track('cook_now_clicked', properties: {
              'recipe_id': 'biryani_001',
              'timestamp': DateTime.now().toIso8601String()
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Starting Cooking Mode...'))
            );
          },
          label: const Text('Start Cooking'),
          icon: const Icon(Icons.play_arrow),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange.shade100,
            child: Text('$number', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4))),
        ],
      ),
    );
  }
}
