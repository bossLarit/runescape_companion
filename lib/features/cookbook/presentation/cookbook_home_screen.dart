import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/cookbook_models.dart';
import 'providers/cookbook_provider.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../../core/widgets/screen_header.dart';

class CookbookHomeScreen extends HookConsumerWidget {
  const CookbookHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cbState = ref.watch(cookbookProvider);
    final activeChar = ref.watch(activeCharacterProvider);
    final searchQuery = useState('');
    final filterMode = useState<CookbookMode?>(null);
    final selectedTemplate = useState<CookbookTemplate?>(null);

    final filtered = cbState.templates.where((t) {
      if (filterMode.value != null && t.mode != filterMode.value) return false;
      if (searchQuery.value.isNotEmpty &&
          !t.title.toLowerCase().contains(searchQuery.value.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    if (selectedTemplate.value != null) {
      return _CookbookReaderView(
        template: selectedTemplate.value!,
        characterId: activeChar?.id ?? '',
        onBack: () => selectedTemplate.value = null,
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Build Cookbook',
              characterName: activeChar?.displayName,
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _showTemplateForm(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New Template'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Search templates...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true),
                    onChanged: (v) => searchQuery.value = v,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<CookbookMode?>(
                  value: filterMode.value,
                  hint: const Text('Mode'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...CookbookMode.values.map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.name))),
                  ],
                  onChanged: (v) => filterMode.value = v,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No templates found',
                          style: TextStyle(color: Colors.white54)))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final template = filtered[index];
                        final progress = activeChar != null
                            ? ref
                                .read(cookbookProvider.notifier)
                                .getOrCreateProgress(template.id, activeChar.id)
                            : null;
                        final completedCount =
                            progress?.completedStepIds.length ?? 0;
                        final totalSteps = template.totalSteps;
                        final pct = totalSteps > 0
                            ? (completedCount / totalSteps * 100)
                            : 0.0;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => selectedTemplate.value = template,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(template.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                      Chip(
                                          label: Text(template.mode.name,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(template.description,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  Text(
                                      '${template.sections.length} sections | $totalSteps steps',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.white38)),
                                  const SizedBox(height: 4),
                                  if (activeChar != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.white12,
                                        valueColor: AlwaysStoppedAnimation(
                                            pct >= 100
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                        '$completedCount / $totalSteps (${pct.toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white38)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateForm(BuildContext context, WidgetRef ref,
      [CookbookTemplate? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final tagsCtrl =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    final mode = ValueNotifier(existing?.mode ?? CookbookMode.iron);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Template' : 'New Template'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  autofocus: true),
              const SizedBox(height: 8),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3),
              const SizedBox(height: 8),
              ValueListenableBuilder<CookbookMode>(
                valueListenable: mode,
                builder: (_, v, __) => DropdownButtonFormField<CookbookMode>(
                  key: ValueKey(v),
                  value: v,
                  decoration: const InputDecoration(labelText: 'Mode'),
                  items: CookbookMode.values
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (val) => mode.value = val ?? CookbookMode.iron,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final tags = tagsCtrl.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();
              if (existing != null) {
                ref.read(cookbookProvider.notifier).updateTemplate(
                    existing.copyWith(
                        title: title,
                        description: descCtrl.text.trim(),
                        mode: mode.value,
                        tags: tags));
              } else {
                ref.read(cookbookProvider.notifier).addTemplate(
                    CookbookTemplate(
                        title: title,
                        description: descCtrl.text.trim(),
                        mode: mode.value,
                        tags: tags));
              }
              Navigator.of(ctx).pop();
            },
            child: Text(existing != null ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}

class _CookbookReaderView extends HookConsumerWidget {
  final CookbookTemplate template;
  final String characterId;
  final VoidCallback onBack;

  const _CookbookReaderView(
      {required this.template,
      required this.characterId,
      required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cbState = ref.watch(cookbookProvider);
    final progress = cbState.progress
        .where(
            (p) => p.templateId == template.id && p.characterId == characterId)
        .firstOrNull;
    final completedIds = progress?.completedStepIds ?? {};
    final selectedSectionIndex = useState(0);
    final totalSteps = template.totalSteps;
    final completedCount = completedIds.length;
    final pct = totalSteps > 0 ? (completedCount / totalSteps * 100) : 0.0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: onBack, icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(template.title,
                        style: Theme.of(context).textTheme.headlineSmall)),
                Chip(label: Text(template.mode.name)),
                const SizedBox(width: 8),
                Text(
                    '$completedCount / $totalSteps (${pct.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white12),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sections nav
                  SizedBox(
                    width: 220,
                    child: ListView.builder(
                      itemCount: template.sections.length,
                      itemBuilder: (_, i) {
                        final section = template.sections[i];
                        final sectionCompleted = section.steps
                            .where((s) => completedIds.contains(s.id))
                            .length;
                        final isSelected = selectedSectionIndex.value == i;
                        return Card(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2)
                              : null,
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            title: Text(section.title,
                                style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                            subtitle: Text(
                                '$sectionCompleted / ${section.steps.length}',
                                style: const TextStyle(fontSize: 11)),
                            onTap: () => selectedSectionIndex.value = i,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Steps
                  Expanded(
                    child: template.sections.isEmpty
                        ? const Center(
                            child: Text('No sections',
                                style: TextStyle(color: Colors.white54)))
                        : _SectionStepsView(
                            section:
                                template.sections[selectedSectionIndex.value],
                            completedIds: completedIds,
                            onToggle: (stepId) {
                              ref
                                  .read(cookbookProvider.notifier)
                                  .toggleStep(template.id, characterId, stepId);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionStepsView extends StatelessWidget {
  final CookbookSection section;
  final Set<String> completedIds;
  final void Function(String) onToggle;

  const _SectionStepsView(
      {required this.section,
      required this.completedIds,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: section.steps.length,
      itemBuilder: (context, index) {
        final step = section.steps[index];
        final isCompleted = completedIds.contains(step.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isCompleted ? Colors.green.withValues(alpha: 0.05) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggle(step.id),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.white38 : null,
                        ),
                      ),
                      if (step.description.isNotEmpty)
                        Text(step.description,
                            style: TextStyle(
                                fontSize: 12,
                                color: isCompleted
                                    ? Colors.white24
                                    : Colors.white54)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (step.category != StepCategory.custom)
                            Text(step.category.name,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.amber[200])),
                          if (step.estimatedMinutes != null)
                            Text('~${step.estimatedMinutes}min',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white38)),
                          if (step.location != null &&
                              step.location!.isNotEmpty)
                            Text(step.location!,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                      if (step.requirements.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Requires: ${step.requirements.join(", ")}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.orange)),
                      ],
                      if (step.links.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: step.links
                              .map((link) => InkWell(
                                    onTap: () => launchUrl(Uri.parse(link)),
                                    child: Text('Wiki',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[300],
                                            decoration:
                                                TextDecoration.underline)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
