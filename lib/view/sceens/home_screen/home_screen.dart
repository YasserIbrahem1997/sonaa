import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../../data/model/ad_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../view_model/auth_cubit/auth_cubit.dart';
import '../../../view_model/auth_cubit/auth_state.dart';
import '../../../view_model/favorites_cuibt/favorites_cubit.dart';
import '../../../view_model/home_cubit/home_cubit.dart';
import '../../../view_model/home_cubit/home_state.dart';
import '../../widgets/home_widget/FavoriteButton.dart';
import '../add_ad_screens/add_ad_screen.dart';
import '../profile/profile_screen.dart';
import '../search_screen/SearchScreen.dart';
import 'ad_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  final List<IconData> iconList = [
    Icons.home,
    Icons.search,
    Icons.business_center,
    Icons.settings,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                body: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _bottomNavIndex = index;
                    });
                  },
                  children: [
                    // 0 - Home Page
                    _buildHomePage(homeState),
                    // 1 - Search Page
                    const SearchScreen(),
                    // 2 - My Ads Page
                    _buildPlaceholderPage('My Ads', Icons.business_center),
                    // 3 - Alerts Page
                    ProfileScreen(),
                  ],
                ),


                bottomNavigationBar: AnimatedBottomNavigationBar(
                  icons: iconList,
                  activeIndex: _bottomNavIndex,
                  gapLocation: GapLocation.none,
                  notchSmoothness: NotchSmoothness.verySmoothEdge,
                  leftCornerRadius: 32,
                  rightCornerRadius: 32,
                  onTap: _onNavItemTapped,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey.shade400,
                  backgroundColor: Colors.grey.shade100,
                  splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  elevation: 8,
                  iconSize: 28,
                  height: 70,

                  // ✅ إضافة النصوص تحت الأيقونات
                  gapWidth: 0,
                  borderColor: Colors.transparent,

                  // إعدادات إضافية لتحسين المظهر
                  shadow: BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ========== HOME PAGE ==========
  Widget _buildHomePage(HomeState homeState) {
    final SupabaseClient client = Supabase.instance.client;
    final user = client.auth.currentUser;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<HomeCubit>().loadAllData(),
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    // Location & User Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello 👋',
                              style: TextStyle(
                                color: Colors.cyan.shade100,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.userMetadata?['full_name'] ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),


                          ],
                        ),
                        IconButton( color: Colors.white, onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('notifications - Coming soon')),
                            );

                        },  icon:Icon(Icons.notifications_active,) ),

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
                        onTap: () {
                          // الانتقال لصفحة البحث عند الضغط على الـ search bar
                          _onNavItemTapped(1);
                        },
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
                        ? _buildFeaturedShimmer()
                        : homeState.featuredAds.isEmpty
                        ? _buildEmptyFeatured()
                        : SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: homeState.featuredAds.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final ad = homeState.featuredAds[index];
                          return _buildFeaturedCard(ad);
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
                        ? _buildCategoriesShimmer()
                        : homeState.categories.isEmpty
                        ? _buildEmptyCategories()
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
                        final count = homeState.categoryCounts[category]?.toString() ?? '1';
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
                        ? _buildRecentAdsShimmer()
                        : homeState.recentAds.isEmpty
                        ? _buildEmptyRecentAds()
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

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ========== PLACEHOLDER PAGES ==========
  Widget _buildPlaceholderPage(String title, IconData icon) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SHIMMER EFFECTS ==========

  Widget _buildFeaturedShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentAdsShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 100,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== EMPTY STATES ==========

  Widget _buildEmptyFeatured() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Text(
        'No featured ads yet',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildEmptyCategories() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(
        'No categories available',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildEmptyRecentAds() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(
        'No ads found',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      ),
    );
  }

  // ========== ACTUAL CONTENT WIDGETS ==========

  Widget _buildFeaturedCard(AdModel ad) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdDetailsScreen(ad: ad),
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
              ad.images.isNotEmpty
                  ? Image.network(
                ad.images.first,
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
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ad.title,
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

  Widget _buildRecentAdItem(AdModel ad) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        final isFavorited = favoritesState is FavoritesLoaded &&
            favoritesState.favoriteIds.contains(ad.id);

        return Material(
          color: Colors.white,
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdDetailsScreen(ad: ad),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Row(
                      children: [
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
                                ad.price != null ? '\$${ad.price}' : 'Price not set',
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
                      ],
                    ),
                  ),
                ),
                FavoriteButton(
                  adId: ad.id,
                  isFavorited: isFavorited,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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