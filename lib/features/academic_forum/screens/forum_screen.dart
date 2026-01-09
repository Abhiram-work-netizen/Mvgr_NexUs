import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../services/forum_service.dart';
import '../../../services/moderation_service.dart';
import '../models/forum_model.dart';

/// Premium Discussion Forum Screen - Q&A Focused
class AcademicForumScreen extends StatefulWidget {
  const AcademicForumScreen({super.key});

  @override
  State<AcademicForumScreen> createState() => _AcademicForumScreenState();
}

class _AcademicForumScreenState extends State<AcademicForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forumColor,
                      AppColors.forumColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Discussion Forum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask anything, share knowledge, help others',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _showAskQuestionSheet(context),
                tooltip: 'Ask Question',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.forumColor,
                unselectedLabelColor: context.appColors.textSecondary,
                indicatorColor: AppColors.forumColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Recent'),
                  Tab(text: 'Unanswered'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _QuestionsList(filter: 'recent', selectedSubject: _selectedSubject),
            _QuestionsList(
              filter: 'unanswered',
              selectedSubject: _selectedSubject,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAskQuestionSheet(context),
        backgroundColor: AppColors.forumColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAskQuestionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AskQuestionSheet(),
    );
  }
}

/// Sliver Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

/// Questions List
class _QuestionsList extends StatelessWidget {
  final String filter;
  final String? selectedSubject;

  const _QuestionsList({required this.filter, this.selectedSubject});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AcademicQuestion>>(
      stream: ForumService.instance.getQuestionsStream(
        subject: selectedSubject,
        onlyUnanswered: filter == 'unanswered',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text('Error: ${snapshot.error}'));
        }

        var questions = snapshot.data ?? [];

        // Sorting is done by Firestore query largely (descending createdAt), but if we want strictly filtered or sorted differently we can do it here.
        // The service already orders by createdAt descending.

        if (questions.isEmpty) {
          return _EmptyState(
            icon: Icons.forum_outlined,
            title: filter == 'unanswered'
                ? 'All questions answered!'
                : 'No questions yet',
            subtitle: 'Be the first to ask a question',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: questions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _QuestionCard(question: questions[index]),
        );
      },
    );
  }
}

