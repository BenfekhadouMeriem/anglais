import 'package:flutter/material.dart';

import 'accueil_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: WavePainter(),
          ),
          // Affichage des boutons
          _buildSquareButtons(context),
          // Logo
          Positioned(
            top: 70,
            left: 20,
            child: _buildLogo(),
          ),
          // Affichage du titre "Catégorie"
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: Column(
              children: const [
                Text(
                  "About Us",
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
      ),
    );
  }

  Widget _buildSquareButtons(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligner le titre à gauche
        children: [
          const SizedBox(height: 200), // Espace avant le titre

          // Titre "Tutorial" en noir et souligné en rose
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Décalage à gauche
            child: Text(
              "Description",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(255, 241, 107, 151),
              ),
            ),
          ),

          /*ici disception*/
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 24), // Espacement à gauche et à droite
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alignement à gauche
              children: [
                SizedBox(height: 30), // Espacement en haut

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16), // Padding interne
                  child: _styledText(
                      "Welcome to ", "AccentFlow!", Colors.pink, null, 22),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _styledText("Ready to ", "join us", Colors.purple,
                      " in transforming your ", 20),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child:
                      _styledText("English", " accent?", Colors.pink, null, 20),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "This journey will be fun, interactive, and effective!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),

                SizedBox(height: 20),

                // Listes avec padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _listItem(
                      "Podcasts",
                      "Dive into engaging ",
                      "audio",
                      Colors.pink,
                      " content to sharpen your listening skills.",
                      18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _listItem("Videos", "Watch and learn with ", "visuals",
                      Colors.pink, " to guide your practice.", 18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _listItem(
                      "Shadowing Practice",
                      "Start following along and perfect your ",
                      "pronunciation.",
                      Colors.pink,
                      null,
                      18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _listItem(
                      "Your Friend,",
                      " Amy -",
                      " SmartHelper",
                      Colors.purple,
                      " is here to answer any questions you have.",
                      18),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _styledText(
                      "All your progress and information will be ",
                      "securely saved.",
                      Colors.pink,
                      null,
                      18),
                ),

                SizedBox(height: 70), // Espacement en bas
                // Texte "Skip" centré
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccueilScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink, // Couleur du texte "Skip"
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _styledText(String text1, String text2, Color color,
      [String? text3, double fontSize = 18]) {
    // Ajout du paramètre fontSize
    return RichText(
      textAlign: TextAlign.start, // Centrer le texte
      text: TextSpan(
        style: TextStyle(
            fontSize: fontSize, color: Colors.black), // Utilise fontSize ici
        children: [
          TextSpan(text: text1),
          TextSpan(
              text: text2,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize)),
          if (text3 != null) TextSpan(text: text3),
        ],
      ),
    );
  }

  Widget _listItem(String title, String text1, String highlighted, Color color,
      [String? text2, double fontSize = 18]) {
    // Ajout du paramètre fontSize
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        textAlign: TextAlign.start, // Centrer le texte
        text: TextSpan(
          style: TextStyle(
              fontSize: fontSize, color: Colors.black), // Utilise fontSize ici
          children: [
            TextSpan(
                text: "• ",
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
            TextSpan(
                text: "$title - ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: fontSize)),
            TextSpan(text: text1),
            TextSpan(
                text: highlighted,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize)),
            if (text2 != null) TextSpan(text: text2),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath, fit: BoxFit.cover),
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
}

class WavePainter extends CustomPainter {
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

    // Vague rose (un peu plus descendue)
    Path pinkPath = Path();
    pinkPath.moveTo(0, size.height * 0.25); // Descente un peu plus profonde
    pinkPath.quadraticBezierTo(size.width * 0.2, size.height * 0.2,
        size.width * 0.5, size.height * 0.24);
    pinkPath.quadraticBezierTo(
        size.width * 0.85, size.height * 0.29, size.width, size.height * 0.24);
    pinkPath.lineTo(size.width, 0);
    pinkPath.lineTo(0, 0);
    pinkPath.close();

    // Vague violette (un peu plus descendue)
    Path purplePath = Path();
    purplePath.moveTo(0, size.height * 0.25); // Descente un peu plus profonde
    purplePath.quadraticBezierTo(size.width * 0, size.height * 0.2,
        size.width * 0.4, size.height * 0.25);
    purplePath.quadraticBezierTo(
        size.width * 0.85, size.height * 0.3, size.width, size.height * 0.2);
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
