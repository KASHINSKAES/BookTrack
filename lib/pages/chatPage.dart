import 'package:booktrack/ChatDetailPage.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatPage extends StatelessWidget {
  final VoidCallback onBack;

  const ChatPage({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(scale),
      body: _buildBody(scale),
    );
  }

  AppBar _buildAppBar(double scale) {
    return AppBar(
      title: Text(
        "Чат",
        style: TextStyle(
          fontSize: 32 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Icon(
          size: 35 * scale,
          MyFlutterApp.back,
          color: Colors.white,
        ),
        onPressed: onBack,
      ),
    );
  }

  Widget _buildBody(double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.baseCircual * scale),
            topRight: Radius.circular(AppDimensions.baseCircual * scale),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatUsers.length,
                padding: EdgeInsets.only(top: 16 * scale),
                itemBuilder: (context, index) {
                  return ConversationList(
                    name: chatUsers[index].name,
                    messageText: chatUsers[index].messageText,
                    imageUrl: chatUsers[index].imageURL,
                    time: chatUsers[index].time,
                    isMessageRead: index == 0 || index == 3,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatUsers {
  final String name;
  final String messageText;
  final String imageURL;
  final String time;

  ChatUsers({
    required this.name,
    required this.messageText,
    required this.imageURL,
    required this.time,
  });
}

List<ChatUsers> chatUsers = [
  ChatUsers(
    name: "Jane Russel",
    messageText: "Awesome Setup",
    imageURL: 'images/logoProfile.svg',
    time: "Now",
  ),
  ChatUsers(
    name: "Glady's Murphy",
    messageText: "That's Great",
    imageURL: 'images/logoProfile.svg',
    time: "Yesterday",
  ),
  ChatUsers(
    name: "Jorge Henry",
    messageText: "Hey where are you?",
    imageURL: 'images/logoProfile.svg',
    time: "31 Mar",
  ),
  ChatUsers(
    name: "Philip Fox",
    messageText: "Busy! Call me in 20 mins",
    imageURL: 'images/logoProfile.svg',
    time: "28 Mar",
  ),
  ChatUsers(
    name: "Debra Hawkins",
    messageText: "Thank you, It's awesome",
    imageURL: 'images/logoProfile.svg',
    time: "23 Mar",
  ),
  ChatUsers(
    name: "Jacob Pena",
    messageText: "Will update you in evening",
    imageURL: 'images/logoProfile.svg',
    time: "17 Mar",
  ),
  ChatUsers(
    name: "Andrey Jones",
    messageText: "Can you please share the file?",
    imageURL: 'images/logoProfile.svg',
    time: "24 Feb",
  ),
  ChatUsers(
    name: "John Wick",
    messageText: "How are you?",
    imageURL: 'images/logoProfile.svg',
    time: "18 Feb",
  ),
];

class ConversationList extends StatelessWidget {
  final String name;
  final String messageText;
  final String imageUrl;
  final String time;
  final bool isMessageRead;

  const ConversationList({
    required this.name,
    required this.messageText,
    required this.imageUrl,
    required this.time,
    required this.isMessageRead,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetailPage(name: name);
        }));
      },
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30 * scale,
              child: SvgPicture.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 16 * scale, color: AppColors.textPrimary)),
                  SizedBox(height: 6 * scale),
                  Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: AppColors.textPrimary.withOpacity(0.5),
                      fontWeight:
                          isMessageRead ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMessageRead ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