/// Question Card
class _QuestionCard extends StatelessWidget {
  final AcademicQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _QuestionDetailScreen(question: question),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - with overflow protection
              Row(
                children: [
                  // Badges - wrapped in Expanded for overflow safety
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Subject Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forumColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            question.subject,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forumColor,
                            ),
                          ),
                        ),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: question.category.color.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                question.category.iconData,
                                size: 12,
                                color: question.category.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                question.category.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: question.category.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (question.isResolved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Resolved',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(question.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                question.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                question.content,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Footer
              Row(
                children: [
                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          question.isAnonymous
                              ? '?'
                              : (question.authorName?[0] ?? 'A'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        question.isAnonymous
                            ? 'Anonymous'
                            : (question.authorName ?? 'Unknown'),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Stats
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: context.appColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${question.upvoteCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: context.appColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${question.answerCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}';
  }
}

/// Question Detail Screen
class _QuestionDetailScreen extends StatelessWidget {
  final AcademicQuestion question;

  const _QuestionDetailScreen({required this.question});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser ?? AppUser.empty;
    final isOwner = question.authorId == user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, question.id),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: StreamBuilder<AcademicQuestion>(
        stream: ForumService.instance.getQuestionStream(question.id),
        builder: (context, qSnapshot) {
          if (!qSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final currentQuestion = qSnapshot.data!;
          // Refreshed user binding is at the top
          final hasUpvoted = currentQuestion.upvotedBy.contains(user.uid);

          return StreamBuilder<List<Answer>>(
            stream: ForumService.instance.getAnswersStream(question.id),
            builder: (context, aSnapshot) {
              final answers = aSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Question
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forumColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentQuestion.subject,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forumColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          currentQuestion.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Content
                        Text(
                          currentQuestion.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.appColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Author & Stats
                        Row(
                          children: [
                            Text(
                              'Asked by ${currentQuestion.isAnonymous ? 'Anonymous' : (currentQuestion.authorName ?? 'Unknown')}',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textTertiary,
                              ),
                            ),
                            const Spacer(),
                            // Upvote Button
                            GestureDetector(
                              onTap: () {
                                if (user.uid.isNotEmpty) {
                                  ForumService.instance.toggleQuestionUpvote(
                                    currentQuestion.id,
                                    user.uid,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: hasUpvoted
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : context.appColors.divider,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: hasUpvoted
                                          ? AppColors.primary
                                          : context.appColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${currentQuestion.upvoteCount}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: hasUpvoted
                                            ? AppColors.primary
                                            : context.appColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answers Section
                  Row(
                    children: [
                      Text(
                        '${answers.length} Answers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAnswerSheet(context),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Answer'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.forumColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (answers.isEmpty)
                    const _EmptyCard(message: 'No answers yet. Be the first to help!')
                  else
                    ...answers.map(
                      (answer) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerCard(answer: answer, questionId: question.id),
                      ),
                    ),

                  const SizedBox(height: 60),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAnswerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnswerSheet(questionId: question.id),
    );
  }

  void _confirmDelete(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text(
            'Are you sure you want to delete this question? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen BEFORE deleting
              try {
                await ForumService.instance.deleteQuestion(questionId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question deleted')),
                  );
                }
              } catch (e) {
                // Ignore or log error
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Detail Card
class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: child,
    );
  }
}

/// Answer Card
class _AnswerCard extends StatelessWidget {
  final Answer answer;
  final String questionId;

  const _AnswerCard({required this.answer, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: answer.isAccepted
            ? AppColors.success.withValues(alpha: 0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: answer.isAccepted ? AppColors.success : context.appColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.isAccepted)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Accepted Answer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            answer.content,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  answer.authorName == 'Anonymous'
                      ? '?'
                      : (answer.authorName[0]),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                answer.authorName,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textTertiary,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) {
                  final user = context.read<UserProvider>().currentUser ?? AppUser.empty; // Handle null safely
                  final hasUpvoted = answer.helpfulByIds.contains(user.uid);

                  return GestureDetector(
                    onTap: () {
                      if (user.uid.isNotEmpty) {
                        ForumService.instance.toggleAnswerUpvote(
                          questionId,
                          answer.id,
                          user.uid,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: hasUpvoted
                              ? AppColors.primary
                              : context.appColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${answer.helpfulCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUpvoted
                                ? AppColors.primary
                                : context.appColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty Card
class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: context.appColors.textTertiary),
        ),
      ),
    );
  }
}

/// Ask Question Sheet
class _AskQuestionSheet extends StatefulWidget {
  const _AskQuestionSheet();

  @override
  State<_AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends State<_AskQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _subject = 'General';
  ForumCategory _category = ForumCategory.academic;
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Ask a Question',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Subject Dropdown
              _DropdownField(
                label: 'Subject',
                value: _subject,
                items: QuestionSubjects.all,
                onChanged: (v) => setState(() => _subject = v!),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.appColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<ForumCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: ForumCategory.values
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.iconData, size: 18, color: cat.color),
                              const SizedBox(width: 8),
                              Text(cat.displayName),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v ?? ForumCategory.academic),
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              _FormField(
                controller: _titleController,
                label: 'Question Title',
                hint: 'What do you want to know?',
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Content Field
              _FormField(
                controller: _contentController,
                label: 'Details',
                hint: 'Provide more context about your question...',
                maxLines: 4,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Details are required' : null,
              ),
              const SizedBox(height: 16),

              // Similar Questions Section (Placeholder or Search Service required)
              // For MVP, we skip client-side filtering of all questions.
              if (_titleController.text.length > 10)
                 Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 18, color: AppColors.info),
                        const SizedBox(width: 8),
                         Expanded(
                           child: Text(
                            'Tip: Search before asking to get answers faster!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                         ),
                      ],
                    ),
                 ),
              if (_titleController.text.length > 10) const SizedBox(height: 16),

              // Anonymous Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ask Anonymously'),
                subtitle: Text(
                  'Your name will be hidden',
                  style: TextStyle(color: context.appColors.textTertiary),
                ),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forumColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post Question'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));

      final user = context.read<UserProvider>().currentUser ?? AppUser.empty;
      if (user.uid.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to post')));
        return;
      }

      final question = AcademicQuestion(
        id: '', // Service generates ID
        authorId: user.uid,
        authorName: _isAnonymous ? null : user.name,
        title: _titleController.text,
        content: _contentController.text,
        subject: _subject,
        category: _category,
        isAnonymous: _isAnonymous,
        createdAt: DateTime.now(),
        upvoteCount: 0,
      );

      if (!mounted) return;
      
      // AI Moderation Check
      final isSafe = await ModerationService.instance.checkText('${_titleController.text} ${_contentController.text}');
      if (!isSafe) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post flagged as inappropriate. Please keep it professional.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        await ForumService.instance.createQuestion(question);
        
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

/// Answer Sheet
class _AnswerSheet extends StatefulWidget {
  final String questionId;

  const _AnswerSheet({required this.questionId});

  @override
  State<_AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends State<_AnswerSheet> {
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Your Answer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            _FormField(
              controller: _contentController,
              label: 'Answer',
              hint: 'Share your knowledge...',
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Answer Anonymously'),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forumColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post Answer'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final user = context.read<UserProvider>().currentUser ?? AppUser.empty;
    if (user.uid.isEmpty) {
       setState(() => _isLoading = false);
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
       return;
    }

    final answer = Answer(
      id: '', // Service generates ID
      questionId: widget.questionId,
      authorId: user.uid,
      authorName: _isAnonymous ? 'Anonymous' : user.name,
      content: _contentController.text,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;

    // AI Moderation Check
    final isSafe = await ModerationService.instance.checkText(_contentController.text);
    if (!isSafe) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer flagged as inappropriate.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      await ForumService.instance.addAnswer(widget.questionId, answer);
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer posted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
       );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Form Field
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.appColors.textTertiary),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.forumColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown Field
class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
