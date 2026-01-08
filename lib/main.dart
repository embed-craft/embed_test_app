import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/cart_screen.dart';
import 'package:untitled/screens/profile_screen.dart';
import 'package:untitled/screens/recipe_detail_screen.dart';
import 'package:untitled/screens/checkout_screen.dart';
import 'package:untitled/screens/membership_screen.dart';

// ⚠️ IMPORTANT: User must add google-services.json for this to work!

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
     await Firebase.initializeApp();
  } catch(e) {
     debugPrint("Firebase Init Failed (Likely missing google-services.json): $e");
  }

  // 2. Initialize InAppNinja SDK with Live Key
  AppNinja.debug(true); // 🔥 ENABLE DEBUG LOGS
  await AppNinja.init(
    'nk_live_bcecb88d32c3a9353e5e765f45e03055', 
    autoRender: true,
    navigatorKey: navigatorKey,
  );

  runApp(const BigBasketApp());
}

class BigBasketApp extends StatelessWidget {
  const BigBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'BigBasket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF689F38),
          primary: const Color(0xFF689F38),
          secondary: const Color(0xFF8BC34A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF689F38),
            foregroundColor: Colors.white,
        ),
      ),
       // ⚠️ IMPORTANT: Wrap the entire app with NinjaApp using builder
      // This ensures Screenshot widget is always at the root, persisting across navigation
      builder: (context, child) {
        return NinjaApp(child: child!);
      },
      // Check Auth State
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
             // User is logged in, restore identity
             _restoreIdentity(snapshot.data!);
             return const HomeScreen(); // Just HomeScreen, NinjaApp is already wrapping via builder
          }
          return const LoginScreen();
        },
      ),
    );
  }

  Future<void> _restoreIdentity(User user) async {
     final prefs = await SharedPreferences.getInstance();
     final name = prefs.getString('user_name') ?? 'BigBasket User';
     final city = prefs.getString('user_city') ?? 'Unknown';
     
     // Re-identify on app launch
     AppNinja.identify({
        'user_id': user.uid,
        'name': name,
        'city': city,
        'email': user.email,
        'plan': 'bb_star',
     });
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cartCount = 2; // Mocked cart count

  @override
  void initState() {
    super.initState();
    // Existing track
    AppNinja.track('screen_viewed', properties: {'screen_name': 'home_feed'});
    
    // TEST: Trigger for Campaign 69354c2a4615f445c869b8b8
    AppNinja.track('home_view', properties: {
      'time_of_day': DateTime.now().hour < 12 ? 'morning' : 'afternoon',
      'cart_items_count': _cartCount,
      'user_tier': 'Gold', // Mock
    });
  }

  void _openCart() {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())); // DIRECT TO CHECKOUT FOR DEMO
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return EmbedWidgetWrapper(
      id: 'home_screen_scaffold',
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {
            AppNinja.track('menu_clicked', properties: {
              'menu_state': 'open', 
              'active_screen': 'HomeScreen'
            });
          }),
          title: const Text('bigbasket', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                EmbedWidgetWrapper(
                  id: 'cart_btn',
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined), 
                    onPressed: _openCart,
                  ),
                ),
                if (_cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$_cartCount', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            EmbedWidgetWrapper(
              id: 'profile_btn',
              child: IconButton(
                icon: const Icon(Icons.person),
                onPressed: _openProfile,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: EmbedWidgetWrapper(
                  id: 'home_search_bar',
                  child: TextField(
                    onTap: () => AppNinja.track('search_tapped', properties: {
                      'placeholder': 'Search for products...',
                      'previous_searches_count': 0
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),

              // 1. CAROUSEL BANNERS (Container 1)
              SizedBox(
                height: 160,
                child: EmbedWidgetWrapper(
                  id: 'home_banner_list',
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildBanner(Colors.green[100]!, 'Fresh Vegetables\nup to 40% OFF'),
                      _buildBanner(Colors.orange[100]!, 'Summer Fruits\nSeason Special'),
                      _buildBanner(Colors.blue[100]!, 'Dairy & Breakfast\nEssentials'),
                    ],
                  ),
                ),
              ),

               // 2. CATEGORIES HORIZONTAL (Container 2 - NEW)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Shop By Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 100,
                child: EmbedWidgetWrapper(
                  id: 'home_category_list',
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildCategoryItem('Fruits', Icons.apple, Colors.red[100]!),
                      _buildCategoryItem('Veg', Icons.grass, Colors.green[100]!),
                      _buildCategoryItem('Dairy', Icons.egg, Colors.blue[100]!),
                      _buildCategoryItem('Meat', Icons.set_meal, Colors.orange[100]!),
                      _buildCategoryItem('Bakery', Icons.cake, Colors.brown[100]!),
                    ],
                  ),
                ),
              ),

              // 3. FRESH ARRIVED GRID (Container 3)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Freshly Arrived', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              EmbedWidgetWrapper(
                id: 'fresh_arrivals_grid',
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildProductCard('Hyd Mango', '1 kg', 85, Colors.amber[100]),
                    _buildProductCard('Baby Corn', '250g', 42, Colors.yellow[100]),
                  ],
                ),
              ),

              // 4. DAILY STAPLES (Container 4)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Daily Staples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              EmbedWidgetWrapper(
                id: 'daily_staples_grid',
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildProductCard('Farm Fresh Onion', '1 kg', 25, Colors.grey[100]),
                    _buildProductCard('Desi Potato', '1 kg', 32, Colors.brown[50]),
                    _buildProductCard('Tomatoes - Hybrid', '1 kg', 18, Colors.red[50]),
                    _buildProductCard('Amul Taaza Milk', '500 ml', 27, Colors.blue[50]),
                  ],
                ),
              ),
              
              // 5. PROMO BANNER (Container 5)
              EmbedWidgetWrapper(
                id: 'promo_banner_container',
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF689F38), Color(0xFF8BC34A)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Join bbStar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Free delivery + Extra cashback', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      EmbedWidgetWrapper(
                        id: 'join_bbstar_btn',
                        child: ElevatedButton(
                          onPressed: () {
                             AppNinja.track('join_program_clicked', properties: {
                               'program': 'bbStar',
                               'referral_source': 'home_banner',
                               'discount_value': 'Freedel + Cashback'
                             });
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green),
                          child: const Text('JOIN NOW'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
          // 4.5 FEATURED RECIPE (New Section)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: EmbedWidgetWrapper(
              id: 'home_featured_recipe_card',
              child: GestureDetector(
                onTap: () {
                    AppNinja.track('featured_recipe_clicked');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeDetailScreen()));
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1589302168068-964664d93dc0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80'),
                      fit: BoxFit.cover
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Colors.black54, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                    ),
                    alignment: Alignment.bottomLeft,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recipe of the Day', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        Text('Hyderabadi Chicken Biryani', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: EmbedWidgetWrapper(
          id: 'home_bottom_nav',
          child: BottomNavigationBar(
            selectedItemColor: const Color(0xFF689F38),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Offers'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            onTap: (index) {
              const tabs = ['Home', 'Categories', 'Search', 'Offers', 'Profile'];
              AppNinja.track('nav_tab_clicked', properties: {
                'tab_name': tabs[index],
                'tab_index': index,
                'previous_tab': 'Home' // Simplified
              });
              
              if (index == 4) _openProfile();
              if (index == 3) _openCart();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(Color color, String text) {
    return EmbedWidgetWrapper(
      id: 'banner_${text.hashCode}',
      child: GestureDetector(
        onTap: () {
            AppNinja.track('banner_clicked', properties: {
              'banner_text': text,
              'banner_type': 'carousel',
              'bg_color_hex': color.value.toRadixString(16)
            });
        },
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    return EmbedWidgetWrapper(
      id: 'cat_${name.toLowerCase()}',
      child: GestureDetector(
        onTap: () {
            AppNinja.track('category_clicked', properties: {
              'category_name': name,
              'section': 'horizontal_list',
              'has_subcategories': true
            });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, String qty, double price, Color? color) {
    return GestureDetector(
      onTap: () {
          AppNinja.track('product_clicked', properties: {
            'product_name': name,
            'price': price,
            'currency': 'INR',
            'in_stock': true,
            'category': 'Daily Staples' // Mock
          });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color ?? Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fresho', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(qty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
                        child: EmbedWidgetWrapper(
                          id: 'add_${name.replaceAll(' ', '_')}',
                          child: InkWell(
                            onTap: () {
                                AppNinja.track('add_to_cart_clicked', properties: {
                                  'product_name': name,
                                  'price': price,
                                  'quantity': 1,
                                  'currency': 'INR'
                                });
                            },
                            child: const Text('ADD', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
