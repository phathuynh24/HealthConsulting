class DiseaseClassifier {
  final Map<String, List<String>> diseaseGroups = {
    'Bệnh truyền nhiễm': [
      'malaria',
      'hepatitis a',
      'hepatitis b',
      'hepatitis c',
      'hepatitis e',
      'hepatitis d',
      'typhoid',
      'common cold',
      'chicken pox',
      'aids',
      'tuberculosis',
      'dengue',
      'pneumonia',
    ],
    'bệnh miễn dịch và dị ứng': [
      'drug reaction',
      'allergy',
      'psoriasis',
    ],
    'bệnh nội tiết': [
      'hypothyroidism',
      'hyperthyroidism',
      'diabetes',
      'hypoglycemia',
    ],
    'bệnh tiêu hóa': [
      'gerd',
      'chronic cholestasis',
      'peptic ulcer disease',
      'gastroenteritis',
    ],
    'bệnh xương khớp và cơ học': [
      'osteoarthritis',
      'cervical spondylosis',
      'arthritis',
      '(vertigo) paroxysmal positional vertigo',
    ],
    'bệnh da liễu': [
      'acne',
      'impetigo',
    ],
    'bệnh tim mạch': [
      'hypertension',
      'heart attack',
    ],
    'bệnh huyết học và mạch máu': [
      'varicose veins',
      'paralysis (brain hemorrhage)',
    ],
    'bệnh hệ hô hấp': [
      'bronchial asthma',
    ],
    'bệnh gan': [
      'alcoholic hepatitis',
      'jaundice',
    ],
    'bệnh thần kinh': [
      'migraine',
    ],
    'bệnh niệu': [
      'urinary tract infection',
    ],
    'bệnh hậu môn trực tràng': [
      'dimorphic hemorrhoids (piles)',
    ],
    'bệnh nấm': [
      'fungal infection',
    ],
    'các bệnh khác': [
      'drug reaction',
    ],
  };

  String classifyDisease(String disease) {
    disease = disease.toLowerCase();
    for (var entry in diseaseGroups.entries) {
      if (entry.value.contains(disease)) {
        return entry.key.replaceAll("bệnh", "Khoa");
      }
    }
    return 'Unknown Disease Group';
  }

  bool isDiseaseInGroup(String disease, List<String> groups) {
    disease = disease.toLowerCase();
    for (String group in groups) {
      if (diseaseGroups.containsKey(group.toLowerCase())) {
        if (diseaseGroups[group.toLowerCase()]!.contains(disease)) {
          return true;
        }
      }
    }
    return false;
  }
}
