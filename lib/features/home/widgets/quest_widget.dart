import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/quest_provider.dart';
import '../../../models/quest.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class QuestWidget extends ConsumerWidget {
  const QuestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeQuests = ref.watch(activeQuestsProvider);
    final completedQuests = ref.watch(completedQuestsProvider);
    final availableQuests = ref.watch(availableQuestsProvider);
    final theme = Theme.of(context);
    
    // 표시할 퀘스트 결정 (수락된/완료된 퀘스트 우선, 그 다음 사용 가능한 퀘스트)
    final displayQuests = [...activeQuests, ...completedQuests, ...availableQuests];
    
    if (displayQuests.isEmpty) {
      return SizedBox(
        height: 180,
        child: Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                AppSpacing.verticalGapMD,
                Text(
                  AppLocalizations.of(context)?.noAvailableQuests ?? '사용 가능한 퀘스트가 없습니다!',
                  style: AppTypography.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)?.quests ?? '퀘스트', style: AppTypography.titleLarge),
            TextButton(
              onPressed: () => _showAllQuests(context, ref),
              child: Text(AppLocalizations.of(context)?.viewAll ?? '모두 보기'),
            ),
          ],
        ),
        AppSpacing.verticalGapMD,
        // 가로 스크롤 퀘스트 카드
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayQuests.length,
            itemBuilder: (context, index) => _buildQuestCard(context, ref, displayQuests[index]),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestCard(BuildContext context, WidgetRef ref, Quest quest) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 180,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showQuestDetail(context, ref, quest),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 아이콘과 난이도
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: quest.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          quest.icon,
                          color: quest.color,
                          size: 20,
                        ),
                      ),
                      // 난이도 별
                      Row(
                        children: List.generate(
                          quest.difficultyStars,
                          (index) => Icon(
                            Icons.star,
                            size: 12,
                            color: quest.difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.verticalGapSM,
                  
                  // 제목
                  Text(
                    quest.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // 진행률 (수락된 퀘스트만)
                  if (quest.status == QuestStatus.accepted) ...[
                    LinearProgressIndicator(
                      value: quest.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(quest.color),
                      minHeight: 3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quest.currentValue}/${quest.targetValue}',
                      style: AppTypography.caption,
                    ),
                  ],
                  
                  // 상태 또는 보상
                  if (quest.status == QuestStatus.available)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.available ?? '수락 가능',
                          style: AppTypography.caption.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (quest.status == QuestStatus.completed)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.completed ?? '완료!',
                          style: AppTypography.caption.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.military_tech, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.xpReward} XP',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (quest.coinReward > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.monetization_on, size: 14, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            '+${quest.coinReward}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getDeadlineText(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 남음';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 남음';
    } else {
      return '${difference.inDays}일 남음';
    }
  }
  
  void _showQuestDetail(BuildContext context, WidgetRef ref, Quest quest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(quest.icon, color: quest.color),
            const SizedBox(width: 8),
            Text(quest.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명
            Text(quest.description, style: AppTypography.body),
            AppSpacing.verticalGapMD,
            
            // 난이도
            Row(
              children: [
                Text('난이도: ', style: AppTypography.body),
                Row(
                  children: List.generate(
                    quest.difficultyStars,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: quest.difficultyColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  quest.difficultyText,
                  style: AppTypography.body.copyWith(
                    color: quest.difficultyColor,
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapMD,
            
            // 진행 상황
            Text('진행 상황', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: quest.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(quest.color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${quest.currentValue}/${quest.targetValue}',
                  style: AppTypography.body,
                ),
              ],
            ),
            
            AppSpacing.verticalGapMD,
            
            // 보상
            Text('보상', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber),
                const SizedBox(width: 8),
                Text('+${quest.xpReward} XP', style: AppTypography.body),
                if (quest.coinReward > 0) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.monetization_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('+${quest.coinReward} 코인', style: AppTypography.body),
                ],
              ],
            ),
            
            if (quest.specialReward != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    '칭호: ${quest.specialReward}',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ],
            
            if (quest.deadline != null) ...[
              AppSpacing.verticalGapMD,
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '마감: ${_getDeadlineText(quest.deadline!)}',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (quest.status == QuestStatus.available)
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(questProvider.notifier).acceptQuest(quest.id);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? '퀘스트를 수락했습니다!' 
                      : _getAcceptLimitMessage(quest, ref)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)?.acceptQuest ?? '퀘스트 수락'),
            )
          else if (quest.status == QuestStatus.completed)
            ElevatedButton(
              onPressed: () {
                ref.read(questProvider.notifier).claimReward(quest.id);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('보상을 받았습니다!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)?.claimReward ?? '보상 받기'),
            ),
        ],
      ),
    );
  }
  
  String _getAcceptLimitMessage(Quest quest, WidgetRef ref) {
    final notifier = ref.read(questProvider.notifier);
    if (quest.type == QuestType.daily) {
      final accepted = notifier.getAcceptedDailyQuestCount();
      return '일일 퀘스트 제한: $accepted/3';
    } else if (quest.type == QuestType.weekly) {
      final accepted = notifier.getAcceptedWeeklyQuestCount();
      return '주간 퀘스트 제한: $accepted/2';
    }
    return '퀘스트를 수락할 수 없습니다';
  }
  
  Widget _buildQuestListItem(BuildContext context, WidgetRef ref, Quest quest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: quest.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            quest.icon,
            color: quest.color,
            size: 24,
          ),
        ),
        title: Text(quest.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            if (quest.status == QuestStatus.accepted)
              LinearProgressIndicator(
                value: quest.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(quest.color),
                minHeight: 2,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.military_tech, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                Text('+${quest.xpReward}', style: AppTypography.caption),
              ],
            ),
            if (quest.status == QuestStatus.available)
              TextButton(
                onPressed: () async {
                  final success = await ref.read(questProvider.notifier).acceptQuest(quest.id);
                  Navigator.pop(context);
                  _showAllQuests(context, ref);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? '퀘스트를 수락했습니다!' 
                        : _getAcceptLimitMessage(quest, ref)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('수락', style: TextStyle(fontSize: 12)),
              )
            else if (quest.status == QuestStatus.completed)
              TextButton(
                onPressed: () {
                  ref.read(questProvider.notifier).claimReward(quest.id);
                  Navigator.pop(context);
                  _showAllQuests(context, ref);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('보상을 받았습니다!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('보상받기', style: TextStyle(fontSize: 12, color: Colors.amber)),
              )
            else
              Text('${quest.currentValue}/${quest.targetValue}', style: AppTypography.caption),
          ],
        ),
        onTap: () => _showQuestDetail(context, ref, quest),
      ),
    );
  }

  void _showAllQuests(BuildContext context, WidgetRef ref) {
    final dailyQuests = ref.read(dailyQuestsProvider);
    final weeklyQuests = ref.read(weeklyQuestsProvider);
    final allQuests = ref.read(questProvider);
    final notifier = ref.read(questProvider.notifier);
    final acceptedDaily = notifier.getAcceptedDailyQuestCount();
    final acceptedWeekly = notifier.getAcceptedWeeklyQuestCount();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            children: [
              // 헤더
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('전체 퀘스트', style: AppTypography.titleLarge),
                        Text(
                          '일일: $acceptedDaily/3 | 주간: $acceptedWeekly/2',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // 퀘스트 목록
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: '일일 퀘스트'),
                          Tab(text: '주간 퀘스트'),
                          Tab(text: '특별 퀘스트'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 일일 퀘스트
                            ListView.builder(
                              padding: AppSpacing.paddingLG,
                              itemCount: dailyQuests.length,
                              itemBuilder: (context, index) {
                                return _buildQuestListItem(context, ref, dailyQuests[index]);
                              },
                            ),
                            // 주간 퀘스트
                            ListView.builder(
                              padding: AppSpacing.paddingLG,
                              itemCount: weeklyQuests.length,
                              itemBuilder: (context, index) {
                                return _buildQuestListItem(context, ref, weeklyQuests[index]);
                              },
                            ),
                            // 특별 퀘스트
                            ListView.builder(
                              padding: AppSpacing.paddingLG,
                              itemCount: allQuests.where((q) => q.type == QuestType.special).length,
                              itemBuilder: (context, index) {
                                final specialQuests = allQuests.where((q) => q.type == QuestType.special).toList();
                                return _buildQuestListItem(context, ref, specialQuests[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}