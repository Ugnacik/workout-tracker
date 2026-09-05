import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../services/rest_timer_service.dart';
import '../../services/system_settings_service.dart';
import '../../state/app_controller.dart';
import '../theme/app_tokens.dart';
import '../widgets/machine_selection_sheet.dart';
import '../widgets/app_components.dart';

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
      return const Scaffold(
        body: AppStateView(
          icon: Icons.storage_outlined,
          title: 'Opening your workout data',
          message: 'Your local workout history is being prepared.',
          primaryAction: SizedBox(
            width: 48,
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }
    if (controller.error != null) {
      return Scaffold(
        body: AppStateView(
          icon: Icons.error_outline,
          title: 'Workout data could not be opened',
          message: 'Your data has not been changed. Try opening it again.',
          primaryAction: FilledButton.icon(
            onPressed: controller.initialize,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
      );
    }

    final titles = ['Workout', 'History', 'Settings'];
    final expanded = MediaQuery.sizeOf(context).width >= 840;
    final content = IndexedStack(
      index: _tab,
      children: [
        WorkoutTab(controller: controller),
        HistoryTab(
          controller: controller,
          onShowWorkout: () => setState(() => _tab = 0),
        ),
        SettingsTab(controller: controller),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_tab]),
        actions: _tab == 0 && controller.activeWorkout != null
            ? [
                TextButton(
                  onPressed: () => _finishWorkout(controller),
                  child: const Text('Finish'),
                ),
                const SizedBox(width: AppSpacing.xs),
              ]
            : null,
      ),
      body: expanded
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _tab,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (value) =>
                      setState(() => _tab = value),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(Icons.fitness_center),
                      label: Text('Workout'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timer.isRunning) RestTimerBar(timer: timer),
          if (!expanded)
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
        const SnackBar(
          content: Text('Complete at least one set before finishing.'),
        ),
      );
      return;
    }
    final finished = await showDialog<bool>(
      context: context,
      builder: (context) => _FinishWorkoutDialog(
        controller: controller,
        completedSets: completedSets,
        incompleteSets: incompleteSets,
      ),
    );
    if (finished == true && mounted) setState(() => _tab = 1);
  }
}

class _FinishWorkoutDialog extends StatefulWidget {
  const _FinishWorkoutDialog({
    required this.controller,
    required this.completedSets,
    required this.incompleteSets,
  });

  final AppController controller;
  final int completedSets;
  final int incompleteSets;

