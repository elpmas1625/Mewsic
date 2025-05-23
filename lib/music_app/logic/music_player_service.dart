import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../models/playlist.dart';

/// Enum for player state.
enum PlayerState {
  playing,
  paused,
  stopped,
  completed,
}

/// Service to manage music playback and playlists.
class MusicPlayerService extends ChangeNotifier {
  // --- Playback Properties ---

  Song? _currentSong;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  /// Stream controller for player state changes.
  final _playerStateController = StreamController<PlayerState>.broadcast();
  /// Stream controller for current song changes.
  final _currentSongController = StreamController<Song?>.broadcast();

  // --- Playlist Properties ---
  final List<Playlist> _playlists = [];
  final List<Song> _currentQueue = [];
  int _currentQueueIndex = -1;


  // --- Playback Getters ---

  /// Gets the current playback position.
  Duration get currentPosition => _currentPosition;

  /// Gets the total duration of the current song.
  Duration get totalDuration => _totalDuration;

  /// Stream of player state changes.
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  /// Stream of the current song.
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  // --- Playback Methods ---

  /// Plays the given [song].
  ///
  /// This will stop any currently playing song and start playing the new one.
  Future<void> play(Song song) async {
    print('Playing ${song.title}');
    _currentSong = song;
    _totalDuration = song.duration; // Assuming song has duration
    _currentPosition = Duration.zero;
    _playerState = PlayerState.playing;
    _playerStateController.add(_playerState);
    _currentSongController.add(_currentSong);
    notifyListeners();
    // Actual playback logic would go here (e.g., using a plugin like audioplayers)
  }

  /// Pauses the currently playing song.
  Future<void> pause() async {
    if (_playerState == PlayerState.playing) {
      print('Pausing playback');
      _playerState = PlayerState.paused;
      _playerStateController.add(_playerState);
      notifyListeners();
      // Actual pause logic
    }
  }

  /// Resumes playback of the currently paused song.
  Future<void> resume() async {
    if (_playerState == PlayerState.paused && _currentSong != null) {
      print('Resuming playback');
      _playerState = PlayerState.playing;
      _playerStateController.add(_playerState);
      notifyListeners();
      // Actual resume logic
    }
  }

  /// Stops the currently playing song.
  Future<void> stop() async {
    print('Stopping playback');
    _currentSong = null;
    _playerState = PlayerState.stopped;
    _currentPosition = Duration.zero;
    _playerStateController.add(_playerState);
    _currentSongController.add(_currentSong);
    notifyListeners();
    // Actual stop logic
  }

  /// Seeks to the given [position] in the current song.
  Future<void> seek(Duration position) async {
    if (_currentSong != null && position >= Duration.zero && position <= _totalDuration) {
      print('Seeking to $position');
      _currentPosition = position;
      notifyListeners();
      // Actual seek logic
    }
  }

  // --- Queue Management ---

  /// Plays the next song in the current queue.
  Future<void> playNext() async {
    if (_currentQueue.isNotEmpty) {
      _currentQueueIndex++;
      if (_currentQueueIndex >= _currentQueue.length) {
        _currentQueueIndex = 0; // Loop back to the beginning or stop
      }
      if (_currentQueueIndex < _currentQueue.length) {
        await play(_currentQueue[_currentQueueIndex]);
      }
    }
  }

  /// Plays the previous song in the current queue.
  Future<void> playPrevious() async {
    if (_currentQueue.isNotEmpty) {
      _currentQueueIndex--;
      if (_currentQueueIndex < 0) {
        _currentQueueIndex = _currentQueue.length - 1; // Loop back to the end or stop
      }
      if (_currentQueueIndex >= 0) {
        await play(_currentQueue[_currentQueueIndex]);
      }
    }
  }

  /// Loads a playlist into the queue and starts playing the first song.
  Future<void> playPlaylist(Playlist playlist) async {
    List<Song> songs = await getSongsFromPlaylist(playlist); // Assuming this method is implemented
    if (songs.isNotEmpty) {
      _currentQueue.clear();
      _currentQueue.addAll(songs);
      _currentQueueIndex = 0;
      await play(_currentQueue[_currentQueueIndex]);
    }
  }


  // --- Playlist Management Methods ---

