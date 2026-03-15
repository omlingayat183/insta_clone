
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'pinch_zoom.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> imageUrls;

  const CarouselWidget({super.key, required this.imageUrls});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
 
   late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.imageUrls.length == 1) {
      return _buildImage(widget.imageUrls.first);
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        
        SizedBox(
          height: 375,
          child: PageView.builder(
            controller: _pageController,
           
            physics: const BouncingScrollPhysics(),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImage(widget.imageUrls[index]);
            },
          ),
        ),

        Positioned(
          bottom: 12,
          child: SmoothPageIndicator(
  controller: _pageController,
  count: widget.imageUrls.length,
  effect: const WormEffect(
    dotHeight: 6,
    dotWidth: 6,
    activeDotColor: Colors.white,
    dotColor: Colors.white38,
    spacing: 5,
  ),
),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: _PageCounter(
            controller: _pageController,
            total: widget.imageUrls.length,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return PinchZoom(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 375,
       
        placeholder: (context, url) => Container(
          color: const Color(0xFF262626),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white30,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF262626),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined, color: Colors.white30, size: 40),
                SizedBox(height: 8),
                Text(
                  'Image unavailable',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _PageCounter extends StatelessWidget {
  final PageController controller;
  final int total;

  const _PageCounter({required this.controller, required this.total});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
       
        final page = (controller.hasClients ? (controller.page ?? 0) : 0).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${page + 1}/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
