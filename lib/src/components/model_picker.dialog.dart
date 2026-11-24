import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/services/ai.service.dart';

/// Fetches the available Gemini models and lets the user pick one.
/// Pops with the selected model name, or null if cancelled.
class ModelPickerDialog extends StatefulWidget {
  final String? currentModel;
  const ModelPickerDialog({super.key, this.currentModel});
  @override
  State<ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<ModelPickerDialog> {
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
