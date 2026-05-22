import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/shared/widgets/morpheus_orb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Generate Morpheus orb launcher icon', () async {
    const size = 1024.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const ui.Rect.fromLTWH(0, 0, size, size),
    );

    // Fill the full canvas to avoid transparent margins on launcher icons.
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, size, size),
      ui.Paint()..color = const ui.Color(0xFF0E1020),
    );

    // Enlarge the orb so it occupies more visible area inside masked icons.
    canvas.save();
    canvas.translate(size * 0.5, size * 0.5);
    canvas.scale(1.28, 1.28);
    canvas.translate(-size * 0.5, -size * 0.5);

    const painter = MorpheusOrbPainter(0.8, showBlueGlow: true);
    painter.paint(canvas, const ui.Size(size, size));
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    expect(pngBytes, isNotNull);

    final outputDir = Directory('assets/icons')..createSync(recursive: true);
    final outputFile = File('${outputDir.path}/morpheus_orb_launcher.png');
    await outputFile.writeAsBytes(pngBytes!.buffer.asUint8List(), flush: true);
  });
}
