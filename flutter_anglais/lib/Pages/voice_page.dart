import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/player_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({Key? key}) : super(key: key);

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  List podcasts = [];
  List filteredPodcasts = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedPodcasts(); // Charger les données mises en cache
    fetchPodcasts();
    _searchController.addListener(() {
      _filterPodcasts(_searchController.text);
    });
  }

  // Charger les podcasts depuis le cache
  Future<void> _loadCachedPodcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('podcasts_cache');
    if (cachedData != null) {
      setState(() {
        podcasts = json.decode(cachedData);
        filteredPodcasts = podcasts;
        isLoading = false;
      });
    }
  }

  // Sauvegarder les podcasts dans le cache
  Future<void> _cachePodcasts(List podcasts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('podcasts_cache', json.encode(podcasts));
  }

  Future<void> fetchPodcasts() async {
    // Vérifier la connectivité réseau
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        errorMessage =
            'Aucune connexion réseau. Veuillez vérifier votre connexion.';
        isLoading = false;
      });
      return;
    }

    const String apiUrl = 'http://192.168.100.186:8000/api/contents';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10), // Timeout réduit
        onTimeout: () {
          throw Exception(
              'Délai de connexion dépassé. Serveur lent ou inaccessible.');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['contents'] == null || jsonData['contents'].isEmpty) {
          throw Exception('Aucun podcast trouvé dans la réponse de l\'API.');
        }
        setState(() {
          podcasts = jsonData['contents'];
          filteredPodcasts = podcasts;
          isLoading = false;
        });
        // Mettre en cache les données
        await _cachePodcasts(podcasts);
        print("📢 Podcasts récupérés: ${podcasts.length}");
      } else {
        setState(() {
          errorMessage =
              'Erreur serveur: ${response.statusCode} - ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Erreur: $e");
      setState(() {
        errorMessage = 'Impossible de charger les podcasts : $e';
        isLoading = false;
      });
    }
  }

  void _filterPodcasts(String query) {
    setState(() {
      searchQuery = query;
      filteredPodcasts = podcasts.where((podcast) {
        final title = podcast['title']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                style: const TextStyle(color: Colors.black),
                autofocus: true,
              )
            : const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterPodcasts('');
                }
              });
            },
          ),
          SizedBox(width: size.width * 0.04),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchPodcasts,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.03),
                Text(
                  'All Podcasts',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.02),
                                ElevatedButton(
                                  onPressed: fetchPodcasts,
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : filteredPodcasts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun podcast trouvé.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPodcasts.length,
                                itemBuilder: (context, index) {
                                  final podcast = filteredPodcasts[index];
                                  final filePath =
                                      podcast['file_path']?.toString() ?? '';
                                  final imagePath =
                                      podcast['image_path']?.toString() ?? '';
                                  final title =
                                      podcast['title']?.toString() ?? 'Podcast';
                                  final description =
                                      podcast['description']?.toString() ??
                                          'Aucune description';
                                  final transcription =
                                      podcast['transcription']?.toString() ??
                                          '';

                                  final fullUrl = filePath.startsWith("http")
                                      ? filePath
                                      : "http://192.168.100.186:8000$filePath";

                                  final imgUrl = imagePath.isNotEmpty &&
                                          !imagePath.startsWith("http")
                                      ? "http://192.168.100.186:8000${imagePath.startsWith('/') ? '' : '/'}$imagePath"
                                      : imagePath;

                                  return Card(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              size.height * 0.005), // réduit
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              6), // légèrement réduit
                                          child: imagePath.isNotEmpty
                                              ? Image.network(
                                                  imgUrl,
                                                  width: size.width *
                                                      0.15, // réduit
                                                  height: size.width * 0.15,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return SizedBox(
                                                      width: size.width * 0.15,
                                                      height: size.width * 0.15,
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : SizedBox(
                                                  width: size.width * 0.15,
                                                  height: size.width * 0.15,
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                        title: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                size.width * 0.035, // réduit
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: size.width *
                                                      0.03), // réduit
                                            ),
                                            SizedBox(
                                                height: size.height * 0.003),
                                            const Icon(
                                              Icons.favorite_border,
                                              color: Colors.grey,
                                              size: 18, // réduit
                                            ),
                                          ],
                                        ),
                                        trailing: StatefulBuilder(
                                          builder: (context, setState) {
                                            return IconButton(
                                              icon: Icon(
                                                Icons.play_circle_fill,
                                                size:
                                                    size.width * 0.07, // réduit
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                if (fullUrl.isEmpty ||
                                                    !fullUrl
                                                        .startsWith("http")) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          '❌ Fichier audio introuvable !'),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PlayerScreen(
                                                      title: title,
                                                      description: description,
                                                      audioUrl: fullUrl,
                                                      transcription:
                                                          transcription,
                                                      imageUrl: imgUrl,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
