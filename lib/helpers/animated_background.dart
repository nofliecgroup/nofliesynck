import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ParticleShape {
  circle,
  square,
  triangle,
  hexagon,
  star,
}

enum AnimationPattern {
  float,
  wave,
  spiral,
  pulse,
  vortex,
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final int numberOfParticles;
  final ParticleShape particleShape;
  final AnimationPattern pattern;
  final double patternSpeed;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.numberOfParticles = 25,
    this.particleShape = ParticleShape.circle,
    this.pattern = AnimationPattern.float,
    this.patternSpeed = 1.0,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<ParticleModel> particles;
  late AnimationController _fadeController;
  late AnimationController _patternController;
  late Animation<double> _fadeAnimation;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _setupAnimationControllers();
    _startAnimation();
  }

  void _initializeParticles() {
    particles = List.generate(
      widget.numberOfParticles,
      (index) => ParticleModel(
        position: Offset(
          math.Random().nextDouble() * 400,
          math.Random().nextDouble() * 800,
        ),
        speed: _getInitialSpeed(),
        size: math.Random().nextDouble() * 20 + 10,
        opacity: math.Random().nextDouble() * 0.6 + 0.1,
        angle: math.Random().nextDouble() * 2 * math.pi,
        angularSpeed: math.Random().nextDouble() * 0.02 - 0.01,
        color: Color.lerp(
          widget.primaryColor ?? Colors.blue,
          widget.secondaryColor ?? Colors.purple,
          math.Random().nextDouble(),
        )!,
      ),
    );
  }

  Offset _getInitialSpeed() {
    switch (widget.pattern) {
      case AnimationPattern.float:
        return Offset(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
        );
      case AnimationPattern.wave:
        return Offset(
          math.Random().nextDouble() * 0.5,
          math.Random().nextDouble() * 0.5,
        );
      case AnimationPattern.spiral:
        return Offset(
          math.cos(math.Random().nextDouble() * 2 * math.pi) * 0.5,
          math.sin(math.Random().nextDouble() * 2 * math.pi) * 0.5,
        );
      case AnimationPattern.pulse:
        return Offset.zero;
      case AnimationPattern.vortex:
        return Offset(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
        );
    }
  }

  void _setupAnimationControllers() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _patternController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: (50 ~/ widget.patternSpeed)), () {
      if (mounted) {
        setState(() {
          _time += 0.016; // Approximately one frame at 60fps
          _updateParticles();
        });
        _startAnimation();
      }
    });
  }

  void _updateParticles() {
    for (var particle in particles) {
      switch (widget.pattern) {
        case AnimationPattern.float:
          _updateFloatingPattern(particle);
          break;
        case AnimationPattern.wave:
          _updateWavePattern(particle);
          break;
        case AnimationPattern.spiral:
          _updateSpiralPattern(particle);
          break;
        case AnimationPattern.pulse:
          _updatePulsePattern(particle);
          break;
        case AnimationPattern.vortex:
          _updateVortexPattern(particle);
          break;
      }

      // Update particle rotation
      particle.angle += particle.angularSpeed;

      // Boundary checks
      _handleBoundaries(particle);
    }
  }

  void _updateFloatingPattern(ParticleModel particle) {
    particle.position += particle.speed;
  }

  void _updateWavePattern(ParticleModel particle) {
    particle.position += Offset(
      particle.speed.dx,
      math.sin(_time + particle.position.dx * 0.02) * 2,
    );
  }

  void _updateSpiralPattern(ParticleModel particle) {
    const center = Offset(200, 400);
    final radius = (particle.position - center).distance;
    final angle = math.atan2(
      particle.position.dy - center.dy,
      particle.position.dx - center.dx,
    );

    particle.position = center +
        Offset(
          radius * math.cos(angle + 0.02),
          radius * math.sin(angle + 0.02),
        );
  }

  void _updatePulsePattern(ParticleModel particle) {
    const center = Offset(200, 400);
    final vector = particle.position - center;
    final normalizedVector = vector / vector.distance;

    particle.position += normalizedVector * math.sin(_time * 2) * 2;
  }

  void _updateVortexPattern(ParticleModel particle) {
    const center = Offset(200, 400);
    final vector = particle.position - center;
    final distance = vector.distance;

    particle.position += Offset(
      -vector.dy / distance * 2,
      vector.dx / distance * 2,
    );
  }

  void _handleBoundaries(ParticleModel particle) {
    const bounds = Rect.fromLTWH(0, 0, 400, 800);
    var position = particle.position;
    var speed = particle.speed;

    if (position.dx - particle.size / 2 < bounds.left) {
      position = Offset(bounds.left + particle.size / 2, position.dy);
      speed = Offset(-speed.dx * 0.8, speed.dy);
      particle.isColliding = true;
    }
    if (position.dx + particle.size / 2 > bounds.right) {
      position = Offset(bounds.right - particle.size / 2, position.dy);
      speed = Offset(-speed.dx * 0.8, speed.dy);
      particle.isColliding = true;
    }
    if (position.dy - particle.size / 2 < bounds.top) {
      position = Offset(position.dx, bounds.top + particle.size / 2);
      speed = Offset(speed.dx, -speed.dy * 0.8);
      particle.isColliding = true;
    }
    if (position.dy + particle.size / 2 > bounds.bottom) {
      position = Offset(position.dx, bounds.bottom - particle.size / 2);
      speed = Offset(speed.dx, -speed.dy * 0.8);
      particle.isColliding = true;
    }

    particle.position = position;
    particle.speed = speed;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final secondaryColor = widget.secondaryColor ??
        Theme.of(context).primaryColor.withValues(alpha: 0.5);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.1),
                secondaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(
            particles: particles,
            color: primaryColor,
            shape: widget.particleShape,
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        ),
      ],
    );
  }
}

