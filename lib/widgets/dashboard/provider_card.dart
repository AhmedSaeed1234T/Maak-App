import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const primary = Color(0xFF13A9F6);

class ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipOval(
                        child:
                            provider.imageUrl != null &&
                                provider.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: provider.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF5F7FA),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  return provider.isCompany
                                      ? Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.orange.withOpacity(
                                              0.15,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.business,
                                            color: Colors.orange,
                                            size: 24,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blue[600],
                                            size: 28,
                                          ),
                                        );
                                },
                              )
                            : provider.isCompany
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange.withOpacity(0.15),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                              )
                            : CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue[600],
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: getIt<PresenceController>().onlineUsers,
                      builder: (context, onlineUsers, _) {
                        final isOnline = getIt<PresenceController>()
                            .isUserOnline(provider.userId);
                        return Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      provider.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (provider.isOccupied) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block,
                            size: 10,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'غير متاح',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (provider.typeOfService != 'Sculptor') ...[
                Text(
                  provider.skill,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
