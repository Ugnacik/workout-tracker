import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../state/app_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appControllerProvider);
    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (controller.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 44),
                const SizedBox(height: 12),
                const Text('We could not open your workout data.'),
                const SizedBox(height: 8),
                Text('${controller.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: controller.initialize,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final titles = ['Workout', 'History', 'Settings'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_tab]),
        actions: _tab == 0 && controller.activeWorkout != null
            ? [
                TextButton(
                  onPressed: () => _finishWorkout(controller),
                  child: const Text('Finish'),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          WorkoutTab(controller: controller),
          HistoryTab(controller: controller),
          SettingsTab(controller: controller),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout(AppController controller) async {
    final workout = controller.activeWorkout;
    if (workout == null) return;
    if (workout.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise first.')),
      );
      return;
    }
    final finish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish workout?'),
        content: Text(
          '${workout.exercises.length} exercises will be saved to your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep logging'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (finish == true) {
      await controller.finishWorkout();
      if (mounted) setState(() => _tab = 1);
    }
  }
}

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final workout = controller.activeWorkout;
    if (workout == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_chart,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ready when you are',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Start at ${controller.defaultLocation?.name ?? 'your gym'}, then choose movements by muscle and function.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.startWorkout,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start workout'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: workout.gymLocationId,
                      isExpanded: true,
                      items: controller.locations
                          .map(
                            (location) => DropdownMenuItem(
                              value: location.id,
                              child: Text(location.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) => id == null
                          ? null
                          : controller.changeWorkoutLocation(id),
                    ),
                  ),
                ),
                Text(
                  _timeOnly(workout.startedAt),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (workout.exercises.isEmpty)
          const _EmptyWorkout()
        else
          ...workout.exercises.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ExerciseLogCard(
                key: ValueKey(entry.value.id),
                controller: controller,
                exercise: entry.value,
                isFirst: entry.key == 0,
                isLast: entry.key == workout.exercises.length - 1,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () async {
            final choice = await context.push<ExerciseChoice>('/exercises');
            if (choice != null) await controller.addExercise(choice);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add exercise'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _discard(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Discard workout'),
        ),
      ],
    );
  }

  Future<void> _discard(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text(
          'This unfinished workout and its sets will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) await controller.discardWorkout();
  }
}

