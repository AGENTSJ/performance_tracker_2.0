// widgets/log_view_widget.dart
import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/models/log.model.dart';
import 'package:performance_tracker/core/services/log.service.dart';

class LogViewWidget extends StatefulWidget {
  final LogService logService = locator<LogService>();
  final String? filterByEntityId;

  LogViewWidget({
    Key? key,
    this.filterByEntityId,
  }) : super(key: key);

  @override
  State<LogViewWidget> createState() => _LogViewWidgetState();
}

class _LogViewWidgetState extends State<LogViewWidget> {
  String _selectedLevel = 'all';
  final List<String> _levels = ['all', 'info', 'success', 'warning', 'error'];

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.filterByEntityId != null
                    ? 'Logs - ${widget.filterByEntityId}'
                    : 'All Logs',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refresh,
                    tooltip: 'Refresh logs',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showClearDialog();
                    },
                    tooltip: 'Clear all logs',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Level Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _levels.map((level) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    checkmarkColor: TEXT_PRIMARY,
                    backgroundColor: SURFACE,
                    selectedColor: SURFACE,
                    label: Text(level.toUpperCase(),style: TextStyle(color: TEXT_PRIMARY),),
                    selected: _selectedLevel == level,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLevel = selected ? level : 'all';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Logs List
        Expanded(
          child: _buildLogsList(),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    List<LogModel> logs;

    if (widget.filterByEntityId != null) {
      logs = widget.logService.getLogsByEntityId(widget.filterByEntityId!);
    } else {
      logs = widget.logService.getAllLogs();
    }

    if (_selectedLevel != 'all') {
      logs = logs.where((log) => log.level == _selectedLevel).toList();
    }

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: TEXT_TERTIARY,
            ),
            const SizedBox(height: 16),
            Text(
              'No logs yet',
              style: TextStyle(
                color: TEXT_TERTIARY,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _LogTile(log: log);
      },
    );
  }

  void _showClearDialog() async {
    var val = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.logService.removeLogsByEntityId('AI');
              Navigator.pop(context,true);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if(val!=null && val)
    {
      _refresh();
    }
  }
}

class _LogTile extends StatelessWidget {
  final LogModel log;

  const _LogTile({Key? key, required this.log}) : super(key: key);

  Color _getLevelColor() {
    switch (log.level) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon() {
    switch (log.level) {
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'error':
        return Icons.error_outline;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: SURFACE,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getLevelIcon(),
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.level.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log.entityId,
                        style: TextStyle(
                          color: TEXT_SECONDARY,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        log.formattedDate,
                        style: TextStyle(
                          color: TEXT_TERTIARY,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log.formattedTime,
                        style: TextStyle(
                          color: TEXT_TERTIARY,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}