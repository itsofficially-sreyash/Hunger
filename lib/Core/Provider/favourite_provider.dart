import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final favouriteProvider = ChangeNotifierProvider<FavouriteProvider>(
  (ref) => FavouriteProvider(),
);

class FavouriteProvider extends ChangeNotifier {
  List<String> _favouriteIds = [];
  final SupabaseClient supabaseClient = Supabase.instance.client;

  //getters
  List<String> get favouriteIds => _favouriteIds;
  String? get userId => supabaseClient.auth.currentUser?.id;

  FavouriteProvider() {
    //load the favourite provider
  }

  void reset() {
    _favouriteIds = [];
    notifyListeners();
  }

  //toggle favourite state
  Future<void> toggleFavourite(String productId) async {
    if (_favouriteIds.contains(productId)) {
      favouriteIds.remove(productId);
      await _removeFavourite(productId);
    } else {
      _favouriteIds.add(productId);
      await _addFavourite(productId);
    }
    notifyListeners();
  }

  //check if product is favourite
  bool isFavourite(String productId) {
    return _favouriteIds.contains(productId);
  }

  //add favourite to supabase
  Future<void> _addFavourite(String productId) async {
    if (userId == null) return;
    try {
      await supabaseClient.from("favourites").insert({
        "user_id": userId,
        "product_id": productId,
      });
    } catch (e) {
      print("Error adding favourites: $e");
    }
  }

  //remove favourites from supabase
  Future<void> _removeFavourite(String productId) async {
    if (userId == null) return;
    try {
      await supabaseClient.from("favourites").delete().match({
        "user_id": userId!,
        "product_id": productId,
      });
    } catch (e) {
      print("Error removing favourites: $e");
    }
  }

  //laod favourites from supabase
  Future<void> loadFavourite() async {
    if (userId == null) return;
    try {
      final data = await supabaseClient
          .from("favourites")
          .select("product_id")
          .eq("user_id", userId!);
      _favouriteIds = data
          .map<String>((row) => row["product_id"] as String)
          .toList();
    } catch (e) {
      print("Error loading favourites: $e");
    }
    notifyListeners();
  }
}
