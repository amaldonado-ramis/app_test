import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rhapsody/models/artist.dart';
import 'package:rhapsody/theme.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final double size;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: artist.picture != null && artist.picture!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: artist.getPictureUrl(),
                    width: size - 16,
                    height: size - 16,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: size - 16,
                      height: size - 16,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: size - 16,
                      height: size - 16,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : Container(
                    width: size - 16,
                    height: size - 16,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              artist.name,
              style: context.textStyles.bodyMedium?.semiBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Artist',
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
