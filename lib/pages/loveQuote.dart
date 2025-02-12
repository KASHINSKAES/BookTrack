import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

final List<Map<String, dynamic>> loveQuote = [
  {
    "bookUrl": "images/img1.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img2.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img1.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img2.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img1.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img5.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
  {
    "bookUrl": "images/img1.svg",
    "quote":
        "– Я вычеркнула все описания, кроме заката, – сказала она наконец. – Его я просто не могла вычеркнуть. Он был лучше всех."
  },
];

final String selectedPaymentMethod = "card_1";

class loveQuotes extends StatelessWidget {
  final VoidCallback onBack;
  loveQuotes({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Любимые цитаты',
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
            onPressed: onBack,
          ),
        ),
        backgroundColor: AppColors.background,
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 19 * scale,
              ),
              children: [
                ...loveQuote.map((quote) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 20 * scale, horizontal: 10 * scale),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 19 * scale, vertical: 20 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: Offset(4, 8), // Shadow position
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(
                              AppDimensions.baseCircual * scale)),
                        ),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 800),
                            child: Row(
                              children: [
                                quote['bookUrl'].toString().isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFD521B),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SvgPicture.asset(
                                          quote['bookUrl'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                SizedBox(
                                  width: 17 * scale,
                                ),
                                Expanded(
                                    child: Text(
                                  quote['quote'],
                                  style: TextStyle(
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  softWrap: true, // ✅ Включает перенос строк
                                  maxLines:
                                      null, // ✅ Позволяет неограниченное количество строк
                                  overflow: TextOverflow.visible,
                                ))
                              ],
                            )))))
              ],
            )));
  }
}
