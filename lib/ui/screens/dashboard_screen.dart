import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../../services/rest_timer_service.dart';

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
    final timer = ref.watch(restTimerProvider);
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
                IconButton(
                  tooltip: 'Save as routine',
                  onPressed: () => _saveRoutine(controller.activeWorkout!),
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timer.isRunning) RestTimerBar(timer: timer),
          NavigationBar(
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
        ],
      ),
    );
  }

  Future<void> _finishWorkout(AppController controller) async {
    final workout = controller.activeWorkout;
    if (workout == null) return;
    final completedSets = workout.exercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.sets.where((set) => set.isCompleted).length,
    );
    final incompleteSets = workout.exercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.sets.where((set) => !set.isCompleted).length,
    );
    if (completedSets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete at least one set first.')),
      );
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _FinishWorkoutDialog(
        summary: incompleteSets == 0
            ? '$completedSets completed sets will be saved to your history.'
            : '$completedSets completed sets will be saved. $incompleteSets unchecked sets will be omitted.',
      ),
    );
    if (name != null) {
      await controller.finishWorkout(name: name);
      if (mounted) setState(() => _tab = 1);
    }
  }

  Future<void> _saveRoutine(WorkoutSessionModel workout) async {
    final name = await _askForName('Save workout as routine');
    if (name == null || name.isEmpty) return;
    await ref.read(appControllerProvider).saveWorkoutAsRoutine(workout, name);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved “$name” as a routine.')));
    }
  }

  Future<String?> _askForName(String title) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _TextPromptDialog(
        title: title,
        label: 'Routine name',
        actionLabel: 'Save',
      ),
    );
  }
}

class _FinishWorkoutDialog extends StatefulWidget {
  const _FinishWorkoutDialog({required this.summary});

  final String summary;

