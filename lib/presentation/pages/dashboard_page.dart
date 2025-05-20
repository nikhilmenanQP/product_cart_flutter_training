import 'package:flutter/material.dart';
import 'products_page.dart';
import 'cart_screen.dart';
// import 'package:go_router/go_router.dart';
import 'package:product_cart_flutter_training/presentation/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final ValueNotifier<int> _cartCountNotifier = ValueNotifier<int>(0);

  late final List<Widget> _pages = <Widget>[
    ProductsPage(cartCountNotifier: _cartCountNotifier),
    Center(child: Text('Search', style: TextStyle(fontSize: 24))),
    CartScreen(cartCountNotifier: _cartCountNotifier),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _cartCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home tab
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration:
                      _selectedIndex == 0
                          ? BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(24),
                          )
                          : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color:
                            _selectedIndex == 0
                                ? Color(0xFF8B5CF6)
                                : Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                      if (_selectedIndex == 0) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Home',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Products tab
              GestureDetector(
                onTap: () => _onItemTapped(1),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration:
                      _selectedIndex == 1
                          ? BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(24),
                          )
                          : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color:
                            _selectedIndex == 1
                                ? Color(0xFF8B5CF6)
                                : Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                      if (_selectedIndex == 1) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Products',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Cart tab
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration:
                      _selectedIndex == 2
                          ? BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(24),
                          )
                          : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color:
                            _selectedIndex == 2
                                ? Color(0xFF8B5CF6)
                                : Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                      if (_selectedIndex == 2) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Cart',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Profile tab
              GestureDetector(
                onTap: () => _onItemTapped(3),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration:
                      _selectedIndex == 3
                          ? BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(24),
                          )
                          : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color:
                            _selectedIndex == 3
                                ? Color(0xFF8B5CF6)
                                : Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                      if (_selectedIndex == 3) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
