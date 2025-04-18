import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LirePlayerScreen extends StatefulWidget {
  final String title;
  final String audioUrl;
  final String transcription;
  final String imageUrl;

  const LirePlayerScreen({
    super.key,
    required this.title,
    required this.audioUrl,
    required this.transcription,
    required this.imageUrl,
  });

  @override
  State<LirePlayerScreen> createState() => _LirePlayerScreenState();
}

class _LirePlayerScreenState extends State<LirePlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final SpeechToText _speechToText;
  final _levenshtein = Levenshtein();

  bool isPlaying = false;
  bool isListening = false;
  bool isReadingMode = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String recognizedText = '';
  String pronunciationFeedback = '';
  bool speechInitialized = false;
  bool isLoading = true;
  double soundLevel = 0.0;
  double fontSize = 18.0;
  List<TextSpan> _transcriptionSpans = [];
  late AnimationController _animationController;
  int _correctWordsCount = 0;
  Timer? _keepAliveTimer; // Timer pour relancer l'écoute périodiquement

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _speechToText = SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _initAudioPlayer();
    _initSpeech();
    _updateTranscriptionDisplay();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      _audioPlayer.durationStream.listen((d) {
        if (mounted) setState(() => duration = d ?? Duration.zero);
      });
      _audioPlayer.positionStream.listen((p) {
        if (mounted) setState(() => position = p);
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) setState(() => isPlaying = state.playing);
      });
    } catch (e) {
      if (mounted) {
        setState(
            () => pronunciationFeedback = 'Erreur de chargement audio : $e');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _initSpeech() async {
    try {
      speechInitialized = await _speechToText.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              pronunciationFeedback =
                  'Statut : $status${isListening ? " (relance en cours)" : ""}';
              if (status == 'notListening' && isListening) {
                isListening = false;
                _restartListening();
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              isListening = false;
              pronunciationFeedback = _getSpeechErrorMessage(error);
            });
            if (!error.permanent) {
              _restartListening();
            }
          }
        },
      );
      if (!speechInitialized && mounted) {
        setState(() {
          pronunciationFeedback =
              'Impossible d\'initialiser la reconnaissance vocale.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => pronunciationFeedback = 'Erreur d\'initialisation : $e');
      }
    }
  }

  String _getSpeechErrorMessage(dynamic error) {
    String errorMessage = error.toString();
    String message = 'Erreur : $errorMessage';
    if (errorMessage.toLowerCase().contains('permission')) {
      message += '\nVeuillez autoriser l\'accès au microphone.';
    } else if (errorMessage.toLowerCase().contains('timeout') ||
        errorMessage.toLowerCase().contains('no speech')) {
      message += '\nAucun son détecté. Relance de l\'écoute...';
    } else if (errorMessage.toLowerCase().contains('network')) {
      message += '\nProblème de connexion.';
    }
    return message;
  }

  String _cleanTranscription(String transcription,
      {bool forComparison = false}) {
    String cleaned = transcription
        .replaceAll(
            RegExp(r'\[\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}\.\d{3}\]'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (forComparison) cleaned = cleaned.toLowerCase();
    return cleaned;
  }

  @override
  void dispose() {
    _keepAliveTimer?.cancel();
    _audioPlayer.dispose();
    _speechToText.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        _animationController.reverse();
      } else {
        await _audioPlayer.play();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => pronunciationFeedback = 'Erreur de lecture audio : $e');
      }
    }
  }

  Future<void> _seekForward() async {
    final newPosition = position + const Duration(seconds: 10);
    await _audioPlayer.seek(newPosition);
  }

  Future<void> _seekBackward() async {
    final newPosition = position - const Duration(seconds: 10);
    await _audioPlayer.seek(newPosition);
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _startListening() async {
    if (!speechInitialized) {
      setState(() =>
          pronunciationFeedback = 'Reconnaissance vocale non initialisée.');
      return;
    }
    bool hasPermission = await _checkMicrophonePermission();
    if (!hasPermission) {
      setState(() => pronunciationFeedback = 'Permission microphone refusée.');
      return;
    }
    bool hasConnectivity = await _checkConnectivity();
    if (!hasConnectivity) {
      setState(() => pronunciationFeedback = 'Aucune connexion Internet.');
      return;
    }
    if (!isListening) {
      print('Démarrage de l\'écoute...');
      setState(() {
        if (recognizedText.isEmpty) recognizedText = '';
        pronunciationFeedback = 'Parlez maintenant...';
        isListening = true;
        soundLevel = 0.0;
      });
      try {
        await _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                recognizedText = result.recognizedWords;
                pronunciationFeedback = result.recognizedWords.isNotEmpty
                    ? 'Continuez à parler...'
                    : 'Parlez maintenant...';
                _updateTranscriptionDisplay();
              });
            }
          },
          onSoundLevelChange: (level) {
            if (mounted) {
              setState(() {
                soundLevel = level;
                // Ajuster ou commenter pour tester
                // if (level < -5 && isListening) {
                //   pronunciationFeedback += '\nParlez plus fort.';
                // }
              });
            }
          },
          localeId: 'en-US',
          listenFor: const Duration(seconds: 300), // 5 minutes
          pauseFor: const Duration(seconds: 60), // 60 secondes
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
        );
        _keepAliveTimer?.cancel();
        _keepAliveTimer =
            Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          if (mounted &&
              !isListening &&
              (pronunciationFeedback.contains('Parlez maintenant') ||
                  pronunciationFeedback.contains('Continuez à parler'))) {
            print('Timer déclenche relance...');
            _restartListening();
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            isListening = false;
            pronunciationFeedback = 'Erreur lors de l\'écoute : $e';
          });
          print('Erreur dans startListening : $e');
          _restartListening();
        }
      }
    }
  }

  Future<void> _restartListening() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted && !isListening) {
      await _startListening();
    }
  }

  Future<void> _stopListening() async {
    if (isListening) {
      _keepAliveTimer?.cancel();
      await _speechToText.stop();
      if (mounted) {
        setState(() {
          isListening = false;
          pronunciationFeedback = recognizedText.isNotEmpty
              ? 'Écoute terminée. Analyse en cours...'
              : 'Aucun texte détecté.';
        });
        if (recognizedText.isNotEmpty) {
          _evaluatePronunciation();
        } else if (soundLevel < -5) {
          setState(() {
            pronunciationFeedback += '\nParlez plus fort.';
          });
        }
      }
    }
  }

  void _evaluatePronunciation() {
    final referenceWords =
        _cleanTranscription(widget.transcription, forComparison: true)
            .split(' ');
    final userWords = recognizedText.toLowerCase().split(' ');
    final totalWords = referenceWords.length;
    final correctWords = _correctWordsCount;

    final similarity = totalWords > 0 ? correctWords / totalWords : 0.0;

    if (mounted) {
      setState(() {
        pronunciationFeedback = similarity >= 0.85
            ? 'Excellente prononciation !'
            : similarity >= 0.65
                ? 'Bonne prononciation.'
                : 'Prononciation à améliorer.';
        pronunciationFeedback += '\nVous avez dit : "$recognizedText"';
        pronunciationFeedback += '\nMots corrects : $correctWords/$totalWords';
      });
    }
  }

  void _updateTranscriptionDisplay() {
    final referenceText = _cleanTranscription(widget.transcription);
    final referenceWords = referenceText.split(' ');
    final recognizedWords = recognizedText
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    _transcriptionSpans.clear();
    _correctWordsCount = 0;

    for (int i = 0; i < referenceWords.length; i++) {
      final refWord = referenceWords[i];
      final recWord = i < recognizedWords.length ? recognizedWords[i] : '';
      final isCorrect =
          recWord.isNotEmpty && refWord.toLowerCase() == recWord.toLowerCase();

      if (isCorrect) _correctWordsCount++;

      _transcriptionSpans.add(
        TextSpan(
          text: '$refWord ',
          style: TextStyle(
            fontSize: fontSize,
            height: 1.5,
            color: i < recognizedWords.length
                ? (isCorrect ? Colors.green : Colors.red)
                : Colors.black,
            backgroundColor: i == recognizedWords.length && isListening
                ? Colors.yellow[200]
                : null,
            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            decoration: i == recognizedWords.length && isListening
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: Colors.blue,
          ),
        ),
      );
    }
    if (mounted) setState(() {});
  }

  void _toggleReadingMode() {
    setState(() {
      isReadingMode = !isReadingMode;
      fontSize = isReadingMode ? 24.0 : 18.0;
      _updateTranscriptionDisplay();
    });
  }

  void _increaseFontSize() {
    setState(() {
      fontSize = (fontSize + 2).clamp(14.0, 30.0);
      _updateTranscriptionDisplay();
    });
  }

  void _decreaseFontSize() {
    setState(() {
      fontSize = (fontSize - 2).clamp(14.0, 30.0);
      _updateTranscriptionDisplay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isReadingMode ? Icons.visibility_off : Icons.visibility),
            tooltip: isReadingMode ? 'Quitter le mode lecture' : 'Mode lecture',
            onPressed: _toggleReadingMode,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Agrandir texte',
            onPressed: _increaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Réduire texte',
            onPressed: _decreaseFontSize,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isReadingMode
              ? _buildReadingMode()
              : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAudioControls(),
          const SizedBox(height: 16),
          _buildSpeechSection(),
          const SizedBox(height: 16),
          _buildTranscriptionSection(),
        ],
      ),
    );
  }

  Widget _buildReadingMode() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transcription',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: _transcriptionSpans,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.5,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.replay_10,
                  label: 'Reculer',
                  onPressed: _seekBackward,
                ),
                const SizedBox(width: 16),
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: _buildControlButton(
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    label: isPlaying ? 'Pause' : 'Jouer',
                    onPressed: _playPause,
                    size: 48,
                  ),
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.forward_10,
                  label: 'Avancer',
                  onPressed: _seekForward,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.pinkAccent,
                thumbColor: Colors.pinkAccent,
                overlayColor: Colors.pinkAccent.withOpacity(0.2),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  final newPosition = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position)),
                Text(_formatDuration(duration)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double size = 32,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: size,
      onPressed: onPressed,
      tooltip: label,
      color: Colors.pinkAccent,
      splashRadius: 24,
    );
  }

  Widget _buildSpeechSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapte les dimensions en fonction de la largeur de l'écran
        final bool isSmallScreen = constraints.maxWidth < 600;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isListening ? _stopListening : _startListening,
                      icon: Icon(
                        isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.pinkAccent,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      label: Text(
                        isListening ? 'Arrêter' : 'Parler',
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (pronunciationFeedback.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    pronunciationFeedback,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: isListening ? Colors.blue : Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptionSection() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transcription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: _transcriptionSpans,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.5,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