  /// Creates a new playlist with the given [name].
  /// Returns the created [Playlist].
  Future<Playlist> createPlaylist(String name) async {
    final newPlaylist = Playlist(name: name, id: DateTime.now().millisecondsSinceEpoch.toString(), songIds: []);
    _playlists.add(newPlaylist);
    print('Playlist "$name" created.');
    notifyListeners();
    return newPlaylist;
  }

  /// Adds a [song] to the given [playlist].
  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    final targetPlaylist = _playlists.firstWhere((p) => p.id == playlist.id, orElse: () => throw Exception("Playlist not found"));
    // In a real app, you'd store song IDs, not full Song objects, if playlists are persistent.
    // For this example, we'll assume songIds in Playlist model can store actual song filePaths or unique IDs.
    // Let's assume song.filePath is a unique identifier for now.
    if (!targetPlaylist.songIds.contains(song.filePath)) {
      // Create a new list for songIds to ensure immutability of Playlist instances if they were records/immutable
      final updatedSongIds = List<String>.from(targetPlaylist.songIds)..add(song.filePath);
      final updatedPlaylist = Playlist(name: targetPlaylist.name, id: targetPlaylist.id, songIds: updatedSongIds);
      
      final index = _playlists.indexOf(targetPlaylist);
      _playlists[index] = updatedPlaylist;

      print('Song "${song.title}" added to playlist "${playlist.name}".');
      notifyListeners();
    } else {
      print('Song "${song.title}" is already in playlist "${playlist.name}".');
    }
  }

  /// Removes a [song] from the given [playlist].
  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    final targetPlaylist = _playlists.firstWhere((p) => p.id == playlist.id, orElse: () => throw Exception("Playlist not found"));
    
    // Create a new list for songIds, removing the specified song's identifier
    final updatedSongIds = List<String>.from(targetPlaylist.songIds)..remove(song.filePath);
    final updatedPlaylist = Playlist(name: targetPlaylist.name, id: targetPlaylist.id, songIds: updatedSongIds);
    
    final index = _playlists.indexOf(targetPlaylist);
    _playlists[index] = updatedPlaylist;
    
    print('Song "${song.title}" removed from playlist "${playlist.name}".');
    notifyListeners();
  }

  /// Returns a list of all created playlists.
  Future<List<Playlist>> getPlaylists() async {
    return List.unmodifiable(_playlists);
  }

  /// Returns a list of songs for the given [playlist].
  /// This is a stub and would need a way to resolve song IDs to Song objects in a real app.
  Future<List<Song>> getSongsFromPlaylist(Playlist playlist) async {
    final targetPlaylist = _playlists.firstWhere((p) => p.id == playlist.id, orElse: () => throw Exception("Playlist not found"));
    // This is a simplified version. In a real app, you'd have a list of all available songs
    // and filter them based on the songIds in the playlist.
    // For now, let's assume we need to find songs in _currentQueue that match songIds.
    // This is not ideal as _currentQueue might not represent all songs.
    // A better approach would be to have a central song repository.
    print('Getting songs for playlist "${playlist.name}". This is a stub implementation.');
    
    // Placeholder: returning an empty list or songs from _currentQueue that match ids
    // This part needs a proper implementation strategy for fetching songs by ID.
    // For now, we'll just return an empty list to fulfill the interface.
    List<Song> songsInPlaylist = [];
    // Example: If you had a master list of all songs:
    // List<Song> allSongs = ... ;
    // songsInPlaylist = allSongs.where((song) => targetPlaylist.songIds.contains(song.filePath)).toList();
    
    // Simulating finding songs from a hypothetical allSongs list that matches what's in the queue
    // This is highly dependent on how songs are loaded and identified.
    // For the purpose of this exercise, if a song was added to a playlist, its ID (filePath) is in songIds.
    // We need a way to map these IDs back to Song objects.
    // Let's assume `_currentQueue` might contain some of these songs, or we have another source.
    // This part is complex without a full app structure for song management.
    // Returning an empty list as a placeholder.
    return songsInPlaylist;
  }

  /// Disposes the service and closes stream controllers.
  @override
  void dispose() {
    _playerStateController.close();
    _currentSongController.close();
    super.dispose();
  }
}
