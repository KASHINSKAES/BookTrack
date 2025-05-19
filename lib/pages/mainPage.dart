import 'package:booktrack/icons.dart';
import 'package:booktrack/models/book.dart';
import 'package:booktrack/servises/bookServises.dart';
import 'package:booktrack/widgets/AllBookGrid.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookService _bookService = BookService();
  List<Book> recommendations = [];
  List<Book> popular = [];
  List<Book> genres = [];
  List<Book> comingSoon = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    recommendations = await _bookService.getBooks('recommendations');
    popular = await _bookService.getBooks('popular');
    genres = await _bookService.getBooks('genres');
    comingSoon = await _bookService.getBooks('coming_soon');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final blockWidth = screenWidth * 0.97;
    final blockHeight = screenHeight * 0.2;
    final overlapOffset = screenWidth * 0.035;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/Logo.svg',
                    height: 100,
                    width: 250,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Что вы хотите почитать?',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          MyFlutterApp.search1,
                          size: 21.0,
                          color: Colors.white,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xff3A4E88).withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CarouselSlider.builder(
              itemCount: 3,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  width: blockWidth,
                  height: blockHeight,
                  margin: EdgeInsets.symmetric(horizontal: overlapOffset / 2),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              },
              options: CarouselOptions(
                height: blockHeight + 16,
                viewportFraction: 0.87,
                enableInfiniteScroll: true,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 10),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xff03044E),
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Рекомендации'),
                  Tab(text: 'Популярные'),
                  Tab(text: 'Жанры'),
                  Tab(text: 'Скоро в продаже'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            AllBookGrid(books: recommendations, storageKey: const PageStorageKey<String>('recommendations')),
            AllBookGrid(books: popular, storageKey: const PageStorageKey<String>('popular')),
            AllBookGrid(books: genres, storageKey: const PageStorageKey<String>('genres')),
            AllBookGrid(books: comingSoon, storageKey: const PageStorageKey<String>('coming_soon')),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}