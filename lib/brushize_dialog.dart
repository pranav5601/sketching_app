import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrushSize extends StatefulWidget {
  final double initialSize;

   BrushSize({this.initialSize});

  @override
  State<BrushSize> createState() => _BrushSizeState();
}

class _BrushSizeState extends State<BrushSize> {

  double _brushSize;

  @override
  void initState() {

    _brushSize = widget.initialSize;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Text("Select Brush size."),
      content: Slider(
          min: 0,
          max: 50,
          divisions: 10,
          value: _brushSize,
          onChanged: (value)=>{
            setState((){
              _brushSize = value;
            })
          }),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context, _brushSize);
        }, child: Text("Select Size"))
      ],
    );
  }
}
