import 'package:flutter_test/flutter_test.dart';
import 'package:mewsic/lib/music_app/models/song.dart'; // Adjust import path as necessary

void main() {
  group('Song Model', () {
    test('Song can be instantiated with all properties', () {
      const song = Song(
        title: 'Test Title',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song.mp3',
        coverArtUrl: 'http://example.com/cover.jpg',
      );

      expect(song.title, 'Test Title');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.duration, const Duration(minutes: 3, seconds: 30));
      expect(song.filePath, '/path/to/song.mp3');
      expect(song.coverArtUrl, 'http://example.com/cover.jpg');
    });

    test('Song instances with same properties should be equal (const constructor)', () {
      const song1 = Song(
        title: 'Test Title',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song.mp3',
        coverArtUrl: 'http://example.com/cover.jpg',
      );

      const song2 = Song(
        title: 'Test Title',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song.mp3',
        coverArtUrl: 'http://example.com/cover.jpg',
      );
      // For const constructors, identical instances are expected if all fields are identical.
      // If not using const or if any field is not final/primitive, this would require overriding == and hashCode.
      expect(song1, song2); 
    });

    test('Song instances with different properties should not be equal', () {
      const song1 = Song(
        title: 'Test Title 1',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song1.mp3',
      );

      const song2 = Song(
        title: 'Test Title 2', // Different title
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song2.mp3',
      );
      // This test relies on the default equality (identity) for classes that don't override ==.
      // Since these are const and have different values, they should not be identical.
      expect(song1 == song2, isFalse);
    });
     test('Song can be instantiated with nullable coverArtUrl as null', () {
      const song = Song(
        title: 'Test Title',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song.mp3',
        coverArtUrl: null, // Explicitly null
      );
      expect(song.coverArtUrl, isNull);
    });

    test('Song can be instantiated without coverArtUrl (defaults to null)', () {
      // This test assumes the constructor in Song.dart allows coverArtUrl to be optional
      // and defaults to null if not provided. This requires checking the Song model's constructor.
      // If the definition is `final String? coverArtUrl;` and it's an optional named parameter,
      // this is valid.
      const song = Song(
        title: 'Test Title',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3, seconds: 30),
        filePath: '/path/to/song.mp3',
        // coverArtUrl is omitted
      );
      expect(song.coverArtUrl, isNull); // Default value for nullable String? is null.
    });
  });
}
