import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});//Ham Khoi tao
  //Giao dien
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinh tong 2 man hinh',
      theme : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true
      ),
      home: MyCal(), // Goi den man hinh MyCal
    );
  }
}

//Dinh nghia activity (quan ly trang thai)
class MyCal extends StatefulWidget{
  @override
  _MyCalState createState() {
    return _MyCalState();
  }
}

class Numb0r{
  late double value;
  late String sign;
  Numb0r(double v, String s){
    sign = s;
    value = v;
  }
}

class _MyCalState extends State<MyCal>{
  String oldValue = '';
  String currentValue = '0';
  bool lastSign = false;
  List<Numb0r> numbers = [];
  List<double> memory = [];

  String debug(){
    String x = "";
    for(Numb0r num in numbers){
      x += '${num.sign} ${num.value}\n';
    }
    return x;
  }
  void handleLabelSign(String label){
    //Khong dau cuoi cung va khong rong
    if(!lastSign && oldValue == ''){
      oldValue = '$currentValue $label';
      numbers.add(Numb0r(double.parse(currentValue), '+'));
      currentValue = '0';
      lastSign = true;
      return;
    }
    //Da co dau cuoi cung va gia tri hien tai khac null
    if(lastSign && currentValue != '0'){
      numbers.add(Numb0r(double.parse(currentValue), oldValue[oldValue.length - 1]));
      oldValue = '$oldValue $currentValue $label';
      currentValue = '0';
      return;
    }
    //Doi dau
    if(lastSign){
      oldValue = oldValue.substring(0, oldValue.length - 2);
      oldValue = '$oldValue $label';
    }
  }

  void handleLabelNumber(String label, bool lastSign){
    if(currentValue != '0'){
      currentValue += label;
    }
    else{
      currentValue = label;
    }
  }

  void handleSpecial(String label){
    switch(label){
      case '%':{
        currentValue = '${double.parse(currentValue)/100}';
        break;
      }
      case 'CE':{
        currentValue = '0';
        break;
      }
      case 'C':{
        currentValue = '0';
        oldValue = '';
        numbers.clear();
        break;
      }
      case 'Del':{
        if(currentValue.length == 1){
          currentValue = '0';
        }
        else{
          currentValue = currentValue.substring(0, currentValue.length - 1);
        }
        break;
      }
      case '1/x':{
        currentValue = '${1.0/double.parse(currentValue)}';
        break;
      }
      case 'x^2':{
        double val = double.parse(currentValue);
        currentValue = '${val * val}';
        break;
      }
      case 'sqrt(x)':{
        double val = double.parse(currentValue);
        currentValue = '${sqrt(val)}';
        break;
      }
      case '+/-':{
        if(currentValue[0] == '-'){
          currentValue = currentValue.substring(1, currentValue.length - 1);
          double val = double.parse(currentValue);
          numbers.add(Numb0r(val, '+'));
          if(lastSign){
            String lb = oldValue[oldValue.length - 1];
            oldValue = oldValue.substring(0, oldValue.length - 2);
            oldValue = '$oldValue + $val $lb';
          }else{
              oldValue = '$val';
          }
        }
        else{
          numbers.add(Numb0r(double.parse(currentValue), '-'));
          if(lastSign){
            String lb = oldValue[oldValue.length - 1];
            oldValue = oldValue.substring(0, oldValue.length - 2);
            oldValue = '$oldValue - ${double.parse(currentValue)} $lb';
          }else{
            oldValue = '-${double.parse(currentValue)}';
          }
        }
        currentValue = '0';
        break;
      }
      case '.':{
        if(!currentValue.contains('.')){
          currentValue += '.';
        }
        break;
      }
      case '=':{
        if(currentValue != '0'){
          String sign = oldValue[oldValue.length - 1];
          numbers.add(Numb0r(double.parse(currentValue), sign));
          currentValue = '0';
        }
        double res = 0.0;
        for(int i = numbers.length - 1 ; i >= 0; i--){
          switch(numbers[i].sign){
            case '+':{
              res += numbers[i].value;
              break;
            }
            case '-' :{
              res -= numbers[i].value;
              break;
            }
            case '*':{
              if(numbers[i-1].sign == '-'){
                res -= numbers[i].value * numbers[i-1].value;
              }
              else{
                res += numbers[i].value * numbers[i-1].value;
              }
              i --;
              break;
            }
            case '/':{
              if(numbers[i-1].sign == '-'){
                res -= numbers[i-1].value / numbers[i].value;
              }
              else{
                res += numbers[i-1].value / numbers[i].value;
              }
              i --;
              break;
            }
          }
        }
        currentValue = '$res';
        oldValue = '';
        numbers.clear();
        lastSign = false;
      }
    }
  }

  void handleBtn(String label){
      switch(label){
        case '+':
        case '-':
        case 'x':
        case '/':{
          handleLabelSign(label);
          break;
        }
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case '0':{
          handleLabelNumber(label, lastSign);
          break;
        }
        default:{
          handleSpecial(label);
        }
      }

      setState(() {
        currentValue;
      });
  }
  List<Widget> renderRowBtn(List<String> labels){
    return labels.map((label){
      return Expanded(
        child: ElevatedButton(
            onPressed: (){
              handleBtn(label);
            },
            child: Text(label)),

      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  oldValue,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25.0
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  currentValue,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30.0
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    memory.clear();
                  },
                  child: const Text(
                    'MC',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(memory.isNotEmpty){
                      currentValue = '${memory[memory.length - 1]}';
                    }
                    else{
                      currentValue = '0';
                    }
                  },
                  child: const Text(
                    'MR',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(memory.isNotEmpty){
                      memory[memory.length - 1] += double.parse(currentValue);
                    }
                    else{
                      memory.add(double.parse(currentValue));
                    }
                  },
                  child: const Text(
                    'M+',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(memory.isNotEmpty){
                      memory[memory.length - 1] -= double.parse(currentValue);
                    }
                    else{
                      memory.add(-double.parse(currentValue));
                    }
                  },
                  child: const Text(
                    'M-',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    memory.add(double.parse(currentValue));
                  },
                  child: const Text(
                    'MS',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder : (context)=>ManHinhMemory(memory)));
                  },
                  child: const Text(
                    'Show',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                )
              ],
            ),//Row MC - MR - M+ - M- - MS
            const SizedBox(height: 20,),
            //Thanh phan chinh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
              children: renderRowBtn(['%', 'CE', 'C', 'Del'])
            ),
            const SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
                children: renderRowBtn(['1/x', 'x^2', 'sqrt(x)', '/'])
            ),
            const SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
                children: renderRowBtn(['7', '8', '9', 'x'])
            ),
            const SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
                children: renderRowBtn(['4', '5', '6', '-'])
            ),
            const SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
                children: renderRowBtn(['1', '2', '3', '+'])
            ),
            const SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // căn chỉnh các nút
                children: renderRowBtn(['+/-', '0', '.', '='])
            ),
            const SizedBox(height: 20,),
          ],
        )
      ),
    );
  }
}

//Dinh nghia manhinhketqua

class ManHinhMemory extends StatelessWidget{
  final List<double> memories;
  ManHinhMemory(this.memories);
  List<Widget> renderMemory(){
    return memories.map((memory){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$memory',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,)
        ],
      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ket qua tinh tong'),),
      body: Center(
        child: Container(
          width: 200, // Giảm kích thước 40% chiều ngang
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: renderMemory(),
          ),
        ),
      ),
    );
  }
}
