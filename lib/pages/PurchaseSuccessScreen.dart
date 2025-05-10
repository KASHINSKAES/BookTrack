// 3. Улучшенный экран успешной покупки
import 'package:booktrack/pages/textBook.dart';
import 'package:flutter/material.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  final String bookId;
  final String bookTitle;
  final double price;
  final int bonusesUsed;
  final int bonusesAdded;
  
  const PurchaseSuccessScreen({
    required this.bookId,
    required this.bookTitle,
    required this.price,
    required this.bonusesUsed,
    required this.bonusesAdded,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Покупка завершена'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Книга "$bookTitle" успешно приобретена!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Книга:', bookTitle),
                  _buildDetailRow('Идентификатор:', bookId),
                  Divider(),
                  _buildDetailRow('Сумма покупки:', '$price ₽'),
                  if (bonusesUsed > 0) ...[
                    _buildDetailRow('Списано бонусов:', '-$bonusesUsed'),
                    _buildDetailRow('Итоговая сумма:', '${price + bonusesUsed} ₽'),
                  ],
                  if (bonusesAdded > 0)
                    _buildDetailRow('Начислено бонусов:', '+$bonusesAdded'),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookScreen(
                      bookId: bookId,
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              child: Text('Читать сейчас'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Text('Вернуться в каталог'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}