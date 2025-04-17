# CocktailFinder SwiftApp 🍸

Мобильное приложение для поиска и сохранения рецептов коктейлей, разработанное на SwiftUI.

## Описание проекта

CocktailFinder - это современное iOS приложение, которое позволяет пользователям искать, просматривать и сохранять рецепты коктейлей. Приложение использует TheCocktailDB API для получения данных о коктейлях и предоставляет удобный интерфейс для работы с рецептами.

## Основные функции

- 🔍 Поиск коктейлей по названию
- 🎲 Случайный коктейль
- ❤️ Сохранение любимых коктейлей
- 🏷️ Фильтрация по категориям
- 📱 Офлайн доступ к сохраненным коктейлям
- 🔄 Кэширование популярных коктейлей

## Пользовательский интерфейс

### Основные экраны

1. **Поиск (SearchView)**
   - Поисковая строка
   - Список популярных коктейлей
   - Карточки коктейлей с изображениями

2. **Рецепт (RecipeView)**
   - Детальная информация о коктейле
   - Список ингредиентов с мерами
   - Инструкция по приготовлению
   - Кнопка добавления в избранное

3. **Избранное (FavoriteCoctailsView)**
   - Сохраненные коктейли
   - Возможность удаления из избранного

4. **Фильтры (FilterView)**
   - Категории фильтрации
   - Опции фильтров

5. **Случайный коктейль (RandomCocktailView)**
   - Случайный рецепт коктейля
   - Возможность обновления

## Особенности реализации

- Использование UserDefaults для хранения избранных коктейлей
- Кэширование данных для оптимизации производительности
- Асинхронная загрузка изображений
- Обработка ошибок и офлайн-режим
- Кастомные UI компоненты

## Требования

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+
- Доступ к интернету для первичной загрузки данных

## Используемые технологии

- SwiftUI
- Combine
- SDWebImageSwiftUI
- UserDefaults
- URLSession
- JSON Decoding/Encoding
- TheCocktailDB API

## Структура проекта

```
CocktailFinder-SwiftApp/
├── View/
│   ├── SearchView.swift
│   ├── RecipeView.swift
│   ├── FavoriteCoctailsView.swift
│   ├── FilterView.swift
│   ├── CocktailCardView.swift
│   └── RandomCocktailView.swift
├── ViewModel/
│   ├── SearchViewModel.swift
│   ├── FilterViewModel.swift
│   ├── RecipeViewModel.swift
│   ├── RandomCocktailViewModel.swift
│   ├── CocktailCardViewModel.swift
│   └── FavoritesViewModel.swift
├── Model/
│   ├── Cocktail.swift
│   ├── FilterCategory.swift
│   └── FilterOption.swift
├── Services/
│   ├── APIService.swift
│   └── FavoritesService.swift
├── ContentView.swift
└── CocktailFinder_SwiftAppApp.swift
```

## Установка и запуск

### Необходимые инструменты

1. macOS Ventura (13.0) или новее
2. Xcode 14.0 или новее
3. Git
4. Учетная запись Apple ID (для запуска на физическом устройстве)

### Шаги по установке

1. **Клонирование репозитория**
   ```bash
   git clone https://github.com/berrrchik/CocktailFinder-SwiftApp
   cd CocktailFinder-SwiftApp
   ```

2. **Открытие проекта**
   - Откройте Xcode
   - Выберите File → Open
   - Найдите склонированную папку проекта
   - Выберите файл `CocktailFinder-SwiftApp.xcodeproj`

3. **Настройка проекта**
   - В Xcode выберите нужный симулятор iOS или подключенное устройство

4. **Запуск приложения**
   - Нажмите кнопку Run (▶️) или используйте сочетание клавиш Cmd + R
   - Дождитесь завершения сборки и запуска приложения

