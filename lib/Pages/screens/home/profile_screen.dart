import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/cart_provider.dart';
import 'package:food_delivery_app/Core/Provider/favourite_provider.dart';
import 'package:food_delivery_app/service/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                _authService.signOut(context);
                ref.invalidate(favouriteProvider);
                ref.invalidate(cartProvider);
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }
}
