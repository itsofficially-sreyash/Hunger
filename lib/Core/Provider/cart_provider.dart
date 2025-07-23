import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/Model/cart_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  final SupabaseClient supabaseClient = Supabase.instance.client;

  //getters
  List<CartItem> get items => _items;
  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + ((item.productData["price"] ?? 0) * item.quantity),
  );

  CartProvider(){
    loadCart();
  }

  //to load the cart items
  Future<void> loadCart() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final response = await supabaseClient
          .from("cart")
          .select()
          .eq("user_id", userId);
      _items = (response as List)
          .map((item) => CartItem.fromMap(item))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  //add items to cart
  Future<void> addCart(
    String productId,
    Map<String, dynamic> productData,
    int selectedQuantity,
  ) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // checking if product already exists
      final existing = await supabaseClient
          .from("cart")
          .select()
          .eq("user_id", userId)
          .eq("product_id", productId)
          .maybeSingle();

      if (existing != null) {
        //item exists -> update quantity
        final newQuantity = (existing["quantity"] ?? 0) + selectedQuantity;

        await supabaseClient
            .from("cart")
            .update({"quantity": newQuantity})
            .eq("product_id", productId)
            .eq("user_id", userId);

        //update in local state
        final index = _items.indexWhere(
          (item) => item.productId == productId && item.userId == userId,
        );
        if (index != -1) {
          _items[index].quantity = newQuantity;
        }
      } else {
        //new item in cart

        final response = await supabaseClient.from("cart").insert({
          "product_id": productId,
          "product_data": productData,
          "quantity": selectedQuantity,
          "user_id": userId,
        }).select();

        if (response.isNotEmpty) {
          _items.add(
            CartItem(
              id: response.first["id"],
              productId: productId,
              productData: productData,
              userId: userId,
              quantity: selectedQuantity,
            ),
          );
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error adding item to cart: $e");
      rethrow;
    }
  }

  //remove from cart
  Future<void> removeItem(String itemId) async {
    try {
      await supabaseClient.from("cart").delete().eq("id", itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print("Error removing item: $e");
    }
  }
}

final cartProvider = ChangeNotifierProvider<CartProvider>(
  (ref) => CartProvider(),
);
