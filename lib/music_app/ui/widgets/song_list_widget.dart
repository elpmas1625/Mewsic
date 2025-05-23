import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../logic/music_player_service.dart';

class SongListWidget extends StatelessWidget {
  final List<Song> songs;

  const SongListWidget({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(
        child: Text('No songs available.'),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text(song.artist),
          leading: const Icon(Icons.audiotrack), // Optional: Add an icon
          onTap: () {
            final musicService = Provider.of<MusicPlayerService>(context, listen: false);
            musicService.play(song);
            // Navigation to NowPlayingScreen will be handled by HomeScreen listening to song changes.
          },
        );
      },
    );
  }
}
