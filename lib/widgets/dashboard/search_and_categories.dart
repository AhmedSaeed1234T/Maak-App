import 'package:abokamall/helpers/enums.dart';
import 'package:flutter/material.dart';

const primary = Color(0xFF13A9F6);

class SearchAndCategories extends StatelessWidget {
  final bool isExpired;
  final String? expirationMessage;
  final bool hasInternet;
  final String search;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchTap;
  final List<String> tabs;
  final int tabIndex;
  final List<ProviderType> providerTypes;
  final Function(int) onTabChanged;

  const SearchAndCategories({
    super.key,
    required this.isExpired,
    this.expirationMessage,
    required this.hasInternet,
    required this.search,
    required this.onSearchChanged,
    required this.onSearchTap,
    required this.tabs,
    required this.tabIndex,
    required this.providerTypes,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isExpired) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B0000).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF8B0000),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        expirationMessage ?? "لقد انتهي اشتراكك",
                        style: const TextStyle(
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ] else if (hasInternet) ...[
              TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة...',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  prefixIcon: const Icon(Icons.search, color: primary),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primary, width: 2),
                  ),
                ),
                onChanged: onSearchChanged,
                onTap: onSearchTap,
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => onTabChanged(i),
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: tabIndex == i ? primary : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(20),
                      border: tabIndex != i
                          ? Border.all(color: const Color(0xFFE0E0E0), width: 1)
                          : null,
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: tabIndex == i ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
