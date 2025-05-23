import 'package:flutter/material.dart';
import 'dart:async'; // For StreamSubscription
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../widgets/song_list_widget.dart';
import 'now_playing_screen.dart';
import 'playlist_screen.dart';
import '../../logic/music_player_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  StreamSubscription? _currentSongSubscription;

  // Sample songs - this could also come from the service or a dedicated data source
  // Added coverArtUrl for NowPlayingScreen
  final List<Song> _sampleSongs = [
    const Song(title: 'Bohemian Rhapsody', artist: 'Queen', album: 'A Night at the Opera', duration: Duration(minutes: 5, seconds: 55), filePath: '/path/to/bohemian.mp3', coverArtUrl: 'https://upload.wikimedia.org/wikipedia/en/9/9f/Queen_Bohemian_Rhapsody.png'),
    const Song(title: 'Stairway to Heaven', artist: 'Led Zeppelin', album: 'Led Zeppelin IV', duration: Duration(minutes: 8, seconds: 2), filePath: '/path/to/stairway.mp3', coverArtUrl: 'https://upload.wikimedia.org/wikipedia/en/2/26/Led_Zeppelin_-_Led_Zeppelin_IV.jpg'),
    const Song(title: 'Hotel California', artist: 'Eagles', album: 'Hotel California', duration: Duration(minutes: 6, seconds: 30), filePath: '/path/to/hotel_california.mp3', coverArtUrl: 'https://upload.wikimedia.org/wikipedia/en/4/49/Hotelcalifornia.jpg'),
    const Song(title: 'Imagine', artist: 'John Lennon', album: 'Imagine', duration: Duration(minutes: 3, seconds: 3), filePath: '/path/to/imagine.mp3', coverArtUrl: 'https://upload.wikimedia.org/wikipedia/en/b/b5/ImagineCover.jpg'),
  ];

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    
    _widgetOptions = <Widget>[
      SongListWidget(songs: _sampleSongs), // Browse tab
      const PlaylistScreen(),               // Playlists tab
    ];

    final musicService = Provider.of<MusicPlayerService>(context, listen: false);
    
    // Listen to current song changes to navigate to NowPlayingScreen
    // This assumes currentSongStream is still part of MusicPlayerService and works with ChangeNotifier.
    // Alternatively, if currentSong is a direct getter updated by notifyListeners,
    // a Consumer/Selector could react to it, but for navigation, a listener in initState is common.
    _currentSongSubscription = musicService.currentSongStream.listen((Song? song) {
      if (song != null && mounted) { // Check if mounted before navigating
          // Check if NowPlayingScreen is already the top-most route.
          // This simple check might not be robust enough for complex navigation stacks.
          if (!(ModalRoute.of(context)?.settings.name == '/now_playing')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NowPlayingScreen(),
                settings: const RouteSettings(name: '/now_playing'), // Name the route
              ),
            );
          }
      }
    });
  }

  @override
  void dispose() {
    _currentSongSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) { // "Now Playing" tab index
      final musicService = Provider.of<MusicPlayerService>(context, listen: false);
      if (musicService.currentSong != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NowPlayingScreen(), settings: const RouteSettings(name: '/now_playing')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No song is currently playing or selected.')),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Browse Songs';
      case 1:
        return 'Playlists';
      default:
        return 'Music App'; // Should not happen if "Now Playing" is navigation only
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
      ),
      body: Center(
        // Ensure _selectedIndex is within bounds of _widgetOptions
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_filled),
            label: 'Now Playing',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
