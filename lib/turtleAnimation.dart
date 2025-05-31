import 'package:flutter/material.dart';


class TurtleAnimation extends StatefulWidget {
  const TurtleAnimation({super.key});

  @override
  State<TurtleAnimation> createState() => _TurtleAnimationState();
}

class _TurtleAnimationState extends State<TurtleAnimation> {
  double x = 0.0;
  double y = 0.0;

  double max_x = 0.0;
  double max_y = 0.0;

  double rotation = 0.0;
  
  final double moveDistance = 20.0;


  void move(String direction){
    setState(() {
      switch(direction){
        case "up":
          y=(y-moveDistance).clamp(-max_y, max_y);
          rotation = 0;
          break;
        case "down":
          y=(y+moveDistance).clamp(-max_y, max_y);
          rotation = 3.1415;
          break;
        case "left":
          x=(x-moveDistance).clamp(-max_x, max_x);
          rotation = -1.5708;
          break;
        case "right":
          x=(x+moveDistance).clamp(-max_x, max_x);
          rotation = 1.5708;
          break;

      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello turtle"),),
      
      body: LayoutBuilder(
          builder: (context, constraints){
            max_x = (constraints.maxWidth)/2 - 50;
            max_y = (constraints.maxHeight)/2 - 150;
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: constraints.maxHeight- 150,
                  color: Colors.lightGreen,

                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(x, y, 0),
                          child: AnimatedRotation(
                              turns: rotation / (2*3.1415),
                              duration: Duration(milliseconds: 200),
                              child: Container(
                                height: 64,
                                width: 64,
                                child: Image.asset("assets/images/card_back.png"),
                              ),
                          ),
                      ),

                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Position: (${x.toInt()}, ${y.toInt()})',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  )
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left button
                        ElevatedButton(onPressed: ()=>move("left"), child: Text("left")),

                        // Up and Down buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(onPressed: ()=>move("up"), child: Text("up")),
                            SizedBox(height: 8),
                            ElevatedButton(onPressed: ()=>move("down"), child: Text("down")),
                          ],
                        ),

                        // Right button
                        ElevatedButton(onPressed: ()=>move("right"), child: Text("right")),
                      ],
                    ),
                  ),
                ),

                // Reset button
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      setState(() {
                        x = 0;
                        y = 0;
                        rotation = 0;
                      });
                    },
                    child: Icon(Icons.refresh),
                    tooltip: 'Reset position',
                  ),
                ),


              ],
            );
          }
      ),
    );
  }



}
