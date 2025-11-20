import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UrlTileProvider implements TileProvider {
  final String urlTemplate;

  UrlTileProvider({required this.urlTemplate});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final url = urlTemplate
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{z}', (zoom ?? 0).toString());

    try {
      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      final bytes = await consolidateHttpClientResponseBytes(response);

      return Tile(256, 256, bytes);
    } catch (e) {
      return Tile(256, 256, Uint8List(0));
    }
  }
}
