import 'package:flutter/material.dart';

class CustomToolbar extends StatelessWidget {
  CustomToolbar(
      {this.title, this.icon, this.onPressed,this.additionalBack, this.needBackBtn = true});

  final String title;
  final IconData icon;
  final Function onPressed;
  final bool needBackBtn;
  final Function additionalBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Visibility(
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 27, color: Theme.of(context).primaryColor,),
              onPressed: () {
                Navigator.pop(context, true);
                if (additionalBack != null)
                  additionalBack();
              },
            ),
            visible: needBackBtn,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor),
          ),
          IconButton(icon: Icon(icon, size: 22, color: Theme.of(context).primaryColor,), onPressed: onPressed),
        ],
      ),
    );
  }
}
