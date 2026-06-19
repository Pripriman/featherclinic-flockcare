import 'package:flutter/material.dart';

import '../widgets/status_pill.dart';

enum BodySystem { behaviour, respiratory, digestive, skinFeather, reproductive, nervous }

extension BodySystemMeta on BodySystem {
  String get label {
    switch (this) {
      case BodySystem.behaviour:
        return 'Behaviour';
      case BodySystem.respiratory:
        return 'Respiratory';
      case BodySystem.digestive:
        return 'Digestive';
      case BodySystem.skinFeather:
        return 'Skin & feather';
      case BodySystem.reproductive:
        return 'Reproductive';
      case BodySystem.nervous:
        return 'Nervous';
    }
  }

  String get emoji {
    switch (this) {
      case BodySystem.behaviour:
        return '🐔';
      case BodySystem.respiratory:
        return '🌬️';
      case BodySystem.digestive:
        return '💧';
      case BodySystem.skinFeather:
        return '🪶';
      case BodySystem.reproductive:
        return '🥚';
      case BodySystem.nervous:
        return '🧠';
    }
  }

  IconData get icon {
    switch (this) {
      case BodySystem.behaviour:
        return Icons.psychology_rounded;
      case BodySystem.respiratory:
        return Icons.air_rounded;
      case BodySystem.digestive:
        return Icons.water_drop_rounded;
      case BodySystem.skinFeather:
        return Icons.spa_rounded;
      case BodySystem.reproductive:
        return Icons.egg_rounded;
      case BodySystem.nervous:
        return Icons.bolt_rounded;
    }
  }
}

enum Contagion { low, moderate, high }

extension ContagionMeta on Contagion {
  String get label {
    switch (this) {
      case Contagion.low:
        return 'Low contagion';
      case Contagion.moderate:
        return 'Moderate contagion';
      case Contagion.high:
        return 'High contagion';
    }
  }

  SeverityTier get tier {
    switch (this) {
      case Contagion.low:
        return SeverityTier.healthy;
      case Contagion.moderate:
        return SeverityTier.watch;
      case Contagion.high:
        return SeverityTier.critical;
    }
  }
}

enum AgeGroup { chick, grower, adult, any }

extension AgeGroupMeta on AgeGroup {
  String get label {
    switch (this) {
      case AgeGroup.chick:
        return 'Chicks';
      case AgeGroup.grower:
        return 'Growers';
      case AgeGroup.adult:
        return 'Adults';
      case AgeGroup.any:
        return 'Any age';
    }
  }
}

class SymptomTrait {
  final String id;
  final String label;
  final BodySystem system;
  const SymptomTrait({
    required this.id,
    required this.label,
    required this.system,
  });
}

class TreatmentNote {
  final String title;
  final String detail;
  const TreatmentNote(this.title, this.detail);
}

class WithdrawalRef {
  final int eggDays;
  final int meatDays;
  const WithdrawalRef({required this.eggDays, required this.meatDays});
}

class ConditionProfile {
  final String id;
  final String name;
  final String emoji;
  final BodySystem system;
  final Contagion contagion;
  final AgeGroup ageGroup;
  final SeverityTier severity;
  final String summary;
  final String differential;
  final Map<String, double> symptomWeights;
  final List<TreatmentNote> treatment;
  final List<String> prevention;
  final bool lifeThreatening;

  const ConditionProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.system,
    required this.contagion,
    required this.ageGroup,
    required this.severity,
    required this.summary,
    required this.differential,
    required this.symptomWeights,
    required this.treatment,
    required this.prevention,
    this.lifeThreatening = false,
  });

  double get profileWeight =>
      symptomWeights.values.fold<double>(0, (s, w) => s + w);
}

