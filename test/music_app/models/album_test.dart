import 'package:flutter_test/flutter_test.dart';
import 'package:mewsic/lib/music_app/models/album.dart'; // Adjust import path

void main() {
  group('Album Model', () {
    test('Album can be instantiated with all properties', () {
      const album = Album(
        id: 'al1',
        title: 'Greatest Hits',
        artist: 'Various Artists', // Or artistId
        coverArtUrl: 'http://example.com/album_cover.jpg',
      );

      expect(album.id, 'al1');
      expect(album.title, 'Greatest Hits');
      expect(album.artist, 'Various Artists');
      expect(album.coverArtUrl, 'http://example.com/album_cover.jpg');
    });

    test('Album instances with same properties should be equal (const constructor)', () {
      const album1 = Album(
        id: 'al1',
        title: 'Greatest Hits',
        artist: 'Various Artists',
        coverArtUrl: 'http://example.com/album_cover.jpg',
      );
      const album2 = Album(
        id: 'al1',
        title: 'Greatest Hits',
        artist: 'Various Artists',
        coverArtUrl: 'http://example.com/album_cover.jpg',
      );
      // For const constructors with final fields of primitive types,
      // identical instances are expected.
      expect(album1, album2);
    });

    test('Album instances with different properties should not be equal', () {
      const album1 = Album(
        id: 'al1',
        title: 'Album One',
        artist: 'Artist A',
      );
      const album2 = Album(
        id: 'al2', // Different ID
        title: 'Album Two', // Different Title
        artist: 'Artist B', // Different Artist
      );
      expect(album1 == album2, isFalse);
    });
    
    test('Album can be instantiated with nullable coverArtUrl as null', () {
      const album = Album(
        id: 'al3',
        title: 'No Cover Album',
        artist: 'Artist C',
        coverArtUrl: null, // Explicitly null
      );
      expect(album.coverArtUrl, isNull);
    });

    test('Album can be instantiated without coverArtUrl (defaults to null)', () {
      // This assumes the constructor in Album.dart makes coverArtUrl optional
      // and it defaults to null if not provided.
      const album = Album(
        id: 'al4',
        title: 'Another No Cover Album',
        artist: 'Artist D',
        // coverArtUrl is omitted
      );
      expect(album.coverArtUrl, isNull); // Default value for nullable String? is null.
    });
  });
}
