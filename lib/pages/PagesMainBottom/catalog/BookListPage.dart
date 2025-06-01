import 'dart:ui';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/filter/filterProvider.dart';
import 'package:booktrack/pages/helpsWidgets/filterButton.dart';
import 'package:booktrack/pages/helpsWidgets/selectableButton.dart';
import 'package:booktrack/pages/helpsWidgets/selectableLanguageButton.dart';
import 'package:booktrack/pages/helpsWidgets/switchesTitle.dart';
import 'package:booktrack/widgets/CatalogBookGrid.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookListPage extends StatefulWidget {
  final String category;
  final VoidCallback onBack;

  const BookListPage({Key? key, required this.category, required this.onBack})
      : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  int selectedSortOption = 1;

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
          BookTrackIcon.onBack,
          color: Colors.white,
        ),
        onPressed: widget.onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            BookTrackIcon.research,
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
            CatalogBookGrid(),
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
          FilterButton(
            label: "Популярные",
            icon: BookTrackIcon.popularCatalog,
            onPressed: () => _showSortOptions(scale),
            scale: scale,
          ),
          FilterButton(
            label: "Фильтры",
            icon: BookTrackIcon.filterCatalog,
            onPressed: () => _showFilterOptions(scale),
            scale: scale,
          ),
        ],
      ),
    );
  }

  void _showSortOptions(double scale) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: (AppDimensions.baseImageHeight - 40) * scale,
          child: Column(
            children: [
              ListTile(
                title: const Text('Популярные'),
                leading: Radio<int>(
                  value: 1,
                  groupValue: selectedSortOption,
                  onChanged: (value) {
                    setState(() => selectedSortOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Новинки'),
                leading: Radio<int>(
                  value: 2,
                  groupValue: selectedSortOption,
                  onChanged: (value) {
                    setState(() => selectedSortOption = value!);
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
        return Consumer<FilterProvider>(
          builder: (context, filterProvider, child) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0 * scale),
                    CustomSwitchTile(
                      value: filterProvider.tempIsSubscription,
                      onChanged: (bool newValue) {
                        filterProvider.toggleSubscription();
                      },
                      title: "Подписка",
                      scale: scale,
                      subtitle: "Книги доступные по подписке",
                    ),
                    Divider(color: AppColors.background),
                    CustomSwitchTile(
                      value: filterProvider.tempIsExclusive,
                      onChanged: (bool newValue) {
                        filterProvider.toggleExclusive();
                      },
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.0 * scale),
                          Row(
                            children: [
                              SelectableButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Текст',
                                icon: BookTrackIcon.bookStat,
                                isSelected:
                                    filterProvider.tempSelectedFormat == 'text',
                                onTap: () {
                                  filterProvider.setFormat('text');
                                },
                              ),
                              SizedBox(width: 8.0 * scale),
                              SelectableButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Аудио',
                                icon: BookTrackIcon.audioFilterBook,
                                isSelected: filterProvider.tempSelectedFormat ==
                                    'audio',
                                onTap: () {
                                  filterProvider.setFormat('audio');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.background),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Язык',
                            style: TextStyle(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.0 * scale),
                          Wrap(
                            spacing: 8.0 * scale,
                            runSpacing: 8.0 * scale,
                            children: [
                              SelectableLanguageButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Русский',
                                flag: '🇷🇺',
                                isSelected:
                                    filterProvider.tempSelectedLanguage ==
                                        'Русский',
                                onTap: () {
                                  filterProvider.setLanguage('Русский');
                                },
                              ),
                              SelectableLanguageButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Английский',
                                flag: '🇬🇧',
                                isSelected:
                                    filterProvider.tempSelectedLanguage ==
                                        'Английский',
                                onTap: () {
                                  filterProvider.setLanguage('Английский');
                                },
                              ),
                              SelectableLanguageButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Японский',
                                flag: '🇯🇵',
                                isSelected:
                                    filterProvider.tempSelectedLanguage ==
                                        'Японский',
                                onTap: () {
                                  filterProvider.setLanguage('Японский');
                                },
                              ),
                              SelectableLanguageButton(
                                textSizeButton:
                                    AppDimensions.baseTextSizeButton * scale,
                                label: 'Французский',
                                flag: '🇫🇷',
                                isSelected:
                                    filterProvider.tempSelectedLanguage ==
                                        'Французский',
                                onTap: () {
                                  filterProvider.setLanguage('Французский');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.background),
                    CustomSwitchTile(
                      value: filterProvider.tempIsHighRated,
                      onChanged: (bool newValue) {
                        filterProvider.toggleHighRated();
                      },
                      title: "Высшая оценка",
                      subtitle: "Книги с рейтингом 4 и выше",
                      scale: scale,
                    ),
                    SizedBox(height: 16.0 * scale),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        minimumSize: Size(double.infinity, 50 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                      onPressed: () {
                        filterProvider.applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Применить",
                        style: TextStyle(
                          fontSize: 18 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0 * scale),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
