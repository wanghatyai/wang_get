import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:wang_get/product_scan_model.dart';
import 'package:wang_get/image_detail.dart';
import 'package:wang_get/home.dart';

import 'package:fluttertoast/fluttertoast.dart';




class AddProductPage extends StatefulWidget {

  //var empCodeReceive;
  //AddProductPage({Key key, this.empCodeReceive}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  List units = [];
  List unitsID = [];
  String _currentUnit;
  var _currentUnitID;

  String act = "Unit";

  File imageFile1;
  File imageFile2;
  File imageFile3;

  var empCodeReceive;

  var loading = false;
  String barcode;
  List<ProductScan> _product = [];
  List<ProductScan> _search = [];

  TextEditingController barcodeProduct = TextEditingController();
  TextEditingController boxAmount = TextEditingController();
  TextEditingController unitAmount = TextEditingController();
  TextEditingController typeUnit = TextEditingController();
  TextEditingController receiveDetail = TextEditingController();

  _getUiitProduct() async{
    final res = await http.get('http://wangpharma.com/API/receiveProduct.php?act=$act');

    if(res.statusCode == 200){

      setState(() {

        var jsonData = json.decode(res.body);

        //units = jsonData;

        jsonData.forEach((unit) => units.add(unit['unitName']));
        jsonData.forEach((unitID) => unitsID.add(unitID['unitID']));

        print(units);
        print(unitsID);
        return units;

      });

    }else{
      throw Exception('Failed load Json');
    }
  }

  _onDropDownItemSelected(newValueSelected){
    setState(() {
      _currentUnit = newValueSelected;
    });
  }

  _openCamera(camPosition) async {
      var picture = await ImagePicker.pickImage(source: ImageSource.camera);
      this.setState((){
        if(camPosition == 1){
          imageFile1 = picture;
        }else if(camPosition == 2){
          imageFile2 = picture;
        }else{
          imageFile3 = picture;
        }
      });
      //Navigator.of(context).pop();
  }

