import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  List _output = [];

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
        return null;
      }
    });
    classifyImg(_image!);
  }
  Future getGalleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
        return null;
      }
    });
    classifyImg(_image!);
  }

  classifyImg(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      if(_output.length > 0) {
        _output.removeLast();
      }
      _output.addAll(output!);
    });
  }
  
  loadModel() async {
    await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            _image != null ? Image.file(_image!) : Container(),
            _output.length > 0? Text('${_output[0]['label'] == '0 DOG' ? 'Dog' : 'Cat'}') : Container(),
            _output.length > 0? Text('${_output[0]}') : Container(),
            ElevatedButton(onPressed: getImage, child: Text('사진찍기')),
            ElevatedButton(onPressed: getGalleryImage, child: Text('사진불러오기')),
          ],),
        ),
      ),
    );
  }
}
