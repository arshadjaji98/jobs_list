import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestApis extends StatefulWidget {
  const TestApis({super.key});

  @override
  State<TestApis> createState() => _TestApisState();
}

class _TestApisState extends State<TestApis> {
  var data;
  Future<void> getUserApi() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body.toString());
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Api Course'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: getUserApi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                } else {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black)),
                          child: Column(
                            children: [
                              ReusbaleRow(
                                title: 'name',
                                value: data[index]['name'].toString(),
                              ),
                              Divider(),
                              ReusbaleRow(
                                title: 'Username',
                                value: data[index]['username'].toString(),
                              ),
                              Divider(),
                              ReusbaleRow(
                                title: 'address',
                                value:
                                    data[index]['address']['street'].toString(),
                              ),
                              Divider(),
                              ReusbaleRow(
                                title: 'Lat',
                                value: data[index]['address']['geo']['lat']
                                    .toString(),
                              ),
                              Divider(),
                              ReusbaleRow(
                                title: 'Lat',
                                value: data[index]['address']['geo']['lng']
                                    .toString(),
                              ),
                            ],
                          ),
                        );
                      });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ReusbaleRow extends StatelessWidget {
  String title, value;
  ReusbaleRow({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}
