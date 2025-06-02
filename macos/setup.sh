#!/bin/bash
echo "Установка Flutter SDK и зависимостей..."
echo "1. Скачиваем Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "2. Запускаем flutter doctor..."
flutter doctor

echo "3. Устанавливаем зависимости проекта..."
flutter pub get