import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:backstage/Inventory/scannedPage.dart';

class BarcodeScanner extends StatefulWidget {
  static const routeName = 'Barcode Scanner';
  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String result;

  File pickedImage;

  Future<void> decode() async {
    pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    final BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    final List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);

    for (Barcode readableCode in barcodes){
      String output = readableCode.displayValue;
      print(output);
      if(output != null){
        setState(() {
          result = output;
        });
      }
    }
    barcodeDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> goToNextPage() async {
      await decode().then((_){
        if(result == null)
        {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('No Barcode Found'),
            )
          );
        } else {
          Navigator.of(context).pushNamed(
            ScannedPage.routeName,
            arguments: result
          );
        }
      });
    }

    return FlatButton.icon(
      icon: Icon(
        Icons.scanner,
        color: Colors.white,
      ),
      label: Text(
        'Scan Barcode',
        style: TextStyle(
          color: Colors.white
        ),
      ),
      onPressed: goToNextPage,
    );
  }
}

class OCR extends StatefulWidget {
  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  String result = "Not yet Scanned";

  File pickedImage;

  bool isImageLoaded = false;

  Future<void> clickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }


  Future<void> pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future<void> readText() async {
    
    pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);

    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recogniseText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recogniseText.processImage(ourImage);

    for (TextBlock block in readText.blocks){
      for(TextLine line in block.lines){
        for(TextElement word in line.elements){
          print(word.text);
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    Future<void> goToNextPage() async {
      await readText().then((_){
        if(result == null)
        {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('No Text Found'),
            )
          );
        } else {
          Navigator.of(context).pushNamed(
            ScannedPage.routeName,
            arguments: result
          );
        }
      });
    }

    return Scaffold(
      body: Center(
        child: FlatButton.icon(
          icon: Icon(
            Icons.scanner,
            color: Colors.white,
          ),
          label: Text(
            result,
            style: TextStyle(
              color: Colors.white
            ),
          ),
          onPressed: goToNextPage,
        ),
      ),
    );
  }
}