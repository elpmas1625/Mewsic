import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/music_player_service.dart';
import '../../models/song.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final musicService = context.watch<MusicPlayerService>();
    // Access state directly from MusicPlayerService, assuming it's updated via notifyListeners()
    final Song? actualCurrentSong = musicService.currentSong;
    final PlayerState actualPlayerState = musicService.playerState;
    final Duration currentPosition = musicService.currentPosition;
    final Duration totalDuration = musicService.totalDuration;

    // Calculate slider value
    double sliderValue = 0.0;
    if (totalDuration.inMilliseconds > 0) {
      sliderValue = currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    }
    // Ensure sliderValue is within 0.0 and 1.0
    sliderValue = sliderValue.clamp(0.0, 1.0);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Album Art
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: actualCurrentSong?.coverArtUrl != null // Assuming Song model has coverArtUrl
                  ? Image.network(actualCurrentSong!.coverArtUrl!) // Or Image.asset/Image.file
                  : const Icon(Icons.music_note, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Song Title
            Text(
              actualCurrentSong?.title ?? 'No song playing',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Artist Name
            Text(
              actualCurrentSong?.artist ?? 'Unknown Artist',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Album Name
            Text(
              actualCurrentSong?.album ?? 'Unknown Album',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Track Progress Slider
            Slider(
              value: sliderValue,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                if (actualCurrentSong != null) {
                  final newPosition = Duration(milliseconds: (value * totalDuration.inMilliseconds).round());
                  musicService.seek(newPosition);
                }
              },
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(currentPosition)),
                  Text(_formatDuration(totalDuration)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36,
                  onPressed: () {
                    musicService.playPrevious();
                  },
                ),
                IconButton(
                  icon: Icon(
                    actualPlayerState == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                  iconSize: 48,
                  onPressed: () {
                    if (actualCurrentSong != null) {
                      if (actualPlayerState == PlayerState.playing) {
                        musicService.pause();
                      } else if (actualPlayerState == PlayerState.paused) {
                        musicService.resume();
                      } else {
                        // If stopped or completed, play the current song again (or first song if queue exists)
                        musicService.play(actualCurrentSong); 
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36,
                  onPressed: () {
                    musicService.playNext();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds".startsWith("00:") 
           ? "$twoDigitMinutes:$twoDigitSeconds" 
           : "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

}

