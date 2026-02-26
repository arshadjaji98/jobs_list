import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // tap to close
        child: Center(
          child: InteractiveViewer(
            // zoom & pan
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
