import 'dart:math';
import 'package:flutter/material.dart';

class RainDrop {
  double x;
  double y;
  double speed;
  double length;
  double opacity;
  double width;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required this.width,
  });
}

class RainAnimation extends StatefulWidget {
  final bool isActive;
  final bool isSnow;
  final bool isThunder;
  final int intensity; // 1-3

  const RainAnimation({
    super.key,
    required this.isActive,
    this.isSnow = false,
    this.isThunder = false,
    this.intensity = 2,
  });

  @override
  State<RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _thunderController;
  final List<RainDrop> _drops = [];
  final Random _random = Random();
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateDrops);

    _thunderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _showFlash = false);
        }
      });

    _initDrops();
    if (widget.isActive) {
      _controller.repeat();
      if (widget.isThunder) _scheduleThunder();
    }
  }

  void _scheduleThunder() {
    Future.delayed(Duration(seconds: 3 + _random.nextInt(7)), () {
      if (mounted && widget.isThunder) {
        setState(() => _showFlash = true);
        _thunderController.forward(from: 0);
        _scheduleThunder();
      }
    });
  }

  void _initDrops() {
    final count = widget.intensity == 1 ? 40 : widget.intensity == 2 ? 80 : 140;
    for (int i = 0; i < count; i++) {
      _drops.add(_createDrop(randomY: true));
    }
  }

  RainDrop _createDrop({bool randomY = false}) {
    if (widget.isSnow) {
      return RainDrop(
        x: _random.nextDouble(),
        y: randomY ? _random.nextDouble() : -0.1,
        speed: 0.001 + _random.nextDouble() * 0.002,
        length: 4 + _random.nextDouble() * 4,
        opacity: 0.4 + _random.nextDouble() * 0.5,
        width: 3 + _random.nextDouble() * 3,
      );
    }
    return RainDrop(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : -0.1,
      speed: 0.008 + _random.nextDouble() * 0.012,
      length: 15 + _random.nextDouble() * 20,
      opacity: 0.3 + _random.nextDouble() * 0.5,
      width: 0.8 + _random.nextDouble() * 0.8,
    );
  }

  void _updateDrops() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _drops.length; i++) {
        _drops[i].y += _drops[i].speed;
        if (widget.isSnow) {
          _drops[i].x += sin(_drops[i].y * 10) * 0.001;
        }
        if (_drops[i].y > 1.1) {
          _drops[i] = _createDrop();
        }
      }
    });
  }

  @override
  void didUpdateWidget(RainAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _thunderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();
    return Stack(
      children: [
        CustomPaint(
          painter: _RainPainter(drops: _drops, isSnow: widget.isSnow),
          size: Size.infinite,
        ),
        if (_showFlash)
          AnimatedBuilder(
            animation: _thunderController,
            builder: (context, _) {
              final opacity = (1 - _thunderController.value) * 0.4;
              return Container(
                color: Colors.white.withOpacity(opacity),
              );
            },
          ),
      ],
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final bool isSnow;

  _RainPainter({required this.drops, required this.isSnow});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drop in drops) {
      final paint = Paint()
        ..color = isSnow
            ? Colors.white.withOpacity(drop.opacity)
            : const Color(0xFF90CAF9).withOpacity(drop.opacity)
        ..strokeWidth = drop.width
        ..strokeCap = StrokeCap.round;

      final x = drop.x * size.width;
      final y = drop.y * size.height;

      if (isSnow) {
        canvas.drawCircle(Offset(x, y), drop.length / 2, paint);
      } else {
        canvas.drawLine(
          Offset(x, y),
          Offset(x - drop.length * 0.2, y + drop.length),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => true;
}

class CloudWidget extends StatefulWidget {
  final double opacity;
  final double size;
  final bool animate;

  const CloudWidget({
    super.key,
    this.opacity = 0.8,
    this.size = 1.0,
    this.animate = true,
  });

  @override
  State<CloudWidget> createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildCloud();
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_anim.value, 0),
        child: child,
      ),
      child: _buildCloud(),
    );
  }

  Widget _buildCloud() {
    return CustomPaint(
      painter: _CloudPainter(opacity: widget.opacity),
      size: Size(120 * widget.size, 60 * widget.size),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double opacity;

  _CloudPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.15, h * 0.75);
    path.quadraticBezierTo(w * 0.0, h * 0.75, w * 0.05, h * 0.55);
    path.quadraticBezierTo(w * 0.05, h * 0.35, w * 0.25, h * 0.35);
    path.quadraticBezierTo(w * 0.25, h * 0.05, w * 0.5, h * 0.05);
    path.quadraticBezierTo(w * 0.75, h * 0.05, w * 0.75, h * 0.3);
    path.quadraticBezierTo(w * 0.95, h * 0.28, w * 0.98, h * 0.5);
    path.quadraticBezierTo(w * 1.0, h * 0.75, w * 0.85, h * 0.75);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.opacity != opacity;
}
