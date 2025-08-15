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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Función para normalizar texto removiendo acentos y convirtiendo a minúsculas
  String _normalizeText(String text) {
    const withAccents = 'áéíóúñüÁÉÍÓÚÑÜàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛãõÃÕçÇ';
    const withoutAccents = 'aeiouñuAEIOUNUaeiouAEIOUaeiouAEIOUaoAOcC';
    
    String normalized = text.toLowerCase();
    
    for (int i = 0; i < withAccents.length; i++) {
      normalized = normalized.replaceAll(withAccents[i], withoutAccents[i]);
    }
    
    return normalized;
  }

  Future<void> _loadData() async {
    try {
      await _loadCategories();
      
      setState(() {
        _filteredCategories = List.from(_allCategories);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
      _allCategories = loadedCategories;

    } catch (e) {
      print('Error loading categories: $e');
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

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _filterCategories(query);
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = List.from(_allCategories);
      });
      return;
    }

    // Normalizar la búsqueda para ignorar acentos
    final normalizedQuery = _normalizeText(query);
    
    final filtered = _allCategories.where((category) {
      final normalizedCategoryName = _normalizeText(category.name);
      return normalizedCategoryName.contains(normalizedQuery);
    }).toList();

    // Ordenar por relevancia: primero las que empiecen con la búsqueda, luego las que la contengan
    filtered.sort((a, b) {
      final aNormalized = _normalizeText(a.name);
      final bNormalized = _normalizeText(b.name);
      
      final aStartsWith = aNormalized.startsWith(normalizedQuery);
      final bStartsWith = bNormalized.startsWith(normalizedQuery);
      
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      
      return aNormalized.compareTo(bNormalized);
    });

    setState(() {
      _filteredCategories = filtered;
    });
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
    
    // Detectar si está en modo oscuro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            _buildSearchBar(isDarkMode),
            SizedBox(height: 16),
            Expanded(child: _buildContent(isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Categorías',
            style: TextStyle(
              fontSize: 24,
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          if (!_isLoading && _filteredCategories.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_filteredCategories.length}${_searchController.text.isNotEmpty ? '/${_allCategories.length}' : ''}',
                style: TextStyle(
                  color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar categorías...',
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
              },
              icon: Icon(
                Icons.clear,
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading) {
      return _buildLoadingState(isDarkMode);
    }

    if (_allCategories.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    if (_filteredCategories.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResultsState(isDarkMode);
    }

    return _buildCategoriesList(isDarkMode);
  }

  Widget _buildNoResultsState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: (isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary).withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No se encontraron categorías',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Buscando en ${_allCategories.length} categorías',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando categorías...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: (isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary).withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No se encontraron categorías',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Agrega archivos .txt en la carpeta\nassets/CATEGORIAS/ con los números\nde himnos de cada categoría',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ejemplo: Categoria 1.txt',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
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

  Widget _buildCategoriesList(bool isDarkMode) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredCategories.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDarkMode ? AppColors.borderDark : AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDarkMode ? AppColors.primaryLight : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.folder,
              color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${category.hymnCount} himnos',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
            size: 16,
          ),
          onTap: () => _navigateToCategory(category),
        );
      },
    );
  }
}