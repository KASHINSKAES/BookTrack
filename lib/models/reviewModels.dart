class QuoteReview {
  final String booktUrl;
  final String review;

  QuoteReview({required this.booktUrl, required this.review});

  Map<String, dynamic> toMap() {
    return {
      'productUrl': booktUrl,
      'review': review,
    };
  }
}