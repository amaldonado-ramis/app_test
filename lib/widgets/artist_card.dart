import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/models/artist.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/artist/${artist.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          ClipOval(
            child: AspectRatio(
              aspectRatio: 1,
              child: artist.getPictureUrl().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artist.getPictureUrl(),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
