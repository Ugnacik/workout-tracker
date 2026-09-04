import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../state/app_controller.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final search = TextEditingController();
  String? muscleId;
  String? patternId;
  EquipmentType? equipment;
  String? manufacturerId;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    final catalog = controller.catalog;
    final patterns = catalog.patterns
        .where((item) => muscleId == null || item.muscleGroupId == muscleId)
        .toList();
    final results = filterExercises(
      catalog,
      ExerciseFilter(
        query: search.text,
        muscleGroupId: muscleId,
        movementPatternId: patternId,
        equipmentType: equipment,
        manufacturerId: manufacturerId,
      ),
    );
    final manufacturers = {
      for (final machine in catalog.machines)
        machine.manufacturerId: machine.manufacturerName,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose exercise'),
        actions: [
          IconButton(
            tooltip: 'Create exercise',
            onPressed: () => _createExercise(controller),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search exercises or functions',
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All muscles'),
                    selected: muscleId == null,
                    onSelected: (_) => setState(() {
                      muscleId = null;
                      patternId = null;
                    }),
                  ),
                ),
                ...catalog.muscles.map(
                  (muscle) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(muscle.name),
                      selected: muscleId == muscle.id,
                      onSelected: (_) => setState(() {
                        muscleId = muscleId == muscle.id ? null : muscle.id;
                        patternId = null;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: patternId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Movement pattern',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All patterns'),
                      ),
                      ...patterns.map(
                        (pattern) => DropdownMenuItem<String?>(
                          value: pattern.id,
                          child: Text(pattern.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => patternId = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<EquipmentType?>(
                    initialValue: equipment,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Equipment',
                      isDense: true,
                    ),
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
                    onChanged: (value) => setState(() {
                      equipment = value;
                      if (value != EquipmentType.machine) manufacturerId = null;
                    }),
                  ),
                ),
              ],
            ),
          ),
          if (equipment == EquipmentType.machine)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DropdownButtonFormField<String?>(
                initialValue: manufacturerId,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All manufacturers'),
                  ),
                  ...manufacturers.entries.map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => manufacturerId = value),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Row(
              children: [
                Text(
                  '${results.length} EXERCISES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _createExercise(controller),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create'),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No exercises match these filters.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final exercise = results[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: Icon(
                              _equipmentIcon(exercise.equipmentType),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${exercise.muscleGroupName} · ${exercise.movementPatternName}\n${exercise.equipmentType.label}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.add),
                          onTap: () => _selectExercise(controller, exercise),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExercise(
    AppController controller,
    ExerciseChoice exercise,
  ) async {
    var selected = exercise;
    if (exercise.equipmentType == EquipmentType.machine) {
      final machine = await _chooseMachine(controller);
      if (machine == null) return;
      selected = exercise.withMachine(machine);
    }
    final previous = await controller.previousSets(selected);
    if (!mounted) return;
    final add = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected.name,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${selected.muscleGroupName} · ${selected.movementPatternName}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (selected.machineModel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    selected.machineModel!.displayName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer
                      .withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  previous.isEmpty
                      ? 'No previous performance for this setup.'
                      : 'Last workout: ${_previousSummary(previous, selected, controller.weightUnit)}',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add to workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (add == true && mounted) Navigator.pop(context, selected);
  }

  Future<MachineModelInfo?> _chooseMachine(AppController controller) async {
    var machines = controller.catalog.machines
        .where(
          (machine) =>
              manufacturerId == null ||
              machine.manufacturerId == manufacturerId,
        )
        .toList();
    MachineModelInfo? selected;
    return showDialog<MachineModelInfo>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Choose machine model'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<MachineModelInfo>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Manufacturer · model',
                  ),
                  items: machines
                      .map(
                        (machine) => DropdownMenuItem(
                          value: machine,
                          child: Text(
                            machine.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => update(() => selected = value),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final created = await _createMachine(controller);
                      if (created != null) {
                        update(() {
                          machines = [...machines, created];
                          selected = created;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add manufacturer or model'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(dialogContext, selected),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<MachineModelInfo?> _createMachine(AppController controller) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => const _MachineModelDialog(),
    );
    if (result == null || result.any((value) => value.isEmpty)) return null;
    return controller.addMachineModel(
      manufacturerName: result[0],
      modelName: result[1],
    );
  }

  Future<void> _createExercise(AppController controller) async {
    final result = await showDialog<ExerciseChoice>(
      context: context,
      builder: (context) => _CreateExerciseDialog(controller: controller),
    );
    if (result != null) await _selectExercise(controller, result);
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
                icon: const Icon(Icons.add, size: 18),
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
                  );
                  if (!mounted) return;
                  Navigator.pop(this.context, created);
                },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _addMovementPattern() async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _TextEntryDialog(
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

class _MachineModelDialog extends StatefulWidget {
  const _MachineModelDialog();

  @override
  State<_MachineModelDialog> createState() => _MachineModelDialogState();
}

class _MachineModelDialogState extends State<_MachineModelDialog> {
  final maker = TextEditingController();
  final model = TextEditingController();

  @override
  void dispose() {
    maker.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add machine model'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: maker,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Manufacturer'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: model,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Model'),
          onSubmitted: (_) => _submit(),
        ),
      ],
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
    final manufacturer = maker.text.trim();
    final modelName = model.text.trim();
    if (manufacturer.isNotEmpty && modelName.isNotEmpty) {
      Navigator.pop(context, [manufacturer, modelName]);
    }
  }
}

IconData _equipmentIcon(EquipmentType type) => switch (type) {
  EquipmentType.bodyweight => Icons.accessibility_new,
  EquipmentType.dumbbell => Icons.fitness_center,
  EquipmentType.barbell => Icons.horizontal_rule,
  EquipmentType.machine => Icons.precision_manufacturing_outlined,
  EquipmentType.other => Icons.category_outlined,
};

String _previousSummary(
  List<PreviousSetSnapshot> sets,
  ExerciseChoice exercise,
  WeightUnit unit,
) {
  return sets
      .take(3)
      .map((set) {
        final kilograms = exercise.equipmentType == EquipmentType.bodyweight
            ? set.bodyweightAdjustmentKg
            : set.loadKg;
        final load = kilograms == null
            ? ''
            : ' × ${_compactPrevious(unit.fromKilograms(kilograms))} ${unit.shortLabel}';
        final kind =
            exercise.equipmentType == EquipmentType.bodyweight &&
                set.adjustment != BodyweightAdjustment.none
            ? ' ${set.adjustment == BodyweightAdjustment.assisted ? 'assisted' : 'added'}'
            : '';
        return '${set.reps}$load$kind';
      })
      .join(' · ');
}

String _compactPrevious(double value) => value == value.roundToDouble()
    ? '${value.round()}'
    : value.toStringAsFixed(1);