  _decideImageView(camPosition){

    File imageFileC;

    if(camPosition == 1){
      imageFileC = imageFile1;
    }else if(camPosition == 2){
      imageFileC = imageFile2;
    }else{
      imageFileC = imageFile3;
    }

    if(imageFileC == null){
      return Image (
        image: AssetImage ( "assets/photo_default_2.png" ), width: 100, height: 100,
      );
    }else{
      return GestureDetector(
        onTap: () {
          print("open img.");
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageDetailPage(imageFile: imageFileC)));
        },
        child: Image.file(imageFileC, width: 100, height: 100),
      );
    }
  }

  onSearch(String text) async{
    _search.clear();
    if(text.isEmpty){
      setState(() {});
      return;
    }

    searchProduct(text);

    _product.forEach((f){
      if(f.productName.contains(text)) _search.add(f);
    });

    setState(() {});
  }

  scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState((){
        this.barcode = barcode;
        searchProduct(this.barcode);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showAlertBarcode();
        print('Camera permission was denied');
      } else {
        print('Unknow Error $e');
      }
    } on FormatException {
      print('User returned using the "back"-button before scanning anything.');
    } catch (e) {
      print('Unknown error.');
    }
  }

  void _showAlertBarcode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('คุณไม่เปิดอนุญาตใช้กล้อง'),
        );
      },
    );
  }

  searchProduct(searchVal) async{

    //barcodeProduct.text = searchVal;

    //barcodeProduct = TextEditingController(text: searchVal);


    setState(() {
      loading = true;
    });
    _product.clear();

    //productAll = [];

    final res = await http.get('http://wangpharma.com/API/receiveProduct.php?SearchVal=$searchVal&act=Search');

    if(res.statusCode == 200){

      setState(() {

        //loading = false;

        var jsonData = json.decode(res.body);

        jsonData.forEach((products) =>_product.add(ProductScan.fromJson(products)));

        print(_product);
        return _product;

      });

    }else{
      throw Exception('Failed load Json');
    }

  }

  _getProductInfo(){

    if(!loading){
      return Text('....');
    }else{
      return Container(
        child: ListView.builder(
          shrinkWrap:true,
          itemCount: _product.length,
          itemBuilder: (context, i){
            final a = _product[i];
            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 1, 10, 1),
              onTap: (){

              },
              leading: Image.network('http://www.wangpharma.com/cms/product/${a.productPic}', fit: BoxFit.cover, width: 70, height: 70),
              title: Text('${a.productName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${a.productCode}'),
                  Text('หน่วยเล็กสุด : ${a.productUnit}', style: TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis),
                ],
              ),
              /*trailing: IconButton(
                  icon: Icon(Icons.view_list, color: Colors.teal, size: 40,),
                  onPressed: (){
                    //addToOrderFast(a);
                  }
              ),*/
            );
          },
        ),
      );
    }
  }


  _addReceiveProduct() async{

    if(imageFile1 != null
        && imageFile2 != null
        && imageFile3 != null
        && _product != []
        && boxAmount.text != null
        && unitAmount.text != null
        && _currentUnitID != null) {
      var uri = Uri.parse("http://wangpharma.com/API/addReceiveProduct.php");
      var request = http.MultipartRequest("POST", uri);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      empCodeReceive = prefs.getString("empCodeReceive");

      img.Image preImageFile1 = img.decodeImage(imageFile1.readAsBytesSync());
      img.Image resizeImage1 = img.copyResize(preImageFile1, width: 400);

      File resizeImageFile1 = File(imageFile1.path)
        ..writeAsBytesSync(img.encodeJpg(resizeImage1, quality: 85));

      var stream1 = http.ByteStream(
          DelegatingStream.typed(resizeImageFile1.openRead()));
      var imgLength1 = await resizeImageFile1.length();
      var multipartFile1 = http.MultipartFile("runFile2", stream1, imgLength1,
          filename: path.basename("resizeImageFile1.jpg"));

      img.Image preImageFile2 = img.decodeImage(imageFile2.readAsBytesSync());
      img.Image resizeImage2 = img.copyResize(preImageFile2, width: 400);

      File resizeImageFile2 = File(imageFile2.path)
        ..writeAsBytesSync(img.encodeJpg(resizeImage2, quality: 85));

      var stream2 = http.ByteStream(
          DelegatingStream.typed(resizeImageFile2.openRead()));
      var imgLength2 = await resizeImageFile2.length();
      var multipartFile2 = http.MultipartFile("runFile2ex", stream2, imgLength2,
          filename: path.basename("resizeImageFile2.jpg"));

      img.Image preImageFile3 = img.decodeImage(imageFile3.readAsBytesSync());
      img.Image resizeImage3 = img.copyResize(preImageFile3, width: 400);

      File resizeImageFile3 = File(imageFile3.path)
        ..writeAsBytesSync(img.encodeJpg(resizeImage3, quality: 85));

      var stream3 = http.ByteStream(
          DelegatingStream.typed(resizeImageFile3.openRead()));
      var imgLength3 = await resizeImageFile3.length();
      var multipartFile3 = http.MultipartFile(
          "runFile2priceTag", stream3, imgLength3,
          filename: path.basename("resizeImageFile3.jpg"));

      request.files.add(multipartFile1);
      request.files.add(multipartFile2);
      request.files.add(multipartFile3);

      request.fields['runDetail2'] = receiveDetail.text;
      request.fields['runPeople2'] = empCodeReceive;

      request.fields['idPro2'] = _product[0].productId;
      request.fields['bcode2'] = _product[0].productBarcode;
      request.fields['runQ2'] = boxAmount.text;
      request.fields['runQs2'] = unitAmount.text;
      request.fields['unit2'] = _currentUnitID;

      print(request.fields);
      print(request.files[0].filename);
      print(request.files[0].length);
      print(request.files[1].filename);
      print(request.files[1].length);
      print(request.files[2].filename);
      print(request.files[2].length);

      var response = await request.send();

      if (response.statusCode == 200) {
        print("add OK");
        print(response);
        showToastAddFast();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()));

      } else {
        print("add Error");
      }

    }else{
      _showAlert();
    }
  }

  showToastAddFast(){
    Fluttertoast.showToast(
        msg: "เพิ่มรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text('คุณกรอกรายละเอียดไม่ครบถ้วน'),
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    _getUiitProduct();
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
                        scanBarcode();
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
                      }
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 10, 0),
                    child: TextField (
                      controller: barcodeProduct,
                      onChanged: onSearch,
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
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                  child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: Icon(Icons.add_circle, size: 50, color: Colors.green,),
                      onPressed: (){
                        _addReceiveProduct();
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
                          var tempIndex = units.indexOf(newValueSelected);
                          _onDropDownItemSelected(newValueSelected);
                          _currentUnitID = unitsID[tempIndex];
                          print(this._currentUnit);
                          print(_currentUnitID);
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
                      _decideImageView(1),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(1);
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
                      _decideImageView(2),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(2);
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
                      _decideImageView(3),
                      IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(Icons.camera_alt, size: 50,),
                          onPressed: (){
                            _openCamera(3);
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
                  child: Container(
                    color: Colors.lightBlue,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text('รายละเอียดสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
                  )
                )
              ],
            ),
            _getProductInfo(),
          ],
        ),
      ),
    );
  }
}
