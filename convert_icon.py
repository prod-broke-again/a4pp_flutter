#!/usr/bin/env python3
"""
Скрипт для конвертации JPEG в ICO формат для Windows иконки
"""

import os
import sys

def check_pillow():
    """Проверяет наличие Pillow"""
    try:
        from PIL import Image
        return True
    except ImportError:
        return False

def install_pillow():
    """Устанавливает Pillow"""
    print("Устанавливаю Pillow...")
    os.system("pip install Pillow")
    return check_pillow()

def convert_to_ico(input_path, output_path, sizes=[16, 32, 48, 256]):
    """Конвертирует изображение в ICO с несколькими размерами"""
    try:
        from PIL import Image

        # Открываем изображение
        img = Image.open(input_path)

        # Создаем список изображений разных размеров
        icons = []
        for size in sizes:
            # Масштабируем изображение
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            icons.append(resized)

        # Сохраняем как ICO
        icons[0].save(output_path, format='ICO', sizes=[(size, size) for size in sizes])

        print(f"Иконка успешно создана: {output_path}")
        print(f"Размеры: {sizes}")

        return True

    except Exception as e:
        print(f"Ошибка конвертации: {e}")
        return False

def main():
    # Пути к файлам
    input_file = "icon.jpeg"
    output_file = "windows/runner/resources/app_icon.ico"

    # Проверяем существование входного файла
    if not os.path.exists(input_file):
        print(f"Файл {input_file} не найден!")
        return 1

    print("Проверяю наличие Pillow...")

    # Проверяем и устанавливаем Pillow
    if not check_pillow():
        print("Pillow не установлен")
        if not install_pillow():
            print("Не удалось установить Pillow")
            return 1
        print("Pillow установлен")

    print("Конвертирую изображение...")

    # Конвертируем
    if convert_to_ico(input_file, output_file):
        print("Готово! Теперь можно пересобрать приложение:")
        print("   flutter build windows")
        return 0
    else:
        return 1

if __name__ == "__main__":
    sys.exit(main())
