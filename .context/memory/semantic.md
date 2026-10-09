# Семантическая память att51

## Доказанные устойчивые сведения
- att51 создан через repo-factory; идентификатор постоянного менеджера project-manager; authoritative manager_state и product_branch — main. Источник: .context/manifest.json, .context/manager/identity.json, GitHub; authority: repository.
- Оригинальный установщик «Аттестация-5.1 (СОУТ)» 5.1.1739 распакован по Inno Setup 5.3.10: 3614 файла, 645359024 байта. Источник: research/EXTRACTION_VERIFIED.md; authority: verified extraction.
- **Полная публикация завершена.** По дереву GitHub main: extracted/ = 3614 файла / 645359024 байта. Старое состояние с 3612 файлами заменено. Добавлены app/dop_info.ini и win/att_reg/att.reg по прямым указаниям владельца; authority: verified repository + owner-directive; проверка GitHub Actions 37865751465 успешна.
- Только att51 имеет исключение владельца на размер/тип файлов в extracted/. Общая фабрика и другие репозитории не затронуты. Источник: .context/project/constraints.md; authority: owner directive.
- **Оригинальная архитектура согласно статическому исследованию:** Windows-загрузчик VB6, Word-шаблоны/надстройка VBA, Access MDB для объектов и РМ, документы DOC/DOCX и XML. Расчёт и специализированная отправка протокола в базу — разные операции. Источник: research/OPERATING_CYCLE.md; authority: static source inspection; точные вызовы и фактический запуск требуют воспроизводимой повторной проверки.
- Пользователь указал **внешнюю реализацию sout-app пока не принимать во внимание**. Источник: прямое сообщение владельца; authority: owner-directive.

## Не повышать до подтверждённых фактов без проверки
- В research/OPERATING_CYCLE.md указано 569 модулей VBA; полный воспроизводимый каталог и функции модулей требуется проверить отдельно.
- Работа программы в Windows, фактический порядок всех окон и правильность формул расчёта, сетевые интеграции и полнота связей MDB пока не испытаны.
- Техническая доступность третьего ПО в GitHub не доказывает права на его распространение.
