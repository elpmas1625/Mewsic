class Song {
  final String title;
  final String artist; // Or artistId
  final String album;  // Or albumId
  final Duration duration;
  final String filePath;
  final String? coverArtUrl; // Added nullable coverArtUrl

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.coverArtUrl, // Added to constructor as optional
  });
}
