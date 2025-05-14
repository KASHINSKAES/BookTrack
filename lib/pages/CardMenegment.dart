import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardsManagementScreen extends StatefulWidget {
  final String userId;

  const CardsManagementScreen({required this.userId, Key? key})
      : super(key: key);

  @override
  _CardsManagementScreenState createState() => _CardsManagementScreenState();
}

class _CardsManagementScreenState extends State<CardsManagementScreen> {
  List<Map<String, dynamic>> _cards = [];
  String? _primaryCardId;
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments')
          .get();

      _primaryCardId = await getPrimaryCardId(widget.userId);

      setState(() {
        _cards = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
            'isPrimary': doc.id == _primaryCardId,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки карт: $e')),
      );
    }
  }

  Future<void> _setAsPrimary(String cardId) async {
    try {
      await setPrimaryCard(widget.userId, cardId);
      await _loadCards();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Основная карта изменена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> setPrimaryCard(String userId, String cardId) async {
    try {
      // Проверяем, что карта существует
      final cardDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .doc(cardId)
          .get();

      if (!cardDoc.exists) {
        throw 'Карта не найдена';
      }

      // Обновляем основную карту
      await _firestore.collection('users').doc(userId).update({
        'selectedPaymentMethod': cardId,
        'lastPaymentUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка установки основной карты: $e');
      rethrow;
    }
  }

  Future<String?> getPrimaryCardId(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['selectedPaymentMethod'] as String?;
  }

  Future<void> _deleteCard(String cardId) async {
    final isPrimary = cardId == _primaryCardId;

    // Подтверждение удаления
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление карты'),
        content: Text(
          isPrimary
              ? 'Это ваша основная карта. После удаления нужно будет выбрать новую основную карту. Продолжить?'
              : 'Вы уверены, что хотите удалить эту карту?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Удаляем карту
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payments')
          .doc(cardId)
          .delete();

      // Если удалили основную карту - сбрасываем selectedPaymentMethod
      if (isPrimary) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'selectedPaymentMethod': FieldValue.delete(),
        });
      }

      // Обновляем список
      await _loadCards();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Карта удалена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои карты')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? const Center(child: Text('Нет добавленных карт'))
              : ListView.builder(
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: card['isPrimary'] ? Colors.blue : Colors.grey,
                        ),
                        title: Text(card['cardNumber']),
                        subtitle: Text(card['brand']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (card['isPrimary'])
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text('Основная',
                                    style: TextStyle(color: Colors.blue)),
                              )
                            else
                              TextButton(
                                child: const Text('Сделать основной '),
                                onPressed: () => _setAsPrimary(card['id']),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(card['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
