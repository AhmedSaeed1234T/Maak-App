import 'package:abokamall/screens/worker_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/models/SearchResultDto.dart';

class SearchResultsPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String specialization;
  final String governorate;
  final String city;
  final String district;
  final int? workerType;
  final dynamic providerType;

  const SearchResultsPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.specialization,
    required this.governorate,
    required this.city,
    required this.district,
    required this.workerType,
    required this.providerType,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final searchController = getIt<searchcontroller>();
  final ScrollController _scrollController = ScrollController();

  List<ServiceProvider> providers = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchResults();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        _fetchResults();
      }
    });
  }

  Future<void> _fetchResults() async {
    setState(() => isLoading = true);

    // <-- simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final result = await searchController.searchWorkers(
      widget.firstName,
      widget.lastName,
      widget.specialization,
      widget.governorate,
      widget.city,
      widget.district,
      widget.workerType,
      widget.providerType,
      false,
      currentPage,
    );

    setState(() {
      providers.addAll(result);
      isLoading = false;
      currentPage++;

      if (result.length < pageSize) {
        hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'نتائج البحث',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${providers.length} نتائج',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: providers.length + (isLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index >= providers.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final provider = providers[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.isCompany
                          ? CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.orange[100],
                              child: const Icon(
                                Icons.business,
                                color: Colors.orange,
                                size: 30,
                              ),
                            )
                          : CircleAvatar(
                              radius: 28,
                              backgroundImage: provider.imageUrl != null
                                  ? NetworkImage(provider.imageUrl!)
                                  : null,
                              backgroundColor: Colors.grey[200],
                              child: provider.imageUrl == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.skill,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    provider.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatPay(provider),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WorkerProfilePage(provider: provider),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'عرض',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPay(ServiceProvider provider) {
    final pay = provider.pay ?? '0';
    if (provider.typeOfService == 'Worker') {
      if (provider.workerType == 0) return '$pay ج باليومية';
      if (provider.workerType == 1) return '$pay ج بالمشروع';
      return '$pay ج';
    }
    if (provider.typeOfService == 'Engineer') return '$pay ج بالمرتب';
    if (provider.typeOfService == 'Contractor' ||
        provider.typeOfService == 'Company')
      return '$pay ج بالمشروع';
    return '$pay ج';
  }
}
