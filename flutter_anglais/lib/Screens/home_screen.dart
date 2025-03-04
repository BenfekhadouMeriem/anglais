import 'package:flutter/material.dart';

import 'young_screen.dart' as young_screen;
import 'advanced_screen.dart' as advances_screen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _showLogo = false;
  bool _showCategories = false; // Ajouter cette variable pour les catégories
  bool _showLoginFields = false;

  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    // Animation pour les vagues
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animation pour le logo
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Démarrer l'animation des vagues et du logo
    Future.delayed(const Duration(seconds: 1), () {
      _animationController.forward();
    });

    // Déclencher l'animation du logo après un délai
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _showLogo = true;
      });
    });

    // Affichage des catégories après l'animation du logo
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showCategories = true;
      });
    });

    // Affichage des champs après l'animation des vagues
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showLoginFields = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: Tween<double>(
            begin: 0.45, end: 0.0), // Animation de la hauteur des vagues
        duration: const Duration(seconds: 2),
        onEnd: () {
          setState(() {
            _showLoginFields =
                true; // Afficher les champs après l'animation des vagues
          });
        },
        builder: (context, double waveHeight, child) {
          return Stack(
            children: [
              // Animation des vagues
              TweenAnimationBuilder(
                tween: Tween<double>(
                    begin: 0.0, end: 0.0), // Déplacement des vagues
                duration: const Duration(seconds: 2),
                builder: (context, double waveOffset, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: WavePainter(
                      waveHeight: waveHeight, // Hauteur dynamique de la vague
                      waveOffset: waveOffset, // Décalage dynamique des vagues
                    ),
                  );
                },
              ),
              // Affichage des "carrés" après l'animation
              if (_showLoginFields) _buildSquareButtons(),
              // Logo positionné avec animation
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                top: 70, // Position du logo
                left: _showLogo
                    ? 20 // Déplacement du logo vers la gauche
                    : MediaQuery.of(context).size.width / 2 -
                        60, // Centré initialement
                child: _buildLogo(),
              ),
              // Affichage du titre "Catégorie" et des noms "Kids" et "Adult"
              if (_showCategories)
                Positioned(
                  top: 100, // Positionner le titre plus bas
                  left: MediaQuery.of(context).size.width / 2 - 40,
                  child: Column(
                    children: [
                      Text(
                        "Catégorie",
                        style: TextStyle(
                          fontSize: 41,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildVerticalBar(
                0, 70, 10, Colors.pink.shade200, Colors.pink.shade100, true),
            _buildVerticalBar(
                15, 10, 35, Colors.pink.shade300, Colors.pink.shade400, false),
            _buildVerticalBar(
                -15, 35, 10, Colors.pink.shade300, Colors.pink.shade400, false),
            _buildVerticalBar(
                30, 20, 10, Colors.pink.shade100, Colors.pink.shade200, true),
            _buildVerticalBar(
                -30, 10, 20, Colors.pink.shade100, Colors.pink.shade200, true),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBar(double offsetX, double topHeight,
      double bottomHeight, Color topColor, Color bottomColor, bool isAttached) {
    return Positioned(
      left: 57 + offsetX, // Position horizontale de la barre
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer la colonne
        children: [
          // Partie supérieure de la barre
          Container(
            width: 10,
            height: topHeight, // Hauteur de la barre supérieure
            decoration: BoxDecoration(
              color: topColor, // Couleur de la barre
              borderRadius: BorderRadius.circular(5), // Coins arrondis
            ),
          ),
          // Partie inférieure de la barre (si attachée)
          isAttached
              ? Container(
                  width: 10,
                  height: bottomHeight, // Hauteur de la barre inférieure
                  decoration: BoxDecoration(
                    color: bottomColor, // Couleur de la barre inférieure
                    borderRadius: BorderRadius.circular(5), // Coins arrondis
                  ),
                )
              : SizedBox(height: 5), // Espacement si non attachée
          // Partie inférieure de la barre (si non attachée)
          if (!isAttached)
            Container(
              width: 10,
              height: bottomHeight, // Hauteur de la barre inférieure
              decoration: BoxDecoration(
                color: bottomColor, // Couleur de la barre inférieure
                borderRadius: BorderRadius.circular(5), // Coins arrondis
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.pink.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildSquareButtons() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(height: 100),
            // Texte explicatif
            Text(
              'Choose your category to start improving your accent:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Texte détaillé sur les catégories
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 19, color: Colors.black87),
                children: [
                  TextSpan(
                    text: 'Young Explorers : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'This category is for beginners who want to explore the basics of the English accent.\n\n',
                  ),
                  TextSpan(
                    text: 'Advanced Learners : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'This category is for those who want to perfect their accent with advanced exercises.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 75),

            // Boutons pour les catégories
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  young_screen.YoungExplorersPage(),
                            ),
                          );
                        },
                        child: _buildSquareButton('assets/kids.jpg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Young Explorers",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20), // Espacement entre les deux catégories
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  advances_screen.AdvancedLearnersPage(),
                            ),
                          );
                        },
                        child: _buildSquareButton('assets/adults1.jpg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Advanced Learners",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(String imagePath) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveHeight;
  final double waveOffset;

  WavePainter({required this.waveHeight, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Peinture pour la vague rose
    Paint pinkPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.pink.shade300,
          Colors.pink.shade200,
          Colors.pink.shade100,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Peinture pour la vague violette
    Paint purplePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.purple.shade200,
          Colors.purple.shade100,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 🔼 Vague rose - Plus haute en diminuant waveHeight
    Path pinkPath = Path();
    pinkPath.moveTo(0, size.height * (waveHeight + 0.25) + waveOffset);
    pinkPath.quadraticBezierTo(
        size.width * 0.2,
        size.height * (waveHeight + 0.2) + waveOffset,
        size.width * 0.45,
        size.height * (waveHeight + 0.23) + waveOffset);
    pinkPath.quadraticBezierTo(
        size.width * 0.85,
        size.height * (waveHeight + 0.29) + waveOffset,
        size.width,
        size.height * (waveHeight + 0.23) + waveOffset);
    pinkPath.lineTo(size.width, 0);
    pinkPath.lineTo(0, 0);
    pinkPath.close();

    // 🔼 Vague violette - Plus haute aussi
    Path purplePath = Path();
    purplePath.moveTo(0, size.height * (waveHeight + 0.22) + waveOffset);
    purplePath.quadraticBezierTo(
        size.width * 0.13,
        size.height * (waveHeight + 0.21) + waveOffset,
        size.width * 0.45,
        size.height * (waveHeight + 0.25) + waveOffset);
    purplePath.quadraticBezierTo(
        size.width * 0.85,
        size.height * (waveHeight + 0.3) + waveOffset,
        size.width,
        size.height * (waveHeight + 0.18) + waveOffset);
    purplePath.lineTo(size.width, 0);
    purplePath.lineTo(0, 0);
    purplePath.close();

    // Dessiner les vagues
    canvas.drawPath(purplePath, purplePaint); // Vague violette
    canvas.drawPath(pinkPath, pinkPaint); // Vague rose
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}








/*import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
*/