class Song {
  final String title;
  final String artist; // Or artistId
  final String album;  // Or albumId
  final Duration duration;
  final String filePath;

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
  });
}
