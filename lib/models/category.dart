class Category {
  final String name;
  final String fileName;
  final List<int> hymnNumbers;
  final int hymnCount;

  Category({
    required this.name,
    required this.fileName,
    required this.hymnNumbers,
  }) : hymnCount = hymnNumbers.length;

  @override
  String toString() {
    return 'Category{name: $name, fileName: $fileName, hymnCount: $hymnCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          fileName == other.fileName;

  @override
  int get hashCode => name.hashCode ^ fileName.hashCode;
}