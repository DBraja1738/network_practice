import 'package:flutter/material.dart';

class AnimationPractice extends StatefulWidget {
  const AnimationPractice({super.key});

  @override
  State<AnimationPractice> createState() => _AnimationPracticeState();
}

class _AnimationPracticeState extends State<AnimationPractice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _cardInCenter= false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(title: Text("hello animations"),),
      body: Stack(
          children: [
            AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                top: _cardInCenter ? screenHeight/2 - 150 : -200,
                left: MediaQuery.of(context).size.width/2- 13,
                child: SizedBox(
                  width: 32, height: 32,
                  child: Image.asset("assets/images/card_back.png", fit: BoxFit.cover,),
                ),
                
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cardInCenter = true;
                    });
                  },
                  child: Text('Show Card'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cardInCenter = true;
                    });
                  },
                  child: Text('Flip card'),
                ),
              ),
            )
          ],
        ),

    );
    
  }
}