  @override
  State<_FinishWorkoutDialog> createState() => _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends State<_FinishWorkoutDialog> {
  final name = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Finish workout?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.summary),
        const SizedBox(height: 18),
        TextField(
          key: const ValueKey('workoutNameField'),
          controller: name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Workout name',
            hintText: 'Optional',
          ),
          onSubmitted: (_) => _finish(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Keep logging'),
      ),
      FilledButton(onPressed: _finish, child: const Text('Finish')),
    ],
  );

  void _finish() => Navigator.pop(context, name.text.trim());
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
                  onPressed: () => _chooseStart(context),
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

  Future<void> _chooseStart(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start workout',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await controller.startWorkout();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Start empty'),
                ),
              ),
              if (controller.routines.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _SectionLabel('SAVED ROUTINES'),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.routines.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final routine = controller.routines[index];
                      final setCount = routine.exercises.fold<int>(
                        0,
                        (total, exercise) => total + exercise.setCount,
                      );
                      return Card(
                        child: ListTile(
                          title: Text(
                            routine.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${routine.exercises.length} exercises · $setCount sets',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'rename') {
                                await _renameRoutine(context, routine);
                              } else if (value == 'delete') {
                                await controller.deleteRoutine(routine.id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await controller.startWorkoutFromRoutine(
                              routine.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _renameRoutine(
    BuildContext context,
    WorkoutRoutineModel routine,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _TextPromptDialog(
        title: 'Rename routine',
        label: 'Routine name',
        actionLabel: 'Save',
        initialValue: routine.name,
      ),
    );
    if (name != null && name.isNotEmpty) {
      await controller.renameRoutine(routine.id, name);
    }
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
            FutureBuilder<List<PreviousSetSnapshot>>(
              future: controller.previousSets(choice),
              builder: (context, snapshot) {
                final previous = snapshot.data ?? const <PreviousSetSnapshot>[];
                return Column(
                  children: exercise.sets.asMap().entries.map((setEntry) {
                    final prior = previous
                        .where(
                          (item) => item.position == setEntry.value.position,
                        )
                        .firstOrNull;
                    return SetEditorRow(
                      key: ValueKey(setEntry.value.id),
                      controller: controller,
                      exercise: choice,
                      set: setEntry.value,
                      previous: prior,
                      isFirst: setEntry.key == 0,
                      isLast: setEntry.key == exercise.sets.length - 1,
                    );
                  }).toList(),
                );
              },
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
    required this.previous,
    required this.isFirst,
    required this.isLast,
  });
  final AppController controller;
  final ExerciseChoice exercise;
  final WorkoutSetModel set;
  final PreviousSetSnapshot? previous;
  final bool isFirst;
  final bool isLast;

  @override
  State<SetEditorRow> createState() => _SetEditorRowState();
}

class _SetEditorRowState extends State<SetEditorRow> {
  late final TextEditingController reps;
  late final TextEditingController load;
  late BodyweightAdjustment adjustment;
  late WeightUnit _displayUnit;

  @override
  void initState() {
    super.initState();
    reps = TextEditingController();
    load = TextEditingController();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant SetEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_displayUnit != widget.controller.weightUnit ||
        oldWidget.set.reps != widget.set.reps ||
        oldWidget.set.loadKg != widget.set.loadKg ||
        oldWidget.set.bodyweightAdjustmentKg !=
            widget.set.bodyweightAdjustmentKg ||
        oldWidget.set.adjustment != widget.set.adjustment ||
        oldWidget.set.isCompleted != widget.set.isCompleted) {
      _syncFromWidget();
    } else if (oldWidget.previous != widget.previous &&
        widget.set.reps == 0 &&
        reps.text.isEmpty) {
      adjustment = widget.previous?.adjustment ?? adjustment;
    }
  }

  void _syncFromWidget() {
    _displayUnit = widget.controller.weightUnit;
    reps.text = widget.set.reps == 0 ? '' : '${widget.set.reps}';
    final kilograms = widget.exercise.equipmentType == EquipmentType.bodyweight
        ? widget.set.bodyweightAdjustmentKg
        : widget.set.loadKg;
    final displayed = kilograms == null
        ? null
        : widget.controller.weightUnit.fromKilograms(kilograms);
    load.text = displayed == null ? '' : _compact(displayed);
    adjustment =
        widget.set.adjustment == BodyweightAdjustment.none &&
            widget.set.bodyweightAdjustmentKg == null
        ? widget.previous?.adjustment ?? BodyweightAdjustment.none
        : widget.set.adjustment;
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

  double? _previousDisplayedLoad() {
    final previous = widget.previous;
    if (previous == null) return null;
    final kilograms = widget.exercise.equipmentType == EquipmentType.bodyweight
        ? previous.bodyweightAdjustmentKg
        : previous.loadKg;
    return kilograms == null
        ? null
        : widget.controller.weightUnit.fromKilograms(kilograms);
  }

  Future<void> _toggleCompleted() async {
    if (widget.set.isCompleted) {
      await widget.controller.reopenSet(widget.set.id);
      return;
    }
    final repsValue = int.tryParse(reps.text) ?? widget.previous?.reps ?? 0;
    if (repsValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter reps before completing the set.')),
      );
      return;
    }
    final displayedLoad =
        double.tryParse(load.text.replaceAll(',', '.')) ??
        _previousDisplayedLoad();
    final kilograms = displayedLoad == null
        ? null
        : widget.controller.weightUnit.toKilograms(displayedLoad);
    final bodyweight =
        widget.exercise.equipmentType == EquipmentType.bodyweight;
    await widget.controller.completeSet(
      setId: widget.set.id,
      reps: repsValue,
      loadKg: bodyweight ? null : kilograms,
      bodyweightAdjustmentKg:
          bodyweight && adjustment != BodyweightAdjustment.none
          ? kilograms
          : null,
      adjustment: bodyweight ? adjustment : BodyweightAdjustment.none,
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
            width: 42,
            child: Column(
              children: [
                Text(
                  '${widget.set.position + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  tooltip: widget.set.isCompleted
                      ? 'Reopen set'
                      : 'Complete set',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _toggleCompleted,
                  icon: Icon(
                    widget.set.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: reps,
              enabled: !widget.set.isCompleted,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                hintText: widget.previous == null
                    ? null
                    : '${widget.previous!.reps}',
                floatingLabelBehavior: FloatingLabelBehavior.always,
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
                key: ValueKey(adjustment),
                initialValue: adjustment,
                disabledHint: Text(
                  adjustment == BodyweightAdjustment.none
                      ? 'Body'
                      : adjustment == BodyweightAdjustment.added
                      ? 'Added'
                      : 'Assist',
                ),
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
                onChanged: widget.set.isCompleted
                    ? null
                    : (value) {
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
                enabled: !widget.set.isCompleted,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.controller.weightUnit.shortLabel,
                  hintText: _previousDisplayedLoad() == null
                      ? null
                      : _compact(_previousDisplayedLoad()!),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
              session.name ??
                  _dateLabel(session.finishedAt ?? session.startedAt),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              session.name == null
                  ? '${session.gymLocationName} · ${session.exercises.length} exercises · $setCount sets'
                  : '${_dateLabel(session.finishedAt ?? session.startedAt)} · ${session.gymLocationName}\n${session.exercises.length} exercises · $setCount sets',
            ),
            isThreeLine: session.name != null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (context) => _HistoryDetail(
                session: session,
                unit: controller.weightUnit,
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryDetail extends StatelessWidget {
  const _HistoryDetail({
    required this.session,
    required this.unit,
    required this.controller,
  });
  final WorkoutSessionModel session;
  final WeightUnit unit;
  final AppController controller;
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
            session.name ?? _dateLabel(session.finishedAt ?? session.startedAt),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (session.name != null)
            Text(
              _dateLabel(session.finishedAt ?? session.startedAt),
              style: const TextStyle(color: Colors.black54),
            ),
          Text(
            session.gymLocationName,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _saveAsRoutine(context),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save as routine'),
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

  Future<void> _saveAsRoutine(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _TextPromptDialog(
        title: 'Save workout as routine',
        label: 'Routine name',
        actionLabel: 'Save',
      ),
    );
    if (name != null && name.isNotEmpty) {
      await controller.saveWorkoutAsRoutine(session, name);
      if (context.mounted) Navigator.pop(context);
    }
  }
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
      const _SectionLabel('REST TIMER'),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.restTimer.durationSeconds,
              isExpanded: true,
              items: const [60, 90, 120, 180]
                  .map(
                    (seconds) => DropdownMenuItem(
                      value: seconds,
                      child: Text(
                        seconds < 60
                            ? '$seconds seconds'
                            : '${seconds ~/ 60}${seconds % 60 == 0 ? '' : ':${(seconds % 60).toString().padLeft(2, '0')}'} minutes',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.setRestTimerSeconds(value);
              },
            ),
          ),
        ),
      ),
      if (controller.restTimer.permissionDenied)
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            'Notification permission is off. The timer will still work while the app is open.',
            style: TextStyle(color: Colors.black54),
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
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _TextPromptDialog(
        title: 'Add gym location',
        label: 'Name',
        actionLabel: 'Add',
      ),
    );
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

class RestTimerBar extends StatelessWidget {
  const RestTimerBar({super.key, required this.timer});
  final RestTimerService timer;

  @override
  Widget build(BuildContext context) {
    final remaining = timer.remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Rest $minutes:$seconds',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton(
                onPressed: timer.addThirtySeconds,
                child: const Text('+30 sec'),
              ),
              TextButton(onPressed: timer.skip, child: const Text('Skip')),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.label,
    required this.actionLabel,
    this.initialValue,
  });

  final String title;
  final String label;
  final String actionLabel;
  final String? initialValue;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController text = TextEditingController(
    text: widget.initialValue,
  );

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
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
    ],
  );

  void _submit() {
    final value = text.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }
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
