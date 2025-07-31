import 'package:hive/hive.dart';
import 'package:performance_tracker/db.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';

class ConversationRepository {
  final _conversationBox = Hive.box<AiChatContent>(Collections.conversations.value);

  Future<int> addConversation(AiChatContent conversation) async {
    return await _conversationBox.add(conversation);
  }

  List<AiChatContent> getAllConversations() {
    return _conversationBox.values.toList();
  }

  Future<void> updateConversation(int index, AiChatContent conversation) async {
    await _conversationBox.putAt(index, conversation);
  }
  Future<void> deleteConversationByKey(dynamic key) async {
    await _conversationBox.delete(key);
  }

  AiChatContent? getConversationByKey(dynamic key) {
    return _conversationBox.get(key);
  }
  Future<void> clearAllChats() async
  {
    await _conversationBox.clear();
  }
}