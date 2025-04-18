import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../Screens/categorypodcasts.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';
  final String baseUrl = 'http://192.168.100.186:8000';

  @override
  void initState() {
    super.initState();
    _loadCachedCategories(); // Load cached data first
    fetchCategories();
  }

  // Load categories from cache
  Future<void> _loadCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('categories_cache');
    if (cachedData != null) {
      setState(() {
        categories = json.decode(cachedData);
        isLoading = false;
      });
    }
  }

  // Save categories to cache
  Future<void> _cacheCategories(List categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categories_cache', json.encode(categories));
  }

  Future<void> fetchCategories() async {
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        errorMessage =
            'Aucune connexion réseau. Veuillez vérifier votre connexion.';
        isLoading = false;
      });
      return;
    }

    final String apiUrl = '$baseUrl/api/categories';
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final startTime = DateTime.now();
        final response = await http.get(Uri.parse(apiUrl)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
                'Délai de connexion dépassé. Serveur lent ou inaccessible.');
          },
        );
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        print("⏱️ Temps de réponse: $duration ms");
        print("Réponse API: ${response.body}");

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final categoryList = jsonData['categories'] ?? jsonData['data'] ?? [];

          if (categoryList.isEmpty) {
            throw Exception(
                'Aucune catégorie trouvée dans la réponse de l\'API.');
          }

          setState(() {
            categories = categoryList;
            isLoading = false;
            errorMessage = '';
          });
          await _cacheCategories(categories);
          print("📋 Catégories récupérées: ${categories.length}");
          return; // Success, exit the loop
        } else {
          throw Exception(
              'Erreur serveur: ${response.statusCode} - ${response.reasonPhrase}');
        }
      } catch (e, stackTrace) {
        print("❌ Tentative ${attempt + 1}: Erreur: $e");
        print("Stack trace: $stackTrace");
        attempt++;
        if (attempt == maxRetries) {
          setState(() {
            errorMessage = 'Impossible de charger les catégories : $e';
            isLoading = false;
          });
        }
        await Future.delayed(const Duration(seconds: 2)); // Delay before retry
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchCategories,
          child: _buildBody(size),
        ),
      ),
    );
  }

  Widget _buildBody(Size size) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red, fontSize: size.width * 0.04),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: fetchCategories,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Aucune catégorie disponible',
          style: TextStyle(fontSize: size.width * 0.04),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Alignement à gauche pour toute la colonne
      children: [
        SizedBox(height: size.height * 0.05),
        Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.04), // Marge à gauche pour le texte
          child: Text(
            'All Category',
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(size.width * 0.04),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: size.width * 0.03,
              mainAxisSpacing: size.height * 0.02,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryCard(categories[index], size),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, Size size) {
    final title = category['name']?.toString() ?? 'Inconnue';
    final imageUrl = category['image']?.toString() ?? '';
    final contentsCount = category['contents_count'] ?? 0;

    // Construct image URL
    final imgUrl = imageUrl.isNotEmpty
        ? imageUrl.startsWith('http')
            ? imageUrl
            : imageUrl.startsWith('/')
                ? '$baseUrl$imageUrl'
                : '$baseUrl/$imageUrl'
        : null;

    return GestureDetector(
      onTap: () {
        if (contentsCount > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryPodcastsPage(categoryTitle: title),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucun podcast disponible pour $title'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: imgUrl != null
                    ? Image.network(
                        imgUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderIcon(size),
                      )
                    : _buildPlaceholderIcon(size),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.04,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$contentsCount podcast${contentsCount > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: size.width * 0.03),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(Size size) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: size.width * 0.1,
          color: Colors.grey,
        ),
      ),
    );
  }
}
