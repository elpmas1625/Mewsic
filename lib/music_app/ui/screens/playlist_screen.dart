import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/music_player_service.dart';
import '../../models/playlist.dart'; // Import Playlist model

class PlaylistScreen extends StatelessWidget { // Changed to StatelessWidget
  const PlaylistScreen({super.key});

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final musicService = Provider.of<MusicPlayerService>(context, listen: false);
    final TextEditingController nameController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Playlist Name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  musicService.createPlaylist(nameController.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild when playlists change
    return Consumer<MusicPlayerService>(
      builder: (context, musicService, child) {
        // Fetch playlists directly within the builder or ensure MusicPlayerService
        // calls notifyListeners when _playlists changes.
        // For simplicity, assuming getPlaylists() returns the current list
        // and notifyListeners() is called on modification.
        // If getPlaylists is async and not just a getter, this needs FutureBuilder.
        // Assuming getPlaylists is a synchronous getter for _playlists
        // List<Playlist> playlists = musicService.getPlaylists(); 
        // For this example, we will use a FutureBuilder as getPlaylists() is async.
        
        return Scaffold(
          // AppBar can be part of the main Scaffold in HomeScreen if preferred
          // For now, keeping it here for modularity.
          // appBar: AppBar( 
          //   title: const Text('Playlists'),
          // ),
          body: FutureBuilder<List<Playlist>>(
            future: musicService.getPlaylists(), // getPlaylists returns a Future<List<Playlist>>
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No playlists yet. Create one!'));
              }

              final playlists = snapshot.data!;
              return ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    title: Text(playlist.name),
                    leading: const Icon(Icons.playlist_play),
                    // subtitle: Text('${playlist.songIds.length} songs'), // Example subtitle
                    onTap: () {
                      print('Tapped on playlist: ${playlist.name}');
                      // TODO: Navigate to a PlaylistDetailScreen(playlist: playlist)
                      // For now, maybe play the first song of the playlist if available.
                      if (playlist.songIds.isNotEmpty) {
                        // This requires resolving songIds to actual Song objects
                        // and then playing. MusicPlayerService's playPlaylist
                        // handles this.
                        // musicService.playPlaylist(playlist);
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Playing playlist ${playlist.name} (not fully implemented).')),
                        );
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${playlist.name} is empty.')),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showCreatePlaylistDialog(context);
            },
            tooltip: 'Create Playlist',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
