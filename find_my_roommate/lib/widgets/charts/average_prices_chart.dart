import 'package:find_my_roommate/providers/apartments_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AveragePrices extends StatefulWidget {
  const AveragePrices({super.key});

  @override
  State<AveragePrices> createState() => _AveragePricesState();
}

class _AveragePricesState extends State<AveragePrices> {
  late List<AveragePricePerLocationData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late List<AveragePricePerLocationData> _maxPricesData;
  late List<AveragePricePerLocationData> _minPricesData;
  late List<AveragePricePerLocationData> _avgPricesData;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  List<AveragePricePerLocationData> _getChartData(
      Map<String, Map<String, dynamic>> data) {
    var chartData = data.entries
        .map((e) => AveragePricePerLocationData(e.key, e.value['averagePrice']))
        .toList();

    chartData.sort((a, b) => a.averagePrice.compareTo(b.averagePrice));

    return chartData;
  }

  Widget _buildChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SfCartesianChart(
        enableSideBySideSeriesPlacement: false,
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
          alignment: ChartAlignment.center,
          toggleSeriesVisibility: true,
        ),
        tooltipBehavior: _tooltipBehavior,
        title: ChartTitle(text: 'Average Prices by Region'),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.multipleRows,
        ),
        primaryYAxis: NumericAxis(),
        series: <ChartSeries>[
          ColumnSeries<AveragePricePerLocationData, String>(
            name: 'Lowest Prices',
            color: const Color.fromARGB(188, 255, 212, 82),
            dataSource: _minPricesData,
            xValueMapper: (AveragePricePerLocationData data, _) =>
                data.location,
            yValueMapper: (AveragePricePerLocationData data, _) =>
                data.averagePrice,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true, labelPosition: ChartDataLabelPosition.outside),
            enableTooltip: true,
          ),
          ColumnSeries<AveragePricePerLocationData, String>(
            name: 'Greatest Prices',
            dataSource: _maxPricesData,
            color: const Color.fromARGB(190, 142, 114, 206),
            xValueMapper: (data, _) => data.location,
            yValueMapper: (data, _) => data.averagePrice,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true, labelPosition: ChartDataLabelPosition.outside),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ApartmentsProvider>(context)
          .calculateAveragePricesByCities(),
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
          final data = snapshot.data as Map<String, Map<String, dynamic>>;
          _chartData = _getChartData(data);

          if (_chartData.length % 2 == 1) {
            _minPricesData = _chartData.sublist(0, _chartData.length ~/ 2 + 1);
          } else {
            _minPricesData = _chartData.sublist(0, _chartData.length ~/ 2);
          }

          _maxPricesData =
              _chartData.sublist(_chartData.length - _chartData.length ~/ 2);

          //if chartData has more or equal to 6 elements take in minPrices only the first 3 and in the maxPrices the last 2
          if (_chartData.length >= 6) {
            _minPricesData = _chartData.sublist(0, 3);
            _maxPricesData =
                _chartData.sublist(_chartData.length - 2, _chartData.length);
          }
          return _buildChart();
        }
      },
    );
  }
}

class AveragePricePerLocationData {
  final String location;
  final double averagePrice;

  const AveragePricePerLocationData(this.location, this.averagePrice);
}
