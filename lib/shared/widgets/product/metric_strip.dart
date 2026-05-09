import 'package:flutter/material.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_tile.dart';

class MetricStrip extends StatelessWidget {
  const MetricStrip({
    required this.metrics,
    this.spacing = 8,
    this.runSpacing = 8,
    this.tileWidth = 124,
    this.tileEmphasis = MetricTileEmphasis.standard,
    this.tileBackgroundColor,
    this.tileBorderColor,
    super.key,
  });

  final List<MetricTileData> metrics;
  final double spacing;
  final double runSpacing;
  final double? tileWidth;
  final MetricTileEmphasis tileEmphasis;
  final Color? tileBackgroundColor;
  final Color? tileBorderColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final metric in metrics)
          MetricTile(
            value: metric.value,
            label: metric.label,
            valueKey: metric.valueKey,
            width: tileWidth,
            emphasis: tileEmphasis,
            backgroundColor: tileBackgroundColor,
            borderColor: tileBorderColor,
          ),
      ],
    );
  }
}
