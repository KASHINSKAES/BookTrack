import 'package:flutter/material.dart';
import '/icons.dart';
import '/widgets/AdaptiveBookGrid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 375.0;
    final scale = screenWidth / baseWidth;
    final blockWidth = screenWidth * 0.97;
    final blockHeight = screenHeight * 0.2;
    final overlapOffset = screenWidth * 0.035;

    return DefaultTabController(
      length: 4, // Define the number of tabs
      child: Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      color: const Color(0xffFD521B),
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
            children: [
              AdaptiveBookGrid(),
              AdaptiveBookGrid(),
              AdaptiveBookGrid(),
              AdaptiveBookGrid(),
            ],
          ),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xff5775CD), // Background color for TabBar
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
