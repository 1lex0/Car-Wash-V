# 2D Wash

Flutter-приложение для поиска автомоек и просмотра живой карты загрузки
(I-Wash), плюс собственный backend.

```
frontend/   Flutter-приложение (экраны, модели, repository)
server/     backend на C# / .NET 9 (Minimal API + SQLite)
```

Backend: выбран порт **C# / .NET (Minimal API)** из kit-а `05_Backend/`
шаблона PAM — язык, которым я владею.

## Запуск

```bash
cd server && dotnet run            # слушает на http://localhost:8080 (env PORT)
curl http://localhost:8080/health  # {"status":"ok"}

cd frontend && flutter run         # эмулятор Android ходит на http://10.0.2.2:8080
```

`app.db` (SQLite) создаётся сервером сам при первом запуске. Изменили
колонки таблицы — удалите `server/app.db` (CREATE TABLE IF NOT EXISTS не
меняет уже созданную таблицу).
