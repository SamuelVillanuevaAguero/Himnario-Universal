import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn.dart';
import '../services/favorites_manager.dart';
import '../constants/app_colors.dart';

class HymnFullScreenPage extends StatefulWidget {
  final Hymn hymn;
  final Function(bool)? onFavoriteChanged;

  const HymnFullScreenPage({
    Key? key, 
    required this.hymn,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  _HymnFullScreenPageState createState() => _HymnFullScreenPageState();
}

class _HymnFullScreenPageState extends State<HymnFullScreenPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() async {
    final isFav = await FavoritesManager.isFavorite(widget.hymn.number);
    if (mounted) {
      setState(() {
        widget.hymn.isFavorite = isFav;
      });
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _playPauseAudio() async {
    try {
      if (widget.hymn.audioPath == null) {
        _showSnackBar('Audio no disponible para este himno');
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
          _isPaused = true;
        });
      } else {
        if (_isPaused) {
          await _audioPlayer.resume();
        } else {
          await _audioPlayer.play(AssetSource(widget.hymn.audioPath!));
        }
        setState(() {
          _isPlaying = true;
          _isPaused = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error al reproducir el audio: $e');
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _position = Duration.zero;
    });
  }

  void _seekAudio(double value) {
    final position = Duration(milliseconds: (value * _duration.inMilliseconds).round());
    _audioPlayer.seek(position);
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 28) _fontSize += 2;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12) _fontSize -= 2;
    });
  }

  void _toggleFavorite() async {
    try {
      final newFavoriteStatus = await FavoritesManager.toggleFavorite(widget.hymn.number);
      
      if (mounted) {
        setState(() {
          widget.hymn.isFavorite = newFavoriteStatus;
        });
        
        if (widget.onFavoriteChanged != null) {
          widget.onFavoriteChanged!(newFavoriteStatus);
        }
        
        _showSnackBar(
          newFavoriteStatus 
            ? 'Himno agregado a favoritos' 
            : 'Himno removido de favoritos'
        );
      }
    } catch (e) {
      _showSnackBar('Error al actualizar favoritos: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: widget.hymn.isFavorite ? AppColors.snackBarSuccess : AppColors.snackBarError,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si está en modo oscuro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            _buildLyricsSection(isDarkMode),
            _buildAudioControls(isDarkMode),
            _buildFontSizeControls(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
            isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back, 
              color: isDarkMode ? AppColors.textWhite : AppColors.textSecondary, 
              size: 28,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No. ${widget.hymn.number}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.hymn.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textPrimary,
                  ),
                ),
                if (widget.hymn.suggestedTone.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'Tono: ${widget.hymn.suggestedTone}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              widget.hymn.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.hymn.isFavorite ? AppColors.favorite : AppColors.favoriteInactive,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection(bool isDarkMode) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Center(
            child: Text(
              widget.hymn.lyrics,
              style: TextStyle(
                fontSize: _fontSize,
                color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary,
                height: 1.6,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioControls(bool isDarkMode) {
    if (widget.hymn.audioPath != null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backgroundCard : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDarkMode ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.music_note, 
                  color: isDarkMode ? AppColors.primaryLight : AppColors.musicNote, 
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Audio disponible',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary, 
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _duration.inMilliseconds > 0 
                        ? _position.inMilliseconds / _duration.inMilliseconds 
                        : 0.0,
                    onChanged: _seekAudio,
                    activeColor: isDarkMode ? AppColors.primaryLight : AppColors.sliderActive,
                    inactiveColor: isDarkMode 
                        ? AppColors.textWhiteTertiary.withOpacity(0.3)
                        : AppColors.sliderInactive,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _stopAudio,
                  icon: Icon(
                    Icons.stop, 
                    color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary, 
                    size: 30,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _playPauseAudio,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isDarkMode ? AppColors.backgroundDark : AppColors.textWhite,
                      size: 40,
                    ),
                  ),
                ),
                Icon(
                  Icons.volume_up, 
                  color: isDarkMode ? AppColors.textWhiteTertiary : AppColors.textTertiary, 
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backgroundCard : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDarkMode ? AppColors.borderDark : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.music_off, 
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.error, 
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Audio no disponible para este himno',
              style: TextStyle(
                color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.error, 
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFontSizeControls(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _decreaseFontSize,
            icon: Icon(
              Icons.text_decrease, 
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary, 
              size: 30,
            ),
            tooltip: 'Disminuir tamaño de texto',
          ),
          Text(
            '${_fontSize.round()}',
            style: TextStyle(
              color: isDarkMode ? AppColors.textWhite : AppColors.textPrimary, 
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: _increaseFontSize,
            icon: Icon(
              Icons.text_increase, 
              color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary, 
              size: 30,
            ),
            tooltip: 'Aumentar tamaño de texto',
          ),
        ],
      ),
    );
  }
}