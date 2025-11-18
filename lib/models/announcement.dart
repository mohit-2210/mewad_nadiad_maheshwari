// lib/models/announcement.dart
class Announcement {
  final String id;
  final String title;
  final String description;
  final String? fullContent;
  final DateTime date;
  final String? image;
  final String? pdfUrl;
  final List<String>? images;
  final List<String>? pdfs;
  final String? sendTo;
  final List<String>? selectedSocieties;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.fullContent,
    required this.date,
    this.image,
    this.pdfUrl,
    this.images,
    this.pdfs,
    this.sendTo,
    this.selectedSocieties,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // Handle date parsing
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      
      try {
        if (dateValue is String) {
          // Try parsing ISO format
          if (dateValue.contains('T')) {
            return DateTime.parse(dateValue);
          }
          // Try parsing date only format (YYYY-MM-DD)
          final parts = dateValue.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } else if (dateValue is DateTime) {
          return dateValue;
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      
      return DateTime.now();
    }

    // Parse image URLs
    String? primaryImage;
    List<String>? imageList;
    
    if (json['image'] != null) {
      if (json['image'] is List) {
        imageList = (json['image'] as List)
            .map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList();
        primaryImage = imageList.isNotEmpty ? imageList.first : null;
      } else if (json['image'] is String) {
        primaryImage = json['image'];
        imageList = [primaryImage!];
      }
    }

    // Parse PDF URLs
    String? primaryPdf;
    List<String>? pdfList;
    
    if (json['pdf'] != null) {
      if (json['pdf'] is List) {
        pdfList = (json['pdf'] as List)
            .map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList();
        primaryPdf = pdfList.isNotEmpty ? pdfList.first : null;
      } else if (json['pdf'] is String) {
        primaryPdf = json['pdf'];
        pdfList = [primaryPdf!];
      }
    }

    // Parse selected societies
    List<String>? societies;
    if (json['selectedSocieties'] != null) {
      if (json['selectedSocieties'] is List) {
        societies = (json['selectedSocieties'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return Announcement(
      id: json['id']?.toString() ?? 
          json['_id']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fullContent: json['content']?.toString(),
      date: parseDate(json['date']),
      image: primaryImage,
      pdfUrl: primaryPdf,
      images: imageList,
      pdfs: pdfList,
      sendTo: json['sendTo']?.toString(),
      selectedSocieties: societies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': fullContent,
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'image': images ?? (image != null ? [image!] : []),
      'pdf': pdfs ?? (pdfUrl != null ? [pdfUrl!] : []),
      'sendTo': sendTo,
      'selectedSocieties': selectedSocieties,
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    String? fullContent,
    DateTime? date,
    String? image,
    String? pdfUrl,
    List<String>? images,
    List<String>? pdfs,
    String? sendTo,
    List<String>? selectedSocieties,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fullContent: fullContent ?? this.fullContent,
      date: date ?? this.date,
      image: image ?? this.image,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      images: images ?? this.images,
      pdfs: pdfs ?? this.pdfs,
      sendTo: sendTo ?? this.sendTo,
      selectedSocieties: selectedSocieties ?? this.selectedSocieties,
    );
  }
}