import 'package:flutter/material.dart';

const _black = Colors.black;
const _white = Colors.white;

class Label extends StatelessWidget {
  const Label({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final unit = constraints.maxWidth / 48;
      final fontSize = unit * 1.5;

      return DefaultTextStyle(
        style: TextStyle(color: _black, fontSize: fontSize),
        child: Padding(
          padding: EdgeInsets.only(top: unit),
          child: AspectRatio(
            aspectRatio: 2 / 1,
            child: Container(
              padding: EdgeInsets.all(unit),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: unit,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: unit * 2,
                      children: [
                        SizedBox.square(
                          dimension: unit * 8,
                          child: ColoredBox(color: _black),
                        ),
                        SizedBox.square(
                          dimension: unit * 8,
                          child: ColoredBox(color: _black),
                        ),
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AspectRatio(
                            aspectRatio: 7 / 2,
                            child: ColoredBox(color: _black)),
                        Text('CODE', textAlign: TextAlign.center),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
