import 'package:barkoduygulamasi/print.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {'title': 'Ülker Çikolata', 'price': 5, 'qty': 2},
    {'title': 'Çokoprens 300G', 'price': 7, 'qty': 5},
    {'title': 'Soğan Kuru Dökme', 'price': 2, 'qty': 2},
    {'title': 'Limon', 'price': 8, 'qty': 5},
    {'title': "Nuh'un Ankara Burgu Makarna 500G", 'price': 5, 'qty': 5},
  ];

  final f = NumberFormat("\TL ###,###.00", "en_US");

  @override
  Widget build(BuildContext context) {
    int _total = 0;
    _total = data.map((e) => e['price'] * e['qty']).reduce(
          (value, element) => value + element,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter - Thermal Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (c, i) {
                return ListTile(
                  title: Text(
                    data[i]['title'].toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${f.format(data[i]['price'])} x ${data[i]['qty']}",
                  ),
                  trailing: Text(
                    f.format(
                      data[i]['price'] * data[i]['qty'],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  "Total: ${f.format(_total)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 80,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrintPage(data),
                        ),
                      );
                    },
                    icon: Icon(Icons.print),
                    label: Text('Print'),
                    style: TextButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
