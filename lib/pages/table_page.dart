import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/mock_api_service.dart';
import '../services/toast_service.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/masked_value.dart';
import '../widgets/raw_card.dart';
import '../widgets/raw_input.dart';
import '../widgets/raw_table.dart';
import '../widgets/skeleton.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final _searchController = TextEditingController();
  String _statusFilter = 'ALL';
  bool _loading = true;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Simulated GET /api/rest/items?q=...&status.eq=...
    final response = await MockApiService.fetchItems(
      query: _searchController.text,
      statusFilter: _statusFilter,
    );
    final data = (response['data'] as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final cart = context.read<CartState>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions', style: AppText.heading1(colors)),
          const SizedBox(height: AppSpacing.xs),
          Text('Mock data only — nothing here calls your real backend yet.', style: AppText.caption(colors)),
          const SizedBox(height: AppSpacing.md),

          RawCard(
            child: const MaskedValue(label: 'Linked Account', value: '4029881029384756'),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: RawInput(label: 'Search', hint: 'e.g. Transaction #1000', controller: _searchController),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusDropdown(
                value: _statusFilter,
                onChanged: (v) {
                  setState(() => _statusFilter = v);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _load,
              child: Text('Apply search', style: AppText.body(colors).copyWith(color: colors.primary)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: _loading
                ? const RawTableSkeleton()
                : SingleChildScrollView(
                    child: RawTable(
                      items: _items,
                      onAdd: (item) {
                        cart.add(item);
                        ToastService.show(context, message: '${item.name} added to cart', type: ToastType.success);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.inputBackground,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: colors.surface,
          style: AppText.body(colors),
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All')),
            DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
            DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
            DropdownMenuItem(value: 'FAILED', child: Text('Failed')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
