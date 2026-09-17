import 'dart:math';
import '../models/item.dart';

/// ---------------------------------------------------------------------
/// MockApiService
///
/// Stands in for a real call to your Java backend. Nothing here hits
/// the network — it's Future.delayed() returning canned data — but the
/// *shape* of the response mirrors what JooqFetchUtil.fetch("items")
/// would actually send back (see the Sunfyre jOOQ guide,
/// "Paginated list — offset mode"):
///
///   { status, domain, current_page, last_page, page_size,
///     total_count, data: [...] }
///
/// When you're ready to wire this to the real backend, this is the
/// only file that changes — swap Future.delayed for a Dio GET/POST
/// call and keep the same method signatures. Nothing in the UI layer
/// needs to know the difference.
/// ---------------------------------------------------------------------
class MockApiService {
  static final List<Item> _fakeDb = List.generate(14, (i) {
    final categories = ['Airtime', 'Data Bundle', 'Subscription', 'Refund'];
    final statuses = ['COMPLETED', 'PENDING', 'FAILED'];
    return Item(
      id: i + 1,
      name: 'Transaction #${1000 + i}',
      category: categories[i % categories.length],
      status: statuses[i % statuses.length],
      amount: 50.0 + (i * 37.5),
      createdAt: DateTime.now().subtract(Duration(hours: i * 6)),
    );
  });

  /// Simulates: GET /api/rest/items?q=...&status.eq=...&sort=...
  static Future<Map<String, dynamic>> fetchItems({
    String? query,
    String? statusFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var results = _fakeDb.where((item) {
      final matchesQuery = query == null ||
          query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase());
      final matchesStatus =
          statusFilter == null || statusFilter == 'ALL' || item.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    // Mirrors the response envelope in the jOOQ guide's
    // "Paginated list — offset mode" section.
    return {
      'status': 'success',
      'domain': 'items',
      'current_page': 1,
      'last_page': 1,
      'page_size': results.length,
      'total_count': results.length,
      'data': results.map((e) => e.toJson()).toList(),
    };
  }

  /// Simulates: POST /api/rest/items  (JooqMutationUtil.create())
  static Future<Item> createItem({
    required String name,
    required String category,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newItem = Item(
      id: Random().nextInt(90000) + 10000,
      name: name,
      category: category,
      status: 'PENDING',
      amount: amount,
      createdAt: DateTime.now(),
    );
    _fakeDb.insert(0, newItem);
    return newItem;
  }
}
