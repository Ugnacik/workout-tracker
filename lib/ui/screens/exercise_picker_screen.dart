import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_components.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final search = TextEditingController();
  final searchFocus = FocusNode();
  String? muscleId;
  String? patternId;
  EquipmentType? equipment;

  int get activeFilterCount =>
      [muscleId, patternId, equipment].where((value) => value != null).length;

  @override
  void dispose() {
    search.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final catalog = controller.catalog;
    final results = filterExercises(
      catalog,
      ExerciseFilter(
        query: search.text,
        muscleGroupId: muscleId,
        movementPatternId: patternId,
        equipmentType: equipment,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          Tooltip(
            message: 'Create exercise',
            child: TextButton.icon(
              onPressed: () => _createExercise(controller),
              icon: MediaQuery.textScalerOf(context).scale(14) >= 21
                  ? const SizedBox.shrink()
                  : const Icon(Icons.add),
              label: const Text('Create'),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
      body: AppContentFrame(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xxs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Semantics(
                textField: true,
                label: 'Search exercises',
                child: TextField(
                  controller: search,
                  focusNode: searchFocus,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const ExcludeSemantics(
                      child: Icon(Icons.search),
                    ),
                    labelText: 'Search exercises',
                    hintText: 'Name, muscle, or movement',
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              search.clear();
                              setState(() {});
                              searchFocus.requestFocus();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
            ),
            _MuscleFilters(
              catalog: catalog,
              selectedMuscleId: muscleId,
              onSelected: (value) => setState(() {
                muscleId = value;
                patternId = null;
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        '${results.length} exercise${results.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showFilters(controller),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      activeFilterCount == 0
                          ? 'Filters'
                          : 'Filters ($activeFilterCount)',
                    ),
                  ),
                ],
              ),
            ),
            if (activeFilterCount > 0)
              _ActiveFilters(
                catalog: catalog,
                muscleId: muscleId,
                patternId: patternId,
                equipment: equipment,
                onRemove: _removeFilter,
                onClear: _clearFilters,
              ),
            const SizedBox(height: AppSpacing.xxs),
            Expanded(
              child: results.isEmpty
                  ? AppStateView(
                      icon: Icons.search_off,
                      title: 'No matching exercises',
                      message: 'Try a different search or clear filters to see more exercises.',
                      primaryAction: FilledButton.tonalIcon(
                        onPressed: _clearSearchAndFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear search and filters'),
                      ),
                      secondaryAction: TextButton.icon(
                        onPressed: () => _createExercise(controller),
                        icon: const Icon(Icons.add),
                        label: const Text('Create exercise'),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        0,
                        AppSpacing.sm,
                        AppSpacing.lg,
                      ),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final exercise = results[index];
                        return Card(
                          child: ListTile(
                            minVerticalPadding: AppSpacing.sm,
                            leading: ExcludeSemantics(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: context.semanticColors.subtleSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _equipmentIcon(exercise.equipmentType),
                                  size: AppSizes.iconSmall,
                                ),
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(exercise.labels.join(' · ')),
                            isThreeLine: true,
                            trailing: const ExcludeSemantics(
                              child: Icon(Icons.add_circle_outline),
                            ),
                            onTap: () => _selectExercise(controller, exercise),
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

  void _removeFilter(_FilterKind kind) => setState(() {
    switch (kind) {
      case _FilterKind.muscle:
        muscleId = null;
        patternId = null;
      case _FilterKind.pattern:
        patternId = null;
      case _FilterKind.equipment:
        equipment = null;
    }
  });

  void _clearFilters() => setState(() {
    muscleId = null;
    patternId = null;
    equipment = null;
  });

  void _clearSearchAndFilters() {
    search.clear();
    _clearFilters();
    searchFocus.requestFocus();
  }

  Future<void> _showFilters(AppController controller) async {
    final catalog = controller.catalog;
    var draftPattern = patternId;
    var draftEquipment = equipment;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          final patterns = catalog.patternsForMuscle(muscleId);
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter exercises',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    muscleId == null
                        ? 'Choose a muscle above the results to filter movement patterns.'
                        : 'Muscle filter is set above the results.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String?>(
                    key: ValueKey('pattern-$draftPattern'),
                    initialValue: draftPattern,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Movement pattern',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All movement patterns'),
                      ),
                      ...patterns.map(
                        (pattern) => DropdownMenuItem<String?>(
                          value: pattern.id,
                          child: Text(pattern.name),
                        ),
                      ),
                    ],
                    onChanged: muscleId == null
                        ? null
                        : (value) => update(() => draftPattern = value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<EquipmentType?>(
                    key: ValueKey('equipment-$draftEquipment'),
                    initialValue: draftEquipment,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Equipment'),
                    items: [
                      const DropdownMenuItem<EquipmentType?>(
                        value: null,
                        child: Text('All equipment'),
                      ),
                      ...EquipmentType.values.map(
                        (type) => DropdownMenuItem<EquipmentType?>(
                          value: type,
                          child: Text(type.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => update(() => draftEquipment = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          update(() {
                            draftPattern = null;
                            draftEquipment = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        child: const Text('Apply filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        patternId = draftPattern;
        equipment = draftEquipment;
      });
      searchFocus.requestFocus();
    }
  }

  Future<void> _selectExercise(
    AppController controller,
    ExerciseChoice exercise,
  ) async {
    Navigator.pop(context, exercise.withEquipmentSelection(null, null));
  }

  Future<void> _createExercise(AppController controller) async {
    final result = await showDialog<ExerciseChoice>(
      context: context,
      builder: (context) => _CreateExerciseDialog(controller: controller),
    );
    if (result != null) await _selectExercise(controller, result);
  }
}

class _MuscleFilters extends StatelessWidget {
  const _MuscleFilters({
    required this.catalog,
    required this.selectedMuscleId,
    required this.onSelected,
  });

  final CatalogSnapshot catalog;
  final String? selectedMuscleId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: FilterChip(
            label: const Text('All muscles'),
            selected: selectedMuscleId == null,
            onSelected: (_) => onSelected(null),
          ),
        ),
        ...catalog.muscles.map(
          (muscle) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: FilterChip(
              label: Text(muscle.name),
              selected: selectedMuscleId == muscle.id,
              onSelected: (_) =>
                  onSelected(selectedMuscleId == muscle.id ? null : muscle.id),
            ),
          ),
        ),
      ],
    ),
  );
}

enum _FilterKind { muscle, pattern, equipment }

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.catalog,
    required this.muscleId,
    required this.patternId,
    required this.equipment,
    required this.onRemove,
    required this.onClear,
  });

  final CatalogSnapshot catalog;
  final String? muscleId;
  final String? patternId;
  final EquipmentType? equipment;
  final ValueChanged<_FilterKind> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (muscleId != null) {
      final muscle = catalog.muscles
          .where((item) => item.id == muscleId)
          .firstOrNull;
      if (muscle != null) {
        chips.add(
          InputChip(
            label: Text(muscle.name),
            onDeleted: () => onRemove(_FilterKind.muscle),
          ),
        );
      }
    }
    if (patternId != null) {
      final pattern = catalog.patterns
          .where((item) => item.id == patternId)
          .firstOrNull;
      if (pattern != null) {
        chips.add(
          InputChip(
            label: Text(pattern.name),
            onDeleted: () => onRemove(_FilterKind.pattern),
          ),
        );
      }
    }
    if (equipment != null) {
      chips.add(
        InputChip(
          label: Text(equipment!.label),
          onDeleted: () => onRemove(_FilterKind.equipment),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: chips,
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear all')),
        ],
      ),
    );
  }
}

class _CreateExerciseDialog extends StatefulWidget {
  const _CreateExerciseDialog({required this.controller});

  final AppController controller;

  @override
  State<_CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<_CreateExerciseDialog> {
  final name = TextEditingController();
  String? muscle;
  String? pattern;
  EquipmentType equipment = EquipmentType.other;
  bool saving = false;
  ExerciseExecution? execution;
  bool independentLimbs = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = widget.controller.catalog;
    final patterns = catalog.patterns
        .where((item) => item.muscleGroupId == muscle)
        .toList();
    return AlertDialog(
      title: const Text('Create exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Exercise name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: muscle,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Primary muscle'),
              items: catalog.muscles
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                muscle = value;
                pattern = null;
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: pattern,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Movement pattern'),
              items: patterns
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => pattern = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: muscle == null ? null : _addMovementPattern,
                icon: const Icon(Icons.add),
                label: const Text('Add movement pattern'),
              ),
            ),
            DropdownButtonFormField<EquipmentType>(
              initialValue: equipment,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Equipment'),
              items: EquipmentType.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => equipment = value ?? EquipmentType.other),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<ExerciseExecution?>(
              initialValue: execution,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Execution (optional)',
              ),
              items: [
                const DropdownMenuItem<ExerciseExecution?>(
                  value: null,
                  child: Text('Unspecified'),
                ),
                ...ExerciseExecution.values.map(
                  (value) => DropdownMenuItem<ExerciseExecution?>(
                    value: value,
                    child: Text(value.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => execution = value),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Independent arms/legs'),
              value: independentLimbs,
              onChanged: (value) =>
                  setState(() => independentLimbs = value ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              saving ||
                  name.text.trim().isEmpty ||
                  muscle == null ||
                  pattern == null
              ? null
              : () async {
                  setState(() => saving = true);
                  final created = await widget.controller.addCustomExercise(
                    name: name.text,
                    muscleGroupId: muscle!,
                    movementPatternId: pattern!,
                    equipmentType: equipment,
                    execution: execution,
                    independentLimbs: independentLimbs,
                  );
                  if (mounted) Navigator.pop(this.context, created);
                },
          child: Text(saving ? 'Creating' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _addMovementPattern() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _TextEntryDialog(
        title: 'Add movement pattern',
        label: 'Pattern name',
      ),
    );
    if (name == null || name.isEmpty || muscle == null) return;
    final created = await widget.controller.addMovementPattern(
      name: name,
      muscleGroupId: muscle!,
    );
    if (mounted) setState(() => pattern = created.id);
  }
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final text = TextEditingController();

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: text,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Add')),
    ],
  );

  void _submit() {
    final value = text.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }
}

IconData _equipmentIcon(EquipmentType type) => switch (type) {
  EquipmentType.bodyweight => Icons.accessibility_new,
  EquipmentType.dumbbell => Icons.fitness_center,
  EquipmentType.barbell => Icons.horizontal_rule,
  EquipmentType.machine => Icons.precision_manufacturing_outlined,
  EquipmentType.cable => Icons.cable,
  EquipmentType.other => Icons.category_outlined,
};
