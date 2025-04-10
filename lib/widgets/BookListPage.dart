import 'package:booktrack/pages/filter/filterProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import '/widgets/AdaptiveBookGrid.dart';
import 'package:booktrack/icons.dart';

class BookListPage extends StatefulWidget {
  final String category;
  final VoidCallback onBack;

  const BookListPage({Key? key, required this.category, required this.onBack})
      : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  int selectedOption = 1;
  String? selectedFormat;
  String? selectedLanguage;
  bool switched1 = false;
  bool switched2 = false;
  bool switched3 = false;

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
        widget.category,
        style: TextStyle(
          fontSize: 24 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        softWrap: true,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(
          MyFlutterApp.back,
          color: Colors.white,
        ),
        onPressed: widget.onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            MyFlutterApp.search1,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
      ],
    );
  }

  Widget _buildBody(double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0 * scale),
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
            _buildFilterBar(scale),
            _buildBookGrid(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.baseCrossAxisSpacing * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FilterButton(
            label: "Популярные",
            icon: MyFlutterApp.tuning,
            onPressed: () => _showSortOptions(scale),
            scale: scale,
          ),
          _FilterButton(
            label: "Фильтры",
            icon: MyFlutterApp.sort,
            onPressed: () => _showFilterOptions(scale),
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid(double scale) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.baseCrossAxisSpacing * scale),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppDimensions.baseCrossAxisSpacingBlock * scale,
            mainAxisSpacing: AppDimensions.baseMainAxisSpacing * scale,
            childAspectRatio: AppDimensions.baseImageWidth /
                (AppDimensions.baseImageHeight + 40 * scale),
          ),
          itemCount: Book.books.length,
          itemBuilder: (context, index) {
            final book = Book.books[index];
            return BookCard(
              scale: scale,
              title: book.title,
              author: book.author,
              image: book.image,
              bookRating: book.bookRating,
              reviewCount: book.reviewCount,
              imageWidth: AppDimensions.baseImageWidth * scale,
              imageHeight: AppDimensions.baseImageHeight * scale,
              textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
              textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
              textSpacing: 6.0 * scale,
            );
          },
        ),
      ),
    );
  }

  void _showSortOptions(double scale) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: AppDimensions.baseImageWidth * scale,
          child: Column(
            children: [
              ListTile(
                title: const Text('Популярные'),
                leading: Radio<int>(
                  value: 1,
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Новинки'),
                leading: Radio<int>(
                  value: 2,
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(double scale) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final filterProvider =
            Provider.of<FilterProvider>(context, listen: false);
        final height = MediaQuery.of(context).size.height * 0.8;

        return SizedBox(
          height: height,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0 * scale),
                _CustomSwitchTile(
                  value: filterProvider.isSubscription,
                  onChanged: (value) =>
                      filterProvider.toggleSubscription(value),
                  title: "Подписка",
                  scale: scale,
                  subtitle: "Книги доступные по подписке",
                ),
                Divider(color: AppColors.background),
                _CustomSwitchTile(
                  value: filterProvider.isExclusive,
                  onChanged: (value) => filterProvider.toggleExclusive(value),
                  title: "Эксклюзивно",
                  scale: scale,
                  subtitle: "Эксклюзивные книги только в нашем приложении",
                ),
                Divider(color: AppColors.background),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Формат',
                        style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      Row(
                        children: [
                          _SelectableButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Текст',
                            icon: Icons.book,
                            isSelected:
                                filterProvider.selectedFormat == 'Текст',
                            onTap: () => filterProvider.setFormat('Текст'),
                          ),
                          SizedBox(width: 8.0 * scale),
                          _SelectableButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Аудио',
                            icon: Icons.audiotrack,
                            isSelected:
                                filterProvider.selectedFormat == 'Аудио',
                            onTap: () => filterProvider.setFormat('Аудио'),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.background),
                      Text(
                        'Язык',
                        style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 8.0 * scale),
                      Wrap(
                        spacing: 8.0 * scale,
                        runSpacing: 8.0 * scale,
                        children: [
                          _SelectableLanguageButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Русский',
                            flag: '🇷🇺',
                            isSelected:
                                filterProvider.selectedLanguage == 'Русский',
                            onTap: () => filterProvider.setLanguage('Русский'),
                          ),
                          _SelectableLanguageButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Английский',
                            flag: '🇬🇧',
                            isSelected:
                                filterProvider.selectedLanguage == 'Английский',
                            onTap: () =>
                                filterProvider.setLanguage('Английский'),
                          ),
                          _SelectableLanguageButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Японский',
                            flag: '🇯🇵',
                            isSelected:
                                filterProvider.selectedLanguage == 'Японский',
                            onTap: () => filterProvider.setLanguage('Японский'),
                          ),
                          _SelectableLanguageButton(
                            textSizeButton:
                                AppDimensions.baseTextSizeButton * scale,
                            label: 'Французский',
                            flag: '🇫🇷',
                            isSelected: filterProvider.selectedLanguage ==
                                'Французский',
                            onTap: () =>
                                filterProvider.setLanguage('Французский'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.background),
                _CustomSwitchTile(
                  value: filterProvider.isHighRated,
                  onChanged: (value) => filterProvider.toggleHighRated(value),
                  title: "Высшая оценка",
                  subtitle: "Книги с рейтингом 4 и выше",
                  scale: scale,
                ),
                SizedBox(height: 16.0 * scale),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectableButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final double textSizeButton;
  final VoidCallback onTap;

  const _SelectableButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.textSizeButton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      label: Text(
        label,
        style:
            TextStyle(fontSize: textSizeButton, color: AppColors.textPrimary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Color(0xff5775CD) : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
    );
  }
}

class _SelectableLanguageButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;
  final double textSizeButton;

  const _SelectableLanguageButton({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
    required this.textSizeButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Color(0xff5775CD) : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: textSizeButton, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double scale;

  const _FilterButton(
      {required this.label,
      required this.icon,
      required this.onPressed,
      required this.scale});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
            fontSize: AppDimensions.baseTextSizeButtonSort * scale,
            fontFamily: 'MPLUSRounded1c'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.baseCircualButton * scale),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 19 * scale,
      ),
      label: Text(label, style: TextStyle(color: AppColors.textPrimary)),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  const _CustomSwitchTile({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.scale,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      activeTrackColor: AppColors.background,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey,
      activeColor: Colors.white,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0 * scale,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.0 * scale,
          color: AppColors.textSecondary,
        ),
      ),
      isThreeLine: true,
    );
  }
}
