class Hymn {
  final int number;
  final String title;
  final String type;
  final String suggestedTone;
  final String lyrics;
  final String fileName;
  final String? audioPath;
  bool isFavorite;

  Hymn({
    required this.number,
    required this.title,
    required this.type,
    required this.suggestedTone,
    required this.lyrics,
    required this.fileName,
    this.audioPath,
    this.isFavorite = false,
  });
}