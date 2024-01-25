import 'package:flutter/material.dart';
import 'home.dart';
import 'package:hide_and_street/map_conf_screen.dart';

class winPage extends StatefulWidget {
  final bool isSeekerWin;

  winPage({required this.isSeekerWin});

  @override
  _winPage createState() => _winPage();
}

class _winPage extends State<winPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isSeekerWin ? 'Seeker Wins!' : 'Hider Wins!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Bouton "Retour à l'accueil" dans un fond blanc
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Couleur du bouton
                  onPrimary: Colors.white, // Couleur du texte
                ),
                child: Text('Retour à l\'accueil'),
              ),
            ),
            SizedBox(height: 20),
            // Bouton pour recréer une partie
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapConfScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
                primary: Colors.blue, // Couleur du bouton
                onPrimary: Colors.white, // Couleur du texte
              ),
              child: Text('Rejouer'),
            ),
          ],
        ),
      ),
    );
  }
}














