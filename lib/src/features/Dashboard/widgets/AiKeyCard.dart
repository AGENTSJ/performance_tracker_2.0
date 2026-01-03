import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/key.service.dart';

class ApiKeyWidget extends StatefulWidget {
  const ApiKeyWidget({Key? key}) : super(key: key);

  @override
  State<ApiKeyWidget> createState() => _ApiKeyWidgetState();
}

class _ApiKeyWidgetState extends State<ApiKeyWidget> {
  String apiKey = '';
  final TextEditingController _controller = TextEditingController();
  var keyService = locator<KeyService>();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this.setKey();
    super.initState();
  }

  setKey() async {
    var key = await this.keyService.getAiApiKey();
    this._controller.text = key ?? '';
  }

  void _handleAdd() async {
    if (_controller.text.isNotEmpty) {
      await this.keyService.addAiApiKey(_controller.text.trim());
      setState(() {
        apiKey = _controller.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: SURFACE2,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gemini API Key',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          obscureText: true,
                          onSubmitted: (_) => _handleAdd(),
                          decoration: InputDecoration(
                            hintText: 'Enter your API key',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleAdd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SURFACE2,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: PRIMARY)
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child:  Icon(Icons.save, color: PRIMARY),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
