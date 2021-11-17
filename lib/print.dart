import 'dart:convert';
import 'dart:async';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  PrintPage(this.data);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  late List<BluetoothDevice> _device = [];
  late List<BluetoothDevice> _selectedPrinter = [];
  String tips = 'no device connect';
  final f = NumberFormat("TL ###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) => {initPrinter()});
    bluetoothPrint.scanResults.listen((devices) {
      setState(() {
        _device = devices;
      });
    });
    initPrinter();
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
    bool? isConnected = await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected != null && isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothPrint.scanResults,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 50.0,
                          child: InkWell(
                            onTap: () => _openDialog(context),
                            child: Text(_device.length == 0
                                ? "Bağlı cihaz bulunamadı"
                                : "Cihaz sayısı${_device.length}"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          color: Colors.pinkAccent,
                          height: 50.0,
                          child: InkWell(
                            onTap: () => _openDialog(context),
                            child: Text("Yazıcı Seçiniz"),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.blueAccent,
                            alignment: Alignment.center,
                            child: Text(
                                _selectedPrinter.length > 0
                                    ? _selectedPrinter[0].name.toString()
                                    : "Yazıcı bulunamadı",
                                style: TextStyle(fontSize: 18.0)),
                          ),
                        ),
                      ],
                    )),
                Flexible(
                  child: InkWell(
                    onTap: () {
                      _connected == true
                          ? _printTest()
                          : _printSnackBar(
                              context, "Cihaza bağlantı kurulamadı.");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.greenAccent,
                      width: double.infinity,
                      child: Text(
                        "Yazdır",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (_, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.redAccent,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () =>
                  bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
            );
          }
        },
      ),
    );
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device.address != null && device.address!.isNotEmpty) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = {};
      List<LineText> list = [];
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'A Title',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'this is conent left',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'this is conent right',
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_BARCODE,
          content: 'A12312112',
          size: 10,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_QRCODE,
          content: 'qrcode i',
          size: 10,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(linefeed: 1));
      await bluetoothPrint.printReceipt(config, list);
    }
  }

  Future _openDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Column(
          children: [
            Text("Cihaz seçiniz"),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
        content: _setupDialogContainer(context),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Tamam"),
          )
        ],
      ),
    );
  }

  Widget _setupDialogContainer(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 200.0,
          width: 300.0,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _device.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async {
                  await bluetoothPrint.connect(_device[index]);
                  setState(() {
                    _selectedPrinter.add(_device[index]);
                  });
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Container(
                      height: 70.0,
                      padding: EdgeInsets.only(left: 10.0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.print),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_device[index].name ?? ""),
                                Text(_device[index].address.toString() ),
                                Flexible(
                                  child: Text(
                                    "Yazıcı seçiniz",
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.justify,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  _printSnackBar(BuildContext context, String _text) {
    final snackBar = SnackBar(
      content: Text(_text),
      action: SnackBarAction(
        label: "Bağlantı",
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _printTest() async{
    Map<String, dynamic> config = Map();
    List<LineText> list = [];
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'Hikmet hocam', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'Burası sol bölge', weight: 0, align: LineText.ALIGN_LEFT,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'burası sağ bölge', align: LineText.ALIGN_RIGHT,linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_BARCODE, content: 'Hikmethocabarkodu', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_QRCODE, content: 'qrcode i', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    await bluetoothPrint.printReceipt(config, list);

  }
}
