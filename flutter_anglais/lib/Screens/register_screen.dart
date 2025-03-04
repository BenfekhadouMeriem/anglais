import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_anglais/Services/auth_services.dart';
/*import 'package:flutter_anglais/Services/globals.dart';
import '../rounded_button.dart';*/

// Utilisation d'un alias pour home_screen.dart
import 'home_screen.dart' as home_screen;

import 'login_screen.dart';
import 'package:http/http.dart' as http;

import '../widgets/wave_login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  bool _isLoading = false;
  bool _showRegisterFields = false;

  registerPressed() async {
    String _name = _nameController.text.trim();
    String _email = _emailController.text.trim();
    String _password = _passwordController.text.trim();
    String _passwordConfirmation = _passwordConfirmationController.text
        .trim(); // Récupérer la confirmation du mot de passe

    // Vérifier que tous les champs sont remplis et que les mots de passe correspondent
    if (_name.isNotEmpty &&
        _email.isNotEmpty &&
        _password.isNotEmpty &&
        _password == _passwordConfirmation) {
      setState(() {
        _isLoading = true;
      });

      try {
        http.Response response = await AuthServices.register(
            _name, _email, _password, _passwordConfirmation);

        // Affiche la réponse complète dans la console
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const home_screen.HomeScreen()));
        } else {
          // Affichage du message d'erreur détaillé
          try {
            Map responseMap = jsonDecode(response.body);
            String errorMessage =
                responseMap['message'] ?? 'Unknown error occurred';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
          } catch (e) {
            // Gestion des erreurs dans le cas où la réponse n'est pas au format JSON
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('An error occurred. Please try again later.')));
          }
        }
      } catch (e) {
        print("Error during registration: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An error occurred. Please try again.')));
      }
    } else {
      // Afficher un message si les mots de passe ne correspondent pas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 0.45),
        duration: const Duration(seconds: 2),
        onEnd: () {
          setState(() {
            _showRegisterFields = true;
          });
        },
        builder: (context, double waveHeight, child) {
          return Stack(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 0.0),
                duration: const Duration(seconds: 2),
                builder: (context, double waveOffset, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: WavePainter(
                      waveHeight: waveHeight,
                      waveOffset: waveOffset,
                    ),
                  );
                },
              ),
              if (_showRegisterFields) _buildRegisterFields(),
              Positioned(
                top: 70,
                left: MediaQuery.of(context).size.width / 2 - 60,
                child: _buildLogo(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegisterFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 215),
          Text(
            'Register',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 35),
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter your name',
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            icon: Icons.email,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordConfirmationController,
            hintText: 'Confirm your password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 35),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: registerPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? '),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFFE57373),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour le logo
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
            // Barres avec une partie supérieure et une partie inférieure
            _buildVerticalBar(0, 70, 10, Colors.pink.shade200,
                Colors.pink.shade100, true), // Attachée
            _buildVerticalBar(15, 10, 35, Colors.pink.shade300,
                Colors.pink.shade400, false), // Pas attachée
            _buildVerticalBar(-15, 35, 10, Colors.pink.shade300,
                Colors.pink.shade400, false), // Pas attachée
            _buildVerticalBar(30, 20, 10, Colors.pink.shade100,
                Colors.pink.shade200, true), // Attachée
            _buildVerticalBar(-30, 10, 20, Colors.pink.shade100,
                Colors.pink.shade200, true), // attachée
          ],
        ),
      ),
    );
  }

  // Méthode pour une barre avec partie supérieure et inférieure de hauteurs spécifiées
  Widget _buildVerticalBar(double offsetX, double topHeight,
      double bottomHeight, Color topColor, Color bottomColor, bool isAttached) {
    return Positioned(
      left: 57 + offsetX, // Décalage horizontal
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer les barres
        children: [
          // Partie supérieure de la barre
          Container(
            width: 10,
            height: topHeight,
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Si les barres doivent être attachées, on ne met pas d'espace
          // Partie inférieure de la barre
          isAttached
              ? Container(
                  width: 10,
                  height: bottomHeight,
                  decoration: BoxDecoration(
                    color: bottomColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              : SizedBox(
                  height: 5), // Espacement entre les parties si non attachée
          // Partie inférieure de la barre (si pas attachée, un petit espace est mis)
          if (!isAttached)
            Container(
              width: 10,
              height: bottomHeight,
              decoration: BoxDecoration(
                color: bottomColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon, color: Colors.pink.shade300),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.pink.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink),
        ),
      ),
    );
  }
}



/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_anglais/Services/auth_services.dart';
import 'package:flutter_anglais/Services/globals.dart';
import '../rounded_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

import '../widgets/wave_login.dart'; // Importez votre fichier contenant WavePainter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showRegisterFields =
      false; // Pour afficher les champs après l'animation

  registerPressed() async {
    String _name = _nameController.text.trim();
    String _email = _emailController.text.trim();
    String _password = _passwordController.text.trim();

    if (_name.isNotEmpty && _email.isNotEmpty && _password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        http.Response response =
            await AuthServices.register(_name, _email, _password);
        Map responseMap = jsonDecode(response.body);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bad Request: ${responseMap.values.first}')),
          );
        } else if (response.statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Server error. Please try again later.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Unexpected error: ${responseMap.values.first}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 0.45), // Animation de la hauteur
        duration: const Duration(seconds: 2),
        onEnd: () {
          setState(() {
            _showRegisterFields = true; // Afficher les champs après l'animation
          });
        },
        builder: (context, double waveHeight, child) {
          return Stack(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 0.0),
                duration: const Duration(seconds: 2),
                builder: (context, double waveOffset, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: WavePainter(
                      waveHeight: waveHeight,
                      waveOffset: waveOffset,
                    ),
                  );
                },
              ),
              if (_showRegisterFields)
                _buildRegisterFields(), // Champs d'inscription après animation
              Positioned(
                top: 70,
                left: MediaQuery.of(context).size.width / 2 - 60,
                child: _buildLogo(), // Afficher le logo
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon, color: Colors.pink.shade300),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.pink.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink),
        ),
      ),
    );
  }

  Widget _buildRegisterFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 215),
          Text(
            'Register',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 35),
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter your name',
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            icon: Icons.email,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 35),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: registerPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
          const SizedBox(height: 150),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? '),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFFE57373),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Méthode pour une barre avec partie supérieure et inférieure de hauteurs spécifiées
  Widget _buildVerticalBar(double offsetX, double topHeight,
      double bottomHeight, Color topColor, Color bottomColor, bool isAttached) {
    return Positioned(
      left: 57 + offsetX, // Décalage horizontal
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer les barres
        children: [
          Container(
            width: 10,
            height: topHeight,
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          isAttached
              ? Container(
                  width: 10,
                  height: bottomHeight,
                  decoration: BoxDecoration(
                    color: bottomColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              : SizedBox(height: 5),
          if (!isAttached)
            Container(
              width: 10,
              height: bottomHeight,
              decoration: BoxDecoration(
                color: bottomColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
        ],
      ),
    );
  }
}*/


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_anglais/Services/auth_services.dart';
import 'package:flutter_anglais/Services/globals.dart';
import '../rounded_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

import '../widgets/wave_login.dart'; // Importez votre fichier contenant WavePainter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  registerPressed() async {
    String _name = _nameController.text.trim();
    String _email = _emailController.text.trim();
    String _password = _passwordController.text.trim();

    if (_name.isNotEmpty && _email.isNotEmpty && _password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        http.Response response =
            await AuthServices.register(_name, _email, _password);
        Map responseMap = jsonDecode(response.body);

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bad Request: ${responseMap.values.first}')),
          );
        } else if (response.statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Server error. Please try again later.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Unexpected error: ${responseMap.values.first}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            /*painter: WavePainter(),*/
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                _buildLogo(),
                const SizedBox(height: 50),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 35),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 35),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: registerPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                const SizedBox(height: 150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFFE57373),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le logo
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
            // Barres avec une partie supérieure et une partie inférieure
            _buildVerticalBar(0, 70, 10, Colors.pink.shade200,
                Colors.pink.shade100, true), // Attachée
            _buildVerticalBar(15, 10, 35, Colors.pink.shade300,
                Colors.pink.shade400, false), // Pas attachée
            _buildVerticalBar(-15, 35, 10, Colors.pink.shade300,
                Colors.pink.shade400, false), // Pas attachée
            _buildVerticalBar(30, 20, 10, Colors.pink.shade100,
                Colors.pink.shade200, true), // Attachée
            _buildVerticalBar(-30, 10, 20, Colors.pink.shade100,
                Colors.pink.shade200, true), // attachée
          ],
        ),
      ),
    );
  }

  // Méthode pour une barre avec partie supérieure et inférieure de hauteurs spécifiées
  Widget _buildVerticalBar(double offsetX, double topHeight,
      double bottomHeight, Color topColor, Color bottomColor, bool isAttached) {
    return Positioned(
      left: 57 + offsetX, // Décalage horizontal
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer les barres
        children: [
          // Partie supérieure de la barre
          Container(
            width: 10,
            height: topHeight,
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Si les barres doivent être attachées, on ne met pas d'espace
          // Partie inférieure de la barre
          isAttached
              ? Container(
                  width: 10,
                  height: bottomHeight,
                  decoration: BoxDecoration(
                    color: bottomColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              : SizedBox(
                  height: 5), // Espacement entre les parties si non attachée
          // Partie inférieure de la barre (si pas attachée, un petit espace est mis)
          if (!isAttached)
            Container(
              width: 10,
              height: bottomHeight,
              decoration: BoxDecoration(
                color: bottomColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon, color: Colors.pink.shade300),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.pink.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink),
        ),
      ),
    );
  }
}
*/
