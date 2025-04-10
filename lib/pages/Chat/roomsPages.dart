import 'dart:ui';

import 'package:booktrack/icons.dart';
import 'package:booktrack/models/roomsModels.dart';
import 'package:booktrack/models/userModels.dart';
import 'package:booktrack/pages/Chat/chatScreen.dart';
import 'package:booktrack/pages/Chat/rooms_repository.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;

UserModel _firebaseUserToUserModel(chat_types.User firebaseUser) {
  return UserModel(
    uid: firebaseUser.id,
    name: firebaseUser.firstName ?? 'Гость',
  );
}

class RoomListPage extends StatelessWidget {
  final VoidCallback onBack;
  final UserModel currentUser;

  const RoomListPage({required this.onBack, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    debugPrint("🔄 RoomListPage.build() вызван");

    final user = FirebaseAuth.instance.currentUser;
    debugPrint("👤 Текущий пользователь: ${user?.uid ?? 'не авторизован'}");
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(scale),
      body: _buildBody(context, scale),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewRoom(context),
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar(double scale) {
    return AppBar(
      title: Text(
        "Чаты",
        style: TextStyle(
          fontSize: 32 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Icon(MyFlutterApp.back, size: 35 * scale, color: Colors.white),
        onPressed: onBack,
      ),
    );
  }

  Widget _buildBody(BuildContext context, double scale) {
    final roomRepo = RoomRepository();

    return StreamBuilder<List<Room>>(
      stream: roomRepo.getRooms(),
      builder: (context, snapshot) {
        debugPrint(
            "📊 Snapshot: ${snapshot.connectionState}, data: ${snapshot.data}, error: ${snapshot.error}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
              padding: EdgeInsets.symmetric(vertical: 10 * scale),
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                  topRight: Radius.circular(AppDimensions.baseCircual * scale),
                ),
              ),
              child: Center(child: Text("Нет активных чатов")));
        }

        final rooms = snapshot.data!;

        return Container(
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 16 * scale),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30 * scale,
                    backgroundImage: NetworkImage(room.imageUrl),
                  ),
                  title:
                      Text(room.name, style: TextStyle(fontSize: 16 * scale)),
                  subtitle: Text(room.lastMessage,
                      style: TextStyle(fontSize: 14 * scale)),
                  trailing: Text(
                    '${room.lastMessageTime.hour}:${room.lastMessageTime.minute}',
                    style: TextStyle(fontSize: 12 * scale),
                  ),
                  onTap: () => _openChat(context, room),
                );
              },
            ));
      },
    );
  }

  void _openChat(BuildContext context, Room room) {
    final chatUser = chat_types.User(
      id: currentUser.uid,
      firstName: currentUser.displayName?.split(' ').first ?? 'Гость',
      lastName: currentUser.displayName?.split(' ').last ?? '',
    );
    final UserModel = _firebaseUserToUserModel(chatUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: room.id,
          currentUser: UserModel, // Теперь правильный тип
        ),
      ),
    );
  }

  void _createNewRoom(BuildContext context) {
    String roomName = '';
    String searchQuery = '';
    String? selectedUserId;
    List<UserModel> foundUsers = [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: 600,
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Новая комната",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Поле поиска пользователя
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Поиск по email",
                        border: OutlineInputBorder(),
                        suffixIcon: isLoading
                            ? CircularProgressIndicator()
                            : Icon(Icons.search),
                      ),
                      onChanged: (query) async {
                        setState(() {
                          searchQuery = query;
                          isLoading = true;
                        });

                        if (query.length > 2) {
                          final users =
                              await RoomRepository().searchUsers(query);
                          setState(() {
                            foundUsers = users;
                            isLoading = false;
                          });
                        } else {
                          setState(() {
                            foundUsers = [];
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Список найденных пользователей
                    if (foundUsers.isNotEmpty)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: foundUsers.length,
                          itemBuilder: (context, index) {
                            final user = foundUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name![0]),
                              ),
                              title: Text(user.name!),
                              subtitle: Text(user.email!),
                              onTap: () {
                                setState(() => selectedUserId = user.uid);
                              },
                              selected: selectedUserId == user.uid,
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 16),

                    // Поле названия комнаты
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Название комнаты",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => roomName = value,
                    ),
                    SizedBox(height: 24),

                    // Кнопки действий
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Отмена"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedUserId == null || roomName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Заполните все поля")),
                              );
                              return;
                            }

                            try {
                              await RoomRepository().createRoom(
                                roomName,
                                currentUser.uid,
                                otherUserId: selectedUserId!,
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Ошибка: ${e.toString()}")),
                              );
                            }
                          },
                          child: Text("Создать"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
