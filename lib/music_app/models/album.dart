class Album {
  final String title;
  final String artist; // Or artistId
  final String id;
  final String? coverArtUrl;

  const Album({
    required this.title,
    required this.artist,
    required this.id,
    this.coverArtUrl,
  });
}
