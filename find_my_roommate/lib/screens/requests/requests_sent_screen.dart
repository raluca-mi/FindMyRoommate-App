import 'package:find_my_roommate/helpers/display_helper.dart';
import 'package:find_my_roommate/providers/requests_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../models/request.dart';
import '../../widgets/requests/requested_apartment_tile.dart';

class RequestsSentScreen extends StatelessWidget {
  static const routeName = Constants.requestsSentScreenRoute;
  const RequestsSentScreen({super.key});

  Future<void> _fetchRequestsSent(BuildContext context) async {
    try {
      await Provider.of<RequestsProvider>(context, listen: false)
          .fetchSentRequests(auth.FirebaseAuth.instance.currentUser!.uid);
    } catch (error) {
      DisplayHelper.showErrorMessage(
          context, ' ${Constants.errorOccuredText}${error.toString()}');
    }
  }

  Widget _buildSection(String sectionTitle, List<Request> requests) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
        color: _getSectionColor(sectionTitle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: requests[index],
              child: RequestedApartmentTile(
                sectionTitle,
                requests[index].apartmentId,
                requests[index].approved,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSectionColor(String sectionTitle) {
    switch (sectionTitle) {
      case 'Pending...':
        return Colors.yellow[100]!;
      case 'Approved':
        return Colors.green[100]!;
      case 'Declined':
        return Colors.red[100]!;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedContext = context;

    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 236, 239, 248),
      appBar: AppBar(
        title: const Text(Constants.requestsSentAppBarText),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchRequestsSent(savedContext),
              child: FutureBuilder(
                future: _fetchRequestsSent(savedContext),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.error != null) {
                    return Text(
                        '${Constants.errorOccuredText} : ${snapshot.error.toString()}');
                  } else {
                    return Consumer<RequestsProvider>(
                      builder: (ctx, requestsData, _) {
                        final requests = requestsData.sentRequests;
                        if (requests.isEmpty) {
                          return const Center(
                              child: Text(Constants.noRequestsSentText));
                        }
                        final pendingRequests = requests
                            .where((request) => request.approved == null)
                            .toList();
                        final approvedRequests = requests
                            .where((request) => request.approved == true)
                            .toList();
                        final declinedRequests = requests
                            .where((request) => request.approved == false)
                            .toList();

                        return ListView(
                          children: [
                            if (pendingRequests.isNotEmpty)
                              _buildSection(
                                'Pending...',
                                pendingRequests,
                              ),
                            if (approvedRequests.isNotEmpty)
                              _buildSection(
                                'Approved',
                                approvedRequests,
                              ),
                            if (declinedRequests.isNotEmpty)
                              _buildSection(
                                'Declined',
                                declinedRequests,
                              ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
