// lib/widgets/chat_bubble_clipper.dart
import 'package:flutter/material.dart';

class ChatBubbleClipper extends CustomClipper<Path> {
  // Ensure 'ChatBubbleClipper' with no underscore
  final double borderRadius;
  final double tailSize;

  ChatBubbleClipper({this.borderRadius = 8.0, this.tailSize = 12.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Adjusted height for the tail to be correctly attached to the bottom of the main shape
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height - tailSize);
    final RRect rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    path.addRRect(rRect);

    // Add the tail (a small triangle at the bottom center)
    final double tailWidth = tailSize * 1.2;
    final double tailHeight = tailSize;
    final double tailCenterX = size.width / 2;
    final double tailTopY =
        size.height - tailHeight; // Tail starts where the rounded rect ends

    path.moveTo(tailCenterX - tailWidth / 2, tailTopY); // Start of tail base
    path.lineTo(
      tailCenterX,
      size.height,
    ); // Tip of the tail (at the very bottom)
    path.lineTo(tailCenterX + tailWidth / 2, tailTopY); // End of tail base

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Only reclip if borderRadius or tailSize changes
    if (oldClipper is ChatBubbleClipper) {
      return oldClipper.borderRadius != borderRadius ||
          oldClipper.tailSize != tailSize;
    }
    return false;
  }
}
