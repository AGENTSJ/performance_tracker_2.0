enum CoachServerTools {
  updateAdvices,
  addRoutine,
  updateRoutine,
  addWorkout,
  updateWorkout,
}

class ServerProtocolDTO {
  CoachServerTools tool;
  Map<String, dynamic> parameters;

  ServerProtocolDTO({
    required this.tool,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool': tool.name, // Store enum as string
      'parameters': parameters,
    };
  }

  factory ServerProtocolDTO.fromJson(Map<String, dynamic> json) {
    return ServerProtocolDTO(
      tool: CoachServerTools.values.firstWhere(
        (e) => e.name == json['tool'],
        orElse: () => throw ArgumentError('Invalid tool: ${json['tool']}'),
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }
}
