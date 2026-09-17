import 'package:flutter/foundation.dart';
import '../models/item.dart';

/// A tiny cart, demonstrating cross-page shared state (Provider) the
/// same way SettingsContext/AuthContext are shared across the whole
/// React app rather than re-fetched per page. Add an item from the
/// Table tab; it shows up here regardless of which tab is active.
class CartState extends ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);
  int get count => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.amount);

  void add(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
