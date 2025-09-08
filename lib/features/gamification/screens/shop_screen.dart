import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  
  final int _userCoins = 1250;
  final int _userGems = 85;
  
  final List<ShopItem> _avatarItems = [
    ShopItem(
      id: '1',
      name: '우주 비행사',
      description: '별들 사이를 여행하는 모험가',
      icon: '🚀',
      price: 100,
      currency: Currency.coins,
      category: ItemCategory.avatar,
      isOwned: false,
      rarity: ItemRarity.rare,
    ),
    ShopItem(
      id: '2',
      name: '마법사',
      description: '지식의 마법을 부리는 현자',
      icon: '🧙‍♂️',
      price: 150,
      currency: Currency.coins,
      category: ItemCategory.avatar,
      isOwned: false,
      rarity: ItemRarity.epic,
    ),
    ShopItem(
      id: '3',
      name: '로봇',
      description: '미래에서 온 학습 도우미',
      icon: '🤖',
      price: 200,
      currency: Currency.coins,
      category: ItemCategory.avatar,
      isOwned: true,
      rarity: ItemRarity.legendary,
    ),
  ];
  
  final List<ShopItem> _boosterItems = [
    ShopItem(
      id: '4',
      name: 'XP 부스터',
      description: '30분간 XP 2배 획득',
      icon: '⚡',
      price: 50,
      currency: Currency.coins,
      category: ItemCategory.booster,
      isOwned: false,
      quantity: 3,
      rarity: ItemRarity.common,
    ),
    ShopItem(
      id: '5',
      name: '집중력 향상',
      description: '1시간 동안 방해 요소 차단',
      icon: '🎯',
      price: 10,
      currency: Currency.gems,
      category: ItemCategory.booster,
      isOwned: false,
      quantity: 1,
      rarity: ItemRarity.rare,
    ),
  ];
  
  final List<ShopItem> _themeItems = [
    ShopItem(
      id: '6',
      name: '다크 테마',
      description: '눈이 편안한 어두운 테마',
      icon: '🌙',
      price: 100,
      currency: Currency.coins,
      category: ItemCategory.theme,
      isOwned: true,
      rarity: ItemRarity.common,
    ),
    ShopItem(
      id: '7',
      name: '네온 테마',
      description: '사이버펑크 스타일의 화려한 테마',
      icon: '💜',
      price: 20,
      currency: Currency.gems,
      category: ItemCategory.theme,
      isOwned: false,
      rarity: ItemRarity.epic,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _coinAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _coinAnimationController.dispose();
    super.dispose();
  }

  void _purchaseItem(ShopItem item) {
    _coinAnimationController.forward().then((_) {
      _coinAnimationController.reverse();
    });
    
    showDialog(
      context: context,
      builder: (context) => _buildPurchaseDialog(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA),
              Color(0xFFE8EDF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with Currency
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF395886)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '상점',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    _buildCurrencyDisplay(Icons.monetization_on, _userCoins, Colors.orange),
                    const SizedBox(width: 12),
                    _buildCurrencyDisplay(Icons.diamond, _userGems, Colors.purple),
                  ],
                ),
              ),

              // Special Offer Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오늘의 특별 할인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '모든 부스터 30% 할인!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '23:59',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF638ECB),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF395886),
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: '전체'),
                    Tab(text: '아바타'),
                    Tab(text: '부스터'),
                    Tab(text: '테마'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Items Grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllItems(),
                    _buildItemGrid(_avatarItems),
                    _buildItemGrid(_boosterItems),
                    _buildItemGrid(_themeItems),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay(IconData icon, int amount, Color color) {
    return AnimatedBuilder(
      animation: _coinAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: icon == Icons.monetization_on ? _coinAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  amount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllItems() {
    final allItems = [..._avatarItems, ..._boosterItems, ..._themeItems];
    return _buildItemGrid(allItems);
  }

  Widget _buildItemGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ShopItem item) {
    Color rarityColor;
    switch (item.rarity) {
      case ItemRarity.common:
        rarityColor = Colors.grey;
        break;
      case ItemRarity.rare:
        rarityColor = Colors.blue;
        break;
      case ItemRarity.epic:
        rarityColor = Colors.purple;
        break;
      case ItemRarity.legendary:
        rarityColor = Colors.orange;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            rarityColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: item.isOwned ? null : () => _purchaseItem(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (item.quantity != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (item.isOwned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '보유중',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.currency == Currency.coins
                          ? Colors.orange
                          : Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.currency == Currency.coins
                              ? Icons.monetization_on
                              : Icons.diamond,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseDialog(ShopItem item) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1E27),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.currency == Currency.coins
                        ? Icons.monetization_on
                        : Icons.diamond,
                    color: item.currency == Currency.coins
                        ? Colors.orange
                        : Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E27),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} 구매 완료!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF638ECB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '구매',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Shop Item Model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price;
  final Currency currency;
  final ItemCategory category;
  final bool isOwned;
  final int? quantity;
  final ItemRarity rarity;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.currency,
    required this.category,
    required this.isOwned,
    this.quantity,
    required this.rarity,
  });
}

enum Currency {
  coins,
  gems,
}

enum ItemCategory {
  avatar,
  booster,
  theme,
  special,
}

enum ItemRarity {
  common,
  rare,
  epic,
  legendary,
}