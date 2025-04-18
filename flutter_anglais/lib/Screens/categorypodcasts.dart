import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lire_player_screen.dart';

class CategoryPodcastsPage extends StatefulWidget {
  final String categoryTitle;

  const CategoryPodcastsPage({Key? key, required this.categoryTitle})
      : super(key: key);

  @override
  _CategoryPodcastsPageState createState() => _CategoryPodcastsPageState();
}

class _CategoryPodcastsPageState extends State<CategoryPodcastsPage> {
  List<dynamic> podcasts = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String errorMessage = '';
  final String baseUrl = 'http://192.168.100.186:8000';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCategoryPodcasts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Vous pourriez implémenter le chargement supplémentaire ici
    }
  }

  Future<void> fetchCategoryPodcasts() async {
    setState(() => isRefreshing = true);
    final url =
        '$baseUrl/api/contents/category/${Uri.encodeComponent(widget.categoryTitle.trim())}';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          podcasts = data['contents'] ?? [];
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = response.statusCode == 404
              ? 'Catégorie non trouvée'
              : 'Erreur serveur: ${response.statusCode}';
        });
      }
    } on SocketException {
      setState(() => errorMessage = 'Problème de connexion internet');
    } on TimeoutException {
      setState(() => errorMessage = 'Temps de réponse dépassé');
    } catch (e) {
      setState(() => errorMessage = 'Erreur: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: size.height * 0.02),
            Text(
              'Chargement des podcasts...',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: size.width * 0.15,
              color: Colors.red[400],
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.red[400],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.03),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.015,
                ),
              ),
              onPressed: fetchCategoryPodcasts,
            ),
          ],
        ),
      );
    }

    if (podcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.audiotrack,
              size: size.width * 0.2,
              color: Colors.grey[400],
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Aucun podcast disponible',
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'dans cette catégorie',
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchCategoryPodcasts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.05),
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.05,
              size.height * 0.02,
              size.width * 0.05,
              size.height * 0.01,
            ),
            child: Text(
              'All Podcasts',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: size.width * 0.03,
                right: size.width * 0.03,
                bottom: size.height * 0.03,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: podcasts.length,
              itemBuilder: (context, index) => _buildPodcastItem(
                podcasts[index],
                context,
                index == podcasts.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastItem(
      Map<String, dynamic> podcast, BuildContext context, bool isLastItem) {
    final size = MediaQuery.of(context).size;
    final title = podcast['title'] ?? 'Podcast';
    final description = podcast['description'] ?? '';
    final audioPath = podcast['file_path'] ?? '';
    final imagePath = podcast['image_path'] ?? '';
    final transcription = podcast['transcription'] ?? '';

    final audioUrl = audioPath.startsWith("http")
        ? audioPath
        : "$baseUrl${audioPath.startsWith('/') ? '' : '/'}$audioPath";

    final imgUrl = imagePath.isNotEmpty && !imagePath.startsWith("http")
        ? "$baseUrl${imagePath.startsWith('/') ? '' : '/'}$imagePath"
        : imagePath;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLastItem ? size.height * 0.03 : size.height * 0.01,
      ),
      child: Card(
        elevation: 1, // Réduit l'élévation pour un look plus plat
        margin: EdgeInsets.symmetric(
          vertical: size.height * 0.005,
          horizontal: size.width * 0.02,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8), // Bordure légèrement moins arrondie
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (audioUrl.isEmpty || !audioUrl.startsWith("http")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Fichier audio introuvable !'),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LirePlayerScreen(
                  title: title,
                  audioUrl: audioUrl,
                  transcription: transcription,
                  imageUrl: imgUrl,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.005,
              horizontal: size.width * 0.02,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imgUrl.isNotEmpty
                      ? Image.network(
                          imgUrl,
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox(
                            width: size.width * 0.15,
                            height: size.width * 0.15,
                            child: Icon(
                              Icons.image_not_supported,
                              size: size.width * 0.05,
                              color: Colors.grey,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: size.width * 0.15,
                              height: size.width * 0.15,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          child: Icon(
                            Icons.audiotrack,
                            size: size.width * 0.05,
                            color: Colors.grey,
                          ),
                        ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.035,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: size.height * 0.003),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: size.width * 0.03,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: size.height * 0.003),
                      Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: size.width * 0.04,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.play_circle_fill,
                    size: size.width * 0.07,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (audioUrl.isEmpty || !audioUrl.startsWith("http")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Fichier audio introuvable !'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LirePlayerScreen(
                          title: title,
                          audioUrl: audioUrl,
                          transcription: transcription,
                          imageUrl: imgUrl,
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

  Widget _buildPlaceholderIcon(Size size) {
    return Container(
      width: size.width * 0.18,
      height: size.width * 0.18,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.audiotrack,
          size: size.width * 0.08,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isRefreshing ? Colors.grey : Colors.black,
            ),
            onPressed: isRefreshing ? null : fetchCategoryPodcasts,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }
}
