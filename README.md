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

## Скриншоты приложения

<p align="center">
   <img src="https://github.com/user-attachments/assets/80227092-f072-4396-a252-1c0f231fb05d" alt="Экран поиска с популярными коктейлями" width="32%" />
   <img src="https://github.com/user-attachments/assets/da70cbef-f5e4-4462-b503-79451f3f6fbc" alt="Экран поиска" width="32%" />
  <img src="https://github.com/user-attachments/assets/a55a02ea-c0ca-4f5e-886c-fdd5845d9110" alt="Экран рецепта" width="32%">
   <img src="https://github.com/user-attachments/assets/bf8b5907-3b83-4a3a-b6f4-8e6fd9e3c429" alt="Экран любимых коктейлей" width="32%" />
   <img src="https://github.com/user-attachments/assets/3a7fc44b-9e34-4782-b10e-737e3af9ef92" alt="Экран коктейлей по фильтрам" width="32%" />
   <img src="https://github.com/user-attachments/assets/78b2c17a-805f-4415-9fce-ce1e5d4ec5ea" alt="Экран случанойго коктейля" width="32%" />
</p>


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

