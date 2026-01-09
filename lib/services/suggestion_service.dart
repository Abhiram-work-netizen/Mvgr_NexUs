import '../features/clubs/models/club_model.dart';
import '../features/events/models/event_model.dart';
import '../features/offline_community/models/meetup_model.dart';

/// Suggestion Service for Interest-Based Recommendations
/// Maps user interests to relevant clubs, events, meetups
class SuggestionService {
  
  // ============ INTEREST TO CATEGORY MAPPING ============
  
  /// Maps interests to ClubCategories
  /// ClubCategory: technical, cultural, sports, social, academic, other
  static const Map<String, List<ClubCategory>> _interestToClubCategories = {
    // Tech & Academic
    'Programming': [ClubCategory.technical],
    'Machine Learning': [ClubCategory.technical, ClubCategory.academic],
    'Web Development': [ClubCategory.technical],
    'Mobile Development': [ClubCategory.technical],
    'Data Science': [ClubCategory.technical, ClubCategory.academic],
    'Cybersecurity': [ClubCategory.technical],
    'Cloud Computing': [ClubCategory.technical],
    'Robotics': [ClubCategory.technical],
    'IoT': [ClubCategory.technical],
    'Blockchain': [ClubCategory.technical],
    
    // Creative & Cultural
    'Music': [ClubCategory.cultural],
    'Dance': [ClubCategory.cultural],
    'Art & Design': [ClubCategory.cultural],
    'Photography': [ClubCategory.cultural],
    'Video Editing': [ClubCategory.cultural],
    'Writing': [ClubCategory.cultural, ClubCategory.academic],
    'Content Creation': [ClubCategory.cultural],
    
    // Sports
    'Cricket': [ClubCategory.sports],
    'Football': [ClubCategory.sports],
    'Basketball': [ClubCategory.sports],
    'Badminton': [ClubCategory.sports],
    'Table Tennis': [ClubCategory.sports],
    'Chess': [ClubCategory.sports],
    'Athletics': [ClubCategory.sports],
    'Fitness': [ClubCategory.sports],
    
    // Social
    'Public Speaking': [ClubCategory.social],
    'Debate': [ClubCategory.social, ClubCategory.academic],
    'Event Management': [ClubCategory.social],
    'Volunteering': [ClubCategory.social],
    'Entrepreneurship': [ClubCategory.social, ClubCategory.technical],
    
    // Gaming & Entertainment
    'E-Sports': [ClubCategory.technical],
    'PC Gaming': [ClubCategory.technical],
    'Mobile Gaming': [ClubCategory.technical],
    'Movies': [ClubCategory.cultural],
    'Anime': [ClubCategory.cultural],
    'Reading': [ClubCategory.academic, ClubCategory.cultural],
  };

  /// Maps interests to EventCategories
  /// EventCategory: academic, cultural, sports, hackathon, workshop, seminar, competition, other
  static const Map<String, List<EventCategory>> _interestToEventCategories = {
    // Tech
    'Programming': [EventCategory.workshop, EventCategory.hackathon, EventCategory.competition],
    'Machine Learning': [EventCategory.workshop, EventCategory.seminar, EventCategory.hackathon],
    'Web Development': [EventCategory.workshop, EventCategory.hackathon],
    'Mobile Development': [EventCategory.workshop, EventCategory.hackathon],
    'Cybersecurity': [EventCategory.workshop, EventCategory.seminar],
    'Robotics': [EventCategory.workshop, EventCategory.competition],
    
    // Creative
    'Music': [EventCategory.cultural],
    'Dance': [EventCategory.cultural, EventCategory.competition],
    'Art & Design': [EventCategory.cultural],
    'Photography': [EventCategory.workshop],
    
    // Sports
    'Cricket': [EventCategory.sports],
    'Football': [EventCategory.sports],
    'Basketball': [EventCategory.sports],
    'E-Sports': [EventCategory.competition],
    
    // Social
    'Public Speaking': [EventCategory.seminar, EventCategory.competition],
    'Debate': [EventCategory.competition],
  };

