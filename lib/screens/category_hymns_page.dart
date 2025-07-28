import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/hymn.dart';
import '../models/category.dart';
import '../services/favorites_manager.dart';
import '../constants/app_colors.dart';
import 'hymn_detail_page.dart';

class CategoryHymnsPage extends StatefulWidget {
  final Category category;

  const CategoryHymnsPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryHymnsPageState createState() => _CategoryHymnsPageState();
}

class _CategoryHymnsPageState extends State<CategoryHymnsPage> {
  List<Hymn> _categoryHymns = [];
  Set<String> _availableAudios = {};
  Set<int> _favoriteHymns = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryHymns();
  }

  Future<void> _loadCategoryHymns() async {
    try {
      // Cargar favoritos
      final favorites = await FavoritesManager.loadFavorites();
      _favoriteHymns = favorites;

      // Cargar audios disponibles
      await _loadAvailableAudios();

      // Cargar himnos de la categoría
      await _loadHymnsFromCategory();

    } catch (e) {
      print('Error loading category hymns: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableAudios() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final audioFiles = manifestMap.keys
          .where((String key) => 
              key.startsWith('assets/AUDIOS/') && 
              key.endsWith('.mp3'))
          .toList();

      _availableAudios = audioFiles.map((path) => path.split('/').last).toSet();
    } catch (e) {
      print('Error loading available audios: $e');
    }
  }

  Future<void> _loadHymnsFromCategory() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final hymnFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/HIMNOS/') && key.endsWith('.txt'))
          .toList();

      List<Hymn> loadedHymns = [];

      // Solo cargar himnos que están en esta categoría
      for (String filePath in hymnFiles) {
        try {
          final fileName = filePath.split('/').last;
          final numberMatch = RegExp(r'\d+').firstMatch(fileName);
          final number = numberMatch != null ? int.parse(numberMatch.group(0)!) : 0;
          
          // Verificar si este himno está en la categoría
          if (widget.category.hymnNumbers.contains(number)) {
            final content = await rootBundle.loadString(filePath);
            final hymn = _parseHymnFile(content, filePath);
            if (hymn != null) {
              loadedHymns.add(hymn);
            }
          }
        } catch (e) {
          print('Error loading file $filePath: $e');
        }
      }

      // Ordenar por el orden en la categoría (no por número)
      loadedHymns.sort((a, b) {
        final indexA = widget.category.hymnNumbers.indexOf(a.number);
        final indexB = widget.category.hymnNumbers.indexOf(b.number);
        return indexA.compareTo(indexB);
      });

      setState(() {
        _categoryHymns = loadedHymns;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading hymns from category: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _findAudioPath(int hymnNumber, String hymnTitle) {
    for (String availableAudio in _availableAudios) {
      if (availableAudio.startsWith('$hymnNumber') || 
          availableAudio.startsWith(hymnNumber.toString().padLeft(3, '0'))) {
        return 'AUDIOS/$availableAudio';
      }
    }
    return null;
  }

  Hymn? _parseHymnFile(String content, String filePath) {
    try {
      final lines = content.split('\n');
      
      if (lines.length < 5) {
        return null;
      }

      final title = lines[0].trim();
      final suggestedTone = lines.length > 2 ? lines[2].trim() : '';
      final lyricsLines = lines.skip(4).toList();
      final lyrics = lyricsLines.join('\n').trim();

      final fileName = filePath.split('/').last;
      final numberMatch = RegExp(r'\d+').firstMatch(fileName);
      final number = numberMatch != null ? int.parse(numberMatch.group(0)!) : 0;

      final audioPath = _findAudioPath(number, title);

      return Hymn(
        number: number,
        title: title,
        type: '',
        suggestedTone: suggestedTone,
        lyrics: lyrics,
        fileName: fileName,
        audioPath: audioPath,
        isFavorite: _favoriteHymns.contains(number),
      );
    } catch (e) {
      print('Error parsing file $filePath: $e');
      return null;
    }
  }

  void _toggleFavorite(int index) async {
    try {
      final hymn = _categoryHymns[index];
      final newFavoriteStatus = await FavoritesManager.toggleFavorite(hymn.number);
      
      setState(() {
        hymn.isFavorite = newFavoriteStatus;
        
        if (newFavoriteStatus) {
          _favoriteHymns.add(hymn.number);
        } else {
          _favoriteHymns.remove(hymn.number);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavoriteStatus 
              ? 'Himno agregado a favoritos' 
              : 'Himno removido de favoritos'
          ),
          duration: Duration(seconds: 2),
          backgroundColor: newFavoriteStatus ? AppColors.snackBarSuccess : AppColors.snackBarError,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favoritos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToHymnDetail(Hymn hymn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HymnFullScreenPage(
          hymn: hymn,
          onFavoriteChanged: (isFavorite) {
            setState(() {
              final index = _categoryHymns.indexWhere((h) => h.number == hymn.number);
              if (index != -1) {
                _categoryHymns[index].isFavorite = isFavorite;
              }
              
              if (isFavorite) {
                _favoriteHymns.add(hymn.number);
              } else {
                _favoriteHymns.remove(hymn.number);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.category.hymnCount} himnos',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_categoryHymns.isEmpty) {
      return _buildEmptyState();
    }

    return _buildHymnsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Cargando himnos de la categoría...',
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
              Icons.library_music_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24),
            Text(
              'No se encontraron himnos',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Esta categoría no contiene himnos\no los archivos no están disponibles',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnsList() {
    return ListView.separated(
      padding: EdgeInsets.all(20),
      itemCount: _categoryHymns.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final hymn = _categoryHymns[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 40,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hymn.number.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hymn.audioPath != null) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.music_note,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          title: Text(
            hymn.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: hymn.audioPath != null ? Row(
            children: [
              Icon(
                Icons.headphones,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: 4),
              Text(
                'Audio disponible',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ) : null,
          trailing: GestureDetector(
            onTap: () => _toggleFavorite(index),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                hymn.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: hymn.isFavorite ? AppColors.favorite : AppColors.favoriteInactive,
                size: 25,
              ),
            ),
          ),
          onTap: () => _navigateToHymnDetail(hymn),
        );
      },
    );
  }
}