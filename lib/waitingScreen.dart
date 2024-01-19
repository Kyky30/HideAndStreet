import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WaitingScreen extends StatelessWidget {
  final String gameCode;

  WaitingScreen({required this.gameCode});

  void _shareGameCode() {
    // Use the share package to send a message with the game code
    Share.share('Join my game with code: $gameCode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waitingRoomTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Game Code: $gameCode'),
          ElevatedButton(
            onPressed: _shareGameCode,
            child: Text('Share Game Code'),
          ),
          SizedBox(height: 20),
          Text('Players in the Game:'),
          PlayerList(), // Replace with the actual list of players
        ],
      ),
    );
  }
}
class PlayerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with the actual logic to fetch and display the list of players
    return ListView(
      shrinkWrap: true,
      children: [
        PlayerListItem(playerName: 'Player 1'),
        PlayerListItem(playerName: 'Player 2'),
        // Add more PlayerListItems as needed
      ],
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final String playerName;

  PlayerListItem({required this.playerName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(playerName),
      // Add checkbox or any other widgets as needed
    );
  }
}
