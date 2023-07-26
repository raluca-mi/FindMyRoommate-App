import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../providers/apartments_provider.dart';

class ApartmentsDistribution extends StatefulWidget {
  const ApartmentsDistribution({super.key});

  @override
  State<ApartmentsDistribution> createState() => _ApartmentsDistributionState();
}

class _ApartmentsDistributionState extends State<ApartmentsDistribution> {
  late List<ApartmentsDistributionData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  List<ApartmentsDistributionData> _getChartData(Map<String, int> data) {
    var chartData = data.entries
        .map((e) => ApartmentsDistributionData(e.key, e.value))
        .toList();

    chartData.sort((a, b) => a.count.compareTo(b.count));
    //get the first 10 elements if there are more than 10
    if (chartData.length > 5) {
      chartData = chartData.sublist(0, 5);
    }

    return chartData;
  }

  Widget _buildChart() {
    return Container(
        margin: const EdgeInsets.all(16),
        child: SfCircularChart(
          tooltipBehavior: _tooltipBehavior,
          title: ChartTitle(text: 'Apartments Distribution by Region'),
          legend: Legend(
              isVisible: true, overflowMode: LegendItemOverflowMode.scroll),
          series: <CircularSeries>[
            PieSeries<ApartmentsDistributionData, String>(
              dataSource: _chartData,
              xValueMapper: (ApartmentsDistributionData data, _) =>
                  data.locality,
              yValueMapper: (ApartmentsDistributionData data, _) => data.count,
              dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside),
              enableTooltip: true,
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<ApartmentsProvider>(context).countApartmentsByCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred while getting requests!'),
          );
        } else {
          final data = snapshot.data as Map<String, int>;
          _chartData = _getChartData(data);

          return _buildChart();
        }
      },
    );
  }
}

class ApartmentsDistributionData {
  final String locality;
  final int count;

  const ApartmentsDistributionData(this.locality, this.count);
}
