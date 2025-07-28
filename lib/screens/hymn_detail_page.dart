import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn.dart';
import '../services/favorites_manager.dart';
import '../constants/app_colors.dart'; // Importar los colores centralizados

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
        backgroundColor: widget.hymn.isFavorite ? AppColors.snackBarSuccess : AppColors.snackBarError, // Cambio: usar color centralizado
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
    return Scaffold(
      backgroundColor: HymnDetail.headerBackground, // Cambio: usar color centralizado
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLyricsSection(),
            _buildAudioControls(),
            _buildFontSizeControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HymnDetail.headerBackground, // Cambio: usar color centralizado
            HymnDetail.headerBackgroundGradient, // Cambio: usar color centralizado
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: HymnDetail.backIcon, size: 28), // Cambio: usar color centralizado
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
                    color: HymnDetail.numberText, // Cambio: usar color centralizado
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.hymn.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: HymnDetail.titleText, // Cambio: usar color centralizado
                  ),
                ),
                if (widget.hymn.suggestedTone.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'Tono: ${widget.hymn.suggestedTone}',
                    style: TextStyle(
                      fontSize: 14,
                      color: HymnDetail.toneText, // Cambio: usar color centralizado
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
              color: widget.hymn.isFavorite ? AppColors.favorite : AppColors.favoriteInactive, // Cambio: usar color centralizado
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
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
                color: HymnDetail.lyricsText, // Cambio: usar color centralizado
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

  Widget _buildAudioControls() {
    if (widget.hymn.audioPath != null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: HymnDetail.audioControlBackground, // Cambio: usar color centralizado
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: HymnDetail.audioControlBorder), // Cambio: usar color centralizado
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: AppColors.musicNote, size: 20), // Cambio: usar color centralizado
                SizedBox(width: 8),
                Text(
                  'Audio disponible',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w500), // Cambio: usar color centralizado
                ),
              ],
            ),
            SizedBox(height: 15),
            
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(color: AppColors.textWhite, fontSize: 12), // Cambio: usar color centralizado
                ),
                Expanded(
                  child: Slider(
                    value: _duration.inMilliseconds > 0 
                        ? _position.inMilliseconds / _duration.inMilliseconds 
                        : 0.0,
                    onChanged: _seekAudio,
                    activeColor: AppColors.sliderActive, // Cambio: usar color centralizado
                    inactiveColor: AppColors.sliderInactive, // Cambio: usar color centralizado
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(color: AppColors.textWhite, fontSize: 12), // Cambio: usar color centralizado
                ),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _stopAudio,
                  icon: Icon(Icons.stop, color: AppColors.textWhite, size: 30), // Cambio: usar color centralizado
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Cambio: usar color centralizado
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _playPauseAudio,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.textWhite, // Cambio: usar color centralizado
                      size: 40,
                    ),
                  ),
                ),
                Icon(Icons.volume_up, color: AppColors.textWhiteTertiary, size: 30), // Cambio: usar color centralizado
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
          color: HymnDetail.audioUnavailableBackground, // Cambio: usar color centralizado
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: HymnDetail.audioUnavailableBorder), // Cambio: usar color centralizado
        ),
        child: Row(
          children: [
            Icon(Icons.music_off, color: HymnDetail.audioUnavailableIcon, size: 20), // Cambio: usar color centralizado
            SizedBox(width: 8),
            Text(
              'Audio no disponible para este himno',
              style: TextStyle(color: HymnDetail.audioUnavailableIcon, fontSize: 14), // Cambio: usar color centralizado
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFontSizeControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _decreaseFontSize,
            icon: Icon(Icons.text_decrease, color: HymnDetail.fontSizeIcon, size: 30), // Cambio: usar color centralizado
            tooltip: 'Disminuir tamaño de texto',
          ),
          Text(
            '${_fontSize.round()}',
            style: TextStyle(color: HymnDetail.fontSizeIcon, fontSize: 16), // Cambio: usar color centralizado
          ),
          IconButton(
            onPressed: _increaseFontSize,
            icon: Icon(Icons.text_increase, color: HymnDetail.fontSizeIcon, size: 30), // Cambio: usar color centralizado
            tooltip: 'Aumentar tamaño de texto',
          ),
        ],
      ),
    );
  }
}