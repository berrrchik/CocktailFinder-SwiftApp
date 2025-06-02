#!/bin/bash

echo "🔧 Настройка GitHub Actions CI/CD для iOS проекта"
echo "================================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода статуса
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Проверка наличия git репозитория
if [ ! -d ".git" ]; then
    print_error "Не найден git репозиторий. Инициализируйте git:"
    echo "git init"
    echo "git remote add origin <URL>"
    exit 1
fi

print_status "Git репозиторий найден"

# Проверка наличия .xcodeproj файла
if [ ! -f "CocktailFinder-SwiftApp.xcodeproj/project.pbxproj" ]; then
    print_error "Не найден Xcode проект!"
    exit 1
fi

print_status "Xcode проект найден"

# Создание директории .github/workflows если не существует
mkdir -p .github/workflows
print_status "Папка .github/workflows создана"

# Проверка файлов CI/CD
files=(
    ".github/workflows/ios-ci.yml"
    ".github/workflows/spm-ci.yml"
    ".github/workflows/tests.yml"
    ".github/README.md"
    ".swiftlint.yml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        print_status "$file существует"
    else
        print_warning "$file не найден"
    fi
done

# Проверка наличия SwiftLint
if command -v swiftlint &> /dev/null; then
    print_status "SwiftLint установлен"
else
    print_warning "SwiftLint не установлен. Установите командой:"
    echo "brew install swiftlint"
fi

# Проверка тестовых файлов
if [ -d "CocktailFinder-SwiftAppTests" ]; then
    test_count=$(find CocktailFinder-SwiftAppTests -name "*.swift" | wc -l | tr -d ' ')
    print_status "Найдено $test_count тестовых файлов"
else
    print_warning "Папка с тестами не найдена"
fi

# Настройка Git hooks (опционально)
echo ""
print_info "Настройка Git hooks для автоматического запуска тестов..."

# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🧪 Запуск тестов перед коммитом..."

# Запуск SwiftLint
if command -v swiftlint &> /dev/null; then
    swiftlint
    if [ $? -ne 0 ]; then
        echo "❌ SwiftLint проверка провалена!"
        exit 1
    fi
fi

# Быстрый запуск тестов
xcodebuild test \
    -project CocktailFinder-SwiftApp.xcodeproj \
    -scheme CocktailFinder-SwiftApp \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ Тесты прошли успешно!"
else
    echo "❌ Тесты провалились!"
    echo "Пропустить проверку: git commit --no-verify"
    exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
print_status "Pre-commit hook настроен"

echo ""
echo "🎉 Настройка завершена!"
echo ""
print_info "Следующие шаги:"
echo "1. Закоммитьте изменения: git add . && git commit -m 'feat: add CI/CD'"
echo "2. Запушьте в GitHub: git push origin main"
echo "3. Перейдите в GitHub → Actions, чтобы увидеть запущенные workflows"
echo ""

# Проверка GitHub remote
if git remote -v | grep -q "github.com"; then
    remote_url=$(git remote get-url origin)
    print_status "GitHub remote: $remote_url"
    echo ""
    print_info "После push перейдите в Actions:"
    echo "${remote_url/git@github.com:/https://github.com/}/actions"
    echo ""
else
    print_warning "GitHub remote не настроен. Добавьте:"
    echo "git remote add origin git@github.com:username/CocktailFinder-SwiftApp.git"
fi

print_info "Полезные команды:"
echo "• Локальные тесты: ./run_tests.sh"
echo "• Следить за изменениями: ./watch_tests.sh"
echo "• SwiftLint: swiftlint"
echo "• Пропуск pre-commit: git commit --no-verify" 