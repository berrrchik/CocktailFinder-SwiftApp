#!/bin/bash

echo "🧪 Запускаю тесты для CocktailFinder-SwiftApp..."

# Проверяем существование проекта
if [ ! -f "CocktailFinder-SwiftApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Файл проекта не найден!"
    exit 1
fi

# Запускаем тесты
xcodebuild -project CocktailFinder-SwiftApp.xcodeproj \
           -scheme CocktailFinder-SwiftApp \
           -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
           clean test \
           | xcbeautify || echo "⚠️  xcbeautify не найден, используем стандартный вывод"

if [ $? -eq 0 ]; then
    echo "✅ Все тесты прошли успешно!"
else
    echo "❌ Некоторые тесты провалились!"
    exit 1
fi 