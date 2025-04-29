import 'package:booktrack/models/userModels.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types; // Импорт типов
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final UserModel currentUser; // Ваша модель пользователя

  const ChatScreen({required this.roomId, required this.currentUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    // Сначала проверьте, что пользователь является участником комнаты
    final roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .get();

    if (!roomDoc.exists ||
        !(roomDoc.data()?['members'] ?? []).contains(widget.currentUser.uid)) {
      throw Exception('You are not a member of this room');
    }

    // Затем загружайте сообщения
    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .get();

    final messages = snapshot.docs.map((doc) {
      return types.TextMessage(
        author: types.User(id: doc['authorId']), // Базовый User из chat_types
        createdAt: doc['createdAt'],
        id: doc.id,
        text: doc['text'],
      );
    }).toList();

    setState(() {
      _messages.addAll(messages);
      _isLoading = false;
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: types.User(
          id: widget.currentUser.uid,
          firstName:
              widget.currentUser.name), // Конвертируем вашего пользователя
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    // Добавляем сообщение локально
    setState(() => _messages.insert(0, textMessage));

    // Отправляем в Firestore
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'authorId': widget.currentUser.uid,
      'createdAt': textMessage.createdAt,
      'text': textMessage.text,
    });

    // Обновляем последнее сообщение в комнате
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .update({
      'lastMessage': textMessage.text,
      'lastMessageTime': textMessage.createdAt,
      'members': FieldValue.arrayUnion(
          [widget.currentUser.uid]) // убедитесь, что пользователь в members
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Чат',
        style: TextStyle(
          fontSize: 32 * scale,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      )),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: types.User(
                  id: widget.currentUser.uid,
                  firstName: widget.currentUser.name)),
    );
  }
}
