class SmartSuggestions {
  const SmartSuggestions._();

  static const directions = [
    'Ж/д вокзал Анапа',
    'Автовокзал Анапа',
    'Аэропорт Анапа',
    'Ж/д вокзал Новороссийск',
    'Аэропорт Сочи',
    'Краснодар',
    'Индивидуальный адрес',
  ];

  static const baggage = [
    'Без багажа',
    '1 сумка',
    '1 чемодан',
    '2 чемодана',
    'Много багажа',
    'Нужна помощь с багажом',
  ];

  static const comments = [
    'Пожилой гость, нужна помощь при посадке',
    'Гость с ребёнком',
    'Нужно место для крупного багажа',
    'Гости ждут у главного входа',
    'Позвонить перед подачей машины',
    'Проверить документы перед выездом',
  ];

  static const driverProblems = [
    'Гость не вышел',
    'Опаздываем',
    'Проблема с машиной',
    'Нужно связаться с регистратором',
    'Изменился багаж',
    'Изменилось количество гостей',
  ];

  static String recommendedVehicle(int peopleCount) {
    if (peopleCount <= 4) return 'Ларгус';
    if (peopleCount <= 13) return 'Газель';
    return 'Автобус';
  }

  static String vehicleHint(int peopleCount) {
    final vehicle = recommendedVehicle(peopleCount);
    if (vehicle == 'Ларгус') return 'Подойдёт Ларгус: малая группа до 4 человек.';
    if (vehicle == 'Газель') return 'Рекомендуется Газель: средняя группа до 13 человек.';
    return 'Нужен автобус: большая группа от 14 человек.';
  }
}
