import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/display_helper.dart';
import '../../helpers/constants.dart';
import '../../providers/requests_provider.dart';
import '../../widgets/requests/requesting_user_tile.dart';

class RequestsReceivedScreen extends StatelessWidget {
  static const routeName = Constants.requestsReceivedScreenRoute;
  const RequestsReceivedScreen({super.key});

  Future<void> _fetchRequestingReceived(BuildContext context) async {
    try {
      await Provider.of<RequestsProvider>(context, listen: false)
          .fetchReceivedRequests(auth.FirebaseAuth.instance.currentUser!.uid);
    } catch (error) {
      DisplayHelper.showErrorMessage(context,
          ' ${Constants.errorOccuredText}${Constants.fetchRequestsReceivedFailedText}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedContext = context;

    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 236, 239, 248),
      appBar: AppBar(
        title: const Text(Constants.requestsReceivedAppBarText),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchRequestingReceived(savedContext),
              child: FutureBuilder(
                future: _fetchRequestingReceived(savedContext),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.error != null) {
                    return Text(
                        '${Constants.errorOccuredText}: ${snapshot.error.toString()}');
                  } else {
                    return Consumer<RequestsProvider>(
                      builder: (ctx, requestsData, _) {
                        final receivedRequests = requestsData.receivedRequests;
                        if (receivedRequests.isEmpty) {
                          return const Center(
                              child: Text(Constants.noRequestsReceivedText));
                        }
                        return ListView.builder(
                          itemCount: receivedRequests.length,
                          itemBuilder: (ctx, index) =>
                              ChangeNotifierProvider.value(
                            value: receivedRequests[index],
                            child: RequestingUserTile(receivedRequests[index]),
                          ),
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
