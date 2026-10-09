# Подтверждённые представления менеджера проекта att51

## B1 — Исходный объект
- Установщик: «Аттестация-5.1 (СОУТ)», версия 5.1.1739, SHA-256 `941e82cd07815861a10d7c77c9c47b94dcad799b6d7408e78bd3749d4eb2cfcc`.
- Таблица Inno Setup 5.3.10 содержит 3614 записей файлов, суммарный исходный объём 645359024 байта.
- source: `research/EXTRACTION_VERIFIED.md`, `research/inno-5.3.10-verified-files.csv`; authority: verified-runtime.

## B2 — Размещение приложения в GitHub
- В `extracted/` опубликованы 3612 оригинальных файлов (645358881 байт), с сохранением относительных путей и байтов. Два файла исключены: `app/dop_info.ini` и `win/att_reg/att.reg` (143 байта).
- Источник: дерево GitHub после коммита `32c5a10f4bd53362d7c3222d013c12777dd28cc8` и успешный процесс восстановления https://github.com/lvlaksim1/att51/actions/runs/37863832729 .
- authority: verified-repository / verified-ci; supersedes прежнее состояние «только 472 файла».

## B3 — Проверка целостности
- ZIP SHA-256: `6ea5f8db55883b39c8620bb2858fb09beff4ce325879c43eeb88295f20d8caed`.
- Перед публикацией проверены исходные SHA-256 всех 3614 файлов; контрольные суммы Git у выборки из 8 опубликованных файлов совпадают с исходными.
- source: https://github.com/lvlaksim1/att51/actions/runs/37863832729 и `research/PUBLICATION_VERIFIED.md`; authority: verified-ci / verified-repository.

## B4 — Политика
- Решение владельца от 09.10.2026: только для `att51` разрешён учёт исследовательских файлов в `extracted/` независимо от расширения и внутреннего лимита 5 МиБ. Общую политику `repo-factory` не менять.
- Секреты и идентификаторы регистрации не публиковать; исключение для `att51` техническое, а не предоставление авторских прав третьих лиц.
- source: прямая директива владельца, `.context/project/constraints.md`; authority: owner-directive.

## B5 — Границы знания
- Файлы доступны для статического изучения, но исполняемый код не запускался; функции Windows/Word, схемы MDB и VBA пока не проверены полностью.
- source: журнал исследования; authority: verified-runtime.
