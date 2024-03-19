import 'package:flutter/material.dart';

class Attributes extends StatefulWidget {
  String token;
  List attributes;
  Attributes({required this.token, required this.attributes});

  @override
  State<Attributes> createState() => _AttributesState();
}

class _AttributesState extends State<Attributes> {
  Widget printAttributes() {
    return SingleChildScrollView(
      child: Column(
        children: widget.attributes.map((attribute) {
          return Card(
            child: InkWell(
              onTap: () {},
              child: SizedBox(
                width: 300,
                height: 50,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          attribute['nazev'].toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          attribute['hodnota'].toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return printAttributes();
  }
}
