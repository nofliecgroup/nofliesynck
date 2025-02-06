/* import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

// Part 1: Core Enums and Types
enum ParticleShape {
  circle,
  square,
  triangle,
  hexagon,
  star,
  custom,
}

enum AnimationPattern {
  float,
  wave,
  spiral,
  pulse,
  vortex,
  dna,
  magneticField,
  chaos,
  flocking,
  soundWave,
}

typedef CustomShapeBuilder = Path Function(Size size, double time);

// Part 2: Vector Extensions
extension Vector2Extensions on vector.Vector2 {
  vector.Vector2 rotated(double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return vector.Vector2(
      x * cos - y * sin,
      x * sin + y * cos,
    );
  }

  static vector.Vector2 fromOffset(Offset offset) {
    return vector.Vector2(offset.dx, offset.dy);
  }

  Offset toOffset() {
    return Offset(x, y);
  }
}

// Part 3: Particle Class
class EnhancedParticle {
  vector.Vector2 position;
  vector.Vector2 velocity;
  vector.Vector2 acceleration;
  final vector.Vector2 initialPosition;
  final double mass;
  double charge;
  Color color;
  double size;
  double lifespan;
  double maxLifespan;
  ParticleShape shape;
  Path? customPath;
  List<TrailPoint> trail;
  double angularVelocity;
  double angle;
  bool isCollidingWithPointer;

  EnhancedParticle({
    required vector.Vector2 position,
    required this.velocity,
    required this.acceleration,
    required this.mass,
    required this.charge,
    required this.color,
    required this.size,
    required this.lifespan,
    required this.shape,
    this.customPath,
    this.angularVelocity = 0.0,
    this.angle = 0.0,
  })  : position = position.clone(),
        initialPosition = position.clone(),
        maxLifespan = lifespan,
        trail = [],
        isCollidingWithPointer = false;

  bool get isDead => lifespan <= 0;
  double get lifeProgress => lifespan / maxLifespan;

  void update(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    acceleration.setZero();
    lifespan -= dt;
    angle += angularVelocity * dt;

    // Update trail
    trail.insert(
      0,
      TrailPoint(
        position: position.clone(),
        color: color,
        size: size,
        age: 0.0,
      ),
    );

    // Update and clean trail
    for (var point in trail) {
      point.age += dt;
    }
    trail.removeWhere((point) => point.age > 1.0);
  }

  void applyForce(vector.Vector2 force) {
    acceleration += force / mass;
  }

  void handleWallCollision(Size bounds) {
    final margin = size / 2;
    bool collided = false;

    if (position.x - margin < 0) {
      position.x = margin;
      velocity.x *= -0.8;
      collided = true;
    } else if (position.x + margin > bounds.width) {
      position.x = bounds.width - margin;
      velocity.x *= -0.8;
      collided = true;
    }

    if (position.y - margin < 0) {
      position.y = margin;
      velocity.y *= -0.8;
      collided = true;
    } else if (position.y + margin > bounds.height) {
      position.y = bounds.height - margin;
      velocity.y *= -0.8;
      collided = true;
    }

    if (collided) {
      angularVelocity += (math.Random().nextDouble() - 0.5) * 2;
    }
  }
}

// Part 4: Trail System
class TrailPoint {
  final vector.Vector2 position;
  final Color color;
  final double size;
  double age;

  TrailPoint({
    required this.position,
    required this.color,
    required this.size,
    required this.age,
  });

  double get opacity => 1.0 - (age / 1.0);
}

// Part 5: Force System
abstract class Force {
  vector.Vector2 apply(
    EnhancedParticle particle,
    List<EnhancedParticle> particles,
    double time,
    Size bounds,
  );
}

class GravitationalForce extends Force {
  final double G;
  GravitationalForce(this.G);

  @override
  vector.Vector2 apply(
    EnhancedParticle particle,
    List<EnhancedParticle> particles,
    double time,
    Size bounds,
  ) {
    var force = vector.Vector2.zero();
    for (var other in particles) {
      if (other != particle) {
        final dir = other.position - particle.position;
        final distance = dir.length;
        if (distance > 0 && distance < 100) {
          final magnitude = G * particle.mass * other.mass / (distance * distance);
          force += dir.normalized() * magnitude;
        }
      }
    }
    return force;
  }
}

class ElectromagneticForce extends Force {
  final double k;
  final double B;

  ElectromagneticForce(this.k, this.B);

  @override
  vector.Vector2 apply(
    EnhancedParticle particle,
    List<EnhancedParticle> particles,
    double time,
    Size bounds,
  ) {
    var force = vector.Vector2.zero();

    // Electric force
    for (var other in particles) {
      if (other != particle) {
        final dir = other.position - particle.position;
        final distance = dir.length;
        if (distance > 0 && distance < 150) {
          final magnitude = k * particle.charge * other.charge / (distance * distance);
          force += dir.normalized() * magnitude;
        }
      }
    }

    // Magnetic force
    final velocity = particle.velocity.clone();
    if (velocity.length > 0) {
      final magneticForce = vector.Vector2(
        -velocity.y * B * particle.charge,
        velocity.x * B * particle.charge,
      );
      force += magneticForce;
    }

    return force;
  }
}

class VortexForce extends Force {
  @override
  vector.Vector2 apply(
    EnhancedParticle particle,
    List<EnhancedParticle> particles,
    double time,
    Size bounds,
  ) {
    final center = vector.Vector2(bounds.width / 2, bounds.height / 2);
    final toCenter = center - particle.position;
    final distance = toCenter.length;

    if (distance > 0) {
      final tangent = vector.Vector2(-toCenter.y, toCenter.x) / distance;
      return tangent * (500 / distance);
    }
    return vector.Vector2.zero();
  }
}

// Part 6: Main Widget
class ParticleField extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final int numberOfParticles;
  final ParticleShape particleShape;
  final List<AnimationPattern> patterns;
  final double patternSpeed;
  final bool enableInteraction;
  final bool enablePhysics;
  final CustomShapeBuilder? customShapeBuilder;

  const ParticleField({
    super.key,
    required this.child,
    required this.colors,
    this.numberOfParticles = 50,
    this.particleShape = ParticleShape.circle,
    this.patterns = const [AnimationPattern.float],
    this.patternSpeed = 1.0,
    this.enableInteraction = true,
    this.enablePhysics = true,
    this.customShapeBuilder,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

// Part 7: Widget State Implementation
class _ParticleFieldState extends State<ParticleField> with TickerProviderStateMixin {
  late List<EnhancedParticle> particles;
  late AnimationController _mainController;
  late List<Force> _forces;
  double _time = 0;
  Offset? _pointerPosition;
  Size? _bounds;

  @override
  void initState() {
    super.initState();
    _initializeSystem();
    _setupControllers();
  }

  void _initializeSystem() {
    _forces = [
      GravitationalForce(0.5),
      ElectromagneticForce(0.3, 0.2),
      VortexForce(),
    ];

    particles = List.generate(
      widget.numberOfParticles,
      (index) => _createParticle(),
    );
  }

  EnhancedParticle _createParticle() {
    final random = math.Random();
    final bounds = _bounds ?? const Size(300, 300);

    return EnhancedParticle(
      position: vector.Vector2(
        random.nextDouble() * bounds.width,
        random.nextDouble() * bounds.height,
      ),
      velocity: vector.Vector2(
        random.nextDouble() * 2 - 1,
        random.nextDouble() * 2 - 1,
      )..scale(2),
      acceleration: vector.Vector2.zero(),
      mass: random.nextDouble() * 2 + 0.5,
      charge: random.nextDouble() * 2 - 1,
      color: widget.colors[random.nextInt(widget.colors.length)],
      size: random.nextDouble() * 10 + 5,
      lifespan: random.nextDouble() * 5 + 5,
      shape: widget.particleShape,
      customPath: widget.customShapeBuilder?.call(const Size(20, 20), 0),
      angularVelocity: (random.nextDouble() - 0.5) * 2,
    );
  }

  void _setupControllers() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _mainController.addListener(_updateParticles);
  }

  vector.Vector2 _calculateSeparation(EnhancedParticle particle) {
    final separation = vector.Vector2.zero();
    int count = 0;
    final separationRadius = 50.0; // Adjust this value to control separation distance

    for (var other in particles) {
      if (other != particle) {
        final distance = (particle.position - other.position).length;
        if (distance > 0 && distance < separationRadius) {
          final diff = particle.position - other.position;
          diff.normalize();
          diff.scale(1.0 / distance); // Weight by distance
          separation.add(diff);
          count++;
        }
      }
    }

    if (count > 0) {
      separation.scale(1.0 / count);
      // Normalize and scale the steering force
      if (separation.length > 0) {
        separation.normalize();
        separation.scale(2.0); // Max separation speed
      }
    }

    return separation;
  }

  vector.Vector2 _calculateAlignment(EnhancedParticle particle) {
    final alignment = vector.Vector2.zero();
    int count = 0;
    final alignmentRadius = 70.0; // Adjust this value to control alignment range

    for (var other in particles) {
      if (other != particle) {
        final distance = (particle.position - other.position).length;
        if (distance > 0 && distance < alignmentRadius) {
          alignment.add(other.velocity);
          count++;
        }
      }
    }

    if (count > 0) {
      alignment.scale(1.0 / count);
      // Normalize and scale the steering force
      if (alignment.length > 0) {
        alignment.normalize();
        alignment.scale(1.5); // Max alignment speed
        final steer = alignment - particle.velocity;
        steer.scale(0.05); // Adjust alignment strength
        return steer;
      }
    }

    return alignment;
  }

  vector.Vector2 _calculateCohesion(EnhancedParticle particle) {
    final cohesion = vector.Vector2.zero();
    int count = 0;
    final cohesionRadius = 100.0; // Adjust this value to control cohesion range

    for (var other in particles) {
      if (other != particle) {
        final distance = (particle.position - other.position).length;
        if (distance > 0 && distance < cohesionRadius) {
          cohesion.add(other.position);
          count++;
        }
      }
    }

    if (count > 0) {
      cohesion.scale(1.0 / count);
      // Create steering vector towards center of mass
      final desired = cohesion - particle.position;
      if (desired.length > 0) {
        desired.normalize();
        desired.scale(1.0); // Max cohesion speed
        final steer = desired - particle.velocity;
        steer.scale(0.03); // Adjust cohesion strength
        return steer;
      }
    }

    return cohesion;
  }

  void _updateParticles() {
    if (!mounted || _bounds == null) return;

    setState(() {
      _time += 0.016 * widget.patternSpeed;

      for (var particle in particles) {
        if (widget.enablePhysics) {
          // Apply forces
          for (var force in _forces) {
            final forceVector = force.apply(particle, particles, _time, _bounds!);
            particle.applyForce(forceVector);
          }

          // Apply patterns
          for (var pattern in widget.patterns) {
            _applyPattern(particle, pattern);
          }

          // Handle pointer interaction
          if (widget.enableInteraction && _pointerPosition != null) {
            _handlePointerInteraction(particle);
          }

          // Update physics
          particle.update(0.016);
          particle.handleWallCollision(_bounds!);
        }

        // Handle particle lifecycle
        if (particle.isDead) {
          final index = particles.indexOf(particle);
          particles[index] = _createParticle();
        }
      }
    });
  }

  void _applyPattern(EnhancedParticle particle, AnimationPattern pattern) {
    switch (pattern) {
      case AnimationPattern.dna:
        _applyDNAPattern(particle);
        break;
      case AnimationPattern.magneticField:
        _applyMagneticFieldPattern(particle);
        break;
      case AnimationPattern.chaos:
        _applyChaosPattern(particle);
        break;
      case AnimationPattern.flocking:
        _applyFlockingPattern(particle);
        break;
      case AnimationPattern.soundWave:
        _applySoundWavePattern(particle, _time);
        break;
      default:
        // Apply existing patterns...
        break;
    }
  }

void _applyFlockingPattern(EnhancedParticle particle) {
  // Calculate flocking forces
  final separation = _calculateSeparation(particle);
  final alignment = _calculateAlignment(particle);
  final cohesion = _calculateCohesion(particle);

  // Apply flocking forces with weights
  particle.velocity += separation * 0.03; // Separation weight
  particle.velocity += alignment * 0.01;  // Alignment weight
  particle.velocity += cohesion * 0.01;   // Cohesion weight

  // Limit velocity to prevent excessive speeds
  if (particle.velocity.length > 4.0) {
    particle.velocity.normalize();
    particle.velocity.scale(4.0);
  }
}
  // Pattern implementations...
  void _applyDNAPattern(EnhancedParticle particle) {
    final t = _time * 0.5;
    final angle = particle.initialPosition.x * 0.1;
    final radius = 100.0;

    particle.position = vector.Vector2(
      particle.initialPosition.x,
      particle.initialPosition.y + math.sin(t + angle) * radius * math.cos(angle),
    );
  }

  void _handlePointerInteraction(EnhancedParticle particle) {
    if (_pointerPosition == null) return;

    final pointerVector = vector.Vector2(_pointerPosition!.dx, _pointerPosition!.dy);
    final toPointer = pointerVector - particle.position;
    final distance = toPointer.length;

    if (distance > 0 && distance < 100) {
      final force = toPointer.normalized() * (1000 / (distance * distance));
      particle.applyForce(force);
      particle.isCollidingWithPointer = true;
    } else {
      particle.isCollidingWithPointer = false;
    }
  }


  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _bounds = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanUpdate: widget.enableInteraction
              ? (details) => setState(() => _pointerPosition = details.localPosition)
              : null,
          onPanEnd: widget.enableInteraction
              ? (_) => setState(() => _pointerPosition = null)
              : null,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: ParticleFieldPainter(
                  particles: particles,
                  time: _time,
                  pointerPosition: _pointerPosition,
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

// Part 8: Custom Painter
class ParticleFieldPainter extends CustomPainter {
  final List<EnhancedParticle> particles;
  final double time;
  final Offset? pointerPosition;

  ParticleFieldPainter({
    required this.particles,
    required this.time,
    this.pointerPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw force field visualization
    if (pointerPosition != null) {
      _drawForceField(canvas, pointerPosition!, size);
    }

    // Draw magnetic field lines
    _drawMagneticFieldLines(canvas, size);

    // Draw trails first for proper layering
    for (var particle in particles) {
      _drawTrail(canvas, particle);
    }

    // Draw particles
    for (var particle in particles) {
      _drawParticle(canvas, particle);
    }

    // Draw connections between nearby particles
    _drawParticleConnections(canvas);
  }

  void _drawForceField(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.2),
          Colors.blue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 100));

    canvas.drawCircle(center, 100, paint);
  }

  void _drawMagneticFieldLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final strength = _calculateMagneticFieldStrength(Offset(x, y));
        final angle = _calculateMagneticFieldAngle(Offset(x, y));

        path.moveTo(x, y);
        path.lineTo(
          x + math.cos(angle) * strength * 20,
          y + math.sin(angle) * strength * 20,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  double _calculateMagneticFieldStrength(Offset point) {
    double strength = 0;
    for (var particle in particles) {
      final distance = (point - particle.position.toOffset()).distance;
      if (distance > 0) {
        strength += particle.charge / (distance * distance);
      }
    }
    return strength.abs();
  }

  double _calculateMagneticFieldAngle(Offset point) {
    double angleX = 0;
    double angleY = 0;
    for (var particle in particles) {
      final delta = particle.position.toOffset() - point;
      final distance = delta.distance;
      if (distance > 0) {
        final contribution = particle.charge / (distance * distance);
        angleX += contribution * delta.dx / distance;
        angleY += contribution * delta.dy / distance;
      }
    }
    return math.atan2(angleY, angleX);
  }

  void _drawTrail(Canvas canvas, EnhancedParticle particle) {
    if (particle.trail.isEmpty) return;

    final path = Path();
    path.moveTo(
      particle.trail.first.position.x,
      particle.trail.first.position.y,
    );

    for (var i = 1; i < particle.trail.length; i++) {
      final point = particle.trail[i];
      final prevPoint = particle.trail[i - 1];

      // Calculate control points for smooth curve
      final ctrl1 = Offset(
        prevPoint.position.x + (point.position.x - prevPoint.position.x) / 3,
        prevPoint.position.y + (point.position.y - prevPoint.position.y) / 3,
      );
      final ctrl2 = Offset(
        prevPoint.position.x + 2 * (point.position.x - prevPoint.position.x) / 3,
        prevPoint.position.y + 2 * (point.position.y - prevPoint.position.y) / 3,
      );

      path.cubicTo(
        ctrl1.dx, ctrl1.dy,
        ctrl2.dx, ctrl2.dy,
        point.position.x, point.position.y,
      );
    }

    // Create gradient for trail
    final gradient = ui.Gradient.linear(
      particle.trail.first.position.toOffset(),
      particle.trail.last.position.toOffset(),
      [
        particle.color.withOpacity(0.5),
        particle.color.withOpacity(0.0),
      ],
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = particle.size * 0.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  void _drawParticle(Canvas canvas, EnhancedParticle particle) {
    canvas.save();
    canvas.translate(particle.position.x, particle.position.y);
    canvas.rotate(particle.angle);

    // Draw glow effect for charged particles
    if (particle.charge.abs() > 0.5) {
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

      canvas.drawCircle(
        Offset.zero,
        particle.size * 1.5,
        glowPaint,
      );
    }

    // Draw particle
    final paint = Paint()
      ..color = particle.isCollidingWithPointer
          ? particle.color.withRed(255)
          : particle.color.withOpacity(particle.lifeProgress);

    switch (particle.shape) {
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
      case ParticleShape.custom:
        if (particle.customPath != null) {
          canvas.drawPath(particle.customPath!, paint);
        }
        break;
    }

    canvas.restore();
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
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
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
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawParticleConnections(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < particles.length; i++) {
      for (var j = i + 1; j < particles.length; j++) {
        final particle1 = particles[i];
        final particle2 = particles[j];
        final distance = (particle1.position - particle2.position).length;

        if (distance < 100) {
          final opacity = (1 - distance / 100) * 0.3;
          paint.color = particle1.color.withValues(alpha: 0.5 * opacity);

          canvas.drawLine(
            particle1.position.toOffset(),
            particle2.position.toOffset(),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticleFieldPainter oldDelegate) =>
      true; // For continuous animation
}

// Enhanced Pattern Implementations
void _applyMagneticFieldPattern(EnhancedParticle particle) {
  final center = vector.Vector2(200, 400);
  final toCenter = center - particle.position;
  final distance = toCenter.length;

  if (distance > 0) {
    final perpendicular = vector.Vector2(-toCenter.y, toCenter.x) / distance;
    particle.velocity += perpendicular * (50 / distance) * particle.charge;
  }
}

void _applyChaosPattern(EnhancedParticle particle) {
  // Lorenz attractor parameters
  const sigma = 10.0;
  const rho = 28.0;
  const beta = 8.0 / 3.0;

  final dt = 0.001;
  final x = particle.position.x;
  final y = particle.position.y;
  final z = particle.velocity.length;

  particle.velocity.x += (sigma * (y - x)) * dt;
  particle.velocity.y += (x * (rho - z) - y) * dt;
  particle.velocity.r += (x * y - beta * z) * dt;
}



void _applySoundWavePattern(EnhancedParticle particle, double time) {
  final frequency = 2.0;
  final amplitude = 50.0;
  final phase = particle.initialPosition.x * 0.1;

  particle.position.y = particle.initialPosition.y +
      amplitude * math.sin(frequency * time + phase);

  // Add harmonic overtones
  particle.position.y += amplitude * 0.5 *
      math.sin(2 * frequency * time + phase);
  particle.position.y += amplitude * 0.25 *
      math.sin(3 * frequency * time + phase);
}
 */
