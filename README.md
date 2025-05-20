# 🔍 Monitoring Task — Система мониторинга процесса `test`

Этот проект представляет собой Bash-скрипт и systemd-юнит, предназначенные для автоматического мониторинга системного процесса с именем `test`.  
Если процесс работает — отправляется HTTP-запрос; если он был перезапущен или сервер недоступен — всё логируется.

## 📁 Структура проекта

monitoring-task/
├── bin/
│ └── test_monitor.sh # Скрипт мониторинга
├── log/
│ ├── monitoring.log # Лог-файл с событиями
│ └── test_monitor.pid # Хранит последний PID процесса
├── systemd/
│ ├── test-monitor.service # Юнит-файл systemd
│ └── test-monitor.timer # Таймер systemd
└── README.md # Описание проекта

Дополнительно 
/etc/logrotate.d/
└── test_monitor # Конфигурация ротации логов 

## ⚙ Что делает скрипт

- Проверяет, запущен ли процесс с именем `test` (`pgrep`)
- Если запущен:
  - Отправляет HTTPS-запрос на `https://test.com/monitoring/test/api`
  - Проверяет, изменился ли PID (т.е. был ли перезапуск)
  - Записывает в лог:
    - факт перезапуска
    - ошибку соединения, если сервер недоступен
- Если процесс **не запущен** — ничего не делает


## 🛠 Установка

### 1. Клонируйте или переместите папку `monitoring-task` в нужное место, например:
cp -r monitoring-task ~/monitoring-task

2. Сделайте скрипт исполняемым
chmod +x ~/monitoring-task/bin/test_monitor.sh

3. Установите systemd-юниты
sudo cp ~/monitoring-task/systemd/test-monitor.* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now test-monitor.timer

🔁 Проверка работоспособности
Ручной запуск скрипта:
~/monitoring-task/bin/test_monitor.sh

Проверка лога:
cat ~/monitoring-task/log/monitoring.log

Проверка systemd-состояния:
systemctl status test-monitor.service
systemctl list-timers --all | grep test-monitor
journalctl -u test-monitor.service --since "10 minutes ago"

📌 Важно
Лог-файл: ~/monitoring-task/log/monitoring.log

PID-файл: ~/monitoring-task/log/test_monitor.pid

Вызывается по таймеру systemd каждую минуту

Работает даже после перезагрузки, если таймер включён

Обратная связь:
TG: @stuntzzz
email: podsevniy.timur@yandex.ru