class ConditionLibrary {
  static const List<SymptomTrait> symptoms = [
    SymptomTrait(id: 'lethargy', label: 'Lethargic, sitting fluffed up', system: BodySystem.behaviour),
    SymptomTrait(id: 'noAppetite', label: 'Not eating or drinking', system: BodySystem.behaviour),
    SymptomTrait(id: 'isolation', label: 'Standing apart from the flock', system: BodySystem.behaviour),
    SymptomTrait(id: 'gasping', label: 'Gasping or open-mouth breathing', system: BodySystem.respiratory),
    SymptomTrait(id: 'rattle', label: 'Rattling or wheezing chest', system: BodySystem.respiratory),
    SymptomTrait(id: 'sneeze', label: 'Sneezing or nasal discharge', system: BodySystem.respiratory),
    SymptomTrait(id: 'bloodyDropping', label: 'Bloody or reddish droppings', system: BodySystem.digestive),
    SymptomTrait(id: 'diarrhea', label: 'Watery or green diarrhoea', system: BodySystem.digestive),
    SymptomTrait(id: 'soggyCrop', label: 'Squishy, sour-smelling crop', system: BodySystem.digestive),
    SymptomTrait(id: 'scabs', label: 'Scabs or warty lesions on comb', system: BodySystem.skinFeather),
    SymptomTrait(id: 'featherLoss', label: 'Feather loss or itching', system: BodySystem.skinFeather),
    SymptomTrait(id: 'swollenFoot', label: 'Swollen foot pad or limping', system: BodySystem.skinFeather),
    SymptomTrait(id: 'paleComb', label: 'Pale, shrunken comb', system: BodySystem.behaviour),
    SymptomTrait(id: 'strainEgg', label: 'Straining, no egg passed', system: BodySystem.reproductive),
    SymptomTrait(id: 'dropEgg', label: 'Sudden drop in egg laying', system: BodySystem.reproductive),
    SymptomTrait(id: 'paralysis', label: 'Leg or wing paralysis', system: BodySystem.nervous),
    SymptomTrait(id: 'twistNeck', label: 'Twisted neck or tremors', system: BodySystem.nervous),
  ];

  static SymptomTrait symptomById(String id) =>
      symptoms.firstWhere((s) => s.id == id, orElse: () => symptoms.first);

