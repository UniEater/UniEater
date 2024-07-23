import 'package:flutter/material.dart';
import 'dart:math';

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpinWheel(),
    );
  }
}

class SpinWheel extends StatefulWidget {
  @override
  _SpinWheelState createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _sectors = [
    "Prize 1",
    "Prize 2",
    "Prize 3",
    "Prize 4",
    "Prize 5",
    "Prize 6",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 6 * pi)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value,
                child: child,
              );
            },
            child: CustomPaint(
              size: Size(300, 300),
              painter: WheelPainter(_sectors),
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: _spinWheel,
            child: Text('Spin'),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> sectors;
  WheelPainter(this.sectors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final double anglePerSector = (2 * pi) / sectors.length;

    for (int i = 0; i < sectors.length; i++) {
      paint.color = i.isEven ? Colors.blue : Colors.red;
      final startAngle = i * anglePerSector;
      final sweepAngle = anglePerSector;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final sectorLabel = sectors[i];
      final textAngle = startAngle + anglePerSector / 2;
      final labelX = center.dx + (radius / 2) * cos(textAngle);
      final labelY = center.dy + (radius / 2) * sin(textAngle);

      textPainter.text = TextSpan(
        text: sectorLabel,
        style: TextStyle(color: Colors.white, fontSize: 20),
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
