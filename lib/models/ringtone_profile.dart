class RingtoneProfile {
  const RingtoneProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.previewFrequencyHz,
  });

  final String id;
  final String title;
  final String description;
  final int previewFrequencyHz;

  static const List<RingtoneProfile> presets = <RingtoneProfile>[
    RingtoneProfile(
      id: 'fiverr_pulse',
      title: 'Fiverr Pulse',
      description: 'Balanced alarm tone for new briefs and buyer messages.',
      previewFrequencyHz: 820,
    ),
    RingtoneProfile(
      id: 'order_beacon',
      title: 'Order Beacon',
      description: 'Sharper tone profile for urgent order and delivery alerts.',
      previewFrequencyHz: 1040,
    ),
    RingtoneProfile(
      id: 'reply_siren',
      title: 'Reply Siren',
      description: 'Bright high-energy tone for message replies and mentions.',
      previewFrequencyHz: 1320,
    ),
  ];

  static RingtoneProfile byId(String id) {
    return presets.firstWhere(
      (RingtoneProfile preset) => preset.id == id,
      orElse: () => presets.first,
    );
  }
}
