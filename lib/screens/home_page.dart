import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/hymn.dart';
import '../services/favorites_manager.dart';
import '../widgets/image_carousel.dart';
import '../constants/app_colors.dart';
import 'hymn_detail_page.dart';

class HimnarioHomePage extends StatefulWidget {
  @override
  _HimnarioHomePageState createState() => _HimnarioHomePageState();
}

class _HimnarioHomePageState extends State<HimnarioHomePage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Hymn> _allHymns = [];
  List<SearchResultHymn> _filteredHymns = [];
  List<String> _carouselImages = [];
  Set<String> _availableAudios = {};
  Set<int> _favoriteHymns = {};
  bool _isLoading = true;

  // Mantener el estado de la página al cambiar de tab
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadFavorites();
    await _loadAvailableAudios();
    await _loadHymnsFromAssets();
    await _loadCarouselImages();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoritesManager.loadFavorites();
      setState(() {
        _favoriteHymns = favorites;
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  void _applyFavoritesToHymns() {
    for (var hymn in _allHymns) {
      hymn.isFavorite = _favoriteHymns.contains(hymn.number);
    }
    for (var searchResult in _filteredHymns) {
      searchResult.hymn.isFavorite = _favoriteHymns.contains(searchResult.hymn.number);
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

      setState(() {
        _availableAudios = audioFiles.map((path) => path.split('/').last).toSet();
      });

      print('Available audios: $_availableAudios');
    } catch (e) {
      print('Error loading available audios: $e');
    }
  }

  Future<void> _loadCarouselImages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final imageFiles = manifestMap.keys
          .where((String key) => 
              key.startsWith('assets/imagenes/') && 
              (key.endsWith('.jpg') || key.endsWith('.jpeg') || key.endsWith('.png')))
          .toList();

      setState(() {
        _carouselImages = imageFiles;
      });
      print('Cargando Carrusel...');
    } catch (e) {
      print('Error loading carousel images: $e');
      setState(() {
        _carouselImages = [];
      });
    }
  }

  Future<void> _loadHymnsFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final hymnFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/HIMNOS/') && key.endsWith('.txt'))
          .toList();

      List<Hymn> loadedHymns = [];

      for (String filePath in hymnFiles) {
        try {
          final content = await rootBundle.loadString(filePath);
          final hymn = _parseHymnFile(content, filePath);
          if (hymn != null) {
            loadedHymns.add(hymn);
          }
        } catch (e) {
          print('Error loading file $filePath: $e');
        }
      }

      loadedHymns.sort((a, b) => a.number.compareTo(b.number));

      setState(() {
        _allHymns = loadedHymns;
        _filteredHymns = _allHymns.map((h) => SearchResultHymn(hymn: h)).toList();
        _isLoading = false;
      });

      _applyFavoritesToHymns();

    } catch (e) {
      print('Error loading hymns: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al cargar los himnos. Verifique que los archivos estén en assets/HIMNOS/');
    }
  }

  String? _findAudioPath(int hymnNumber, String hymnTitle) {
    print('Buscando audio para: $hymnNumber - $hymnTitle');
    print('Audios disponibles: $_availableAudios');
    
    String cleanTitle = hymnTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');

    List<String> possibleNames = [
      '${hymnNumber}_$cleanTitle.mp3',
      '${hymnNumber.toString().padLeft(3, '0')}_$cleanTitle.mp3',
      '$hymnNumber.mp3',
      '${hymnNumber.toString().padLeft(3, '0')}.mp3',
      '${hymnNumber}_${hymnTitle.toLowerCase().replaceAll(' ', '_')}.mp3',
      '${hymnNumber}_${hymnTitle.toLowerCase().replaceAll(' ', '')}.mp3',
    ];

    for (String availableAudio in _availableAudios) {
      if (availableAudio.startsWith('$hymnNumber') || 
          availableAudio.startsWith(hymnNumber.toString().padLeft(3, '0'))) {
        print('Audio encontrado: $availableAudio');
        return 'AUDIOS/$availableAudio';
      }
    }

    for (String fileName in possibleNames) {
      if (_availableAudios.contains(fileName)) {
        print('Audio encontrado: $fileName');
        return 'AUDIOS/$fileName';
      }
    }

    print('Audio no encontrado para himno $hymnNumber');
    return null;
  }

  Hymn? _parseHymnFile(String content, String filePath) {
    try {
      final lines = content.split('\n');
      
      if (lines.length < 5) {
        print('File $filePath has insufficient lines');
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
        isFavorite: _favoriteHymns.contains(number),
      );
    } catch (e) {
      print('Error parsing file $filePath: $e');
      return null;
    }
  }

  String _removeDiacritics(String str) {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽz';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz'; 

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  String _findMatchingLine(String lyrics, String query) {
    final lines = lyrics.split('\n');
    final normalizedQuery = _removeDiacritics(query.toLowerCase());
    
    for (final line in lines) {
      final normalizedLine = _removeDiacritics(line.toLowerCase());
      if (normalizedLine.contains(normalizedQuery) && line.trim().isNotEmpty) {
        return line.trim();
      }
    }
    return '';
  }

  void _filterHymns(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHymns = _allHymns.map((h) => SearchResultHymn(hymn: h)).toList();
      } else {
        final normalizedQuery = _removeDiacritics(query.trim().toLowerCase());
        List<SearchResultHymn> results = [];
        
        for (final hymn in _allHymns) {
          SearchResultType? matchType;
          String matchingText = '';
          
          // Buscar por número
          if (hymn.number.toString().contains(query.trim())) {
            matchType = SearchResultType.number;
            matchingText = 'Himno #${hymn.number}';
          }
          // Buscar por título
          else if (_removeDiacritics(hymn.title.toLowerCase()).contains(normalizedQuery)) {
            matchType = SearchResultType.title;
            matchingText = hymn.title;
          }
          // Buscar en las letras
          else if (_removeDiacritics(hymn.lyrics.toLowerCase()).contains(normalizedQuery)) {
            matchType = SearchResultType.lyrics;
            matchingText = _findMatchingLine(hymn.lyrics, query);
          }
          
          if (matchType != null) {
            results.add(SearchResultHymn(
              hymn: hymn,
              matchType: matchType,
              matchingText: matchingText,
            ));
          }
        }
        
        // Ordenar por relevancia: número > título > letras
        results.sort((a, b) {
          final aOrder = a.matchType?.index ?? 999;
          final bOrder = b.matchType?.index ?? 999;
          if (aOrder != bOrder) return aOrder.compareTo(bOrder);
          return a.hymn.number.compareTo(b.hymn.number);
        });
        
        _filteredHymns = results;
      }
    });
  }

  void _toggleFavorite(int index) async {
    try {
      final searchResult = _filteredHymns[index];
      final hymn = searchResult.hymn;
      final newFavoriteStatus = await FavoritesManager.toggleFavorite(hymn.number);
      
      setState(() {
        hymn.isFavorite = newFavoriteStatus;
        
        final mainIndex = _allHymns.indexWhere((h) => h.number == hymn.number);
        if (mainIndex != -1) {
          _allHymns[mainIndex].isFavorite = newFavoriteStatus;
        }
        
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

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredHymns = _allHymns.map((h) => SearchResultHymn(hymn: h)).toList();
    });
  }

  void _showErrorDialog(String message) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.backgroundCard : AppColors.backgroundSecondary,
          title: Text(
            'Error',
            style: TextStyle(
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onFavoriteChanged(int hymnNumber, bool isFavorite) {
    setState(() {
      final mainIndex = _allHymns.indexWhere((h) => h.number == hymnNumber);
      if (mainIndex != -1) {
        _allHymns[mainIndex].isFavorite = isFavorite;
      }
      
      final filteredIndex = _filteredHymns.indexWhere((h) => h.hymn.number == hymnNumber);
      if (filteredIndex != -1) {
        _filteredHymns[filteredIndex].hymn.isFavorite = isFavorite;
      }
      
      if (isFavorite) {
        _favoriteHymns.add(hymnNumber);
      } else {
        _favoriteHymns.remove(hymnNumber);
      }
    });
  }

  void _navigateToHymnDetail(Hymn hymn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HymnFullScreenPage(
          hymn: hymn,
          onFavoriteChanged: (isFavorite) {
            _onFavoriteChanged(hymn.number, isFavorite);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Detectar si está en modo oscuro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            ImageCarousel(images: _carouselImages),
            _buildTitle(isDarkMode),
            _buildSearchBar(isDarkMode),
            SizedBox(height: 20),
            _buildHymnsList(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.home,
            color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'Himnos | Universal',
            style: TextStyle(
              fontSize: 24,
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundCard : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 15),
          Icon(
            Icons.search, 
            color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary, 
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterHymns,
              decoration: InputDecoration(
                hintText: 'Buscar por título, número o letra...',
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.close,
                  color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildHymnsList(bool isDarkMode) {
    return Expanded(
      child: _isLoading
          ? _buildLoadingState(isDarkMode)
          : _allHymns.isEmpty
              ? _buildEmptyState(isDarkMode)
              : _filteredHymns.isEmpty
                  ? _buildNoResultsState(isDarkMode)
                  : _buildHymnsListView(isDarkMode),
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
            'Cargando himnos...',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 64,
            color: (isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary).withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron himnos',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Verifique que los archivos .txt estén\nen la carpeta assets/HIMNOS/',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
              size: 48,
              color: (isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary).withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta buscar por:\n• Número del himno\n• Título del himno\n• Palabras de la letra',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnsListView(bool isDarkMode) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredHymns.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDarkMode ? AppColors.borderDark : AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final searchResult = _filteredHymns[index];
        final hymn = searchResult.hymn;
        
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
                    color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hymn.audioPath != null) ...[
                  SizedBox(width: 10),
                  Icon(
                    Icons.music_note,
                    size: 16,
                    color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
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
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar información de audio si está disponible
              if (hymn.audioPath != null)
                Row(
                  children: [
                    Icon(
                      Icons.headphones,
                      size: 14,
                      color: isDarkMode ? AppColors.audioAvailable : AppColors.audioAvailable,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Audio disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.audioAvailable : AppColors.audioAvailable,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              // Mostrar el tipo de coincidencia y texto coincidente
              if (searchResult.matchType != null && _searchController.text.isNotEmpty) ...[
                if (hymn.audioPath != null) SizedBox(height: 2),
                Row(
                  children: [
                    _buildMatchTypeIcon(searchResult.matchType!, isDarkMode),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getMatchTypeDescription(searchResult.matchType!, searchResult.matchingText),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                          fontStyle: searchResult.matchType == SearchResultType.lyrics 
                              ? FontStyle.italic 
                              : FontStyle.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else if (hymn.type.isNotEmpty)
                Text(
                  hymn.type,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
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

  Widget _buildMatchTypeIcon(SearchResultType matchType, bool isDarkMode) {
    IconData icon;
    Color color = isDarkMode ? AppColors.primaryLight : AppColors.primary;
    
    switch (matchType) {
      case SearchResultType.number:
        icon = Icons.tag;
        break;
      case SearchResultType.title:
        icon = Icons.book;
        break;
      case SearchResultType.lyrics:
        icon = Icons.lyrics;
        color = Colors.orange;
        break;
    }
    
    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  String _getMatchTypeDescription(SearchResultType matchType, String matchingText) {
    switch (matchType) {
      case SearchResultType.number:
        return 'Coincidencia por número';
      case SearchResultType.title:
        return 'Coincidencia en título';
      case SearchResultType.lyrics:
        return matchingText.isNotEmpty 
            ? 'En la letra: "$matchingText"'
            : 'Coincidencia en la letra';
    }
  }
}

enum SearchResultType {
  number,
  title,
  lyrics,
}

class SearchResultHymn {
  final Hymn hymn;
  final SearchResultType? matchType;
  final String matchingText;
  
  SearchResultHymn({
    required this.hymn,
    this.matchType,
    this.matchingText = '',
  });
}