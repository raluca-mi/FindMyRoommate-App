import 'package:flutter/material.dart';

class PageViewGallery extends StatefulWidget {
  final List<dynamic> imageUrls;

  const PageViewGallery({
    required this.imageUrls,
    super.key,
  });

  @override
  State<PageViewGallery> createState() => _PageViewGalleryState();
}

class _PageViewGalleryState extends State<PageViewGallery> {
  late PageController pageController;
  late ValueNotifier<int> currentPage;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    currentPage = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    pageController.dispose();
    currentPage.dispose();
    super.dispose();
  }

  void openFullscreenImage(BuildContext context, int index) {
    final fullscreenPageController = PageController(initialPage: index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: PageView.builder(
              itemCount: widget.imageUrls.length,
              controller: fullscreenPageController,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Hero(
                    tag: 'image_$index',
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int index) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPage,
      builder: (context, value, _) {
        int maxDots = 3;
        int diff = widget.imageUrls.length - maxDots;

        if (index < maxDots) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == value ? Colors.grey : Colors.grey[300],
            ),
          );
        } else if (index == maxDots && diff > 0) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '+$diff',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            controller: pageController,
            onPageChanged: (index) {
              currentPage.value = index;
            },
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  openFullscreenImage(context, index);
                },
                child: Hero(
                  tag: 'image_$index',
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => buildIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
