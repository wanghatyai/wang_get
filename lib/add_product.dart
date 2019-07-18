import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  List units = ["โหล","กล่อง"];
  String _currentUnit;

  File imageFile;

  TextEditingController barcodeProduct = TextEditingController();
  TextEditingController boxAmount = TextEditingController();
  TextEditingController unitAmount = TextEditingController();
  TextEditingController typeUnit = TextEditingController();
  TextEditingController receiveDetail = TextEditingController();

  _onDropDownItemSelected(newValueSelected){
    setState(() {
      _currentUnit = newValueSelected;
    });
  }

  _openCamera() async {
      var picture = await ImagePicker.pickImage(source: ImageSource.camera);
      this.setState((){
        imageFile = picture;
      });
      //Navigator.of(context).pop();
  }

  _decideImageView(){
    if(imageFile == null){
      return Image (
        image: AssetImage ( "assets/photo_default_2.png" ), width: 100, height: 100,
      );
    }else{
      return GestureDetector(
        onTap: () {
          print("open img.");
        },
        child: Image.file(imageFile, width: 100, height: 100),
      );
    }
  }

  _decideImageViewFull(){
    if(imageFile == null){
      return Text("ยังไม่ได้ถ่ายรูป");
    }else{
      return GestureDetector(
        onTap: () {
          print("open img.");
        },
        child: Image.file(imageFile, fit: BoxFit.fitWidth,),
      );
    }
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: Icon(Icons.settings_overscan, size: 50, color: Colors.red,),
                      onPressed: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                      }
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 10, 0),
                    child: TextFormField (
                      controller: barcodeProduct,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'Barcode / Code สินค้า',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                  child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: Icon(Icons.add_circle, size: 50, color: Colors.green,),
                      onPressed: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                      }
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextFormField (
                      textAlign: TextAlign.center,
                      controller: boxAmount,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'จำนวนลัง',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Text(" / ลัง", style: TextStyle(fontSize: 18)),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: TextFormField (
                      textAlign: TextAlign.center,
                      controller: unitAmount,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'จำนวนหน่วย',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Text("/", style: TextStyle(fontSize: 18)),
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                      child: DropdownButton(
                        hint: Text("หน่วยสินค้า",style: TextStyle(fontSize: 16)),
                        items: units.map((dropDownStringItem){
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem, style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (newValueSelected){
                          _onDropDownItemSelected(newValueSelected);
                          print(this._currentUnit);
                        },
                        value: _currentUnit,
                      ),
                    )
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  //flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField (
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.start,
                      controller: receiveDetail,
                      style: TextStyle (
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration (
                          labelText: 'เพิ่มเติม*',
                          labelStyle: TextStyle (
                            fontSize: (15),
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูปวันหมดอายุ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _decideImageView(),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera();
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูปราคาป้าย", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text("รูป LOT สินค้า", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                          }
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _decideImageViewFull(),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _decideImageViewFull(),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _decideImageViewFull(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}