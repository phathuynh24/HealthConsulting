class ModelMessage {
  final bool isPrompt;
  final String message;
  final String userId;
  final DateTime time;

  ModelMessage({
    required this.isPrompt,
    required this.message,
    required this.userId,
    required this.time,
  });
}
