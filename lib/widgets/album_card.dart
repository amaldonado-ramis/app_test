import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/models/album.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/album/${album.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: album.getCoverUrl().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: album.getCoverUrl(),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (album.artist != null) ...[
            const SizedBox(height: 4),
            Text(
              album.artist!.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