class ParticleModel {
  Offset position;
  Offset speed;
  final double size;
  double opacity;
  double angle;
  final double angularSpeed;
  Color color; // Added for collision effects
  bool isColliding; // Track collision state
  double mass; // For realistic collisions

  ParticleModel({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.angle,
    required this.angularSpeed,
    required this.color,
  })  : isColliding = false,
        mass = size * size; // Mass proportional to area

  // Helper method to calculate distance to another particle
  double distanceTo(ParticleModel other) {
    return (position - other.position).distance;
  }

  // Check for collision with another particle
  bool isCollidingWith(ParticleModel other) {
    return distanceTo(other) < (size + other.size) / 2;
  }

  // Update particle velocity after collision
  void resolveCollision(ParticleModel other) {
    if (!isCollidingWith(other)) return;

    // Calculate collision normal
    final delta = other.position - position;
    final distance = delta.distance;
    // Fix: Create normalized vector manually
    final normal = distance > 0
        ? Offset(delta.dx / distance, delta.dy / distance)
        : const Offset(1, 0);

    // Relative velocity
    final relativeVelocity = other.speed - speed;

    // Collision response
    final velocityAlongNormal =
        relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

    // Do not resolve if particles are moving apart
    if (velocityAlongNormal > 0) return;

    // Calculate restitution (bounciness)
    const restitution = 0.8;

    // Calculate impulse scalar
    final impulseScalar =
        -(1 + restitution) * velocityAlongNormal / (1 / mass + 1 / other.mass);

    // Apply impulse
    final impulse = normal * impulseScalar;
    speed -= impulse / mass;
    other.speed += impulse / other.mass;

    // Visual feedback
    isColliding = true;
    other.isColliding = true;

    // Optional: Add some chaos to rotation
    angle += math.Random().nextDouble() * 0.1;
    other.angle -= math.Random().nextDouble() * 0.1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final Color color;
  final ParticleShape shape;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = particle.isColliding
            ? particle.color.withRed(255).withValues(alpha:particle.opacity)
            : particle.color.withValues(alpha: particle.opacity);

      // Optional: Add glow effect for colliding particles
      if (particle.isColliding) {
        final glowPaint = Paint()
          ..color = particle.color.withValues(alpha:0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

        canvas.drawCircle(
          particle.position,
          particle.size * 1.2,
          glowPaint,
        );
      }

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.angle);

      // Draw the particle with the selected shape
      switch (shape) {
        case ParticleShape.circle:
          _drawCircle(canvas, paint, particle.size);
          break;
        case ParticleShape.square:
          _drawSquare(canvas, paint, particle.size);
          break;
        case ParticleShape.triangle:
          _drawTriangle(canvas, paint, particle.size);
          break;
        case ParticleShape.hexagon:
          _drawHexagon(canvas, paint, particle.size);
          break;
        case ParticleShape.star:
          _drawStar(canvas, paint, particle.size);
          break;
      }

      canvas.restore();
    }
  }

  void _drawCircle(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size / 2, paint);
  }

  void _drawSquare(Canvas canvas, Paint paint, double size) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size,
      ),
      paint,
    );
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final height = size * math.sqrt(3) / 2;

    path.moveTo(0, -height / 2);
    path.lineTo(size / 2, height / 2);
    path.lineTo(-size / 2, height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final point = Offset(
        math.cos(angle) * size / 2,
        math.sin(angle) * size / 2,
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = size / 4;

    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5;
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
