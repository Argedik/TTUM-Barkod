import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  PrintPage(this.data);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";
  final f = NumberFormat("TL ###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => {initPrinter()});
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
      (val) {
        print(val);
        print("absürt");
        if (!mounted) return;
        print("${_devices} device objesi");
        print("${val} device objesi");
        print("${val.reversed} device objesi");
        print("${val.first} device first");
        print("${_devices.reversed} yazıcı");
        print("${_devices.runtimeType} yazıcı tipi");
        print("${_devices} yazıcı tipi");
        print("absürt2");
        setState(() => {_devices = val});
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "Cihaz yok";
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: _devices.isEmpty
          ? Center(
              child: Text("yok"),
            )
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: Icon(Icons.print),
                  title:
                      Text("${_devices.isNotEmpty ? _devices[i].name : "yok"}"),
                  subtitle: Text(
                      "${_devices.isNotEmpty ? _devices[i].address : "yok"}"),
                  onTap: () {
                    _startPrint(_devices[i]);
                  },
                );
              },
            ),
    );
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    print("absadf");
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);


      Map<String, dynamic> config = Map();
      List<LineText> list = [];
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'A Title', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent left', weight: 0, align: LineText.ALIGN_LEFT,linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent right', align: LineText.ALIGN_RIGHT,linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_BARCODE, content: 'A12312112', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_QRCODE, content: 'qrcode i', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));

      ByteData data = await rootBundle.load("assets/store.png");
      List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      String base64Image = base64Encode(imageBytes);
      // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));
      await bluetoothPrint.printReceipt(config, list);


        /*list.add(
          LineText(
            type: LineText.TYPE_TEXT,
            content: "Grocery App",
            weight: 2,
            width: 2,
            height: 2,
            align: LineText.ALIGN_CENTER,
            linefeed: 1,
          ),
      );

      for (var i = 0; i < widget.data.length; i++) {
        list.add(
          LineText(
            type: LineText.TYPE_TEXT,
            content: widget.data[i]['title'],
            weight: 0,
            align: LineText.ALIGN_LEFT,
            linefeed: 1,
          ),
        );

        list.add(
          LineText(
            type: LineText.TYPE_TEXT,
            content:
                "${f.format(this.widget.data[i]['price'])} x ${this.widget.data[i]['qty']}",
            align: LineText.ALIGN_LEFT,
            linefeed: 1,
          ),
        );
      }*/
    }
  }
}
