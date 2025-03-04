import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({Key? key}) : super(key: key);

  @override
  _AccueilScreenState createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final GlobalKey<CurvedNavigationBarState> _curvedNavigationKey = GlobalKey();
  int _intpage = 0;
  bool _isMenuOpen = false; // Contrôle du menu contextuel

  bool _isSearching = false; // Contrôle de la recherche
  final TextEditingController _searchController = TextEditingController();

  List<String> pageNames = ["Vidéo", "Audio", "Add", "Ai Chat", "Profil"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              )
            : const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,

        /*leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _openMenu(context),
        ),*/

        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      drawer: _buildDrawer(context), // Ajout du menu latéral

      // 🏠 Contenu Principal
      body: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎥 Section Vidéo Principale
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      image: const DecorationImage(
                        image: AssetImage(
                            'assets/microphone.jpg'), // Remplace avec ton image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 16,
                          left: 16,
                          child: Text(
                            'Practice your English',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.play_circle_fill,
                              size: 50, color: Colors.white),
                        ),
                        const Positioned(
                          bottom: 16,
                          right: 16,
                          child:
                              Icon(Icons.favorite_border, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📢 Trending Podcasts
                  const Text('Trending Podcast',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 📻 Liste de Podcasts
                  Column(
                    children: [
                      podcastTile(
                        'Generations',
                        'Leaders of the next generation',
                        'assets/generations.jpg',
                        true,
                      ),
                      podcastTile('Social Media', 'Elite Team',
                          'assets/social_media.jpg', false),
                      podcastTile('Business Time', 'Rahim Reda',
                          'assets/business_time.jpg', false),
                      podcastTile('Having Fun', 'Ikram Selma',
                          'assets/having_fun.jpg', false),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🏠 Bottom Navigation Bar Stylisée
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Fond arrondi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(35)), // Arrondi en haut
              child: Container(
                height: 70.0,
                color: Colors.white, // Même couleur que la navbar
              ),
            ),
          ),

          // Barre de navigation courbée
          CurvedNavigationBar(
            key: _curvedNavigationKey,
            index: _intpage,
            height: 70.0,
            items: List.generate(5, (index) {
              bool isSelected = _intpage == index ||
                  (_isMenuOpen && index == 2 && _isMenuOpen);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    [
                      Icons.videocam_outlined,
                      Icons.settings_voice_outlined,
                      _isMenuOpen
                          ? Icons.cancel_outlined
                          : Icons.add_circle_outline, // Changement ici
                      Icons.question_answer_outlined,
                      Icons.person_outlined
                    ][index],
                    size: index == 2
                        ? 30
                        : 25, // Ajustement de la taille des icônes
                    color: isSelected
                        ? Colors.white
                        : (_intpage == index ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 2), // Espacement entre icône et texte
                  Text(
                    pageNames[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
            color: Colors.transparent, // Transparent pour afficher l'arrondi
            buttonBackgroundColor: Colors.pink.shade300,
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 600),
            onTap: (index) {
              setState(() {
                if (index == 2) {
                  _isMenuOpen =
                      !_isMenuOpen; // Ouvrir/Fermer le menu vidéo/micro
                  _intpage =
                      2; // Forcer la sélection pour que seul "Ajouter" reste blanc
                } else {
                  _intpage = index;
                  _isMenuOpen = false; // Cacher le menu si on clique ailleurs
                }
              });
            },
            letIndexChange: (index) => true,
          ),
        ],
      ),

      // 🎛️ Floating Action Button (Menu Flottant)
      floatingActionButton: _isMenuOpen
          ? Padding(
              padding: const EdgeInsets.only(
                  bottom: 80), // Place au-dessus de la barre
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.pink.shade300,
                    child: const Icon(Icons.videocam, color: Colors.white),
                    onPressed: () {
                      // Action pour vidéo
                    },
                  ),
                  const SizedBox(width: 10), // Espacement entre les boutons
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.pink.shade300,
                    child: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      // Action pour micro
                    },
                  ),
                ],
              ),
            )
          : null, // Ne pas afficher si _isMenuOpen est false

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 🎭 Fonction pour récupérer l'icône selon l'index
  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.videocam;
      case 1:
        return Icons.settings_voice;
      case 2:
        return Icons.add_circle;
      case 3:
        return Icons.question_answer;
      case 4:
        return Icons.person;
      default:
        return Icons.help;
    }
  }

  // 🎵 Widget pour un élément de podcast
  Widget podcastTile(
      String title, String subtitle, String imagePath, bool isPink) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(imagePath, width: 90, height: 90, fit: BoxFit.cover),
      ),
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12, // Taille du sous-titre
        ),
      ),
      trailing: Icon(Icons.play_circle_fill,
          color: isPink ? Colors.pink : Colors.black),
    );
  }
}

// fonction pour ouvrir le menu
void _openMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text("Accueil"),
            onTap: () {
              Navigator.pop(context);
              print("Accueil sélectionné");
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.black),
            title: Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              print("Profil sélectionné");
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black),
            title: Text("Paramètres"),
            onTap: () {
              Navigator.pop(context);
              print("Paramètres sélectionnés");
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Déconnexion"),
            onTap: () {
              Navigator.pop(context);
              print("Déconnexion effectuée");
            },
          ),
        ],
      );
    },
  );
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.pink.shade200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.account_circle, size: 60, color: Colors.white),
              SizedBox(height: 10),
              Text("Bienvenue !",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("user@example.com",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Colors.black),
          title: const Text("Accueil"),
          onTap: () {
            Navigator.pop(context); // Ferme le menu
            print("Accueil sélectionné");
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.black),
          title: const Text("Profil"),
          onTap: () {
            Navigator.pop(context);
            print("Profil sélectionné");
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.black),
          title: const Text("Paramètres"),
          onTap: () {
            Navigator.pop(context);
            print("Paramètres sélectionnés");
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Déconnexion"),
          onTap: () {
            Navigator.pop(context);
            print("Déconnexion effectuée");
          },
        ),
      ],
    ),
  );
}
