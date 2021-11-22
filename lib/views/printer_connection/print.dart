import 'dart:async';
import 'package:barkoduygulamasi/views/barcode_settings/barcode_scan.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
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

  List<String> messages = <String>[];
  MethodChannel channel = MethodChannel('SocketIOClient');
  bool _connected = false;
  late List<BluetoothDevice> _device = [];
  late List<BluetoothDevice> _selectedPrinter = [];
  String tips = 'no device connect';
  final f = NumberFormat("TL ###,###.00", "en_US");

  @override
  void dispose() {
    print("disconnect bağlantı koparma");
    bluetoothPrint.disconnect();
    bluetoothPrint.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // if( WidgetsBinding.instance.)
    try {
      // WidgetsBinding.instance!.addPostFrameCallback((_) => {initPrinter()});
      bluetoothPrint.scanResults.listen((devices) {
        print("yazıcıların test $devices");

        setState(() {
          _device = devices;
        });
        print("yazıcılar ${devices}");
      });
    } catch (e) {
      print("yazıcı arama hatası: $e");
    } finally {
      print("yazıcılarbuarsı ${_device}");
      initPrinter();
    }

    // checkFlutterChanel();
  }

/*  void checkFlutterChanel() {
    Future result = channel.invokeMethod('flutterChannelTest',<String, String> {
      'arg': 'test'
    });
    result.then((boolVal) {
      if (boolVal == true) {
        setState(() {
          this.messages.add("Flutter Channel Test Başarılı");
        });
      } else {
        setState(() {
          this.messages.add("Flutter Channel Test Başarısız");
        });
      }
    });
  }*/

  Future<void> initPrinter() async {
    print("********");
    try {
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
    } catch (e) {
      print("${e.runtimeType}${e.toString()} print komudu çalıştı");
    } /*finally {
      EasyLoading.dismiss();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.account_box),
            tooltip: 'Open shopping cart',
            onPressed: () {
              bluetoothPrint.stopScan();
              if (!mounted) return;
            },
          ),
        ],
        title: const Text('Yazıcılar'),
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
                        InkWell(
                          onTap: () => _openDialog(context),
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 50.0,
                            child: Text(_device.length == 0
                                ? "Bağlı cihaz bulunamadı"
                                : "Cihaz sayısı${_device.length}"),
                          ),
                        ),
                        InkWell(
                          onTap: () => _openDialog(context),
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            color: Colors.greenAccent,
                            height: 50.0,
                            child: Text("Yazıcı seçiniz"),
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
                        GestureDetector(
                          onTap: () {
/*                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const BarcodeScan()));*/
                          },
                          child: Container(
                            height: 110,
                            width: 110,
                            color: Colors.blueAccent,
                            child: const Center(child:Text("Barkod Oku")),
                          ),
                        )
                      ],
                    )),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
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
                            child: Text(
                              "Barkod Yazdır",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: InkWell(
                          onTap: () {
                            _connected == true
                                ? _printFis()
                                : _printSnackBar(
                                    context, "Cihaza bağlantı kurulamadı.");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.yellowAccent,
                            child: Text(
                              "Fiş Yazdır",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                                Text(_device[index].address.toString()),
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

  void _printFis() async {
    // if (device.address != null && device.address!.isNotEmpty) {

    Map<String, dynamic> config = {};
    List<LineText> list = [];
    for (var i = 0; i < widget.data.length; i++) {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: widget.data[i]["title"],
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: widget.data[i]["price"].toString(),
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));
    }
    await bluetoothPrint.printReceipt(config, list);
    // }
  }

  void _printTest() async {
    // if (device.address != null && device.address!.isNotEmpty) {

    Map<String, dynamic> config = {};
    List<LineText> list = [];
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Deneme",
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Burası sol bölge',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'burası sağ bölge',
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_BARCODE,
        content:
            'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
                'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
                'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
                'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW',
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_QRCODE,
        content:
            "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
                "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
                "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
                "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    await bluetoothPrint.printReceipt(config, list);
    // }
  }
}
