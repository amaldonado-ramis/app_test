import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/theme.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;
  final double size;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: size,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: album.cover != null && album.cover!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: album.getCoverUrl(),
                    width: size - 16,
                    height: size - 16,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: size - 16,
                      height: size - 16,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: size - 16,
                      height: size - 16,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : Container(
                    width: size - 16,
                    height: size - 16,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              album.title,
              style: context.textStyles.bodyMedium?.semiBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              album.artistNames,
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
