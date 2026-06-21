import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/src/features/Nutrition/pages/foodEntry.page.dart';
import 'package:performance_tracker/constants.ui.dart';

class FoodDescriptionPopUp extends StatefulWidget {
  final String foodName;
  const FoodDescriptionPopUp({super.key, required this.foodName});
  @override
  State<StatefulWidget> createState() => _FoodDescriptionPopupState();
}

class _FoodDescriptionPopupState extends State<FoodDescriptionPopUp> {
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
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AiFoodGenState>(
      valueListenable: foodService.aiFoodGenNotifier,
      builder: (context, state, _) {
        // When a generation is in flight or finished, reflect that state
        // regardless of which food name this modal was opened with.
        final title = state.status == AiFoodGenStatus.idle
            ? widget.foodName
            : (state.foodName ?? widget.foodName);
        return AlertDialog(
          backgroundColor: CONT_BACKGROUND,
          actionsPadding: EdgeInsets.all(5),
          titlePadding: EdgeInsets.only(left: 15, top: 16, right: 15, bottom: 0),
          contentPadding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
          title: Text(title, style: TextStyle(color: TEXT_PRIMARY)),
          content: _buildContent(state),
          actions: _buildActions(state),
        );
      },
    );
  }

  Widget _buildContent(AiFoodGenState state) {
    switch (state.status) {
      case AiFoodGenStatus.generating:
        return _statusMessage(
          spinner: true,
          message: "Master chef is cooking ✨✨",
        );
      case AiFoodGenStatus.ready:
        return _statusMessage(
          spinner: false,
          message: "Your food is ready ✨\nTap continue to review it.",
        );
      case AiFoodGenStatus.error:
        return _statusMessage(
          spinner: false,
          message: "Mysterious food indeed !!\nTry again.",
        );
      case AiFoodGenStatus.idle:
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusGeometry.circular(8),
                  color: SURFACE,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Enter a description for ${widget.foodName}',
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Model: ${_modelLabel()}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: TEXT_SECONDARY, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _changeModel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }

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

  Widget _statusMessage({required bool spinner, required String message}) {
    return Container(
      height: 150,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (spinner) ...[
            SpinKitSpinningLines(color: PRIMARY, size: 50),
            SizedBox(height: 20),
          ],
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 2),
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
            child: Text('Close'),
          ),
        ];
      case AiFoodGenStatus.ready:
        return [
          TextButton(
            onPressed: openGeneratedFood,
            child: Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back'),
          ),
        ];
      case AiFoodGenStatus.error:
        return [
          TextButton(
            onPressed: () => foodService.startFoodGeneration(
              state.foodName ?? widget.foodName,
              descriptionController.text,
            ),
            child: Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              foodService.resetFoodGeneration();
              Navigator.pop(context);
            },
            child: Text('Back'),
          ),
        ];
      case AiFoodGenStatus.idle:
        return [
          TextButton(
            onPressed: () => foodService.startFoodGeneration(
              widget.foodName,
              descriptionController.text,
            ),
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back'),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
