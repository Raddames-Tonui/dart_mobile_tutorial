import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_api_service.dart';
import '../services/toast_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/raw_button.dart';
import '../widgets/raw_input.dart';
import 'form_success_page.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Airtime';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // Simulated POST /api/rest/items
    final created = await MockApiService.createItem(
      name: _nameController.text.trim(),
      category: _category,
      amount: double.parse(_amountController.text.trim()),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    // Toast = dismiss-and-forget notice. The pushed success page below
    // is the "decision point" equivalent for anything more deliberate.
    ToastService.show(context, message: 'Transaction created', type: ToastType.success);

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FormSuccessPage(item: created)));

    _nameController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Transaction', style: AppText.heading1(colors)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Validated fields, styled with RawInput — no Material default underline or fill color.',
              style: AppText.caption(colors),
            ),
            const SizedBox(height: AppSpacing.lg),

            RawInput(
              label: 'Name',
              hint: 'e.g. Data Bundle Purchase',
              controller: _nameController,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Category', style: AppText.label(colors)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['Airtime', 'Data Bundle', 'Subscription', 'Refund'].map((c) {
                final selected = c == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : colors.inputBackground,
                      border: Border.all(color: selected ? colors.primary : colors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: AppText.caption(colors).copyWith(
                        color: selected ? Colors.white : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            RawInput(
              label: 'Amount (KES)',
              hint: '0.00',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            RawButton(label: 'Submit', loading: _submitting, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
