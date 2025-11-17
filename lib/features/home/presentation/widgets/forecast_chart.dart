import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/features/home/data/weather_model.dart';

class ForecastChart extends StatelessWidget {
  const ForecastChart({super.key, required this.items});

  final List<WeatherModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) {
      return const SizedBox.shrink();
    }
    final temps = items.map((e) => e.temp).toList();
    final minTemp = temps.reduce(min);
    final maxTemp = temps.reduce(max);
    final range = (maxTemp - minTemp).abs() < 0.01 ? 1.0 : (maxTemp - minTemp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _ForecastChartPainter(
              normalizedValues: temps
                  .map((t) => (t - minTemp) / range)
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
              .map(
                (e) => Expanded(
                  child: Text(
                    DateFormat('E').format(e.dateTime),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ForecastChartPainter extends CustomPainter {
  _ForecastChartPainter({required this.normalizedValues});

  final List<double> normalizedValues;

  @override
  void paint(Canvas canvas, Size size) {
    if (normalizedValues.isEmpty) return;
    final path = Path();
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo.withValues(alpha: 0.4),
        Colors.indigo.withValues(alpha: 0.05),
      ],
    );
    final linePaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = Colors.orange.shade400;

    for (var i = 0; i < normalizedValues.length; i++) {
      final dx = (i / (normalizedValues.length - 1)) * size.width;
      final dy = size.height - (normalizedValues[i] * size.height);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // draw points
    for (var i = 0; i < normalizedValues.length; i++) {
      final dx = (i / (normalizedValues.length - 1)) * size.width;
      final dy = size.height - (normalizedValues[i] * size.height);
      canvas.drawCircle(Offset(dx, dy), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) =>
      oldDelegate.normalizedValues != normalizedValues;
}
