import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlas/pages/APIcalls.dart';

class ChooseSport extends StatefulWidget {
  const ChooseSport({super.key});

  @override
  State<ChooseSport> createState() => _ChooseSportState();
}

class _ChooseSportState extends State<ChooseSport> {
  String? token;
  String? error;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
  }

  Future<Map> getSportsFromApi() async {
    try {
      return await getSports();
    } catch (e) {
      print(e);
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    List? _selectedSport;
    int? _selectedExp;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[800],
        title: Text('Sport'),
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (error != null) Text(error!),
            FutureBuilder<Map>(
                future: getSportsFromApi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If data is still loading, show a progress indicator
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    // If there's an error or no data, show an error message
                    return Center(child: Text('Error fetching data'));
                  } else {
                    // If data is available, display the DropdownButton
                    List sports = snapshot.data!['sportList'];
                    // nastaveni defaultniho sportu
                    _selectedSport = sports[0];
                    return DropdownButton<dynamic>(
                      items: sports.map((sport) {
                        return DropdownMenuItem<dynamic>(
                          value: sport,
                          child: Text(sport[1]),
                        );
                      }).toList(),
                      value: _selectedSport,
                      onChanged: (selectedSport) {
                        // Handle the selected sport here
                        // For example, you can update the state with the selectedSport
                        setState(() {
                          _selectedSport = selectedSport;
                        });
                      },
                    );
                  }
                }),
            FutureBuilder<Map>(
                future: getSportsFromApi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If data is still loading, show a progress indicator
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    // If there's an error or no data, show an error message
                    return Center(child: Text('Error fetching data'));
                  } else {
                    // If data is available, display the DropdownButton
                    List sports = snapshot.data!['zkusenostiList'];
                    // nastaveni defaultniho sportu
                    _selectedExp = sports[0][0];
                    return DropdownButton<dynamic>(
                      items: sports.map((sport) {
                        return DropdownMenuItem<dynamic>(
                          value: sport[0],
                          child: Text(sport[1]),
                        );
                      }).toList(),
                      value: _selectedExp,
                      onChanged: (selectedExp) {
                        // Handle the selected sport here
                        // For example, you can update the state with the selectedSport
                        setState(() {
                          _selectedExp = selectedExp[0];
                        });
                      },
                    );
                  }
                }),
            SizedBox(width: double.infinity),
            ElevatedButton(
                onPressed: () async {
                  if (_selectedSport != null) {
                    try {
                      Map res = await setSport(token!, _selectedSport![0],
                          _selectedExp!, _selectedSport![1]);

                      switch (res['status_code']) {
                        case 200:
                          context.goNamed('root');
                          break;
                        case 401:
                          context.goNamed('login');
                          break;
                        default:
                          error = res['error'];
                      }
                    } catch (e) {
                      error = 'Funkce je momentálně nedostupná';
                    }
                  }
                },
                child: Text('Vybrat sport'))
          ],
        ),
      ),
    );
  }
}
