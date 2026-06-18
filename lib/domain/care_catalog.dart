class VaccineSlot {
  final String id;
  final String name;
  final String target;
  final int windowStartDay;
  final int windowEndDay;
  final String route;

  const VaccineSlot({
    required this.id,
    required this.name,
    required this.target,
    required this.windowStartDay,
    required this.windowEndDay,
    required this.route,
  });
}

class MedicationItem {
  final String id;
  final String name;
  final String purpose;
  final int eggWithdrawalDays;
  final int meatWithdrawalDays;

  const MedicationItem({
    required this.id,
    required this.name,
    required this.purpose,
    required this.eggWithdrawalDays,
    required this.meatWithdrawalDays,
  });
}

class ChecklistTask {
  final String id;
  final String text;
  const ChecklistTask(this.id, this.text);
}

class BiosecurityRoutine {
  final String id;
  final String title;
  final String emoji;
  final String purpose;
  final List<ChecklistTask> tasks;
  final int? defaultQuarantineDays;

  const BiosecurityRoutine({
    required this.id,
    required this.title,
    required this.emoji,
    required this.purpose,
    required this.tasks,
    this.defaultQuarantineDays,
  });
}

class CareCatalog {
  static const List<VaccineSlot> vaccineSchedule = [
    VaccineSlot(
      id: 'mareks',
      name: "Marek's",
      target: "Marek's disease",
      windowStartDay: 0,
      windowEndDay: 1,
      route: 'Hatchery, day-old',
    ),
    VaccineSlot(
      id: 'coccidiosis',
      name: 'Coccidiosis',
      target: 'Coccidiosis',
      windowStartDay: 1,
      windowEndDay: 7,
      route: 'Spray or water, first week',
    ),
    VaccineSlot(
      id: 'newcastleIb1',
      name: 'Newcastle + IB (1)',
      target: 'Newcastle & bronchitis',
      windowStartDay: 14,
      windowEndDay: 21,
      route: 'Eye drop or water',
    ),
    VaccineSlot(
      id: 'gumboro',
      name: 'Gumboro (IBD)',
      target: 'Infectious bursal disease',
      windowStartDay: 18,
      windowEndDay: 28,
      route: 'Water',
    ),
    VaccineSlot(
      id: 'fowlpox',
      name: 'Fowl pox',
      target: 'Fowl pox',
      windowStartDay: 56,
      windowEndDay: 84,
      route: 'Wing web',
    ),
    VaccineSlot(
      id: 'newcastleIb2',
      name: 'Newcastle + IB (boost)',
      target: 'Newcastle & bronchitis',
      windowStartDay: 112,
      windowEndDay: 133,
      route: 'Water, pre-lay booster',
    ),
  ];

  static const List<MedicationItem> medications = [
    MedicationItem(
      id: 'amprolium',
      name: 'Amprolium',
      purpose: 'Anticoccidial',
      eggWithdrawalDays: 0,
      meatWithdrawalDays: 0,
    ),
    MedicationItem(
      id: 'oxytetracycline',
      name: 'Oxytetracycline',
      purpose: 'Broad-spectrum antibiotic',
      eggWithdrawalDays: 14,
      meatWithdrawalDays: 7,
    ),
    MedicationItem(
      id: 'tylosin',
      name: 'Tylosin',
      purpose: 'Respiratory antibiotic',
      eggWithdrawalDays: 7,
      meatWithdrawalDays: 5,
    ),
    MedicationItem(
      id: 'enrofloxacin',
      name: 'Enrofloxacin',
      purpose: 'Antibiotic (vet only)',
      eggWithdrawalDays: 21,
      meatWithdrawalDays: 14,
    ),
    MedicationItem(
      id: 'fenbendazole',
      name: 'Fenbendazole',
      purpose: 'Dewormer',
      eggWithdrawalDays: 14,
      meatWithdrawalDays: 7,
    ),
    MedicationItem(
      id: 'permethrinDust',
      name: 'Permethrin dust',
      purpose: 'Mite & lice control',
      eggWithdrawalDays: 0,
      meatWithdrawalDays: 7,
    ),
  ];

  static MedicationItem medById(String id) =>
      medications.firstWhere((m) => m.id == id, orElse: () => medications.first);

  static const List<BiosecurityRoutine> routines = [
    BiosecurityRoutine(
      id: 'newBird',
      title: 'New bird quarantine',
      emoji: '🚧',
      purpose: 'Isolate every new bird before it joins the flock.',
      defaultQuarantineDays: 30,
      tasks: [
        ChecklistTask('separateHousing', 'House new birds at least 10 m from the flock'),
        ChecklistTask('separateGear', 'Use separate feeders, waterers and tools'),
        ChecklistTask('observeDaily', 'Observe daily for any symptoms'),
        ChecklistTask('treatParasites', 'Treat for external parasites on arrival'),
        ChecklistTask('handleLast', 'Care for quarantined birds last each day'),
      ],
    ),
    BiosecurityRoutine(
      id: 'sickIsolation',
      title: 'Sick bird isolation',
      emoji: '🏥',
      purpose: 'Separate an unwell bird to protect the rest of the flock.',
      defaultQuarantineDays: 14,
      tasks: [
        ChecklistTask('moveSick', 'Move the sick bird to a warm, quiet pen'),
        ChecklistTask('logSymptoms', 'Record symptoms and start a triage note'),
        ChecklistTask('disinfectRoute', 'Disinfect anything shared with the flock'),
        ChecklistTask('wash', 'Wash hands and change footwear after contact'),
      ],
    ),
    BiosecurityRoutine(
      id: 'disinfect',
      title: 'Coop disinfection',
      emoji: '🧼',
      purpose: 'Routine deep clean to break disease cycles.',
      tasks: [
        ChecklistTask('removeLitter', 'Remove all old litter and droppings'),
        ChecklistTask('scrub', 'Scrub surfaces with detergent, then disinfect'),
        ChecklistTask('dry', 'Let housing dry fully before re-bedding'),
        ChecklistTask('cleanFeeders', 'Clean and disinfect feeders and waterers'),
      ],
    ),
    BiosecurityRoutine(
      id: 'visitors',
      title: 'Visitor & footwear control',
      emoji: '👢',
      purpose: 'Stop disease arriving on people, boots and vehicles.',
      tasks: [
        ChecklistTask('footbath', 'Provide a disinfectant footbath at the gate'),
        ChecklistTask('dedicatedBoots', 'Keep dedicated boots for the coop'),
        ChecklistTask('limitVisitors', 'Limit visitors who keep their own birds'),
        ChecklistTask('logVisits', 'Record any visitor contact with the flock'),
      ],
    ),
    BiosecurityRoutine(
      id: 'pests',
      title: 'Rodent & wild-bird control',
      emoji: '🐀',
      purpose: 'Reduce disease carried by rodents and wild birds.',
      tasks: [
        ChecklistTask('secureFeed', 'Store feed in sealed, rodent-proof bins'),
        ChecklistTask('coverRun', 'Cover the run to keep wild birds out'),
        ChecklistTask('removeSpill', 'Clean up spilled feed promptly'),
        ChecklistTask('checkGaps', 'Seal gaps where rodents can enter housing'),
      ],
    ),
  ];

  static BiosecurityRoutine routineById(String id) =>
      routines.firstWhere((r) => r.id == id, orElse: () => routines.first);
}
