import 'package:bike_app/models/accessory_model.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final Accessory accessory;
  int quantity;

  CartItem({required this.accessory, this.quantity = 1});

  int get subtotal => accessory.price * quantity;
}

/// Cart lives in memory only (matches the "no browser/local storage in
/// artifacts" constraint that also applies to real device state — this
/// resets on app restart). Swap in shared_preferences or a Django-backed
/// cart endpoint later if you want it to survive restarts.
class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {}; // accessory.id -> CartItem

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);
  int get total => _items.values.fold(0, (sum, i) => sum + i.subtotal);

  void add(Accessory accessory, {int quantity = 1}) {
    if (_items.containsKey(accessory.id)) {
      _items[accessory.id]!.quantity += quantity;
    } else {
      _items[accessory.id] = CartItem(accessory: accessory, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(int accessoryId, int quantity) {
    if (quantity <= 0) {
      _items.remove(accessoryId);
    } else if (_items.containsKey(accessoryId)) {
      _items[accessoryId]!.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(int accessoryId) {
    _items.remove(accessoryId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