  @override
  State<_FinishWorkoutDialog> createState() => _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends State<_FinishWorkoutDialog> {
  final name = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Finish workout?'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.completedSets} completed sets will be saved.'),
          if (widget.incompleteSets > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '${widget.incompleteSets} unchecked sets will stay out of history.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const ValueKey('workoutNameField'),
            controller: name,
            enabled: !saving,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              hintText: 'Optional',
            ),
            onSubmitted: saving ? null : (_) => _finish(),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppInlineNotice(
              icon: Icons.error_outline,
              title: 'Workout was not saved',
              message: 'Your workout and name are still here. Try again.',
              isError: true,
              action: TextButton.icon(
                onPressed: saving ? null : _finish,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context, false),
        child: const Text('Keep logging'),
      ),
      FilledButton.icon(
        onPressed: saving ? null : _finish,
        icon: saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: Text(saving ? 'Saving' : 'Finish'),
      ),
    ],
  );

  Future<void> _finish() async {
    FocusScope.of(context).unfocus();
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.controller.finishWorkout(name: name.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        saving = false;
        error = '$exception';
      });
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
      return AppContentFrame(
        child: AppStateView(
          icon: Icons.add_chart_outlined,
          title: 'Ready when you are',
          message:
              'Start at ${controller.defaultLocation?.name ?? 'your gym'}. You can change the location during the workout.',
          primaryAction: FilledButton.icon(
            onPressed: () => _chooseStart(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start workout'),
          ),
        ),
      );
    }

    final completed = workout.exercises.fold<int>(
      0,
      (sum, item) => sum + item.sets.where((set) => set.isCompleted).length,
    );
    final total = workout.exercises.fold<int>(
      0,
      (sum, item) => sum + item.sets.length,
    );
    return AppContentFrame(
      padding: EdgeInsets.zero,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          WorkoutStatusCard(
            controller: controller,
            workout: workout,
            completedSets: completed,
            totalSets: total,
            onActions: () => _showWorkoutActions(context, workout),
          ),
          if (controller.actionError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppInlineNotice(
              icon: Icons.sync_problem_outlined,
              title: 'A change could not be saved',
              message: 'Your entered values remain on screen. Check them and try the action again.',
              isError: true,
              action: TextButton(
                onPressed: controller.clearActionError,
                child: const Text('Dismiss'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (workout.exercises.isEmpty)
            AppPanel(
              child: AppStateView(
                icon: Icons.format_list_bulleted_add,
                title: 'No exercises yet',
                message: 'Add the first exercise to begin logging sets.',
                primaryAction: FilledButton.tonalIcon(
                  onPressed: () => _addExercise(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add exercise'),
                ),
              ),
            )
          else ...[
            ...workout.exercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ExerciseLogCard(
                  key: ValueKey(entry.value.id),
                  controller: controller,
                  exercise: entry.value,
                  isFirst: entry.key == 0,
                  isLast: entry.key == workout.exercises.length - 1,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            FilledButton.tonalIcon(
              onPressed: () => _addExercise(context),
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addExercise(BuildContext context) async {
    final choice = await context.push<ExerciseChoice>('/exercises');
    if (choice != null) await controller.addExercise(choice);
  }

  Future<void> _showWorkoutActions(
    BuildContext context,
    WorkoutSessionModel workout,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workout actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text('Save as routine'),
                subtitle: const Text(
                  'Keep this exercise and set structure for later.',
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _saveRoutine(context, workout);
                },
              ),
              ListTile(
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                leading: const Icon(Icons.delete_outline),
                title: const Text('Discard workout'),
                subtitle: const Text(
                  'Permanently remove this unfinished workout.',
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _discard(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRoutine(
    BuildContext context,
    WorkoutSessionModel workout,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _TextPromptDialog(
        title: 'Save workout as routine',
        label: 'Routine name',
        actionLabel: 'Save',
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      await controller.saveWorkoutAsRoutine(workout, name);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved “$name” as a routine.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine was not saved. Try again.')),
        );
      }
    }
  }

  Future<void> _discard(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text(
          'This unfinished workout and every entered set will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep workout'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
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
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
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
                'Start workout',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.lg),
                const AppSectionLabel(
                  'Saved routines',
                  description:
                      'Start with a familiar exercise and set structure.',
                ),
                ...controller.routines.map((routine) {
                  final setCount = routine.exercises.fold<int>(
                    0,
                    (total, exercise) => total + exercise.setCount,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Card(
                      child: ListTile(
                        minVerticalPadding: AppSpacing.sm,
                        title: Text(routine.name),
                        subtitle: Text(
                          '${routine.exercises.length} exercises · $setCount sets',
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Actions for ${routine.name}',
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
                          await controller.startWorkoutFromRoutine(routine.id);
                        },
                      ),
                    ),
                  );
                }),
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
      builder: (context) => _TextPromptDialog(
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

class WorkoutStatusCard extends StatelessWidget {
  const WorkoutStatusCard({
    super.key,
    required this.controller,
    required this.workout,
    required this.completedSets,
    required this.totalSets,
    required this.onActions,
  });

  final AppController controller;
  final WorkoutSessionModel workout;
  final int completedSets;
  final int totalSets;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) => AppPanel(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(16) >= 24;
        final compact = constraints.maxWidth < 340 || largeText;
        final location = DropdownButtonHideUnderline(
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
            onChanged: (id) =>
                id == null ? null : controller.changeWorkoutLocation(id),
          ),
        );
        final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout in progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        totalSets == 0
                            ? 'Add an exercise to begin'
                            : '$completedSets of $totalSets sets completed',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact)
                  OutlinedButton.icon(
                    onPressed: onActions,
                    icon: const Icon(Icons.more_horiz),
                    label: const Text('Actions'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: '$completedSets of $totalSets sets completed',
              value: '${(progress * 100).round()} percent',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (compact) ...[
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.location_on_outlined),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: location),
                ],
              ),
              Text(
                'Started ${_timeOnly(workout.startedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.location_on_outlined),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: location),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Started ${_timeOnly(workout.startedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            if (compact) ...[
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onActions,
                  icon: const Icon(Icons.more_horiz),
                  label: const Text('Workout actions'),
                ),
              ),
            ],
          ],
        );
      },
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
    final firstIncomplete = exercise.sets
        .where((set) => !set.isCompleted)
        .firstOrNull;
    return AppPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      choice.labels.join(' · '),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (choice.machineDescription != null)
                      Text(
                        choice.machineDescription!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions for ${choice.name}',
                onSelected: (value) {
                  if (value == 'machine') {
                    showMachineSelection(context, controller, exercise);
                  }
                  if (value == 'up') controller.moveExercise(exercise.id, -1);
                  if (value == 'down') controller.moveExercise(exercise.id, 1);
                  if (value == 'remove') controller.removeExercise(exercise.id);
                },
                itemBuilder: (context) => [
                  if (choice.supportsMachineSelection)
                    const PopupMenuItem(
                      value: 'machine',
                      child: Text('Edit machine information'),
                    ),
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
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<PreviousSetSnapshot>>(
            key: ValueKey(
              '${choice.id}-${choice.manufacturerId}-${choice.machineModel?.id}-${controller.activeWorkout?.gymLocationId}',
            ),
            future: controller.previousSets(choice),
            builder: (context, snapshot) {
              final previous = snapshot.data ?? const <PreviousSetSnapshot>[];
              return Column(
                children: exercise.sets.asMap().entries.map((entry) {
                  final set = entry.value;
                  final prior = previous
                      .where((item) => item.position == set.position)
                      .firstOrNull;
                  if (set.isCompleted) {
                    return _CompletedSetSummary(
                      controller: controller,
                      exercise: choice,
                      set: set,
                      isFirst: entry.key == 0,
                      isLast: entry.key == exercise.sets.length - 1,
                    );
                  }
                  return SetEditor(
                    key: ValueKey(set.id),
                    controller: controller,
                    exercise: choice,
                    set: set,
                    previous: prior,
                    isNext: set.id == firstIncomplete?.id,
                    isFirst: entry.key == 0,
                    isLast: entry.key == exercise.sets.length - 1,
                  );
                }).toList(),
              );
            },
          ),
          TextButton.icon(
            onPressed: () => controller.addSet(exercise.id),
            icon: const Icon(Icons.add),
            label: const Text('Add set'),
          ),
        ],
      ),
    );
  }
}

class _CompletedSetSummary extends StatelessWidget {
  const _CompletedSetSummary({
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
  Widget build(BuildContext context) => Semantics(
    container: true,
    label:
        'Set ${set.position + 1}, completed, ${_setValue(set, exercise, controller.weightUnit)}',
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.semanticColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          ExcludeSemantics(
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set ${set.position + 1} · Completed',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(_setValue(set, exercise, controller.weightUnit)),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => controller.reopenSet(set.id),
            child: const Text('Edit'),
          ),
          _SetMenu(
            controller: controller,
            set: set,
            isFirst: isFirst,
            isLast: isLast,
          ),
        ],
      ),
    ),
  );
}

class SetEditor extends StatefulWidget {
  const SetEditor({
    super.key,
    required this.controller,
    required this.exercise,
    required this.set,
    required this.previous,
    required this.isNext,
    required this.isFirst,
    required this.isLast,
  });

  final AppController controller;
  final ExerciseChoice exercise;
  final WorkoutSetModel set;
  final PreviousSetSnapshot? previous;
  final bool isNext;
  final bool isFirst;
  final bool isLast;

  @override
  State<SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends State<SetEditor> {
  late final TextEditingController reps;
  late final TextEditingController load;
  late BodyweightAdjustment adjustment;
  late WeightUnit displayUnit;
  bool completing = false;

  @override
  void initState() {
    super.initState();
    reps = TextEditingController();
    load = TextEditingController();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant SetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (displayUnit != widget.controller.weightUnit ||
        oldWidget.set.reps != widget.set.reps ||
        oldWidget.set.loadKg != widget.set.loadKg ||
        oldWidget.set.bodyweightAdjustmentKg !=
            widget.set.bodyweightAdjustmentKg ||
        oldWidget.set.adjustment != widget.set.adjustment) {
      _syncFromWidget();
    } else if (oldWidget.previous != widget.previous &&
        widget.set.reps == 0 &&
        reps.text.isEmpty) {
      adjustment = widget.previous?.adjustment ?? adjustment;
    }
  }

  void _syncFromWidget() {
    displayUnit = widget.controller.weightUnit;
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

  Future<void> _save() async {
    final repsValue = int.tryParse(reps.text) ?? 0;
    final displayedLoad = double.tryParse(load.text.replaceAll(',', '.'));
    final kilograms = displayedLoad == null
        ? null
        : widget.controller.weightUnit.toKilograms(displayedLoad);
    try {
      await widget.controller.updateSet(
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
    } catch (_) {
      // The controller exposes the failure without clearing these controllers.
    }
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

  Future<void> _complete() async {
    final repsValue = int.tryParse(reps.text) ?? widget.previous?.reps ?? 0;
    if (repsValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter reps before completing the set.')),
      );
      return;
    }
    setState(() => completing = true);
    final displayedLoad =
        double.tryParse(load.text.replaceAll(',', '.')) ??
        _previousDisplayedLoad();
    final kilograms = displayedLoad == null
        ? null
        : widget.controller.weightUnit.toKilograms(displayedLoad);
    final bodyweight =
        widget.exercise.equipmentType == EquipmentType.bodyweight;
    try {
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
    } catch (_) {
      if (mounted) setState(() => completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyweight =
        widget.exercise.equipmentType == EquipmentType.bodyweight;
    final previous = widget.previous == null
        ? 'No previous set at this location'
        : 'Previous: ${_previousValue(widget.previous!, widget.exercise, widget.controller.weightUnit)}';
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          'Set ${widget.set.position + 1}${widget.isNext ? ', next set' : ''}',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.semanticColors.subtleSurface,
          borderRadius: BorderRadius.circular(AppRadii.input),
          border: Border.all(
            color: widget.isNext
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Set ${widget.set.position + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (widget.isNext)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Next'),
                        ),
                    ],
                  ),
                ),
                _SetMenu(
                  controller: widget.controller,
                  set: widget.set,
                  isFirst: widget.isFirst,
                  isLast: widget.isLast,
                ),
              ],
            ),
            Text(
              previous,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (bodyweight) ...[
              DropdownButtonFormField<BodyweightAdjustment>(
                key: ValueKey(adjustment),
                initialValue: adjustment,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Load type'),
                items: const [
                  DropdownMenuItem(
                    value: BodyweightAdjustment.none,
                    child: Text('Bodyweight only'),
                  ),
                  DropdownMenuItem(
                    value: BodyweightAdjustment.added,
                    child: Text('Added weight'),
                  ),
                  DropdownMenuItem(
                    value: BodyweightAdjustment.assisted,
                    child: Text('Assisted'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    adjustment = value ?? BodyweightAdjustment.none;
                    if (adjustment == BodyweightAdjustment.none) load.clear();
                  });
                  _save();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final largeText =
                    MediaQuery.textScalerOf(context).scale(16) >= 24;
                final stack = constraints.maxWidth < 300 || largeText;
                final repsField = TextField(
                  controller: reps,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    hintText: widget.previous == null
                        ? 'Enter reps'
                        : '${widget.previous!.reps}',
                  ),
                  onChanged: (_) => _save(),
                );
                final loadField = TextField(
                  controller: load,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: bodyweight
                        ? adjustment == BodyweightAdjustment.assisted
                              ? 'Assistance (${widget.controller.weightUnit.shortLabel})'
                              : 'Added (${widget.controller.weightUnit.shortLabel})'
                        : 'Load (${widget.controller.weightUnit.shortLabel})',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    hintText: _previousDisplayedLoad() == null
                        ? 'Weight'
                        : _compact(_previousDisplayedLoad()!),
                  ),
                  onChanged: (_) => _save(),
                );
                if (stack) {
                  return Column(
                    children: [
                      repsField,
                      if (!bodyweight ||
                          adjustment != BodyweightAdjustment.none) ...[
                        const SizedBox(height: AppSpacing.sm),
                        loadField,
                      ],
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: repsField),
                    if (!bodyweight ||
                        adjustment != BodyweightAdjustment.none) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: loadField),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: completing ? null : _complete,
                icon: completing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.radio_button_unchecked),
                label: Text(completing ? 'Saving set' : 'Complete set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetMenu extends StatelessWidget {
  const _SetMenu({
    required this.controller,
    required this.set,
    required this.isFirst,
    required this.isLast,
  });

  final AppController controller;
  final WorkoutSetModel set;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Actions for set ${set.position + 1}',
    onSelected: (value) {
      if (value == 'copy') controller.duplicateSet(set.id);
      if (value == 'up') controller.moveSet(set.id, -1);
      if (value == 'down') controller.moveSet(set.id, 1);
      if (value == 'remove') controller.removeSet(set.id);
    },
    itemBuilder: (context) => [
      const PopupMenuItem(value: 'copy', child: Text('Duplicate')),
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
      const PopupMenuItem(value: 'remove', child: Text('Remove set')),
    ],
  );
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.controller,
    required this.onShowWorkout,
  });

  final AppController controller;
  final VoidCallback onShowWorkout;

  @override
  Widget build(BuildContext context) {
    if (controller.history.isEmpty) {
      return AppContentFrame(
        child: AppStateView(
          icon: Icons.history_outlined,
          title: 'No workout history yet',
          message: 'Finished workouts will appear here with their exercises and completed sets.',
          primaryAction: FilledButton.icon(
            onPressed: onShowWorkout,
            icon: const Icon(Icons.fitness_center),
            label: const Text('Start from the Workout tab'),
          ),
        ),
      );
    }
    return AppContentFrame(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: controller.history.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final session = controller.history[index];
          final setCount = session.exercises.fold<int>(
            0,
            (sum, item) => sum + item.sets.length,
          );
          final date = session.finishedAt ?? session.startedAt;
          final names = session.exercises
              .map((item) => item.exercise.name)
              .toList();
          final exerciseSummary = names.isEmpty
              ? 'No completed exercises'
              : names.take(2).join(' · ') +
                    (names.length > 2 ? ' · +${names.length - 2}' : '');
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: () => _showHistoryDetail(context, session),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.semanticColors.successSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name ?? _dateLabel(date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (session.name != null)
                            Text(
                              _dateLabel(date),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${session.gymLocationName} · ${session.exercises.length} exercises · $setCount sets',
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          if (session.muscleLabels.isNotEmpty)
                            Text(
                              session.muscleLabels.join(' · '),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          Text(
                            exerciseSummary,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const ExcludeSemantics(child: Icon(Icons.chevron_right)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showHistoryDetail(
    BuildContext context,
    WorkoutSessionModel session,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _HistoryDetail(
      session: session,
      unit: controller.weightUnit,
      controller: controller,
    ),
  );
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => _buildDetail(context),
  );

  Widget _buildDetail(BuildContext context) {
    final session =
        controller.history.where((s) => s.id == this.session.id).firstOrNull ??
        this.session;
    final setCount = session.exercises.fold<int>(
      0,
      (sum, item) => sum + item.sets.length,
    );
    final date = session.finishedAt ?? session.startedAt;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name ?? _dateLabel(date),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${_dateLabel(date)} · ${session.gymLocationName}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${session.exercises.length} exercises · $setCount completed sets',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _saveAsRoutine(context),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save as routine'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemCount: session.exercises.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = session.exercises[index];
                  return AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.exercise.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          entry.exercise.labels.join(' · '),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        if (entry.exercise.machineDescription != null)
                          Text(entry.exercise.machineDescription!),
                        if (entry.exercise.supportsMachineSelection)
                          TextButton.icon(
                            onPressed: () => showMachineSelection(
                              context,
                              controller,
                              entry,
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit machine information'),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        ...entry.sets.map(
                          (set) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${set.position + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _setValue(set, entry.exercise, unit),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _saveAsRoutine(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _TextPromptDialog(
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
  Widget build(BuildContext context) => AppContentFrame(
    padding: EdgeInsets.zero,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xxs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        const AppSectionLabel(
          'Appearance',
          description:
              'Dark is the default. System follows your device setting.',
        ),
        Card(
          child: RadioGroup<AppThemePreference>(
            groupValue: controller.themePreference,
            onChanged: (value) {
              if (value != null) controller.setThemePreference(value);
            },
            child: const Column(
              children: [
                RadioListTile(
                  value: AppThemePreference.dark,
                  title: Text('Dark'),
                  subtitle: Text('Default appearance'),
                ),
                RadioListTile(
                  value: AppThemePreference.light,
                  title: Text('Light'),
                ),
                RadioListTile(
                  value: AppThemePreference.system,
                  title: Text('System'),
                  subtitle: Text('Match this device'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppSectionLabel(
          'Measurements',
          description: 'Changing units converts display values without changing stored workouts.',
        ),
        Card(
          child: RadioGroup<WeightUnit>(
            groupValue: controller.weightUnit,
            onChanged: (value) {
              if (value != null) controller.setWeightUnit(value);
            },
            child: const Column(
              children: [
                RadioListTile(
                  value: WeightUnit.kilograms,
                  title: Text('Kilograms (kg)'),
                ),
                RadioListTile(
                  value: WeightUnit.pounds,
                  title: Text('Pounds (lb)'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppSectionLabel(
          'Rest timer',
          description:
              'Starts when a set is completed and stays visible in the app.',
        ),
        AppPanel(
          child: DropdownButtonFormField<int>(
            initialValue: controller.restTimer.durationSeconds,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Default duration'),
            items: const [60, 90, 120, 180]
                .map(
                  (seconds) => DropdownMenuItem(
                    value: seconds,
                    child: Text(_timerDurationLabel(seconds)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) controller.setRestTimerSeconds(value);
            },
          ),
        ),
        if (controller.restTimer.timingMayBeDelayed) ...[
          const SizedBox(height: AppSpacing.sm),
          AppInlineNotice(
            icon: Icons.timer_outlined,
            title: 'Precise timer alerts',
            message: 'Android may delay rest alerts. Allow alarms and reminders for precise timing.',
            action: TextButton(
              onPressed: controller.restTimer.enablePreciseAlerts,
              child: const Text('Enable precise alerts'),
            ),
          ),
        ],
        if (controller.restTimer.permissionDenied) ...[
          const SizedBox(height: AppSpacing.sm),
          AppInlineNotice(
            icon: Icons.notifications_off_outlined,
            title: 'Notifications are off',
            message: 'The timer still works while the app is open. Enable notifications for background alerts.',
            action: TextButton.icon(
              onPressed: () => _openNotificationSettings(context),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open notification settings'),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const AppSectionLabel(
          'Gym locations',
          description:
              'The default location is selected when a workout starts.',
        ),
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
                const Divider(),
                ListTile(
                  minTileHeight: AppSizes.minTouchTarget,
                  leading: const Icon(Icons.add),
                  title: const Text('Add location'),
                  onTap: () => _addLocation(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppSectionLabel('Privacy'),
        const Card(
          child: ListTile(
            minVerticalPadding: AppSpacing.md,
            leading: ExcludeSemantics(child: Icon(Icons.offline_bolt_outlined)),
            title: Text('Local-first storage'),
            subtitle: Text(
              'Your workout data stays on this device. No account or connection is required.',
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _openNotificationSettings(BuildContext context) async {
    final opened = await SystemSettingsService.openNotificationSettings();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification settings could not be opened. Open this app in system Settings instead.',
          ),
        ),
      );
    }
  }

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

class RestTimerBar extends StatelessWidget {
  const RestTimerBar({super.key, required this.timer});

  final RestTimerService timer;

  @override
  Widget build(BuildContext context) {
    final remaining = timer.remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final largeText = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final timerLabel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rest $minutes:$seconds',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        if (timer.permissionDenied)
          Text(
            'Alerts unavailable · see Settings',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else if (timer.timingMayBeDelayed)
          Text(
            'Alerts may be delayed · see Settings',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: timer.addThirtySeconds,
          child: const Text('+30 sec'),
        ),
        TextButton(onPressed: timer.skip, child: const Text('Skip')),
      ],
    );
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Semantics(
          container: true,
          liveRegion: true,
          label: 'Rest timer, $minutes minutes $seconds seconds remaining',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: largeText
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: timerLabel,
                      ),
                      Align(alignment: Alignment.centerRight, child: controls),
                    ],
                  )
                : Row(
                    children: [
                      const ExcludeSemantics(
                        child: Icon(
                          Icons.timer_outlined,
                          size: AppSizes.iconSmall,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: timerLabel),
                      controls,
                    ],
                  ),
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

String _previousValue(
  PreviousSetSnapshot set,
  ExerciseChoice exercise,
  WeightUnit unit,
) {
  final kilograms = exercise.equipmentType == EquipmentType.bodyweight
      ? set.bodyweightAdjustmentKg
      : set.loadKg;
  final load = kilograms == null
      ? ''
      : ' × ${_compact(unit.fromKilograms(kilograms))} ${unit.shortLabel}';
  final kind =
      exercise.equipmentType == EquipmentType.bodyweight &&
          set.adjustment != BodyweightAdjustment.none
      ? set.adjustment == BodyweightAdjustment.assisted
            ? ' assisted'
            : ' added'
      : '';
  return '${set.reps} reps$load$kind';
}

String _setValue(
  WorkoutSetModel set,
  ExerciseChoice exercise,
  WeightUnit unit,
) {
  final kilograms = exercise.equipmentType == EquipmentType.bodyweight
      ? set.bodyweightAdjustmentKg
      : set.loadKg;
  final load = kilograms == null
      ? ''
      : ' × ${_compact(unit.fromKilograms(kilograms))} ${unit.shortLabel}';
  final kind =
      exercise.equipmentType == EquipmentType.bodyweight &&
          set.adjustment != BodyweightAdjustment.none
      ? set.adjustment == BodyweightAdjustment.assisted
            ? ' assisted'
            : ' added'
      : '';
  return '${set.reps} reps$load$kind';
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

String _timerDurationLabel(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  if (remainder == 0) return '$minutes minute${minutes == 1 ? '' : 's'}';
  return '$minutes:${remainder.toString().padLeft(2, '0')} minutes';
}
