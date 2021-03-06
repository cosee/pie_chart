import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartPainter extends CustomPainter {
  List<Paint> _paintList = [];
  List<double> _subParts;
  double _total = 0;
  double _totalAngle = math.pi * 2;

  final TextStyle chartValueStyle;
  final Color chartValueBackgroundColor;
  final double initialAngle;
  final bool showValuesInPercentage;
  final bool showChartValues;
  final bool showChartValuesOutside;
  final int decimalPlaces;
  final bool showChartValueLabel;
  final ChartType chartType;
  final TextSpan centerText;
  final Function formatChartValues;

  double _prevAngle = 0;

  PieChartPainter(
    double angleFactor,
    this.showChartValuesOutside,
    List<Color> colorList, {
    double strokeWidth,
    this.showChartValues,
    this.chartValueStyle,
    this.chartValueBackgroundColor,
    List<double> values,
    this.initialAngle,
    this.showValuesInPercentage,
    this.decimalPlaces,
    this.showChartValueLabel,
    this.chartType,
    this.centerText,
    this.formatChartValues,
  }) {
    for (int i = 0; i < values.length; i++) {
      final paint = Paint()..color = getColor(colorList, i);
      if (chartType == ChartType.ring) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth;
      }
      _paintList.add(paint);
    }
    _totalAngle = angleFactor * math.pi * 2;
    _subParts = values;
    _total = values.fold(0, (v1, v2) => v1 + v2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final minDimension = size.width < size.height ? size.width : size.height;
    _prevAngle = this.initialAngle;
    for (int i = 0; i < _subParts.length; i++) {
      canvas.drawArc(
        new Rect.fromLTWH(0.0, 0.0, minDimension, size.height),
        _prevAngle,
        (((_totalAngle) / _total) * _subParts[i]),
        chartType == ChartType.disc ? true : false,
        _paintList[i],
      );
      if (showChartValues) {
        _drawChartValue(canvas, minDimension, _subParts[i]);
      }
      _prevAngle = _prevAngle + (((_totalAngle) / _total) * _subParts[i]);
    }

    if (centerText != null) {
      _drawCenterText(canvas, minDimension);
    }
  }

  void _drawChartValue(Canvas canvas, double sideLength, double dataValue) {
    final radius = showChartValuesOutside ? sideLength * 0.5 : sideLength / 3;
    final x = (radius) *
        math.cos(_prevAngle + ((((_totalAngle) / _total) * dataValue) / 2));
    final y = (radius) *
        math.sin(_prevAngle + ((((_totalAngle) / _total) * dataValue) / 2));
    if (dataValue.toInt() != 0) {
      final value = formatChartValues != null
          ? formatChartValues(dataValue)
          : dataValue.toStringAsFixed(decimalPlaces);
      final String name = showValuesInPercentage
          ? "${((dataValue * 100) / _total).toStringAsFixed(decimalPlaces)}%"
          : value;

      final nameSpan = TextSpan(
        style: chartValueStyle,
        text: name,
      );
      _drawName(canvas, nameSpan, x, y, sideLength);
    }
  }

  void _drawCenterText(Canvas canvas, double side) {
    _drawName(canvas, centerText, 0, 0, side);
  }

  void _drawName(
    Canvas canvas,
    TextSpan textSpan,
    double x,
    double y,
    double side,
  ) {
    TextPainter tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    if (showChartValueLabel) {
      //Draw text background box
      final rect = Rect.fromCenter(
        center: Offset((side / 2 + x), (side / 2 + y)),
        width: tp.width + 6,
        height: tp.height + 4,
      );
      final rRect = RRect.fromRectAndRadius(rect, Radius.circular(4));
      final paint = Paint()
        ..color = chartValueBackgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rRect, paint);
    }
    //Finally paint the text above box
    tp.paint(
      canvas,
      new Offset(
        (side / 2 + x) - (tp.width / 2),
        (side / 2 + y) - (tp.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) =>
      oldDelegate._totalAngle != _totalAngle;
}
