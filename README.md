# АЧПП - Ассоциация частнопрактикующих психологов и психотерапевтов

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Мобильное приложение АЧПП для психологов и психотерапевтов, предоставляющее доступ к курсам, клубам, встречам, блогу и профессиональным материалам.

[📱 Скачать APK](https://github.com/prod-broke-again/a4pp_flutter/releases) • [🐛 Сообщить о баге](https://github.com/prod-broke-again/a4pp_flutter/issues) • [💡 Предложить фичу](https://github.com/prod-broke-again/a4pp_flutter/issues)

## 🎨 Дизайн

Приложение выполнено в современном фиолетово-белом стиле с темной темой, обеспечивающей комфортное использование в любое время суток.

### Цветовая схема:
- **Основной цвет**: `#6B46C1` (фиолетовый)
- **Вторичный цвет**: `#8B5CF6` (светло-фиолетовый)
- **Фон**: `#1A1A1A` (темно-серый)
- **Карточки**: `#2D2D2D` (серый)
- **Текст**: Белый и оттенки серого

## 📱 Экраны приложения

### Аутентификация:
- **Вход** - экран авторизации с email и паролем
- **Регистрация** - создание нового аккаунта
- **Восстановление пароля** - сброс пароля по email

### Основные разделы:
- **Курсы** - каталог обучающих программ с фильтрацией
- **Клубы** - профессиональные сообщества и группы
- **Встречи** - расписание консультаций и мероприятий
- **Блог** - статьи и материалы для развития
- **Профиль** - личный кабинет и настройки

### Дополнительные экраны:
- **Подписка** - управление тарифными планами
- **Пополнение баланса** - финансовые операции
- **История транзакций** - детализация платежей
- **Настройки** - конфигурация приложения

## 🚀 Запуск проекта

### Требования:
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Эмулятор Android или физическое устройство

### Установка зависимостей:
```bash
flutter pub get
```

### Генерация кода:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Запуск приложения:
```bash
flutter run
```

### Сборка APK:
```bash
flutter build apk --release
```

## 🏗️ Архитектура

Приложение построено с использованием современной архитектуры:

### State Management:
- **BLoC Pattern** - управление состоянием приложения
- **Flutter BLoC** - библиотека для реализации BLoC паттерна

### Data Layer:
- **Repository Pattern** - абстракция доступа к данным
- **API Integration** - REST API с Dio и Retrofit
- **Local Storage** - Hive для кэширования данных
- **Shared Preferences** - хранение настроек пользователя

### Networking:
- **Dio** - HTTP клиент для API запросов
- **Retrofit** - генерация API клиентов
- **JSON Serializable** - сериализация/десериализация данных

### UI Framework:
- **Material Design 3** - современный дизайн-система
- **Go Router** - навигация между экранами
- **Google Fonts** - типографика
- **Responsive Design** - адаптация под разные размеры экранов

## 📁 Структура проекта

```
lib/
├── main.dart                    # Точка входа приложения
├── blocs/                       # BLoC для управления состоянием
│   └── auth/                   # Аутентификация
│       ├── auth_bloc.dart      # BLoC логика
│       ├── auth_event.dart     # События
│       └── auth_state.dart     # Состояния
├── models/                      # Модели данных
│   ├── user.dart               # Модель пользователя
│   ├── user.g.dart             # Сгенерированная сериализация
│   ├── blog.dart               # Модель блога
│   ├── category.dart           # Категории
│   ├── club.dart               # Клубы
│   ├── course.dart             # Курсы
│   ├── meeting.dart            # Встречи
│   ├── news.dart               # Новости
│   ├── notification.dart       # Уведомления
│   ├── subscription.dart       # Подписки
│   ├── transaction.dart        # Транзакции
│   ├── video.dart              # Видео материалы
│   └── ...                     # Другие модели
├── repositories/                # Репозитории для доступа к данным
│   ├── auth_repository.dart    # Аутентификация
│   ├── blog_repository.dart    # Блог
│   ├── comment_repository.dart # Комментарии
│   ├── meeting_repository.dart # Встречи
│   ├── news_repository.dart    # Новости
│   ├── notification_repository.dart # Уведомления
│   └── video_repository.dart   # Видео
├── services/                    # Сервисы для API и внешних интеграций
│   ├── api_client.dart         # HTTP клиент
│   ├── auth_service.dart       # Сервис аутентификации
│   ├── blog_service.dart       # Сервис блога
│   ├── comment_service.dart    # Сервис комментариев
│   ├── meeting_service.dart    # Сервис встреч
│   ├── news_service.dart       # Сервис новостей
│   ├── notification_service.dart # Сервис уведомлений
│   └── video_service.dart      # Сервис видео
├── screens/                     # Экраны приложения
│   ├── auth/                   # Аутентификация
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── main/                   # Основные экраны
│   │   ├── main_screen.dart
│   │   └── main_screen_temp.dart
│   ├── home/                   # Домашний экран
│   │   └── home_digest_screen.dart
│   ├── courses/                # Курсы
│   │   ├── courses_screen.dart
│   │   └── course_details_screen.dart
│   ├── clubs/                  # Клубы
│   │   ├── clubs_screen.dart
│   │   └── club_details_screen.dart
│   ├── meetings/               # Встречи
│   │   ├── meetings_screen.dart
│   │   ├── meetings_screen_temp.dart
│   │   └── meeting_create_screen.dart
│   ├── blog/                   # Блог
│   │   ├── blog_screen.dart
│   │   └── blog_detail_screen.dart
│   ├── news/                   # Новости
│   │   ├── news_screen.dart
│   │   └── news_detail_screen.dart
│   ├── notifications/          # Уведомления
│   │   └── notifications_screen.dart
│   ├── profile/                # Профиль
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   ├── subscription/           # Подписка
│   │   └── subscription_screen.dart
│   ├── balance/                # Баланс
│   │   └── balance_screen.dart
│   ├── transactions/           # Транзакции
│   │   └── transactions_screen.dart
│   ├── video_library/          # Библиотека видео
│   │   └── video_library_screen.dart
│   ├── video_player/           # Видео плеер
│   │   └── video_player_screen.dart
│   ├── events/                 # События
│   │   └── events_screen.dart
│   ├── favorites/              # Избранное
│   │   └── favorites_screen.dart
│   ├── settings/               # Настройки
│   │   └── settings_screen.dart
│   └── splash/                 # Заставка
│       └── splash_screen.dart
├── utils/                      # Утилиты
│   └── intl_utils.dart         # Интернационализация
├── widgets/                    # Переиспользуемые виджеты
│   ├── app_drawer.dart         # Боковое меню
│   ├── comments_widget.dart    # Комментарии
│   ├── donation_dialog.dart    # Диалог донатов
│   └── universal_card.dart     # Универсальная карточка
└── data/                       # Дополнительные данные
```

## 📦 Основные зависимости

### Core Framework:
- **Flutter** 3.8.1+ - кроссплатформенный фреймворк
- **Dart** 3.0+ - язык программирования

### State Management & Architecture:
- **flutter_bloc** ^9.0.0 - BLoC паттерн для управления состоянием
- **equatable** ^2.0.5 - сравнение объектов

### Networking & API:
- **dio** ^5.7.0 - HTTP клиент
- **retrofit** ^4.4.1 - генерация API клиентов
- **json_annotation** ^4.9.0 - сериализация JSON
- **json_serializable** ^6.8.0 - кодогенерация для JSON

### Storage & Persistence:
- **hive** ^2.2.3 - NoSQL база данных
- **hive_flutter** ^1.1.0 - Flutter интеграция Hive
- **shared_preferences** ^2.3.2 - хранение настроек

### UI & Media:
- **google_fonts** ^6.3.0 - Google Fonts
- **cached_network_image** ^3.4.1 - кэширование изображений
- **video_player** ^2.9.2 - видео плеер
- **flutter_html** ^3.0.0 - рендеринг HTML
- **flutter_kinescope_sdk** ^0.2.3 - видео SDK

### Integrations:
- **firebase_messaging** ^16.0.2 - push-уведомления
- **url_launcher** ^6.3.0 - открытие URL
- **image_picker** ^1.0.7 - выбор изображений
- **webview_flutter** ^4.13.0 - вебвью

### Navigation & Utils:
- **go_router** ^16.2.2 - маршрутизация
- **intl** ^0.20.2 - интернационализация

## 🔗 API Интеграции

Приложение интегрируется с REST API для:
- **Аутентификация** - вход/регистрация пользователей
- **Контент** - курсы, блог, новости, видео
- **Социальные функции** - комментарии, клубы, встречи
- **Платежи** - подписки, транзакции, баланс
- **Уведомления** - push-уведомления через Firebase

## ✨ Особенности

### UI/UX:
- **Современный Material Design 3** - интуитивно понятный интерфейс
- **Адаптивный дизайн** - поддержка различных размеров экранов
- **Темная тема** - комфортное использование в любое время
- **Плавные анимации** - интерактивные переходы и эффекты

### Функциональность:
- **Полнотекстный поиск** - быстрый доступ к контенту
- **Фильтрация и сортировка** - персонализация контента
- **Оффлайн режим** - кэширование данных
- **Push-уведомления** - своевременные оповещения
- **Мультимедиа** - видео плеер с Kinescope интеграцией

### Качество кода:
- **Валидация форм** - проверка корректности данных
- **Обработка ошибок** - graceful error handling
- **Type-safe** - строгая типизация с Dart
- **Тестируемость** - модульная архитектура

## 🔧 Настройка

### Изменение цветовой схемы:
Отредактируйте файл `lib/main.dart` в секции `ThemeData`:

```dart
colorScheme: const ColorScheme.dark(
  primary: Color(0xFF6B46C1),      // Основной цвет
  secondary: Color(0xFF8B5CF6),     // Вторичный цвет
  surface: Color(0xFF2D2D2D),       // Цвет карточек
  background: Color(0xFF1A1A1A),    // Цвет фона
),
```

### Добавление новых экранов:
1. Создайте новый файл в соответствующей папке `screens/`
2. Добавьте импорт в `main_screen.dart`
3. Обновите навигацию

## 📱 Поддерживаемые платформы

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ⏳ Web (в разработке)
- ⏳ Desktop (в разработке)

## 🧪 Тестирование

### Запуск тестов:
```bash
flutter test
```

### Генерация покрытия:
```bash
flutter test --coverage
```

### Интеграционные тесты:
```bash
flutter test integration_test/
```

## 📋 Roadmap

### В разработке:
- [ ] Web поддержка
- [ ] Desktop приложения (Windows, macOS, Linux)
- [ ] Расширенная аналитика
- [ ] Социальные функции (чат, форумы)

### Планируется:
- [ ] Мобильные платежи
- [ ] Видеоконференции
- [ ] AI-powered рекомендации контента
- [ ] Многоязычная поддержка

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие АЧПП! Вот как вы можете помочь:

### Для разработчиков:
1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Внесите изменения и напишите тесты
4. Запустите тесты (`flutter test`)
5. Создайте Pull Request с подробным описанием

### Для тестировщиков:
- Тестируйте приложение на разных устройствах
- Сообщайте о найденных багах через Issues
- Предлагайте улучшения UX/UI

### Для контент-мейкеров:
- Предлагайте идеи для нового контента
- Помогайте с написанием документации
- Создавайте обучающие материалы

## 📊 Статистика проекта

[![GitHub issues](https://img.shields.io/github/issues/prod-broke-again/a4pp_flutter)](https://github.com/prod-broke-again/a4pp_flutter/issues)
[![GitHub stars](https://img.shields.io/github/stars/prod-broke-again/a4pp_flutter)](https://github.com/prod-broke-again/a4pp_flutter/stargazers)
[![GitHub license](https://img.shields.io/github/license/prod-broke-again/a4pp_flutter)](https://github.com/prod-broke-again/a4pp_flutter/blob/main/LICENSE)

## 👥 Команда разработчиков

- **Разработчик**: [prod-broke-again](https://github.com/prod-broke-again)

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для получения дополнительной информации.

## 📞 Поддержка

Если у вас есть вопросы или предложения:

- 📧 **Email**: [support@appp-psy.ru](mailto:support@appp-psy.ru)
- 🐛 **Issues**: [GitHub Issues](https://github.com/prod-broke-again/a4pp_flutter/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/prod-broke-again/a4pp_flutter/discussions)

### Сообщество:
- Присоединяйтесь к нашему [Telegram каналу](https://t.me/acpp_app)
- Следите за обновлениями в [Telegram чате](https://t.me/acpp_community)

---

<div align="center">

**АЧПП** - ваш надежный партнер в профессиональном развитии! 🌟

**Разработано с ❤️ для профессионального сообщества психологов и психотерапевтов**

[⭐ Поставьте звезду](https://github.com/prod-broke-again/a4pp_flutter) • [🍴 Форкните проект](https://github.com/prod-broke-again/a4pp_flutter/fork) • [📢 Поделитесь](https://t.me/share/url?url=https://github.com/prod-broke-again/a4pp_flutter&text=Откройте для себя АЧПП - профессиональную платформу для психологов!)

</div>
