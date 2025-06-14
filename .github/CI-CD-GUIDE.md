# GitHub Actions CI/CD для iOS проекта

## 🚀 Обзор

Этот проект использует GitHub Actions для автоматизации:
- ✅ Тестирования кода (Unit + UI тесты)
- 🔍 Линтинга (SwiftLint)
- 📊 Анализа покрытия кода
- 🔨 Сборки релизных версий
- 📱 Параллельного тестирования на разных симуляторах

## 📁 Структура файлов

```
.github/
├── workflows/
│   └── ios-ci.yml          # Основной CI/CD pipeline
└── CI-CD-GUIDE.md          # Этот файл
```

## 🔧 Конфигурация

### Основной пайплайн (ios-ci.yml)

#### Триггеры:
- **Push** в ветки `main` и `develop`
- **Pull Request** в ветку `main`
- **Ручной запуск** через GitHub UI

#### Задачи (Jobs):

##### 📝 SwiftLint
```yaml
lint:
  name: SwiftLint
  runs-on: macos-latest
```
- Устанавливает SwiftLint через Homebrew
- Проверяет стиль кода
- Отчеты в формате GitHub Actions

##### 🧪 Unit Tests
```yaml
unit-tests:
  strategy:
    matrix:
      destination: 
        - 'iPhone 16'
        - 'iPhone 16 Pro'
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

#### 🚫 Пропуск CI/CD:
Добавьте в сообщение коммита одно из:
- `[skip ci]`
- `[ci skip]`

Пример:
```bash
git commit -m "docs: update README [skip ci]"
```

## 📊 Мониторинг

### Badges для README
Добавьте в основной README.md:

```markdown
[![iOS CI/CD](https://github.com/berrrchik/CocktailFinder-SwiftApp/workflows/iOS%20CI%2FCD/badge.svg)](https://github.com/berrrchik/CocktailFinder-SwiftApp/actions)
[![codecov](https://codecov.io/gh/berrrchik/CocktailFinder-SwiftApp/branch/main/graph/badge.svg)](https://codecov.io/gh/berrrchik/CocktailFinder-SwiftApp)
```

### Просмотр результатов:
1. **Actions tab** - все запуски
2. **Artifacts** - результаты тестов (.xcresult файлы)
3. **Logs** - детальные логи каждого шага

## 🔧 Настройка

### Xcode версии
Используется `latest-stable` через:
```yaml
- name: Set up Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: latest-stable
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

- iPhone 16 (iOS latest)
- iPhone 16 Pro (iOS latest)
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
    sudo rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### Проблемы с подписью кода:
Для CI сборок мы отключаем требование подписи кода с помощью следующих флагов:
```yaml
CODE_SIGNING_ALLOWED=NO
CODE_SIGNING_REQUIRED=NO
CODE_SIGN_IDENTITY=""
```

#### Проблемы с покрытием кода:
Если файл TestResults.xcresult не генерируется или не может быть прочитан:
1. Убедитесь, что тесты запускаются с флагом `-enableCodeCoverage YES`
2. Проверьте, что артефакт с результатами тестов правильно загружается и скачивается
3. Добавьте проверку наличия файла перед генерацией отчета:
```yaml
if [ -f TestResults.xcresult ]; then
  xcrun xccov view --report --json TestResults.xcresult > coverage.json
else
  echo "TestResults.xcresult file not found"
fi
```

## 🔄 Workflow статусы

- ✅ **Success** - все тесты прошли
- ❌ **Failure** - есть проваленные тесты
- 🟡 **Cancelled** - отменено пользователем
- ⚪ **Skipped** - пропущено по условию или `[skip ci]`

## 🚀 Продвинутые возможности

### Условный запуск:
```yaml
if: github.ref == 'refs/heads/main'        # Только main
if: contains(github.event.head_commit.message, '[skip ci]')  # Пропуск по сообщению
```

### Matrix builds:
```yaml
strategy:
  matrix:
    destination: ['iPhone 16', 'iPhone 16 Pro']
    xcode: ['latest-stable']
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
- `maxim-lobanov/setup-xcode@v1` → latest 