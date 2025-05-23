import 'package:flutter_test/flutter_test.dart';
import 'package:mewsic/lib/music_app/models/artist.dart'; // Adjust import path

void main() {
  group('Artist Model', () {
    test('Artist can be instantiated with all properties', () {
      const artist = Artist(
        id: 'a1',
        name: 'The Great Artist',
      );

      expect(artist.id, 'a1');
      expect(artist.name, 'The Great Artist');
    });

    test('Artist instances with same properties should be equal (const constructor)', () {
      const artist1 = Artist(
        id: 'a1',
        name: 'The Great Artist',
      );
      const artist2 = Artist(
        id: 'a1',
        name: 'The Great Artist',
      );
      // For const constructors with final fields of primitive types,
      // identical instances are expected.
      expect(artist1, artist2);
    });

    test('Artist instances with different properties should not be equal', () {
      const artist1 = Artist(
        id: 'a1',
        name: 'Artist One',
      );
      const artist2 = Artist(
        id: 'a2', // Different ID
        name: 'Artist Two', // Different Name
      );
      expect(artist1 == artist2, isFalse);
    });
  });
}
