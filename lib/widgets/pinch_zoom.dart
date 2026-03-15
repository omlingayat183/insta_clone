

import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  final Widget child;

  const PinchZoom({super.key, required this.child});

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;

 
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _offsetAnim;

  Rect _widgetRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _animController.dispose();
    super.dispose();
  }

  Rect _getWidgetRect() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _widgetRect = _getWidgetRect();
    _startFocalPoint = details.focalPoint;
    _scale = 1.0;
    _offset = Offset.zero;
    _showOverlay();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _scale = details.scale.clamp(1.0, 4.0);
    _offset = details.focalPoint - _startFocalPoint;
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scaleAnim = Tween<double>(begin: _scale, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _offsetAnim = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.reset();
    _animController.addListener(() {
      _scale = _scaleAnim.value;
      _offset = _offsetAnim.value;
      _overlayEntry?.markNeedsBuild();
    });

    _animController.forward().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animController.removeListener(() {});
    });
  }

  void _showOverlay() {
    _overlayEntry?.remove();

   
    _overlayEntry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: _widgetRect.left + _offset.dx,
          top: _widgetRect.top + _offset.dy,
          width: _widgetRect.width,
          height: _widgetRect.height,
          child: Transform.scale(
            scale: _scale,
            child: Material(
              color: Colors.transparent,
              child: widget.child,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: widget.child,
    );
  }
}
