import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/cart_provider.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:food_delivery_app/Pages/screens/cart/cart_screen.dart';
import 'package:food_delivery_app/Pages/screens/favourite/favourite_screen.dart';
import 'package:food_delivery_app/Pages/screens/home/app_home_screen.dart';
import 'package:food_delivery_app/Pages/screens/home/profile_screen.dart';
import 'package:iconsax/iconsax.dart';

class AppMainScreen extends ConsumerStatefulWidget {
  const AppMainScreen({super.key});

  @override
  ConsumerState<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends ConsumerState<AppMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    AppHomeScreen(),
    FavouriteScreen(),
    ProfileScreen(),
    CartScreen()
  ];

  @override
  Widget build(BuildContext context) {
  CartProvider _cartProvider = ref.watch(cartProvider);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItems(Iconsax.home_15, "A", 0),
            SizedBox(width: 10),
            _buildNavItems(Iconsax.heart, "B", 1),
            SizedBox(width: 90),
            _buildNavItems(Icons.person_outline, "C", 2),
            SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNavItems(Iconsax.shopping_bag, "D", 3),
                Positioned(
                  right: -7,
                  top: 16,
                  child: CircleAvatar(
                    backgroundColor: red,
                    radius: 10,
                    child: Text(
                      _cartProvider.items.length.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 155,
                  top: -25,
                  child: CircleAvatar(
                    backgroundColor: red,
                    radius: 35,
                    child: Icon(
                      CupertinoIcons.search,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //helper method to build each navigation items
  Widget _buildNavItems(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: _currentIndex == index ? Colors.red : Colors.grey,
          ),
          SizedBox(height: 3),
          CircleAvatar(
            radius: 3,
            backgroundColor: _currentIndex == index ? red : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