class _EmptyWorkout extends StatelessWidget {
  const _EmptyWorkout();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE4E9E2)),
    ),
    child: const Column(
      children: [
        Icon(Icons.format_list_bulleted_add, size: 38, color: Colors.black38),
        SizedBox(height: 12),
        Text(
          'No exercises yet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        SizedBox(height: 4),
        Text(
          'Browse by muscle and movement pattern.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}

class ExerciseLogCard extends StatelessWidget {
  const ExerciseLogCard({
    super.key,
    required this.controller,
    required this.exercise,
    required this.isFirst,
    required this.isLast,
  });
  final AppController controller;
  final WorkoutExerciseModel exercise;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final choice = exercise.exercise;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${choice.muscleGroupName} · ${choice.movementPatternName}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (choice.machineModel != null)
                        Text(
                          choice.machineModel!.displayName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'up') controller.moveExercise(exercise.id, -1);
                    if (value == 'down') {
                      controller.moveExercise(exercise.id, 1);
                    }
                    if (value == 'remove') {
                      controller.removeExercise(exercise.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'up',
                      enabled: !isFirst,
                      child: const Text('Move up'),
                    ),
                    PopupMenuItem(
                      value: 'down',
                      enabled: !isLast,
                      child: const Text('Move down'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove exercise'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...exercise.sets.asMap().entries.map(
              (setEntry) => SetEditorRow(
                key: ValueKey(setEntry.value.id),
                controller: controller,
                exercise: choice,
                set: setEntry.value,
                isFirst: setEntry.key == 0,
                isLast: setEntry.key == exercise.sets.length - 1,
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => controller.addSet(exercise.id),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add set'),
            ),
          ],
        ),
      ),
    );
  }
}

class SetEditorRow extends StatefulWidget {
  const SetEditorRow({
    super.key,
    required this.controller,
    required this.exercise,
    required this.set,
    required this.isFirst,
    required this.isLast,
  });
  final AppController controller;
  final ExerciseChoice exercise;
  final WorkoutSetModel set;
  final bool isFirst;
  final bool isLast;

  @override
  State<SetEditorRow> createState() => _SetEditorRowState();
}

class _SetEditorRowState extends State<SetEditorRow> {
  late final TextEditingController reps;
  late final TextEditingController load;
  late BodyweightAdjustment adjustment;

  @override
  void initState() {
    super.initState();
    reps = TextEditingController(
      text: widget.set.reps == 0 ? '' : '${widget.set.reps}',
    );
    final kilograms = widget.exercise.equipmentType == EquipmentType.bodyweight
        ? widget.set.bodyweightAdjustmentKg
        : widget.set.loadKg;
    final displayed = kilograms == null
        ? null
        : widget.controller.weightUnit.fromKilograms(kilograms);
    load = TextEditingController(
      text: displayed == null ? '' : _compact(displayed),
    );
    adjustment = widget.set.adjustment;
  }

  @override
  void dispose() {
    reps.dispose();
    load.dispose();
    super.dispose();
  }

  Future<void> _save() {
    final repsValue = int.tryParse(reps.text) ?? 0;
    final displayedLoad = double.tryParse(load.text.replaceAll(',', '.'));
    final kilograms = displayedLoad == null
        ? null
        : widget.controller.weightUnit.toKilograms(displayedLoad);
    return widget.controller.updateSet(
      setId: widget.set.id,
      reps: repsValue,
      loadKg: widget.exercise.equipmentType == EquipmentType.bodyweight
          ? null
          : kilograms,
      bodyweightAdjustmentKg:
          widget.exercise.equipmentType == EquipmentType.bodyweight &&
              adjustment != BodyweightAdjustment.none
          ? kilograms
          : null,
      adjustment: widget.exercise.equipmentType == EquipmentType.bodyweight
          ? adjustment
          : BodyweightAdjustment.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyweight =
        widget.exercise.equipmentType == EquipmentType.bodyweight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '${widget.set.position + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
              ),
              onChanged: (_) => _save(),
            ),
          ),
          const SizedBox(width: 8),
          if (bodyweight)
            SizedBox(
              width: 108,
              child: DropdownButtonFormField<BodyweightAdjustment>(
                initialValue: adjustment,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Load',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: BodyweightAdjustment.none,
                    child: Text('Body'),
                  ),
                  DropdownMenuItem(
                    value: BodyweightAdjustment.added,
                    child: Text('Added'),
                  ),
                  DropdownMenuItem(
                    value: BodyweightAdjustment.assisted,
                    child: Text('Assist'),
                  ),
                ],
                onChanged: (value) {
                  setState(
                    () => adjustment = value ?? BodyweightAdjustment.none,
                  );
                  _save();
                },
              ),
            ),
          if (!bodyweight || adjustment != BodyweightAdjustment.none) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 82,
              child: TextField(
                controller: load,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.controller.weightUnit.shortLabel,
                  isDense: true,
                ),
                onChanged: (_) => _save(),
              ),
            ),
          ],
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'copy') {
                widget.controller.duplicateSet(widget.set.id);
              }
              if (value == 'up') widget.controller.moveSet(widget.set.id, -1);
              if (value == 'down') widget.controller.moveSet(widget.set.id, 1);
              if (value == 'remove') widget.controller.removeSet(widget.set.id);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'copy', child: Text('Duplicate')),
              PopupMenuItem(
                value: 'up',
                enabled: !widget.isFirst,
                child: const Text('Move up'),
              ),
              PopupMenuItem(
                value: 'down',
                enabled: !widget.isLast,
                child: const Text('Move down'),
              ),
              const PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Finished workouts will appear here.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: controller.history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = controller.history[index];
        final setCount = session.exercises.fold<int>(
          0,
          (sum, item) => sum + item.sets.length,
        );
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.check),
            ),
            title: Text(
              _dateLabel(session.finishedAt ?? session.startedAt),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${session.gymLocationName} · ${session.exercises.length} exercises · $setCount sets',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (context) =>
                  _HistoryDetail(session: session, unit: controller.weightUnit),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryDetail extends StatelessWidget {
  const _HistoryDetail({required this.session, required this.unit});
  final WorkoutSessionModel session;
  final WeightUnit unit;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            _dateLabel(session.finishedAt ?? session.startedAt),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            session.gymLocationName,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ...session.exercises.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    entry.exercise.machineModel?.displayName ??
                        entry.exercise.equipmentType.label,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  ...entry.sets.map(
                    (set) => Text(_setSummary(set, entry.exercise, unit)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
    children: [
      const _SectionLabel('MEASUREMENTS'),
      Card(
        child: RadioGroup<WeightUnit>(
          groupValue: controller.weightUnit,
          onChanged: (value) {
            if (value != null) controller.setWeightUnit(value);
          },
          child: Column(
            children: WeightUnit.values
                .map(
                  (unit) => RadioListTile<WeightUnit>(
                    value: unit,
                    title: Text(
                      unit == WeightUnit.kilograms
                          ? 'Kilograms (kg)'
                          : 'Pounds (lb)',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      const SizedBox(height: 22),
      const _SectionLabel('GYM LOCATIONS'),
      Card(
        child: RadioGroup<String>(
          groupValue: controller.defaultLocation?.id,
          onChanged: (value) {
            if (value != null) controller.setDefaultLocation(value);
          },
          child: Column(
            children: [
              ...controller.locations.map(
                (location) => RadioListTile<String>(
                  value: location.id,
                  title: Text(location.name),
                  subtitle: location.isDefault
                      ? const Text('Default location')
                      : null,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add location'),
                onTap: () => _addLocation(context),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      const _SectionLabel('ABOUT'),
      const Card(
        child: ListTile(
          leading: Icon(Icons.offline_bolt_outlined),
          title: Text('Local-first storage'),
          subtitle: Text('Your workout data stays on this device.'),
        ),
      ),
    ],
  );

  Future<void> _addLocation(BuildContext context) async {
    final text = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add gym location'),
        content: TextField(
          controller: text,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, text.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    text.dispose();
    if (name != null && name.isNotEmpty) await controller.addLocation(name);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

String _setSummary(
  WorkoutSetModel set,
  ExerciseChoice exercise,
  WeightUnit unit,
) {
  if (exercise.equipmentType == EquipmentType.bodyweight) {
    if (set.adjustment == BodyweightAdjustment.none ||
        set.bodyweightAdjustmentKg == null) {
      return '${set.position + 1}. ${set.reps} reps · bodyweight';
    }
    final kind = set.adjustment == BodyweightAdjustment.assisted
        ? 'assisted'
        : 'added';
    return '${set.position + 1}. ${set.reps} reps · ${_compact(unit.fromKilograms(set.bodyweightAdjustmentKg!))} ${unit.shortLabel} $kind';
  }
  return '${set.position + 1}. ${set.reps} reps · ${_compact(unit.fromKilograms(set.loadKg ?? 0))} ${unit.shortLabel}';
}

String _compact(double value) => value == value.roundToDouble()
    ? '${value.round()}'
    : value.toStringAsFixed(1);
String _timeOnly(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
