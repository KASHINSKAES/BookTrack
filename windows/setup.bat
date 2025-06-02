@echo off
echo Установка Flutter SDK и зависимостей...
echo 1. Скачиваем Flutter...
curl -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.0-stable.zip
tar -xf flutter.zip
set PATH=%cd%\flutter\bin;%PATH%

echo 2. Запускаем flutter doctor...
flutter doctor

echo 3. Устанавливаем зависимости проекта...
flutter pub get

pause