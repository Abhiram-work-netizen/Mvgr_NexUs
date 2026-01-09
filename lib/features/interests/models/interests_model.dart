/// Available interests for students to select (limited set for recommendations)
class Interests {
  static const List<String> all = [
    // Academic
    'Programming',
    'Machine Learning',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'Robotics',
    'IoT',
    'Blockchain',
    
    // Creative
    'Music',
    'Dance',
    'Art & Design',
    'Photography',
    'Video Editing',
    'Writing',
    'Content Creation',
    
    // Sports & Fitness
    'Cricket',
    'Football',
    'Basketball',
    'Badminton',
    'Table Tennis',
    'Chess',
    'Athletics',
    'Fitness',
    
    // Gaming
    'E-Sports',
    'PC Gaming',
    'Mobile Gaming',
    'Board Games',
    
    // Entertainment
    'Movies',
    'Anime',
    'Reading',
    'Podcasts',
    
    // Social
    'Public Speaking',
    'Debate',
    'Event Management',
    'Volunteering',
    'Entrepreneurship',
  ];
  
  static const Map<String, String> icons = {
    'Programming': '💻',
    'Machine Learning': '🤖',
    'Web Development': '🌐',
    'Mobile Development': '📱',
    'Data Science': '📊',
    'Cybersecurity': '🔒',
    'Cloud Computing': '☁️',
    'Robotics': '🦾',
    'IoT': '🔌',
    'Blockchain': '⛓️',
    'Music': '🎵',
    'Dance': '💃',
    'Art & Design': '🎨',
    'Photography': '📷',
    'Video Editing': '🎬',
    'Writing': '✍️',
    'Content Creation': '📺',
    'Cricket': '🏏',
    'Football': '⚽',
    'Basketball': '🏀',
    'Badminton': '🏸',
    'Table Tennis': '🏓',
    'Chess': '♟️',
    'Athletics': '🏃',
    'Fitness': '💪',
    'E-Sports': '🎮',
    'PC Gaming': '🖥️',
    'Mobile Gaming': '📲',
    'Board Games': '🎲',
    'Movies': '🎥',
    'Anime': '🎌',
    'Reading': '📚',
    'Podcasts': '🎧',
    'Public Speaking': '🎤',
    'Debate': '💬',
    'Event Management': '📋',
    'Volunteering': '🤝',
    'Entrepreneurship': '🚀',
  };

  static String getIcon(String interest) => icons[interest] ?? '⭐';
}

/// Available skills for students to tag
class Skills {
  static const List<String> programming = [
    'Python',
    'Java',
    'JavaScript',
    'TypeScript',
    'C++',
    'C',
    'Dart',
    'Kotlin',
    'Swift',
    'Rust',
    'Go',
    'PHP',
    'Ruby',
    'SQL',
  ];
  
  static const List<String> frameworks = [
    'React',
    'Angular',
    'Vue.js',
    'Next.js',
    'Flutter',
    'React Native',
    'Node.js',
    'Django',
    'Flask',
    'Spring Boot',
    'Express.js',
    '.NET',
    'TensorFlow',
    'PyTorch',
  ];
  
  static const List<String> tools = [
    'Git',
    'Docker',
    'Kubernetes',
    'AWS',
    'GCP',
    'Azure',
    'Firebase',
    'MongoDB',
    'PostgreSQL',
    'Redis',
    'Linux',
    'Figma',
    'Photoshop',
    'Premiere Pro',
  ];
  
  static const List<String> softSkills = [
    'Leadership',
    'Communication',
    'Teamwork',
    'Problem Solving',
    'Time Management',
    'Critical Thinking',
    'Presentation',
    'Project Management',
  ];
  
  static List<String> get all => [
    ...programming,
    ...frameworks,
    ...tools,
    ...softSkills,
  ];
  
  static const Map<String, List<String>> categories = {
    'Programming Languages': programming,
    'Frameworks & Libraries': frameworks,
    'Tools & Platforms': tools,
    'Soft Skills': softSkills,
  };
}
