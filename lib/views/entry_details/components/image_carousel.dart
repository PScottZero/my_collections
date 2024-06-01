import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:my_collections/views/entry_details/components/clickable_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  final MyCollectionsModel model;

  const ImageCarousel(this.model, {super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _activeIndex = 0;
  Function(Function())? _setIndicatorState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: widget.model.currImages
              .map(
                (image) => ClickableImage(
                  image: image.image,
                  bytes: widget.model.currImageData[image.image]!,
                ),
              )
              .toList(),
          options: CarouselOptions(
            aspectRatio: 1,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              if (_setIndicatorState != null) {
                _setIndicatorState!(() => _activeIndex = index);
              }
            },
          ),
        ),
        Constants.height16,
        StatefulBuilder(
          builder: (context, setState) {
            _setIndicatorState = setState;
            return AnimatedSmoothIndicator(
              activeIndex: _activeIndex,
              count: widget.model.currImages.length,
              effect: ScaleEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Theme.of(context).colorScheme.secondaryContainer,
                dotWidth: 6,
                dotHeight: 6,
                scale: 1.8,
              ),
            );
          },
        ),
      ],
    );
  }
}
