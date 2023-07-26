import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../models/apartment.dart';
import '../../screens/apartments/apartment_details_screen.dart';

class ApartmentTile extends StatelessWidget {
  const ApartmentTile({super.key});

  @override
  Widget build(BuildContext context) {
    final apartment = Provider.of<Apartment>(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ApartmentDetailsScreen.routeName,
            arguments: {'apartment': apartment, 'requestedMode': false});
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        margin: const EdgeInsets.fromLTRB(22, 15, 22, 15),
        child: Column(children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: apartment.imageUrl.isEmpty
                    ? Image.asset(
                        Constants.apartmentPlaceholderPath,
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        apartment.imageUrl[0],
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  color: const Color.fromARGB(137, 77, 77, 78),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Text(
                    apartment.title,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      //if location is longer than 10 characters, it will be shown with ellipsis
                      Text(apartment.address.length > 10
                          ? '${apartment.address.substring(0, 10)}...'
                          : apartment.address)
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.euro,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${apartment.price}/month')
                    ],
                  ),
                ],
              )),
        ]),
      ),
    );
  }
}
