import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  final VoidCallback onBack;
  LanguageScreen({super.key, required this.onBack});
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selected_language');
    });
  }

  void _saveSelectedLanguage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_language', index);
  }

  @override
  Widget build(BuildContext context) {
    List<String> languages = [
      "Русский",
      "Английский",
      "Испанский",
      "Французский",
      "Немецкий"
    ];
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Язык интерфейса',
          style: TextStyle(
            fontSize: 32 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(
            size: 35 * scale,
            MyFlutterApp.back,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.baseCircual * scale),
              topRight: Radius.circular(AppDimensions.baseCircual * scale),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(languages[index],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      trailing: _selectedIndex == index
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        _saveSelectedLanguage(index);
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
