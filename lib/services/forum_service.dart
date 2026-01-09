import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/academic_forum/models/forum_model.dart';
import 'moderation_service.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModerationService _moderationService = ModerationService.instance;

  static final ForumService instance = ForumService._init();
  ForumService._init();

  CollectionReference get _postsRef => _firestore.collection('posts');

  /// Get stream of questions
  Stream<List<AcademicQuestion>> getQuestionsStream({
    String? subject,
    bool onlyUnanswered = false,
  }) {
    Query query = _postsRef.orderBy('createdAt', descending: true);

    if (subject != null && subject.isNotEmpty) {
      query = query.where('subject', isEqualTo: subject);
    }
    
    // 'onlyUnanswered' via query if possible, or client side. 
    // Firestore can't easily do `where('answerCount', isEqualTo: 0)` AND `orderBy('createdAt')` 
    // without composite index. For now, client side if volume is low, or separate index.
    // Let's rely on client side filter for 'unanswered' for simplicity in MVP.

    return query.snapshots().map((snapshot) {
      final questions = snapshot.docs
          .map((doc) => AcademicQuestion.fromFirestore(doc))
          .toList();
      
      if (onlyUnanswered) {
        return questions.where((q) => q.answerCount == 0).toList();
      }
      return questions;
    });
  }

  /// Get stream of single question
  Stream<AcademicQuestion> getQuestionStream(String questionId) {
    return _postsRef.doc(questionId).snapshots().map((doc) => AcademicQuestion.fromFirestore(doc));
  }
  
  /// Get stream of answers for a question
  Stream<List<Answer>> getAnswersStream(String questionId) {
    return _postsRef
        .doc(questionId)
        .collection('answers')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Answer.fromFirestore(doc)).toList();
    });
  }

  /// Create a new question
  Future<void> createQuestion(AcademicQuestion question) async {
    await _moderationService.validateContent('${question.title} ${question.content}');
    
    final docRef = _postsRef.doc();
    final newQuestion = question.copyWith(id: docRef.id);
    await docRef.set(newQuestion.toFirestore());
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    await _postsRef.doc(questionId).delete();
  }

  /// Add an answer
  Future<void> addAnswer(String questionId, Answer answer) async {
    await _moderationService.validateContent(answer.content);

    final questionRef = _postsRef.doc(questionId);
    final answerRef = questionRef.collection('answers').doc();
    
    final newAnswer = Answer(
      id: answerRef.id,
      questionId: questionId,
      authorId: answer.authorId,
      authorName: answer.authorName,
      content: answer.content,
      createdAt: DateTime.now(),
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(answerRef, newAnswer.toFirestore());
      transaction.update(questionRef, {
        'answerCount': FieldValue.increment(1),
      });
    });
  }

  /// Toggle Question Upvote
  Future<void> toggleQuestionUpvote(String questionId, String userId) async {
    final docRef = _postsRef.doc(questionId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final question = AcademicQuestion.fromFirestore(doc);
      final hasUpvoted = question.upvotedBy.contains(userId);
      
      List<String> newUpvotedBy = List.from(question.upvotedBy);
      int newCount = question.upvoteCount;

      if (hasUpvoted) {
        newUpvotedBy.remove(userId);
        newCount--;
      } else {
        newUpvotedBy.add(userId);
        newCount++;
      }
      
      transaction.update(docRef, {
        'upvoteCount': newCount,
        'upvotedBy': newUpvotedBy,
      });
    });
  }

  /// Toggle Answer Upvote (Helpful)
  Future<void> toggleAnswerUpvote(String questionId, String answerId, String userId) async {
    final docRef = _postsRef.doc(questionId).collection('answers').doc(answerId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final data = doc.data()!;
      final helpfulByIds = List<String>.from(data['helpfulByIds'] ?? []);
      final hasUpvoted = helpfulByIds.contains(userId);
      
      int newCount = data['helpfulCount'] ?? 0;

      if (hasUpvoted) {
        helpfulByIds.remove(userId);
        newCount--;
      } else {
        helpfulByIds.add(userId);
        newCount++;
      }
      
      transaction.update(docRef, {
        'helpfulCount': newCount,
        'helpfulByIds': helpfulByIds,
      });
    });
  }

  /// Mark Answer as Accepted
  Future<void> markAnswerAsAccepted(String questionId, String answerId) async {
     final questionRef = _postsRef.doc(questionId);
     final answersRef = questionRef.collection('answers');
     
     // Unmark any previously accepted answer? 
     // For simplicity, we assume one accepted answer.
     // Better to run transaction to unmark others if multiple allowed/checked.
     
     await _firestore.runTransaction((transaction) async {
        final questionDoc = await transaction.get(questionRef);
        final data = questionDoc.data() as Map<String, dynamic>?;
        final currentAcceptedId = data?['acceptedAnswerId'];
        
        if (currentAcceptedId != null) {
           transaction.update(answersRef.doc(currentAcceptedId), {'isAccepted': false});
        }
        
        transaction.update(answersRef.doc(answerId), {'isAccepted': true});
        transaction.update(questionRef, {
          'acceptedAnswerId': answerId,
          'isResolved': true,
        });
     });
  }
}
