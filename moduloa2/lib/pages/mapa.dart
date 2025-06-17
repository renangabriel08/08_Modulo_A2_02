import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moduloa2/controllers/app.dart';
import 'package:moduloa2/styles/cores.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  LatLng pos = LatLng(0, 0);

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  bool loading = true;

  startApp() async {
    Position position = await determinePosition();
    pos = LatLng(position.latitude, position.longitude);
    await App.getEscolas();
    await App.validarToken(context);

    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              width: width,
              height: height,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: pos, zoom: 17),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                markers: {
                  for (var escola in App.escolas)
                    Marker(
                      markerId: MarkerId(escola['id'].toString()),
                      position: LatLng(escola['latitude'], escola['longitude']),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  escola['nome'],
                                  style: TextStyle(
                                    color: Cores.azulClaro,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(height: 16),
                                Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      base64Decode(
                                        escola['image']
                                            .toString()
                                            .split(',')
                                            .last,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Distância: ${Geolocator.distanceBetween(pos.latitude, pos.longitude, escola['latitude'], escola['longitude']) < 1000 ? '${(Geolocator.distanceBetween(pos.latitude, pos.longitude, escola['latitude'], escola['longitude'])).toStringAsFixed(2)}m' : '${((Geolocator.distanceBetween(pos.latitude, pos.longitude, escola['latitude'], escola['longitude'])) / 1000).toStringAsFixed(2)}km'}',
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (
                                          int i = 0;
                                          i < escola['avaliacao'].round();
                                          i++
                                        )
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        if (escola['avaliacao'].round() < 5)
                                          for (
                                            int e = escola['avaliacao'].round();
                                            e < 5;
                                            e++
                                          )
                                            Icon(
                                              Icons.star_border,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Fechar'),
                            ),

                            TextButton(
                              onPressed: () {
                                App.escola = escola;
                                Navigator.pushNamed(context, '/detalhes');
                              },
                              child: Text('Detalhes da Escola'),
                            ),
                          ],
                        ),
                      ),
                    ),
                },
              ),
            ),
    );
  }
}
