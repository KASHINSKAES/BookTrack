import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktrack/main.dart';

void main() {
  testWidgets('Проверка адаптивности логотипа, поиска и блока',
      (WidgetTester tester) async {
    // Запускаем приложение
    await tester.pumpWidget(const MyApp());

    // Проверяем наличие поля поиска
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Что вы хотите почитать?'), findsOneWidget);

    // Проверяем наличие логотипа (SVG)
    expect(find.byType(SvgPicture), findsOneWidget);

    // Проверяем адаптивный блок
    final block = tester.widget<Container>(find.byType(Container).last);
    expect(block.constraints?.maxWidth, isNotNull);
    expect(block.constraints?.maxHeight, isNotNull);
    // Проверяем наличие горизонтального списка
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Проверяем, что список горизонтальный
    final listView = tester.widget<ListView>(listViewFinder);
    expect(listView.scrollDirection, Axis.horizontal);

    // Проверяем наличие 5 блоков
    final blockFinder = find.byType(Container);
    expect(blockFinder, findsNWidgets(5)); // Ожидаем ровно 5 блоков

    // Проверяем адаптивность размеров блоков
    final screenWidth = 375.0; // Указываем примерную ширину экрана для теста
    final screenHeight = 742.0; // Указываем примерную высоту экрана для теста
    final blockWidth = screenWidth * 0.87; // Примерная ширина блока
    final blockHeight = screenHeight * 0.2; // Примерная высота блока

    final firstBlock = tester.widget<Container>(blockFinder.at(0));
    final blockConstraints = firstBlock.constraints;
    expect(blockConstraints?.maxWidth,
        closeTo(blockWidth, 1.0)); // Проверяем ширину блока
    expect(blockConstraints?.maxHeight,
        closeTo(blockHeight, 1.0)); // Проверяем высоту блока

    // Проверяем отступы для "торчащих" блоков
    final blockPaddingFinder = find.byType(Padding);
    final firstPadding = tester.widget<Padding>(blockPaddingFinder.at(0));
    final overlapOffset = screenWidth * 0.035; // Ожидаемый отступ
    final padding = firstPadding.padding as EdgeInsets; // Приводим к EdgeInsets
    expect(padding.left, closeTo(overlapOffset, 1.0)); // Проверяем отступ слева
  });
}
