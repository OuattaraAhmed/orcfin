import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_ml_text_recognition/api/firebase_ml_api.dart';
import 'package:firebase_ml_text_recognition/widget/text_area_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'controls_widget.dart';

class TextRecognitionWidget extends StatefulWidget {
  const TextRecognitionWidget({
    Key key,
  }) : super(key: key);

  @override
  _TextRecognitionWidgetState createState() => _TextRecognitionWidgetState();
}

class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
  String text = '';
  File image;
  TextEditingController nameController = TextEditingController();
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Expanded(child: buildImage()),
            const SizedBox(height: 16),
            ControlsWidget(
              onClickedPickImage: pickImage,
              onClickedScanText: scanText,
              onClickedClear: clear,
            ),
            const SizedBox(height: 16),
            TextAreaWidget(
              //controller: textController,
              text: text,
              // controller: textController,

              onClickedCopy: copyToClipboard,
            ),
          ],
        ),
      );

  Widget buildImage() => Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: "Nom de l'image", hintText: 'ecrie moi ffg'),
              ),
            ),
            image != null
                ? Image.file(image)
                : Icon(Icons.photo, size: 80, color: Colors.black),
          ],
        ),
      );

  Future pickImage() async {
    final file = await ImagePicker().getImage(source: ImageSource.gallery);
    setImage(File(file.path));
  }

  Future scanText() async {
    showDialog(
      context: context,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    final text = await FirebaseMLApi.recogniseText(image);
    setText(text);

    Navigator.of(context).pop();
  }

  void clear() {
    setImage(null);
    setText('');
  }

  //void copyToClipboard() {
  //  if (text.trim() != '') {
  //    FlutterClipboard.copy(text);
  // }
  // }

  Future copyToClipboard() async {
    final uri =
        Uri.parse("http://172.16.21.116/ocr/image_upload_php_mysql/upload.php");
    var request = http.MultipartRequest('POST', uri);
    //request.fields['content'] = text;
    request.fields['content'] = text;
    request.fields['name'] =nameController.text;
    //request.fields['content'] = text;
    // _image.path
    var pic = await http.MultipartFile.fromPath("image", image.path);
    request.files.add(pic);
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image envoyée');
    } else {
      print('Image non envoyée');
    }
    setState(() {});
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }

  void setText(String newText) {
    setState(() {
      text = newText;
    });
  }
}