  static const List<ConditionProfile> conditions = [
    ConditionProfile(
      id: 'mareks',
      name: "Marek's disease",
      emoji: '🧠',
      system: BodySystem.nervous,
      contagion: Contagion.high,
      ageGroup: AgeGroup.grower,
      severity: SeverityTier.critical,
      lifeThreatening: true,
      summary:
          'A highly contagious herpesvirus of young birds causing tumours and progressive paralysis. Spreads through inhaled feather dander and persists in the environment.',
      differential:
          'Classic leg or wing paralysis with one limb forward and one back. Unlike botulism it progresses over days and often affects growers 6–25 weeks old.',
      symptomWeights: {
        'paralysis': 1.0,
        'lethargy': 0.6,
        'noAppetite': 0.4,
        'paleComb': 0.4,
        'dropEgg': 0.3,
      },
      treatment: [
        TreatmentNote('No cure',
            'There is no treatment for the virus itself. Affected birds are usually humanely culled to prevent suffering and spread; supportive care only delays the course.'),
        TreatmentNote('Protect the rest',
            'Vaccinate chicks at day-old, keep ages separated and reduce dander with good ventilation and cleaning.'),
      ],
      prevention: [
        'Vaccinate chicks against Marek at the hatchery on day one.',
        'Raise young birds away from older flocks and wild birds.',
        'Control feather dust with ventilation and regular cleaning.',
      ],
    ),
    ConditionProfile(
      id: 'newcastle',
      name: 'Newcastle disease',
      emoji: '🌬️',
      system: BodySystem.respiratory,
      contagion: Contagion.high,
      ageGroup: AgeGroup.any,
      severity: SeverityTier.critical,
      lifeThreatening: true,
      summary:
          'A fast-moving viral disease hitting the respiratory and nervous systems. Virulent strains are reportable in many regions and can devastate a flock in days.',
      differential:
          'Respiratory distress combined with twisted neck or tremors and a sharp egg drop points to Newcastle rather than a simple cold.',
      symptomWeights: {
        'gasping': 0.8,
        'twistNeck': 0.9,
        'dropEgg': 0.7,
        'diarrhea': 0.5,
        'lethargy': 0.5,
        'sneeze': 0.4,
      },
      treatment: [
        TreatmentNote('No specific cure',
            'There is no antiviral treatment. Care is supportive only, and virulent Newcastle must be reported to local animal-health authorities.'),
        TreatmentNote('Strict isolation',
            'Quarantine immediately and stop all bird and equipment movement to contain spread.'),
      ],
      prevention: [
        'Use a Newcastle vaccine where it is recommended in your region.',
        'Quarantine every new or returning bird before mixing.',
        'Keep wild birds and visitors away from the flock.',
      ],
    ),
    ConditionProfile(
      id: 'coccidiosis',
      name: 'Coccidiosis',
      emoji: '💧',
      system: BodySystem.digestive,
      contagion: Contagion.high,
      ageGroup: AgeGroup.chick,
      severity: SeverityTier.critical,
      lifeThreatening: true,
      summary:
          'A common intestinal parasite (Eimeria) that thrives in warm, damp bedding. Most dangerous in chicks, causing bloody droppings and rapid decline.',
      differential:
          'Bloody or reddish droppings in young birds with huddling and pale combs strongly suggest coccidiosis over a simple gut upset.',
      symptomWeights: {
        'bloodyDropping': 1.0,
        'lethargy': 0.6,
        'noAppetite': 0.5,
        'paleComb': 0.5,
        'diarrhea': 0.4,
      },
      treatment: [
        TreatmentNote('Anticoccidial therapy',
            'Veterinarians commonly treat with an anticoccidial such as amprolium in water. Confirm dose and product with a vet and follow label withdrawal times.'),
        TreatmentNote('Dry the brooder',
            'Remove wet litter, keep bedding dry and provide clean water to break the cycle.'),
      ],
      prevention: [
        'Keep bedding dry and avoid overcrowding chicks.',
        'Use medicated starter feed or vaccination where appropriate.',
        'Clean and disinfect waterers daily.',
      ],
    ),
    ConditionProfile(
      id: 'fowlpox',
      name: 'Fowl pox',
      emoji: '🪶',
      system: BodySystem.skinFeather,
      contagion: Contagion.moderate,
      ageGroup: AgeGroup.any,
      severity: SeverityTier.watch,
      summary:
          'A slow-spreading viral disease causing wart-like scabs on the comb and wattles (dry form) or lesions in the mouth (wet form). Often spread by mosquitoes.',
      differential:
          'Crusty scabs on unfeathered skin without severe respiratory signs point to dry fowl pox rather than a respiratory infection.',
      symptomWeights: {
        'scabs': 1.0,
        'lethargy': 0.3,
        'dropEgg': 0.3,
        'noAppetite': 0.2,
      },
      treatment: [
        TreatmentNote('Supportive care',
            'Most birds recover. Keep them comfortable, treat scabs gently and watch for secondary infection. A vet may advise for the wet form.'),
        TreatmentNote('Mosquito control',
            'Reduce standing water and biting insects that carry the virus.'),
      ],
      prevention: [
        'Vaccinate where fowl pox is common in your area.',
        'Control mosquitoes and remove standing water.',
        'Isolate affected birds until scabs heal.',
      ],
    ),
    ConditionProfile(
      id: 'bronchitis',
      name: 'Infectious bronchitis',
      emoji: '🌬️',
      system: BodySystem.respiratory,
      contagion: Contagion.high,
      ageGroup: AgeGroup.any,
      severity: SeverityTier.watch,
      summary:
          'A contagious coronavirus of poultry causing coughing, sneezing and a marked drop in egg quality and number. Spreads quickly through a flock.',
      differential:
          'Respiratory signs with soft-shelled or misshapen eggs and a laying drop, but without nervous signs, suggest bronchitis over Newcastle.',
      symptomWeights: {
        'sneeze': 0.8,
        'rattle': 0.7,
        'dropEgg': 0.7,
        'gasping': 0.4,
        'lethargy': 0.3,
      },
      treatment: [
        TreatmentNote('Supportive care',
            'No antiviral cure. Provide warmth, good ventilation and clean water; a vet may prescribe antibiotics only for secondary bacterial infection.'),
        TreatmentNote('Reduce stress',
            'Lower stocking density and avoid chilling while birds recover.'),
      ],
      prevention: [
        'Vaccinate where infectious bronchitis is endemic.',
        'Quarantine new birds and avoid mixing age groups.',
        'Maintain good ventilation without draughts.',
      ],
    ),
    ConditionProfile(
      id: 'ectoparasites',
      name: 'Mites & lice',
      emoji: '🪶',
      system: BodySystem.skinFeather,
      contagion: Contagion.moderate,
      ageGroup: AgeGroup.any,
      severity: SeverityTier.watch,
      summary:
          'External parasites that live on the skin and feathers or hide in coop cracks. They cause itching, feather loss, anaemia and a drop in condition.',
      differential:
          'Feather loss with visible insects or eggs at the feather base and a pale comb from blood loss points to ectoparasites rather than moulting.',
      symptomWeights: {
        'featherLoss': 1.0,
        'paleComb': 0.5,
        'dropEgg': 0.4,
        'lethargy': 0.3,
      },
      treatment: [
        TreatmentNote('Approved parasite control',
            'A vet can recommend a poultry-safe acaricide or dusting product. Always follow the label dose and egg or meat withdrawal time.'),
        TreatmentNote('Treat the coop',
            'Clean and treat housing, perches and cracks where red mite hides during the day.'),
      ],
      prevention: [
        'Inspect birds and perches regularly for parasites.',
        'Keep the coop clean and seal hiding cracks.',
        'Provide a dust-bathing area for natural control.',
      ],
    ),
    ConditionProfile(
      id: 'bumblefoot',
      name: 'Bumblefoot',
      emoji: '🦶',
      system: BodySystem.skinFeather,
      contagion: Contagion.low,
      ageGroup: AgeGroup.adult,
      severity: SeverityTier.watch,
      summary:
          'A bacterial foot infection, usually from a cut or rough landing, that forms a swollen abscess with a dark scab on the footpad. Not contagious between birds.',
      differential:
          'A single swollen, warm foot with a black scab and limping points to bumblefoot, not a flock-wide disease.',
      symptomWeights: {
        'swollenFoot': 1.0,
        'lethargy': 0.2,
      },
      treatment: [
        TreatmentNote('Wound care',
            'Mild cases respond to cleaning, soaking and dressing the foot. Deeper abscesses may need veterinary debridement and prescribed antibiotics.'),
        TreatmentNote('Fix the cause',
            'Lower perches, add soft bedding and remove sharp surfaces to prevent recurrence.'),
      ],
      prevention: [
        'Use smooth, correctly sized perches at a safe height.',
        'Keep bedding soft and dry to cushion landings.',
        'Check feet during routine handling.',
      ],
    ),
    ConditionProfile(
      id: 'eggBinding',
      name: 'Egg binding',
      emoji: '🥚',
      system: BodySystem.reproductive,
      contagion: Contagion.low,
      ageGroup: AgeGroup.adult,
      severity: SeverityTier.critical,
      lifeThreatening: true,
      summary:
          'A stuck egg that the hen cannot pass, often from calcium deficiency or a large egg. It is an emergency that can be fatal within hours if not relieved.',
      differential:
          'A hen straining, walking penguin-like and sitting fluffed with no egg passed is egg-bound, not simply broody.',
      symptomWeights: {
        'strainEgg': 1.0,
        'lethargy': 0.6,
        'noAppetite': 0.5,
        'isolation': 0.3,
      },
      treatment: [
        TreatmentNote('Warmth and calcium',
            'A warm, humid environment and supplemental calcium can help her pass the egg. If there is no progress within hours, contact a vet urgently.'),
        TreatmentNote('Handle gently',
            'Never pull the egg — a broken egg inside the hen is dangerous. Seek veterinary help if she is not improving.'),
      ],
      prevention: [
        'Provide constant access to calcium such as oyster shell.',
        'Avoid over-stimulating very young or moulting hens to lay.',
        'Keep laying birds at a healthy weight and active.',
      ],
    ),
    ConditionProfile(
      id: 'sourCrop',
      name: 'Sour crop',
      emoji: '💧',
      system: BodySystem.digestive,
      contagion: Contagion.low,
      ageGroup: AgeGroup.adult,
      severity: SeverityTier.watch,
      summary:
          'A yeast overgrowth in the crop that leaves it squishy and sour-smelling, often after a slow or impacted crop. The bird goes off food and loses condition.',
      differential:
          'A soft, fluid-filled crop with a sour smell and bad breath points to sour crop rather than a respiratory illness.',
      symptomWeights: {
        'soggyCrop': 1.0,
        'noAppetite': 0.5,
        'lethargy': 0.4,
      },
      treatment: [
        TreatmentNote('Crop management',
            'Withhold food briefly, offer plain water and massage the crop gently. Persistent cases may need an antifungal prescribed by a vet.'),
        TreatmentNote('Find the cause',
            'Check for long fibrous grass or an impacted crop that triggered the imbalance.'),
      ],
      prevention: [
        'Avoid long, fibrous grass clippings that cause impaction.',
        'Provide grit so birds can grind food properly.',
        'Keep feed fresh and dry to limit mould and yeast.',
      ],
    ),
  ];

  static ConditionProfile byId(String id) =>
      conditions.firstWhere((c) => c.id == id, orElse: () => conditions.first);
}
