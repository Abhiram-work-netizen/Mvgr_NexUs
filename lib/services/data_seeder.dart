import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../features/clubs/models/club_model.dart';
import '../features/events/models/event_model.dart';
import '../features/mentorship/models/mentorship_model.dart';
import '../features/study_buddy/models/study_buddy_model.dart';
import '../features/play_buddy/models/play_buddy_model.dart';
import '../features/lost_found/models/lost_found_model.dart';
import '../features/vault/models/vault_model.dart';

/// Data Seeder - Creates sample data for demo/testing
class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final DataSeeder instance = DataSeeder._init();
  DataSeeder._init();

  /// Seed all demo data
  Future<void> seedAll() async {
    debugPrint('🌱 Starting data seeding...');
    
    await seedClubs();
    await seedEvents();
    await seedMentors();
    await seedStudyRequests();
    await seedTeamRequests();
    await seedLostFoundItems();
    await seedVaultResources();
    await seedAnnouncements();
    
    debugPrint('✅ Data seeding complete!');
  }

  /// Seed sample clubs
  Future<void> seedClubs() async {
    final clubs = [
      {
        'name': 'GDSC MVGR',
        'description': 'Google Developer Student Clubs - Learn, grow and build with Google technologies. Weekly workshops, hackathons, and study jams.',
        'category': ClubCategory.technical.name,
        'coverImageUrl': '',
        'adminIds': ['test_admin_001'],
        'memberIds': ['test_admin_001', 'test_student_001', 'test_student_002'],
        'pendingMemberIds': [],
        'tags': ['Google', 'Android', 'Flutter', 'Cloud', 'ML'],
        'isActive': true,
        'createdAt': Timestamp.now(),
        'memberCount': 3,
      },
      {
        'name': 'CodeChef MVGR',
        'description': 'Competitive programming club. Daily challenges, weekly contests, and mentorship from top rankers.',
        'category': ClubCategory.technical.name,
        'coverImageUrl': '',
        'adminIds': ['test_admin_002'],
        'memberIds': ['test_admin_002', 'test_student_001'],
        'pendingMemberIds': [],
        'tags': ['CP', 'DSA', 'Algorithms', 'Contest'],
        'isActive': true,
        'createdAt': Timestamp.now(),
        'memberCount': 2,
      },
      {
        'name': 'Literary Society',
        'description': 'For the love of literature! Book discussions, poetry slams, creative writing workshops, and more.',
        'category': ClubCategory.cultural.name,
        'coverImageUrl': '',
        'adminIds': ['test_admin_003'],
        'memberIds': ['test_admin_003', 'test_student_002'],
        'pendingMemberIds': [],
        'tags': ['Literature', 'Poetry', 'Writing', 'Books'],
        'isActive': true,
        'createdAt': Timestamp.now(),
        'memberCount': 2,
      },
      {
        'name': 'Robotics Club',
        'description': 'Build robots, compete in nationals! Arduino, Raspberry Pi, drone projects and more.',
        'category': ClubCategory.technical.name,
        'coverImageUrl': '',
        'adminIds': ['test_admin_001'],
        'memberIds': ['test_admin_001'],
        'pendingMemberIds': ['test_student_001'],
        'tags': ['Robotics', 'Arduino', 'IoT', 'Drones'],
        'isActive': true,
        'createdAt': Timestamp.now(),
        'memberCount': 1,
      },
      {
        'name': 'Dance Crew',
        'description': 'Express yourself through dance! Hip-hop, contemporary, classical - all styles welcome.',
        'category': ClubCategory.cultural.name,
        'coverImageUrl': '',
        'adminIds': ['test_admin_004'],
        'memberIds': ['test_admin_004', 'test_student_002'],
        'pendingMemberIds': [],
        'tags': ['Dance', 'Hip-Hop', 'Contemporary'],
        'isActive': true,
        'createdAt': Timestamp.now(),
        'memberCount': 2,
      },
    ];

    final batch = _firestore.batch();
    for (final club in clubs) {
      final docRef = _firestore.collection('clubs').doc();
      batch.set(docRef, {...club, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${clubs.length} clubs');
  }

  /// Seed sample events
  Future<void> seedEvents() async {
    final now = DateTime.now();
    final events = [
      {
        'title': 'Flutter Bootcamp 2024',
        'description': 'A 3-day intensive workshop on building beautiful cross-platform apps with Flutter. Learn from industry experts and build your first app!',
        'category': EventCategory.workshop.name,
        'eventDate': Timestamp.fromDate(now.add(const Duration(days: 7))),
        'venue': 'Seminar Hall, Block A',
        'authorId': 'test_admin_001',
        'authorName': 'GDSC MVGR',
        'rsvpIds': ['test_student_001', 'test_student_002'],
        'rsvpCount': 2,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Hackathon: Build for Bharat',
        'description': '24-hour hackathon focused on solving real problems for India. Amazing prizes worth ₹50,000!',
        'category': EventCategory.hackathon.name,
        'eventDate': Timestamp.fromDate(now.add(const Duration(days: 14))),
        'venue': 'Main Auditorium',
        'authorId': 'test_admin_002',
        'authorName': 'CodeChef MVGR',
        'rsvpIds': ['test_student_001'],
        'rsvpCount': 1,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Poetry Night',
        'description': 'An evening of beautiful poetry recitals and open mic sessions. Share your verses!',
        'category': EventCategory.cultural.name,
        'eventDate': Timestamp.fromDate(now.add(const Duration(days: 3))),
        'venue': 'Open Air Theatre',
        'authorId': 'test_admin_003',
        'authorName': 'Literary Society',
        'rsvpIds': ['test_student_002'],
        'rsvpCount': 1,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Annual Sports Meet',
        'description': 'Inter-department sports competition. Cricket, football, basketball, athletics and more!',
        'category': EventCategory.sports.name,
        'eventDate': Timestamp.fromDate(now.add(const Duration(days: 21))),
        'venue': 'College Grounds',
        'authorId': 'faculty_001',
        'authorName': 'Sports Department',
        'rsvpIds': [],
        'rsvpCount': 0,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'AI/ML Workshop',
        'description': 'Introduction to Machine Learning with hands-on TensorFlow and Python. No prior ML experience needed!',
        'category': EventCategory.workshop.name,
        'eventDate': Timestamp.fromDate(now.add(const Duration(days: 5))),
        'venue': 'Computer Lab 3',
        'authorId': 'test_admin_001',
        'authorName': 'GDSC MVGR',
        'rsvpIds': ['test_student_001', 'test_student_002'],
        'rsvpCount': 2,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final event in events) {
      final docRef = _firestore.collection('events').doc();
      batch.set(docRef, {...event, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${events.length} events');
  }

  /// Seed sample mentors
  Future<void> seedMentors() async {
    final mentors = [
      {
        'name': 'Dr. Rajesh Kumar',
        'email': 'rajesh.k@mvgr.edu.in',
        'bio': 'Professor with 15 years experience in AI/ML. Passionate about guiding students in research and career development.',
        'type': MentorType.faculty.name,
        'areas': [MentorshipArea.career.name, MentorshipArea.research.name],
        'expertise': ['Machine Learning', 'Deep Learning', 'Computer Vision', 'Research Methodology'],
        'department': 'Computer Science',
        'designation': 'Associate Professor',
        'maxMentees': 5,
        'currentMentees': 2,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Priya Sharma',
        'email': 'priya.s@alumni.mvgr.edu.in',
        'bio': 'Software Engineer at Google. MVGR 2020 batch. Happy to help juniors with placement prep and tech career advice.',
        'type': MentorType.alumni.name,
        'areas': [MentorshipArea.career.name, MentorshipArea.placement.name, MentorshipArea.skills.name],
        'expertise': ['System Design', 'DSA', 'Interview Prep', 'Google Tech Stack'],
        'department': null,
        'designation': 'SDE-2 at Google',
        'maxMentees': 3,
        'currentMentees': 1,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Arjun Reddy',
        'email': 'arjun.r@mvgr.edu.in',
        'bio': '4th year CSE, GSOC 2024 contributor. Can help with open source, competitive programming, and project building.',
        'type': MentorType.senior.name,
        'areas': [MentorshipArea.skills.name, MentorshipArea.career.name],
        'expertise': ['Open Source', 'Competitive Programming', 'Web Development', 'Git/GitHub'],
        'department': 'Computer Science',
        'designation': 'Final Year Student',
        'maxMentees': 4,
        'currentMentees': 2,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Dr. Sunita Rao',
        'email': 'sunita.r@mvgr.edu.in',
        'bio': 'HOD of ECE department. Expert in VLSI design and embedded systems. Guiding students since 2005.',
        'type': MentorType.faculty.name,
        'areas': [MentorshipArea.academic.name, MentorshipArea.research.name],
        'expertise': ['VLSI', 'Embedded Systems', 'Digital Electronics', 'Academic Writing'],
        'department': 'Electronics',
        'designation': 'Professor & HOD',
        'maxMentees': 3,
        'currentMentees': 3,
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final mentor in mentors) {
      final docRef = _firestore.collection('mentors').doc();
      batch.set(docRef, {...mentor, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${mentors.length} mentors');
  }

  /// Seed sample study buddy requests
  Future<void> seedStudyRequests() async {
    final requests = [
      {
        'userId': 'test_student_001',
        'userName': 'Rahul Kumar',
        'subject': 'Data Structures',
        'topic': 'Trees and Graphs',
        'description': 'Looking for a study partner to prepare for upcoming DSA exam. Planning to solve LeetCode problems together.',
        'preferredMode': StudyMode.hybrid.name,
        'availableDays': ['Monday', 'Wednesday', 'Saturday'],
        'preferredTime': 'Evening',
        'status': RequestStatus.active.name,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      },
      {
        'userId': 'test_student_002',
        'userName': 'Sneha Patel',
        'subject': 'Operating Systems',
        'topic': 'Process Scheduling',
        'description': 'Need help understanding process scheduling algorithms. Can meet in library or online.',
        'preferredMode': StudyMode.inPerson.name,
        'availableDays': ['Tuesday', 'Thursday'],
        'preferredTime': 'Afternoon',
        'status': RequestStatus.active.name,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
      },
      {
        'userId': 'test_student_003',
        'userName': 'Aditya Verma',
        'subject': 'Machine Learning',
        'topic': 'Neural Networks',
        'description': 'Working on a project using CNNs. Looking for someone interested in deep learning to collaborate.',
        'preferredMode': StudyMode.online.name,
        'availableDays': ['Friday', 'Saturday', 'Sunday'],
        'preferredTime': 'Night',
        'status': RequestStatus.active.name,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
      },
    ];

    final batch = _firestore.batch();
    for (final request in requests) {
      final docRef = _firestore.collection('study_requests').doc();
      batch.set(docRef, {...request, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${requests.length} study requests');
  }

  /// Seed sample team/play buddy requests
  Future<void> seedTeamRequests() async {
    final teams = [
      {
        'title': 'Smart India Hackathon Team',
        'description': 'Looking for 2 more developers for SIH 2024. Need someone with Flutter/React and backend experience.',
        'category': TeamCategory.hackathon.name,
        'eventName': 'Smart India Hackathon 2024',
        'creatorId': 'test_student_001',
        'creatorName': 'Rahul Kumar',
        'teamSize': 6,
        'currentMembers': 4,
        'memberIds': ['test_student_001'],
        'requiredSkills': ['Flutter', 'Node.js', 'Firebase', 'UI/UX'],
        'status': 'open',
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Cricket Team for Inter-Department',
        'description': 'Need batsmen and a wicket-keeper for the upcoming cricket tournament. Practice every evening.',
        'category': TeamCategory.sports.name,
        'eventName': 'Inter-Department Cricket 2024',
        'creatorId': 'test_student_002',
        'creatorName': 'Sneha Patel',
        'teamSize': 11,
        'currentMembers': 7,
        'memberIds': ['test_student_002'],
        'requiredSkills': ['Batting', 'Wicket-keeping', 'Fielding'],
        'status': 'open',
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Research Paper Team',
        'description': 'Working on a paper about blockchain in healthcare. Need someone with writing skills and blockchain knowledge.',
        'category': TeamCategory.project.name,
        'eventName': null,
        'creatorId': 'test_student_003',
        'creatorName': 'Aditya Verma',
        'teamSize': 3,
        'currentMembers': 1,
        'memberIds': ['test_student_003'],
        'requiredSkills': ['Academic Writing', 'Blockchain', 'Research'],
        'status': 'open',
        'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final team in teams) {
      final docRef = _firestore.collection('team_requests').doc();
      batch.set(docRef, {...team, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${teams.length} team requests');
  }

  /// Seed sample lost & found items
  Future<void> seedLostFoundItems() async {
    final items = [
      {
        'title': 'Blue Backpack',
        'description': 'Lost my blue Wildcraft backpack near the cafeteria. Has a laptop and notebooks inside.',
        'type': LostFoundStatus.lost.name,
        'category': LostFoundCategory.bag.name,
        'location': 'Cafeteria',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'userId': 'test_student_001',
        'userName': 'Rahul Kumar',
        'contactInfo': '9876543210',
        'imageUrl': null,
        'isResolved': false,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Calculator (Casio FX-991)',
        'description': 'Found a scientific calculator in Exam Hall 3 after the maths exam. Owner can claim with proof.',
        'type': LostFoundStatus.found.name,
        'category': LostFoundCategory.electronics.name,
        'location': 'Exam Hall 3',
        'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'userId': 'test_student_002',
        'userName': 'Sneha Patel',
        'contactInfo': 'sneha@mvgr.edu.in',
        'imageUrl': null,
        'isResolved': false,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'ID Card',
        'description': 'Found a student ID card near the library entrance. Name starts with "A". Check with me if its yours.',
        'type': LostFoundStatus.found.name,
        'category': LostFoundCategory.documents.name,
        'location': 'Library',
        'date': Timestamp.fromDate(DateTime.now()),
        'userId': 'test_student_003',
        'userName': 'Aditya Verma',
        'contactInfo': 'Block C, Room 205',
        'imageUrl': null,
        'isResolved': false,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final item in items) {
      final docRef = _firestore.collection('lost_found').doc();
      batch.set(docRef, {...item, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${items.length} lost/found items');
  }

  /// Seed sample vault resources
  Future<void> seedVaultResources() async {
    final resources = [
      {
        'title': 'Data Structures Notes - Complete',
        'description': 'Comprehensive notes covering arrays, linked lists, trees, graphs, and advanced topics.',
        'type': VaultItemType.notes.name,
        'branch': 'CSE',
        'year': 2,
        'semester': 1,
        'subject': 'Data Structures',
        'uploaderId': 'test_student_001',
        'uploaderName': 'Rahul Kumar',
        'downloadCount': 45,
        'rating': 4.5,
        'fileUrl': 'https://example.com/dsa_notes.pdf',
        'fileName': 'dsa_notes.pdf',
        'fileSizeBytes': 2621440,
        'tags': ['DSA', 'Trees', 'Graphs', 'Exam Prep'],
        'isApproved': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'DBMS Previous Year Papers (2020-2024)',
        'description': 'Collection of all DBMS question papers with solutions for the last 5 years.',
        'type': VaultItemType.pyq.name,
        'branch': 'CSE',
        'year': 3,
        'semester': 1,
        'subject': 'Database Management',
        'uploaderId': 'test_student_002',
        'uploaderName': 'Sneha Patel',
        'downloadCount': 89,
        'rating': 4.8,
        'fileUrl': 'https://example.com/dbms_pyq.pdf',
        'fileName': 'dbms_pyq.pdf',
        'fileSizeBytes': 15728640,
        'tags': ['DBMS', 'PYQ', 'SQL', 'Exam'],
        'isApproved': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Operating Systems Lab Manual',
        'description': 'Complete lab manual with all programs, viva questions, and explanations.',
        'type': VaultItemType.lab.name,
        'branch': 'CSE',
        'year': 3,
        'semester': 2,
        'subject': 'Operating Systems',
        'uploaderId': 'test_student_003',
        'uploaderName': 'Aditya Verma',
        'downloadCount': 32,
        'rating': 4.2,
        'fileUrl': 'https://example.com/os_lab.pdf',
        'fileName': 'os_lab_manual.pdf',
        'fileSizeBytes': 5242880,
        'tags': ['OS', 'Lab', 'Programs', 'Linux'],
        'isApproved': true,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final resource in resources) {
      final docRef = _firestore.collection('vault_resources').doc();
      batch.set(docRef, {...resource, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${resources.length} vault resources');
  }

  /// Seed sample announcements
  Future<void> seedAnnouncements() async {
    final announcements = [
      {
        'title': 'Mid-Semester Exams Schedule Released',
        'content': 'The mid-semester examination schedule for all branches has been released. Please check the official notice board for your exam dates and timings.',
        'authorId': 'faculty_001',
        'authorName': 'Examination Cell',
        'priority': 'high',
        'targetAudience': 'all',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Library Timing Extended',
        'content': 'Due to upcoming exams, library timings have been extended till 10 PM on weekdays. Make the most of it!',
        'authorId': 'council_001',
        'authorName': 'Student Council',
        'priority': 'normal',
        'targetAudience': 'all',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'GDSC Flutter Workshop Registration Open',
        'content': 'Registrations are now open for the 3-day Flutter Bootcamp. Limited seats available! Register on the events page.',
        'authorId': 'test_admin_001',
        'authorName': 'GDSC MVGR',
        'priority': 'normal',
        'targetAudience': 'students',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final announcement in announcements) {
      final docRef = _firestore.collection('announcements').doc();
      batch.set(docRef, {...announcement, 'id': docRef.id});
    }
    await batch.commit();
    debugPrint('  ✓ Seeded ${announcements.length} announcements');
  }

  /// Clear all seeded data (for testing)
  Future<void> clearAllData() async {
    debugPrint('🗑️ Clearing all data...');
    
    final collections = [
      'clubs', 'events', 'mentors', 'study_requests', 
      'team_requests', 'lost_found', 'vault_resources', 'announcements'
    ];
    
    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    
    debugPrint('✅ All data cleared!');
  }
}
