import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../features/best_setup/data/bank_provider.dart';

/// Shows a bank import dialog. Returns the number of items imported, or null
/// if cancelled.
Future<int?> showBankImportDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const _BankImportDialog(),
  );
}

class _BankImportDialog extends ConsumerStatefulWidget {
  const _BankImportDialog();

  @override
  ConsumerState<_BankImportDialog> createState() => _BankImportDialogState();
}

class _BankImportDialogState extends ConsumerState<_BankImportDialog> {
  final _controller = TextEditingController();
  bool _importing = false;
  int? _importedCount;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _doImport() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _importing = true);
    final count = await ref.read(bankProvider.notifier).importFromText(text);
    setState(() {
      _importing = false;
      _importedCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imported = _importedCount != null;

    return Dialog(
      backgroundColor: const Color(0xFF3B2A14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    imported ? Icons.check_circle : Icons.inventory_2,
                    size: 22,
                    color: imported ? kGreen : const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    imported ? 'Bank Imported!' : 'Import Your Bank',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kGold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(_importedCount),
                    color: Colors.white38,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (imported) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: kGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_importedCount items loaded',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: kCream,
                                )),
                            Text('Recommendations will now use your bank data.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kCream.withValues(alpha: 0.5),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_importedCount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Done',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kDarkBrown.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: kLightBrown.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 13, color: kGold),
                          SizedBox(width: 6),
                          Text('How to export from RuneLite',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kGold,
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _instructionRow('1',
                          'Install the "Bank Memory" plugin from Plugin Hub'),
                      _instructionRow('2', 'Open your bank in-game'),
                      _instructionRow(
                          '3', 'Click export in the Bank Memory panel'),
                      _instructionRow('4', 'Paste the data below'),
                      const SizedBox(height: 4),
                      Text(
                        'Also supports: one item per line, "item x qty", or comma-separated.',
                        style: TextStyle(
                          fontSize: 10,
                          color: kCream.withValues(alpha: 0.35),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Text area
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Paste your bank export here...\n\ne.g.:\n590\tTinderbox\t3\n3142\tRaw karambwan\t16483',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      color: kCream.withValues(alpha: 0.25),
                    ),
                    filled: true,
                    fillColor: kDarkBrown.withValues(alpha: 0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: kLightBrown.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: kLightBrown.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kGold),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: kCream.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _importing ? null : _doImport,
                        icon: _importing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.file_upload, size: 16),
                        label: Text(_importing ? 'Importing...' : 'Import Bank',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          _controller.text = data!.text!;
                        }
                      },
                      icon: const Icon(Icons.paste, size: 14),
                      label:
                          const Text('Paste', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _instructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: kGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: kGold,
                )),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 11,
                  color: kCream.withValues(alpha: 0.6),
                  height: 1.3,
                )),
          ),
        ],
      ),
    );
  }
}

/// A compact banner shown when bank is empty, prompting the user to import.
/// Place this at the top of screens that benefit from bank data.
class BankEmptyBanner extends ConsumerWidget {
  const BankEmptyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankState = ref.watch(bankProvider);
    if (!bankState.isLoaded || bankState.items.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, size: 16, color: Color(0xFFFF9800)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Import your bank for smarter recommendations',
              style: TextStyle(
                fontSize: 12,
                color: kCream.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => showBankImportDialog(context),
            icon: const Icon(Icons.file_upload, size: 14),
            label: const Text('Import',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
