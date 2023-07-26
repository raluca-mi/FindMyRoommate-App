import 'package:find_my_roommate/widgets/charts/apartments_distribution_chart.dart';
import 'package:find_my_roommate/widgets/charts/average_prices_chart.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import '../../widgets/charts/requests_chart.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = Constants.statisticsScreenRoute;
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.statisticsAppBarText),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RequestChart(auth.FirebaseAuth.instance.currentUser!.uid),
            const Divider(),
            const AveragePrices(),
            const Divider(),
            const ApartmentsDistribution(),
          ],
        ),
      ),
    );
  }
}
