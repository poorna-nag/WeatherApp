import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class UrlTileProvider implements TileProvider {
  final String urlTemplate;
  final int tileSize;

  UrlTileProvider({required this.urlTemplate, this.tileSize = 256});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final zoomValue = zoom ?? 0;
    try {
      final url = urlTemplate
          .replaceAll('{x}', x.toString())
          .replaceAll('{y}', y.toString())
          .replaceAll('{z}', zoomValue.toString());

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final Uint8List bytes = res.bodyBytes;
        return Tile(tileSize, tileSize, bytes);
      }
      return TileProvider.noTile;
    } catch (e) {
      // On any error, skip the tile so the base map shows through.
      return TileProvider.noTile;
    }
  }
}
