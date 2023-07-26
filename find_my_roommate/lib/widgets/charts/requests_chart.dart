import 'package:find_my_roommate/providers/requests_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/request.dart';

class RequestChart extends StatefulWidget {
  final String ownerId;

  const RequestChart(this.ownerId, {super.key});

  @override
  State<RequestChart> createState() => _RequestChartState();
}

class _RequestChartState extends State<RequestChart> {
  List<Request> _requests = [];
  List<ChartDataPoint> _chartData = [];

  List<ChartDataPoint> countRequestsByDate(List<Request> requests) {
    Map<DateTime, int> counts = {};

    for (var request in requests) {
      DateTime date = request.sentDate.toDate().toUtc();
      date = DateTime(date.year, date.month, date.day);

      counts[date] = (counts[date] ?? 0) + 1;
    }

    List<ChartDataPoint> chartData = [];
    counts.forEach((date, value) {
      chartData.add(ChartDataPoint(date: date, value: value));
    });
    chartData.sort((a, b) => a.date.compareTo(b.date));

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<RequestsProvider>(context)
            .findRequestsByOwnerId(widget.ownerId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred while getting requests!'),
            );
          } else {
            _requests = snapshot.data as List<Request>;
            _chartData = countRequestsByDate(_requests);

            return Container(
              margin: const EdgeInsets.all(16),
              child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true, // Enable pinch zooming
                  enablePanning: true, // Enable panning
                ),
                plotAreaBackgroundColor:
                    const Color.fromARGB(255, 247, 247, 247),

                title: auth.FirebaseAuth.instance.currentUser!.uid ==
                        widget.ownerId
                    ? ChartTitle(text: 'My requests analysis')
                    : ChartTitle(text: 'Requests analysis'),
                crosshairBehavior: CrosshairBehavior(enable: true),
                enableAxisAnimation: true,

                primaryXAxis: DateTimeCategoryAxis(
                  labelIntersectAction: AxisLabelIntersectAction.multipleRows,
                  isVisible: true,
                  dateFormat:
                      DateFormat.MMMd(), // Format to display only the day
                  labelPlacement: LabelPlacement.onTicks,
                  edgeLabelPlacement: EdgeLabelPlacement.none,
                  interval: 1,
                  intervalType: DateTimeIntervalType.days,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryYAxis: NumericAxis(),
                series: <LineSeries<ChartDataPoint, DateTime>>[
                  LineSeries<ChartDataPoint, DateTime>(
                      name: 'Requests',
                      enableTooltip: true,
                      markerSettings: const MarkerSettings(
                          isVisible: true,
                          height: 6,
                          width: 6,
                          shape: DataMarkerType.circle,
                          borderWidth: 3,
                          borderColor: Color.fromARGB(255, 73, 41, 254)),
                      dataSource: _chartData,
                      xValueMapper: (point, _) => point.date,
                      yValueMapper: (point, _) => point.value,
                      color: const Color.fromARGB(255, 255, 211, 81),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true)),
                ],
              ),
            );
          }
        });
  }
}

class ChartDataPoint {
  final DateTime date;
  final int value;

  ChartDataPoint({required this.date, required this.value});
}
