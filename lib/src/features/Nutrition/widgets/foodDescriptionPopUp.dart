import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/features/Nutrition/pages/foodEntry.page.dart';
import 'package:performance_tracker/constants.ui.dart';

class FoodDescriptionPopUp extends StatefulWidget {
  final String? initialName;
  const FoodDescriptionPopUp({super.key, this.initialName});
  @override
  State<StatefulWidget> createState() => _FoodDescriptionPopupState();
}

class _FoodDescriptionPopupState extends State<FoodDescriptionPopUp> {
  late final TextEditingController nameController = TextEditingController(
    text: widget.initialName ?? '',
  );
  late final TextEditingController descriptionController =
      TextEditingController();
  var foodService = locator<FoodService>();
  var aiService = locator<AiService>();
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _loadSelectedModel();
  }

  Future<void> _loadSelectedModel() async {
    var model = await aiService.getSelectedModel();
    if (mounted) setState(() => _selectedModel = model);
  }

  String _modelLabel() =>
      (_selectedModel ?? AiService.defaultModel).replaceFirst('models/', '');

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AiFoodGenState>(
      valueListenable: foodService.aiFoodGenNotifier,
      builder: (context, state, _) {
        return AlertDialog(
          backgroundColor: CONT_BACKGROUND,
          actionsPadding: EdgeInsets.fromLTRB(12, 0, 12, 8),
          titlePadding: EdgeInsets.fromLTRB(20, 18, 20, 0),
          contentPadding: EdgeInsets.fromLTRB(20, 14, 20, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: _buildTitle(state),
          content: _buildContent(state),
          actions: _buildActions(state),
        );
      },
    );
  }

  Widget _buildTitle(AiFoodGenState state) {
    if (state.status == AiFoodGenStatus.idle) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PRIMARY.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome, color: PRIMARY, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create with AI',
                  style: TextStyle(
                    color: TEXT_PRIMARY,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Generate nutrition for any food',
                  style: TextStyle(color: TEXT_SECONDARY, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Text(
      state.foodName ?? 'Create with AI',
      style: TextStyle(
        color: TEXT_PRIMARY,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildContent(AiFoodGenState state) {
    switch (state.status) {
      case AiFoodGenStatus.generating:
        return _thinkingView(state.progressText);
      case AiFoodGenStatus.ready:
        return _statusMessage(
          icon: Icon(Icons.restaurant_menu, color: PRIMARY, size: 44),
          message: "Your food is ready ✨\nTap continue to review it.",
        );
      case AiFoodGenStatus.error:
        return _statusMessage(
          icon: Icon(Icons.error_outline, color: ACCENT, size: 44),
          message: "Mysterious food indeed !!\nTry again.",
        );
      case AiFoodGenStatus.idle:
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Food name'),
              const SizedBox(height: 6),
              _boxed(
                child: TextField(
                  controller: nameController,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: TEXT_PRIMARY, fontSize: 14),
                  decoration: _hint('e.g. Grilled chicken breast'),
                ),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Description (optional)'),
              const SizedBox(height: 6),
              _boxed(
                child: TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: TextStyle(color: TEXT_PRIMARY, fontSize: 14),
                  decoration: _hint(
                    'Cooking method, brand, portion hints...',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _modelRow(),
            ],
          ),
        );
    }
  }

  Widget _thinkingView(String progress) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SpinKitThreeBounce(color: PRIMARY, size: 16),
              const SizedBox(width: 10),
              Text(
                'Thinking…',
                style: TextStyle(
                  color: TEXT_PRIMARY,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SURFACE,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BORDER_PRIMARY),
              ),
              child: progress.isEmpty
                  ? Text(
                      'Warming up the kitchen ✨',
                      style: TextStyle(color: TEXT_TERTIARY, fontSize: 12),
                    )
                  : SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        progress,
                        style: TextStyle(
                          color: TEXT_SECONDARY,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      color: TEXT_SECONDARY,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  InputDecoration _hint(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: TEXT_TERTIARY, fontSize: 13),
    border: InputBorder.none,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  Widget _boxed({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: SURFACE,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: BORDER_PRIMARY),
    ),
    child: child,
  );

  Widget _modelRow() => Container(
    padding: const EdgeInsets.only(left: 12),
    decoration: BoxDecoration(
      color: SURFACE,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: BORDER_PRIMARY),
    ),
    child: Row(
      children: [
        Icon(Icons.memory, size: 15, color: TEXT_SECONDARY),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _modelLabel(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: TEXT_PRIMARY, fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: _changeModel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: PRIMARY,
          ),
          child: const Text('Change', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  Future<void> _changeModel() async {
    var selected = await showDialog<String>(
      context: context,
      builder: (context) => _ModelPickerDialog(currentModel: _selectedModel),
    );
    if (selected != null) {
      await aiService.setSelectedModel(selected);
      if (mounted) setState(() => _selectedModel = selected);
    }
  }

  Widget _statusMessage({required Widget icon, required String message}) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: TEXT_PRIMARY),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(AiFoodGenState state) {
    switch (state.status) {
      case AiFoodGenStatus.generating:
        // Generation continues in the service; just close the modal.
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ];
      case AiFoodGenStatus.ready:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: openGeneratedFood,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ];
      case AiFoodGenStatus.error:
        return [
          TextButton(
            onPressed: () {
              foodService.resetFoodGeneration();
            },
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () => foodService.startFoodGeneration(
              state.foodName ?? nameController.text.trim(),
              descriptionController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ];
      case AiFoodGenStatus.idle:
        final canSubmit = nameController.text.trim().isNotEmpty;
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: canSubmit
                ? () => foodService.startFoodGeneration(
                    nameController.text.trim(),
                    descriptionController.text,
                  )
                : null,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
              foregroundColor: Colors.white,
            ),
          ),
        ];
    }
  }

  openGeneratedFood() async {
    var food = foodService.consumeGeneratedFood();
    if (food == null) return;
    var returnedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryPage(food: food, isCreateMode: true),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(returnedFood);
  }
}

/// Fetches the available Gemini models and lets the user pick one.
/// Pops with the selected model name, or null if cancelled.
class _ModelPickerDialog extends StatefulWidget {
  final String? currentModel;
  const _ModelPickerDialog({this.currentModel});
  @override
  State<_ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<_ModelPickerDialog> {
  final aiService = locator<AiService>();
  late final Future<List<GeminiModel>> _modelsFuture;

  @override
  void initState() {
    super.initState();
    _modelsFuture = aiService.fetchAvailableModels();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CONT_BACKGROUND,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text('Select model', style: TextStyle(color: TEXT_PRIMARY)),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
        child: FutureBuilder<List<GeminiModel>>(
          future: _modelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: SpinKitSpinningLines(color: PRIMARY, size: 40),
              );
            }
            final models = snapshot.data ?? [];
            if (models.isEmpty) {
              return Center(
                child: Text(
                  'No models available.\nCheck your API key.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TEXT_SECONDARY),
                ),
              );
            }
            return ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, i) {
                final model = models[i];
                final selected = model.name == widget.currentModel;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  selected: selected,
                  title: Text(
                    model.displayName,
                    style: TextStyle(color: TEXT_PRIMARY, fontSize: 14),
                  ),
                  subtitle: Text(
                    model.name.replaceFirst('models/', ''),
                    style: TextStyle(color: TEXT_SECONDARY, fontSize: 11),
                  ),
                  trailing: selected
                      ? Icon(Icons.check, color: PRIMARY, size: 20)
                      : null,
                  onTap: () => Navigator.pop(context, model.name),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
