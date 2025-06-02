#!/bin/bash

# Установите fswatch если его нет: brew install fswatch

echo "🧪 Запускаю автоматическое тестирование..."
echo "📁 Отслеживаю изменения в: $(pwd)"
echo "⚡ Тесты будут запускаться при изменении Swift файлов"
echo "🛑 Нажмите Ctrl+C для остановки"
echo ""

run_tests() {
    echo "🔄 Обнаружены изменения. Запускаю тесты..."
    echo "$(date): Запуск тестов" >> test_runs.log
    
    xcodebuild -project CocktailFinder-SwiftApp.xcodeproj \
               -scheme CocktailFinder-SwiftApp \
               -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
               test \
               | xcbeautify
    
    if [ $? -eq 0 ]; then
        echo "✅ Тесты прошли успешно!"
        echo "$(date): УСПЕХ" >> test_runs.log
    else
        echo "❌ Тесты провалились!"
        echo "$(date): ОШИБКА" >> test_runs.log
    fi
    echo ""
}

# Запускаем тесты в начале
run_tests

# Отслеживаем изменения в Swift файлах
fswatch -o . \
    --include=".*\.swift$" \
    --exclude=".*\.git.*" \
    --exclude=".*build.*" \
    --exclude=".*DerivedData.*" \
    | while read num; do
        sleep 1  # Небольшая задержка чтобы избежать множественных запусков
        run_tests
    done 