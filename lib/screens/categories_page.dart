import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/category.dart';
import '../constants/app_colors.dart';
import 'category_hymns_page.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with AutomaticKeepAliveClientMixin {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final categoryFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/CATEGORIAS/') && key.endsWith('.txt'))
          .toList();

      List<Category> loadedCategories = [];

      for (String filePath in categoryFiles) {
        try {
          final content = await rootBundle.loadString(filePath);
          final category = _parseCategoryFile(content, filePath);
          if (category != null) {
            loadedCategories.add(category);
          }
        } catch (e) {
          print('Error loading category file $filePath: $e');
        }
      }

      // Ordenar categorías alfabéticamente
      loadedCategories.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _categories = loadedCategories;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Category? _parseCategoryFile(String content, String filePath) {
    try {
      final lines = content.split('\n');
      final fileName = filePath.split('/').last;
      
      // Obtener el nombre de la categoría del nombre del archivo (sin extensión)
      final categoryName = fileName.replaceAll('.txt', '');
      
      // Parsear los números de himnos
      List<int> hymnNumbers = [];
      
      for (String line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) {
          // Buscar números en la línea
          final numberMatches = RegExp(r'\d+').allMatches(trimmedLine);
          for (RegExpMatch match in numberMatches) {
            final number = int.tryParse(match.group(0)!);
            if (number != null && !hymnNumbers.contains(number)) {
              hymnNumbers.add(number);
            }
          }
        }
      }

      if (hymnNumbers.isEmpty) {
        print('No hymn numbers found in category file: $filePath');
        return null;
      }

      return Category(
        name: categoryName,
        fileName: fileName,
        hymnNumbers: hymnNumbers,
      );
    } catch (e) {
      print('Error parsing category file $filePath: $e');
      return null;
    }
  }

  void _navigateToCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryHymnsPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Categorías',
            style: TextStyle(
              fontSize: 24,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          if (!_isLoading && _categories.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_categories.length}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_categories.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCategoriesList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Cargando categorías...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No se encontraron categorías',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Agrega archivos .txt en la carpeta\nassets/CATEGORIAS/ con los números\nde himnos de cada categoría',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ejemplo: Categoria 1.txt',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _categories.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.folder,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${category.hymnCount} himnos',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
          onTap: () => _navigateToCategory(category),
        );
      },
    );
  }
}