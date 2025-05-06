import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String title;
  final String text;
    final Epigraph? epigraph; 
  final int pageCount;
  final Map<String, String>? footnotes;
  final int order;

  Chapter({
    required this.id,
    required this.title,
    required this.text,
    this.epigraph,
    required this.pageCount,
    this.footnotes,
    required this.order,
  });

  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chapter(
      id: doc.id,
      title: data['title'] ?? '',
      text: data['text'] ?? '',
       epigraph: data['epigraph'] != null 
          ? Epigraph.fromMap(data['epigraph'] as Map<String, dynamic>)
          : null,
      pageCount: data['pageCount'] ?? 0,
      footnotes: data['footnotes'] != null
          ? Map<String, String>.from(data['footnotes'])
          : null,
      order: data['order'] ?? 0,
    );
  }
}
class Epigraph {
  final String? author;
  final String text;

  Epigraph({this.author, required this.text});

  factory Epigraph.fromMap(Map<String, dynamic> map) {
    return Epigraph(
      author: map['author'] as String?,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'text': text,
    };
  }
}