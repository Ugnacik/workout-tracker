import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../theme/app_tokens.dart';

Future<void> showMachineSelection(
  BuildContext context,
  AppController controller,
  WorkoutExerciseModel entry,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _MachineSelectionSheet(controller: controller, entry: entry),
);

class _MachineSelectionSheet extends StatefulWidget {
  const _MachineSelectionSheet({required this.controller, required this.entry});
  final AppController controller;
  final WorkoutExerciseModel entry;

  @override
  State<_MachineSelectionSheet> createState() => _MachineSelectionSheetState();
}

class _MachineSelectionSheetState extends State<_MachineSelectionSheet> {
  String? manufacturerId;
  String? modelId;
  String? error;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    manufacturerId = widget.entry.exercise.manufacturerId;
    final current = widget.entry.exercise.machineModel;
    modelId = current?.supports(widget.entry.exercise) == true
        ? current?.id
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = widget.controller.catalog;
    final manufacturers = [...catalog.manufacturers];
    final current = widget.entry.exercise;
    if (manufacturerId != null &&
        !manufacturers.any((m) => m.id == manufacturerId)) {
      manufacturers.add(
        current.manufacturer ??
            ManufacturerInfo(
              id: manufacturerId!,
              name: current.machineModel!.manufacturerName,
            ),
      );
    }
    final models = catalog.compatibleModels(current, manufacturerId);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Machine information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(current.name),
          const SizedBox(height: AppSpacing.sm),
          const Text('Manufacturer and model are optional.'),
          if (current.machineModel != null &&
              !current.machineModel!.supports(current))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Previously saved: ${current.machineModel!.displayName}. '
                'Choose a compatible model below, or save without a model.',
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String?>(
            key: ValueKey('manufacturer-$manufacturerId'),
            initialValue: manufacturerId,
            isExpanded: true,
            itemHeight: null,
            decoration: const InputDecoration(labelText: 'Manufacturer'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No manufacturer'),
              ),
              ...manufacturers.map(
                (m) =>
                    DropdownMenuItem<String?>(value: m.id, child: Text(m.name)),
              ),
            ],
            onChanged: saving
                ? null
                : (value) => setState(() {
                    manufacturerId = value;
                    modelId = null;
                  }),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String?>(
            key: ValueKey('model-$manufacturerId-$modelId'),
            initialValue: modelId,
            isExpanded: true,
            itemHeight: null,
            decoration: const InputDecoration(labelText: 'Model'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No model'),
              ),
              ...models.map(
                (m) =>
                    DropdownMenuItem<String?>(value: m.id, child: Text(m.name)),
              ),
            ],
            onChanged: saving || manufacturerId == null
                ? null
                : (value) => setState(() => modelId = value),
          ),
          if (modelId != null &&
              MediaQuery.textScalerOf(context).scale(16) >= 24)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Selected model: ${models.firstWhere((m) => m.id == modelId).name}',
              ),
            ),
          if (manufacturerId == null || models.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                manufacturerId == null
                    ? 'Choose a manufacturer to see compatible models.'
                    : 'No compatible models yet. Save the manufacturer alone or add a model.',
              ),
            ),
          TextButton.icon(
            onPressed: saving ? null : _addModel,
            icon: const Icon(Icons.add),
            label: const Text('Add compatible model'),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => setState(() {
                        manufacturerId = null;
                        modelId = null;
                      }),
                child: const Text('Clear selection'),
              ),
              FilledButton(
                onPressed: saving ? null : _save,
                child: Text(saving ? 'Saving' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.controller.setExerciseMachine(
        widget.entry.id,
        manufacturerId: manufacturerId,
        machineModelId: modelId,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Could not save machine information. Please try again.';
        });
      }
    }
  }

  Future<void> _addModel() async {
    final maker = widget.controller.catalog.manufacturers
        .where((m) => m.id == manufacturerId)
        .firstOrNull;
    final created = await showDialog<MachineModelInfo>(
      context: context,
      builder: (_) => _AddModelDialog(
        controller: widget.controller,
        exercise: widget.entry.exercise,
        maker: maker?.name,
      ),
    );
    if (created != null && mounted) {
      setState(() {
        manufacturerId = created.manufacturerId;
        modelId = created.id;
      });
    }
  }
}

class _AddModelDialog extends StatefulWidget {
  const _AddModelDialog({
    required this.controller,
    required this.exercise,
    this.maker,
  });
  final AppController controller;
  final ExerciseChoice exercise;
  final String? maker;
  @override
  State<_AddModelDialog> createState() => _AddModelDialogState();
}

class _AddModelDialogState extends State<_AddModelDialog> {
  late final maker = TextEditingController(text: widget.maker);
  final model = TextEditingController();
  bool independent = false;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    maker.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add compatible model'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('For ${widget.exercise.name}'),
          TextField(
            controller: maker,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Manufacturer',
              hintText: 'Life Fitness',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: model,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Model'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Independent arms/legs'),
            value: independent,
            onChanged: (v) => setState(() => independent = v ?? false),
          ),
          if (error != null) Text(error!),
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
            saving || maker.text.trim().isEmpty || model.text.trim().isEmpty
            ? null
            : () async {
                setState(() => saving = true);
                try {
                  final created = await widget.controller.addMachineModel(
                    manufacturerName: maker.text,
                    modelName: model.text,
                    exerciseId: widget.exercise.id,
                    independentLimbs: independent,
                  );
                  if (context.mounted) Navigator.pop(context, created);
                } catch (_) {
                  if (mounted) {
                    setState(() {
                      saving = false;
                      error = 'Could not add model. Please try again.';
                    });
                  }
                }
              },
        child: Text(saving ? 'Adding' : 'Add'),
      ),
    ],
  );
}
