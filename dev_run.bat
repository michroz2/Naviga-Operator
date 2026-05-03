@echo off
echo Cleaning files desktop.ini...

:: Команда удаляет файлы desktop.ini рекурсивно (/s), без запроса (/q), 
:: включая скрытые атрибуты (/a:h), и подавляет вывод ошибок (2>nul)
del /s /q /a:h desktop.ini 2>nul

echo Cleaning complete. Starting run...
flutter run