  /// Maps interests to MeetupCategories
  /// MeetupCategory: studyCircle, gaming, anime, music, art, sports, movies, books, tech, other
  static const Map<String, List<MeetupCategory>> _interestToMeetupCategories = {
    // Tech
    'Programming': [MeetupCategory.studyCircle, MeetupCategory.tech],
    'Machine Learning': [MeetupCategory.studyCircle, MeetupCategory.tech],
    'Web Development': [MeetupCategory.studyCircle, MeetupCategory.tech],
    
    // Creative
    'Music': [MeetupCategory.music],
    'Photography': [MeetupCategory.art],
    'Art & Design': [MeetupCategory.art],
    
    // Gaming
    'E-Sports': [MeetupCategory.gaming],
    'PC Gaming': [MeetupCategory.gaming],
    'Mobile Gaming': [MeetupCategory.gaming],
    
    // Sports
    'Cricket': [MeetupCategory.sports],
    'Football': [MeetupCategory.sports],
    'Badminton': [MeetupCategory.sports],
    'Fitness': [MeetupCategory.sports],
    
    // Entertainment
    'Movies': [MeetupCategory.movies],
    'Anime': [MeetupCategory.anime],
    'Reading': [MeetupCategory.books],
  };

  // ============ RECOMMENDATION METHODS ============

  /// Get recommended clubs based on user interests
  List<Club> getRecommendedClubs(List<String> interests, List<Club> allClubs, {int limit = 10}) {
    if (interests.isEmpty) return [];

    final Set<ClubCategory> relevantCategories = {};
    for (final interest in interests) {
      final categories = _interestToClubCategories[interest];
      if (categories != null) {
        relevantCategories.addAll(categories);
      }
    }

    if (relevantCategories.isEmpty) return [];

    final clubs = allClubs.where((club) {
      return relevantCategories.contains(club.category);
    }).toList();

    // Sort by member count (more members = more popular)
    clubs.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));

    return clubs.take(limit).toList();
  }

  /// Get recommended events based on user interests
  List<Event> getRecommendedEvents(List<String> interests, List<Event> allEvents, {int limit = 10}) {
    if (interests.isEmpty) return [];

    final Set<EventCategory> relevantCategories = {};
    for (final interest in interests) {
      final categories = _interestToEventCategories[interest];
      if (categories != null) {
        relevantCategories.addAll(categories);
      }
    }

    if (relevantCategories.isEmpty) return [];

    final events = allEvents.where((event) {
      return relevantCategories.contains(event.category) && 
             event.eventDate.isAfter(DateTime.now());  // Future events only
    }).toList();

    // Sort by date (soonest first)
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return events.take(limit).toList();
  }

  /// Get recommended meetups based on user interests
  List<Meetup> getRecommendedMeetups(List<String> interests, List<Meetup> allMeetups, {int limit = 10}) {
    if (interests.isEmpty) return [];

    final Set<MeetupCategory> relevantCategories = {};
    for (final interest in interests) {
      final categories = _interestToMeetupCategories[interest];
      if (categories != null) {
        relevantCategories.addAll(categories);
      }
    }

    if (relevantCategories.isEmpty) return [];

    final meetups = allMeetups.where((meetup) {
      return relevantCategories.contains(meetup.category) &&
             meetup.scheduledAt.isAfter(DateTime.now());  // Future meetups only
    }).toList();

    // Sort by date (soonest first)
    meetups.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return meetups.take(limit).toList();
  }

  /// Get all recommendations as a combined list for home screen
  SuggestionResults getAllRecommendations(
      List<String> interests, 
      List<Club> allClubs, 
      List<Event> allEvents, 
      List<Meetup> allMeetups
    ) {
    return SuggestionResults(
      clubs: getRecommendedClubs(interests, allClubs, limit: 5),
      events: getRecommendedEvents(interests, allEvents, limit: 5),
      meetups: getRecommendedMeetups(interests, allMeetups, limit: 5),
    );
  }

  /// Check if user has set any interests
  bool hasInterests(List<String> interests) => interests.isNotEmpty;
}

/// Container for all suggestion results
class SuggestionResults {
  final List<Club> clubs;
  final List<Event> events;
  final List<Meetup> meetups;

  SuggestionResults({
    required this.clubs,
    required this.events,
    required this.meetups,
  });

  bool get isEmpty => clubs.isEmpty && events.isEmpty && meetups.isEmpty;
  int get totalCount => clubs.length + events.length + meetups.length;
}
