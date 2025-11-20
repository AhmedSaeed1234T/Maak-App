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
    const primary = Color(0xFF13A9F6);
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
      body: providers.isEmpty && !isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لم يتم العثور على نتائج',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حاول تغيير معايير البحث',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${providers.length} نتائج',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= providers.length) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator(color: primary)),
                        );
                      }

                      final provider = providers[index];
                      return _buildProviderCard(context, provider, primary);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProviderCard(BuildContext context, ServiceProvider provider, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerProfilePage(provider: provider),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.isCompany
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withOpacity(0.15),
                      ),
                      child: Icon(Icons.business, color: Colors.orange, size: 24),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundImage: provider.imageUrl != null
                          ? NetworkImage(provider.imageUrl!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: provider.imageUrl == null
                          ? Icon(Icons.person, color: Colors.grey[600], size: 28)
                          : null,
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.skill,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPay(provider),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: primary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
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
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'عرض',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
