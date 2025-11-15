
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.image,
    this.pdfUrl,
    this.fullContent,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      image: json['image'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      fullContent: json['fullContent'] as String?,
    );
  }

  final String id;

  final String title;

  final String description;

  final DateTime date;

  final String? image;

  final String? pdfUrl;

  final String? fullContent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'image': image,
      'pdfUrl': pdfUrl,
      'fullContent': fullContent,
    };
  }
}
