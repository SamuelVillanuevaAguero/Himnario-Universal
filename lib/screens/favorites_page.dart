import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/hymn.dart';
import '../services/favorites_manager.dart';
import '../constants/app_colors.dart';
import 'hymn_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Hymn> _favoriteHymns = [];
  Set<int> _favoriteNumbers = {};
  Set<String> _availableAudios = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteHymns();
  }

  Future<void> _loadFavoriteHymns() async {
    try {
      // Cargar favoritos
      final favorites = await FavoritesManager.loadFavorites();
      _favoriteNumbers = favorites;

      if (favorites.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Cargar audios disponibles
      await _loadAvailableAudios();

      // Cargar todos los himnos y filtrar favoritos
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final hymnFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/HIMNOS/') && key.endsWith('.txt'))
          .toList();

      List<Hymn> allHymns = [];

      for (String filePath in hymnFiles) {
        try {
          final content = await rootBundle.loadString(filePath);
          final hymn = _parseHymnFile(content, filePath);
          if (hymn != null && favorites.contains(hymn.number)) {
            hymn.isFavorite = true;
            allHymns.add(hymn);
          }
        } catch (e) {
          print('Error loading file $filePath: $e');
        }
      }

      allHymns.sort((a, b) => a.number.compareTo(b.number));

      setState(() {
        _favoriteHymns = allHymns;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading favorite hymns: $e');
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

  String? _findAudioPath(int hymnNumber, String hymnTitle) {
    String cleanTitle = hymnTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');

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
      final suggestedTone = lines[2].trim();
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
        isFavorite: true,
      );
    } catch (e) {
      print('Error parsing file $filePath: $e');
      return null;
    }
  }

  void _toggleFavorite(int index) async {
    try {
      final hymn = _favoriteHymns[index];
      final newFavoriteStatus = await FavoritesManager.toggleFavorite(hymn.number);
      
      if (!newFavoriteStatus) {
        // Si se removió de favoritos, quitarlo de la lista
        setState(() {
          _favoriteHymns.removeAt(index);
          _favoriteNumbers.remove(hymn.number);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Himno removido de favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.snackBarError,
          ),
        );
      }
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
            if (!isFavorite) {
              // Si se removió de favoritos, actualizar la lista
              setState(() {
                _favoriteHymns.removeWhere((h) => h.number == hymn.number);
                _favoriteNumbers.remove(hymn.number);
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Icons.favorite,
            color: AppColors.favorite,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Mis Favoritos',
            style: TextStyle(
              fontSize: 24,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          if (!_isLoading && _favoriteHymns.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.favorite.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_favoriteHymns.length}',
                style: TextStyle(
                  color: AppColors.favorite,
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

    if (_favoriteHymns.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFavoritesList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Cargando favoritos...',
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
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No tienes himnos favoritos',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Marca tus himnos favoritos desde la\nlista principal para verlos aquí',
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
                color: AppColors.favorite.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.favorite.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.favorite,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Toca el corazón para agregar favoritos',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.favorite,
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

  Widget _buildFavoritesList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _favoriteHymns.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final hymn = _favoriteHymns[index];
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
          subtitle: Row(
            children: [
              Text(
                hymn.type,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (hymn.audioPath != null) ...[
                SizedBox(width: 8),
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
            ],
          ),
          trailing: GestureDetector(
            onTap: () => _toggleFavorite(index),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.favorite,
                color: AppColors.favorite,
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