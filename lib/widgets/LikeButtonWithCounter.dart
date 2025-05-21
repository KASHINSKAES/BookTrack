import 'dart:ui';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikeButtonWithCounter extends StatefulWidget {
  final String bookId;
  final String reviewId;
  final String? currentUserId;

  const LikeButtonWithCounter({
    required this.bookId,
    required this.reviewId,
    this.currentUserId,
  });

  @override
  _LikeButtonWithCounterState createState() => _LikeButtonWithCounterState();
}

class _LikeButtonWithCounterState extends State<LikeButtonWithCounter> {
  bool _isOptimisticLike = false;
  bool _isUpdating = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('books')
          .doc(widget.bookId)
          .collection('reviews')
          .doc(widget.reviewId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildLoadingState();

        final reviewData = snapshot.data!.data() as Map<String, dynamic>;
        final likes = List<String>.from(reviewData['likes'] ?? []);
        final realIsLiked = widget.currentUserId != null &&
            likes.contains(widget.currentUserId);

        // Синхронизируем оптимистичное состояние с реальным
        if (!_isUpdating) _isOptimisticLike = realIsLiked;

        return Row(
          children: [
            _buildAnimatedLikeButton(realIsLiked),
            const SizedBox(width: 4),
            _buildLikeCounter(likes.length),
            if (_isUpdating) _buildLoadingIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLikeButton(bool realIsLiked) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Tooltip(
      message: realIsLiked ? 'Убрать лайк' : 'Поставить лайк',
      child: InkWell(
        onTap: _handleLikeTap,
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Transform.scale(
              scaleY: -1,
              child: Icon(
                BookTrackIcon.dislikeDetailBook,
                key: ValueKey<bool>(_isOptimisticLike),
                color: _isOptimisticLike ? AppColors.orange : Colors.grey,
                size: 20 * scale,
              ),
            )),
      ),
    );
  }

  Widget _buildLikeCounter(int count) {
    return Text(
      count.toString(),
      style: TextStyle(
        color: _isOptimisticLike ? AppColors.orange : Colors.grey,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Future<void> _handleLikeTap() async {
    if (widget.currentUserId == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
      _isOptimisticLike = !_isOptimisticLike; // Оптимистичное обновление
    });

    try {
      await _reviewService.toggleLike(
        widget.bookId,
        widget.reviewId,
        widget.currentUserId!,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
      // Откатываем оптимистичное обновление
      setState(() => _isOptimisticLike = !_isOptimisticLike);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildLoadingState() {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Row(
      children: [
        Icon(
          BookTrackIcon.dislikeDetailBook,
          color: Colors.grey[300], // Полупрозрачный цвет
          size: 20 * scale,
        ),
        const SizedBox(width: 4),
        Container(
          width: 20,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
