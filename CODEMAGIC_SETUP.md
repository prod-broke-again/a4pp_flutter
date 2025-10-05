# Настройка Codemagic для iOS сборки

## 🚀 Быстрый старт

### 1. Регистрация в Codemagic
- Перейдите на [codemagic.io](https://codemagic.io)
- Зарегистрируйтесь (есть бесплатный тариф)

### 2. Подключение репозитория
- В Codemagic нажмите "Add application"
- Выберите ваш Git репозиторий
- Codemagic автоматически найдет `codemagic.yaml`

### 3. Настройка для TestFlight (опционально)

#### Получение Apple Developer аккаунта
1. Зарегистрируйтесь в [Apple Developer Program](https://developer.apple.com/programs/)
2. Стоимость: $99/год

#### Создание App ID в App Store Connect
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Создайте новое приложение
3. Запишите App ID (например: 1234567890)

#### Настройка сертификатов
1. В Codemagic создайте группу credentials: `app_store_credentials`
2. Добавьте следующие переменные:
   - `APP_STORE_CONNECT_PRIVATE_KEY` - ваш приватный ключ
   - `APP_STORE_CONNECT_KEY_IDENTIFIER` - ID ключа
   - `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID
   - `CERTIFICATE_PRIVATE_KEY` - зашифрованный приватный ключ сертификата
   - `CERTIFICATE_PASSWORD` - пароль от сертификата
   - `DEVELOPMENT_TEAM` - ваш Team ID из Apple Developer

### 4. Первый запуск
- В Codemagic нажмите "Start new build"
- Выберите workflow: `ios-debug` или `ios-release`
- Для TestFlight выберите `ios-release`

## 📱 Тестирование без TestFlight

Если у вас нет Apple Developer аккаунта, используйте:
- **Flutter Web** для проверки UI: `flutter run -d chrome --web-renderer html`
- **Chrome DevTools** для мобильного режима

## 🐛 Возможные проблемы

### Ошибка "firebase_core requires iOS 15.0"
✅ **Уже исправлено**: deployment target обновлен до 15.0

### Ошибка "No platform specified"
✅ **Уже исправлено**: добавлен Podfile с platform :ios, '15.0'

### Проблемы с certificates
- Убедитесь, что все переменные в Codemagic зашифрованы
- Проверьте Team ID в Apple Developer Console

## 📞 Поддержка

Если что-то не работает, проверьте:
1. Логи сборки в Codemagic
2. Правильность переменных окружения
3. Наличие всех необходимых файлов в репозитории
