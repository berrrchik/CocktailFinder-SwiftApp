# GitHub Actions CI/CD для iOS проекта

## 🚀 Обзор

Этот проект использует GitHub Actions для автоматизации:
- ✅ Тестирования кода
- 🔍 Линтинга (SwiftLint)
- 📊 Анализа покрытия кода
- 🔨 Сборки релизных версий
- 📱 UI-тестирования

## 📁 Структура файлов

```
.github/
├── workflows/
│   ├── ios-ci.yml      # Основной CI/CD pipeline
│   ├── spm-ci.yml      # Swift Package Manager CI
│   └── tests.yml       # Упрощенная версия для тестов
└── README.md           # Этот файл
```

## 🔧 Конфигурация

### 1. Основной пайплайн (ios-ci.yml)

#### Триггеры:
- **Push** в ветки `main` и `develop`
- **Pull Request** в ветку `main`
- **Ручной запуск** через GitHub UI

#### Задачи (Jobs):

##### 📝 Lint
```yaml
lint:
  name: SwiftLint
  runs-on: macos-latest
```
- Устанавливает SwiftLint
- Проверяет стиль кода
- Отчеты в формате GitHub Actions

##### 🧪 Unit Tests
```yaml
unit-tests:
  strategy:
    matrix:
      destination: 
        - 'iPhone 15'
        - 'iPhone 15 Pro'
```
- Параллельное тестирование на разных симуляторах
- Кэширование зависимостей для ускорения
- Сохранение результатов тестов

##### 🖥️ UI Tests
- Запускается только для `main` ветки
- Тестирует пользовательский интерфейс
- Создает скриншоты ошибок

##### 📊 Code Coverage
- Генерирует отчеты покрытия
- Интеграция с Codecov
- JSON и текстовые отчеты

##### 🏗️ Build Release
- Сборка релизной версии
- Только для `main` ветки
- Проверка на продакшн-готовность

## 🛠️ Использование

### Локальная разработка

1. **Запуск тестов локально:**
```bash
# Все тесты
./run_tests.sh

# Автоматический запуск при изменениях
./watch_tests.sh
```

2. **Проверка линтинга:**
```bash
# Установка SwiftLint
brew install swiftlint

# Запуск проверки
swiftlint
```

### GitHub Actions

#### Автоматический запуск:
- При push в `main`/`develop`
- При создании Pull Request
- При merge PR

#### Ручной запуск:
1. Перейти в `Actions` → `iOS CI/CD`
2. Нажать `Run workflow`
3. Выбрать ветку и нажать `Run workflow`

## 📊 Мониторинг

### Badges для README
Добавьте в основной README.md:

```markdown
[![iOS CI](https://github.com/username/CocktailFinder-SwiftApp/workflows/iOS%20CI%2FCD/badge.svg)](https://github.com/username/CocktailFinder-SwiftApp/actions)
[![codecov](https://codecov.io/gh/username/CocktailFinder-SwiftApp/branch/main/graph/badge.svg)](https://codecov.io/gh/username/CocktailFinder-SwiftApp)
```

### Просмотр результатов:
1. **Actions tab** - все запуски
2. **Artifacts** - результаты тестов (.xcresult файлы)
3. **Logs** - детальные логи каждого шага

## 🔧 Настройка

### Переменные окружения
```yaml
env:
  DEVELOPER_DIR: /Applications/Xcode_15.2.app/Contents/Developer
```

### Секреты (Settings → Secrets)
Если нужны:
- `CODECOV_TOKEN` - для отправки покрытия
- `APP_STORE_CONNECT_KEY` - для деплоя
- `MATCH_PASSWORD` - для сертификатов

### Кэширование
```yaml
- name: Cache build artifacts
  uses: actions/cache@v4
  with:
    path: |
      ~/Library/Developer/Xcode/DerivedData
      ~/.cache/org.swift.swiftpm/
    key: ${{ runner.os }}-xcode-${{ hashFiles('**/*.xcodeproj') }}
```

## 📱 Поддерживаемые устройства

- iPhone 15 (iOS latest)
- iPhone 15 Pro (iOS latest)
- Легко добавить другие в `matrix.destination`

## 🐛 Отладка

### Просмотр логов:
1. Перейти в Actions → выбрать workflow
2. Кликнуть на нужный job
3. Развернуть нужный step

### Общие проблемы:

#### Simulator не найден:
```yaml
- name: Show available simulators
  run: xcrun simctl list devicetypes
```

#### Timeout тестов:
```yaml
- name: Run Tests
  timeout-minutes: 30  # Добавить timeout
```

#### Недостаток места:
```yaml
- name: Free disk space
  run: |
    sudo rm -rf /Applications/Xcode_*.app
    sudo rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

## 🔄 Workflow статусы

- ✅ **Success** - все тесты прошли
- ❌ **Failure** - есть проваленные тесты
- 🟡 **Cancelled** - отменено пользователем
- ⚪ **Skipped** - пропущено по условию

## 🚀 Продвинутые возможности

### Conditional runs:
```yaml
if: github.ref == 'refs/heads/main'        # Только main
if: contains(github.event.head_commit.message, '[skip ci]')  # Пропуск по сообщению
```

### Matrix builds:
```yaml
strategy:
  matrix:
    xcode: ['15.1', '15.2']
    ios: ['17.0', '17.1']
```

### Slack уведомления:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 📚 Полезные ссылки

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Command Line Tools](https://developer.apple.com/xcode/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Codecov Documentation](https://docs.codecov.com/)

## 🔄 Обновления

Регулярно обновляйте версии actions:
- `actions/checkout@v4` → latest
- `actions/cache@v4` → latest
- `codecov/codecov-action@v4` → latest 