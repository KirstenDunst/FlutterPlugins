/*
 * @Author: Cao Shixin
 * @Date: 2020-04-23 00:25:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-03-07 13:46:48
 * @Description: 
 */
import 'package:flutter/material.dart';

class ListViewDSL extends StatefulWidget {
  const ListViewDSL({super.key});

  @override
  State<ListViewDSL> createState() => _ListViewDSLState();
}

class _ListViewDSLState extends State<ListViewDSL> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'ListViewDSL',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            color: Colors.lightBlue.shade300,
            height: 45,
            child: Text('Hellow World',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        },
        itemCount: 50,
      ),
    );
  }
}
