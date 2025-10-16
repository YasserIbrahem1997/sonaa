import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/ad_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../view_model/auth_cubit/auth_cubit.dart';
import '../../../view_model/auth_cubit/auth_state.dart';
import '../../../view_model/home_cubit/home_cubit.dart';
import '../../../view_model/home_cubit/home_state.dart';
import '../add_ad_screens/add_ad_screen.dart';
import 'ad_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // Home - Already here
        break;
      case 1:
      // Search page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search page - Coming soon')),
        );
        break;
      case 2:
      // My Ads page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('My Ads page - Coming soon')),
        );
        break;
      case 3:
      // Alerts page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerts page - Coming soon')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(repository: HomeRepository())..loadAllData(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
            builder: (context, homeState) {
              return Scaffold(
                backgroundColor: Colors.grey.shade50,
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<HomeCubit>().loadAllData(),
                    child: CustomScrollView(
                      slivers: [
                        // Header Section
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.shade600,
                                  Colors.cyan.shade700,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                            child: Column(
                              children: [
                                // Location & Add Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Location',
                                          style: TextStyle(
                                            color: Colors.cyan.shade100,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Row(
                                          children: [
                                            Icon(Icons.location_on, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'New York, USA',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, size: 32),
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const AddAdScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search cars, jobs, houses...',
                                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        context.read<HomeCubit>().searchAds(value);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Featured Ads
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Featured Ads',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        children: [
                                          const Text('See All', style: TextStyle(fontSize: 14)),
                                          Icon(Icons.chevron_right, size: 18, color: Colors.cyan.shade600),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                homeState.isFeaturedLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : homeState.featuredAds.isEmpty
                                    ? Container(
                                  height: 160,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No featured ads yet',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                )
                                    : SizedBox(
                                  height: 160,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homeState.featuredAds.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final ad = homeState.featuredAds[index];
                                      return _buildFeaturedCard(
                                        ad.images.isNotEmpty ? ad.images.first : '',
                                        ad.title,
                                        'Featured',
                                          ad

                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Categories
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Categories',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 16),
                                homeState.isCategoriesLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : homeState.categories.isEmpty
                                    ? Container(
                                  padding: const EdgeInsets.all(32),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No categories available',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                )
                                    : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: homeState.categories.length,
                                  itemBuilder: (context, index) {
                                    final category = homeState.categories[index];
                                    final count = homeState.categoryCounts[category]?.toString() ?? '0';
                                    final color = _getCategoryColor(index);
                                    final icon = _getCategoryIcon(category);

                                    return _buildCategoryItem(
                                      context,
                                      icon,
                                      category,
                                      count,
                                      color,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Recent Ads
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recent Ads',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        children: [
                                          const Text('View All', style: TextStyle(fontSize: 14)),
                                          Icon(Icons.chevron_right, size: 18, color: Colors.cyan.shade600),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                homeState.isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : homeState.recentAds.isEmpty
                                    ? Container(
                                  padding: const EdgeInsets.all(32),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No ads found',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                  ),
                                )
                                    : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: homeState.recentAds.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final ad = homeState.recentAds[index];
                                    return _buildRecentAdItem(ad);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Padding
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: _buildBottomNav(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(String imageUrl, String title, String badge, AdModel ad ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdDetailsScreen(ad: ad,),
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              )
                  : Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context,
      IconData icon,
      String name,
      String count,
      Color color,
      ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.read<HomeCubit>().loadCategoryAds(name);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Loading $name ads...')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                count,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAdItem(ad) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdDetailsScreen(ad: ad,),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
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
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ad.images.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ad.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                  ),
                )
                    : Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.price != null ? '\${ad.price}' : 'Price not set',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ad.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.favorite_border,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              _buildNavItem(Icons.business_center, 'My Ads', 2),
              _buildNavItem(Icons.notifications, 'Alerts', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.cyan.shade600 : Colors.grey.shade400,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? Colors.cyan.shade600 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper: اختيار لون للكاتيجوري
  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue.shade500,
      Colors.green.shade500,
      Colors.purple.shade500,
      Colors.orange.shade500,
      Colors.pink.shade500,
      Colors.red.shade500,
      Colors.teal.shade500,
      Colors.indigo.shade500,
      Colors.amber.shade500,
      Colors.deepPurple.shade500,
    ];
    return colors[index % colors.length];
  }

  // ✅ Helper: اختيار أيقونة للكاتيجوري
  IconData _getCategoryIcon(String category) {
    final Map<String, IconData> icons = {
      'Cars': Icons.directions_car,
      'Real Estate': Icons.home,
      'Jobs': Icons.work,
      'Electronics': Icons.laptop,
      'Mobiles': Icons.phone_android,
      'Fashion': Icons.checkroom,
      'Furniture': Icons.weekend,
      'Services': Icons.business_center,
    };

    return icons[category] ?? Icons.category;
  }
}