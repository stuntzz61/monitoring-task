#  Monitoring Task — Система мониторинга процесса `test`

Этот проект представляет собой Bash-скрипт и systemd-юнит, предназначенные для автоматического мониторинга системного процесса с именем `test`.  
Если процесс работает — отправляется HTTP-запрос; если он был перезапущен или сервер недоступен — всё логируется.

## 📁 Структура проекта
monitoring-task/
├── README.md                      #  описание проекта
├── bin/
│   └── test_monitor.sh            #  основной скрипт мониторинга
├── log/ 
│   └── test_monitor.pid           #  PID последнего отслеживаемого процесса
└── systemd/
    ├── test-monitor.service       # nit-файл systemd
    └── test-monitor.timer         # таймер systemd

Дополнительно 
/etc/logrotate.d/
└── test_monitor # Конфигурация ротации логов 

# Что делает скрипт

- Проверяет, запущен ли процесс с именем `test` (`pgrep`)
- Если запущен:
  - Отправляет HTTPS-запрос на `https://test.com/monitoring/test/api`
  - Проверяет, изменился ли PID (т.е. был ли перезапуск)
  - Записывает в лог:
    - факт перезапуска
    - ошибку соединения, если сервер недоступен
- Если процесс **не запущен** — ничего не делает


## Установка

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

# Доп. функция
Проверка лога через journalctl:
journalctl -t test_monitor --since "10 minutes ago"

Проверка логов в файле:
sudo tail /var/log/monitoring.log

Проверка systemd-состояния:
systemctl status test-monitor.service
systemctl list-timers --all | grep test-monitor

Важно

Логирование выполняется через logger, доступно через journalctl

Файл ~/monitoring-task/log/test_monitor.pid хранит последний отслеживаемый PID

Таймер запускает мониторинг раз в минуту

Работает даже после перезагрузки, если таймер включён

Отправляет JSON в формате:

{
  "proc_status": "ok",
  "pid": 1234,
  "timestamp": "2025-05-23T16:40:00+03:00"
}

Как отключить мониторинг

Если вы хотите временно или полностью отключить работу скрипта:

### 🔻 1. Остановить таймер и сервис:
sudo systemctl stop test-monitor.timer
sudo systemctl stop test-monitor.service

Отключить автозапуск при загрузке:
sudo systemctl disable test-monitor.timer
sudo systemctl disable test-monitor.service

# Тестирование
При использовании https://test.com/monitoring/test/api (как в тз) сервер возвращает ошибку (HTTP 403), что корректно логируется как сбой
мониторинга.
При замене на другой API https://httpbin.org/post запросы успешно проходят.(Успешные запросы не фиксируются, т.к противоречит ТЗ)
но, при временном методе для проверки в логах фиксируется "Monitoring success (HTTP 200)".

Обратная связь:
TG: @stuntzzz
email: podsevniy.timur@yandex.ru
