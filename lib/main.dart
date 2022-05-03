import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bother Printer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Brother Label Printer demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String scanStatus = "No Printer Found";
  var printer = Printer();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void printLabel() async {
    printer.printImage(await loadImage('labels/helloWorld.png'));
  }

  void printcanvas() async {
    TextStyle style = const TextStyle(
        color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold);

    ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: style.fontSize,
      fontFamily: style.fontFamily,
      fontStyle: style.fontStyle,
      fontWeight: style.fontWeight,
      textAlign: TextAlign.center,
      maxLines: 10,
    ))
          ..pushStyle(style.getTextStyle())
          ..addText("This is it ");

    ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 300));

    PrinterStatus status = await printer.printText(paragraph);
  }

  void initializePrinter() async {
    print("Scaning the Printers");
    //
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.PT_P910BT;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.BLUETOOTH;
    //printInfo.orientation = Orientation.LANDSCAPE;
    //printInfo.rotate180 = true;
    // Set the label type.
    //printInfo.labelNameIndex = QL1100.ordinalFromID(QL1100.W103.getId());
    printInfo.labelNameIndex = PT.ordinalFromID(PT.W18.getId());

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model a vailable in the network.
    List<BluetoothPrinter> printers =
        await printer.getBluetoothPrinters([Model.PT_P910BT.getName()]);

    setState(() {
      if (printers.isEmpty) {
        scanStatus = "No Printer Found";
      } else {
        scanStatus = "Printer Found";
        printInfo.macAddress = printers.single.macAddress;
        printer.setPrinterInfo(printInfo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('labels/helloWorld.png'),
            ElevatedButton(
              onPressed: initializePrinter,
              child: const Text('Initialize Printer'),
            ),
            Text(
              scanStatus,
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              onPressed: printLabel,
              child: const Text('Print Label'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
