# Переносимый Docker-стенд Codex

Стенд запускает Codex CLI в Docker на macOS (Docker Desktop) и Linux. Для
Linux поддерживаются стандартные меню KDE/GNOME, для macOS создаётся приложение
`~/Applications/Codex CLI Docker.app`.

## Возможности

- автоматическая сборка под архитектуру целевой машины (`arm64` или `amd64`);
- одинаковые команды запуска на macOS и Linux;
- выбор VPN или прямого подключения перед каждым запуском;
- сохранение авторизации и истории в локальном `codex-home/`;
- опциональный AmneziaWG userspace split tunnel только для OpenAI;
- автоматическое создание `.env` с UID/GID и путями пользователя;
- безопасный переносимый архив без ключей и runtime-состояния.

## Быстрый старт

```bash
./install.sh
./exec_codex.sh
```

С AmneziaWG:

```bash
./install.sh --awg-config /path/to/amneziawg.conf
./exec_codex.sh
```

Перед запуском скрипт предложит один из двух режимов:

```text
How should Codex CLI Docker connect?
  1) Through AmneziaWG VPN
  2) Without VPN (direct connection)
```

Выбор `1` требует файла `secrets/amneziawg.conf`. Выбор `2` запускает контейнер
через обычную сеть Docker. При смене режима Compose пересоздаёт контейнер с
новой сетевой настройкой.

После `docker compose down` скрипт `exec_codex.sh` сам поднимет контейнер и
дождётся его готовности.

## Основные файлы

- `Dockerfile` — Codex, `amneziawg-go` и `amneziawg-tools`;
- `docker-compose.yml` — переносимая Compose-конфигурация;
- `install.sh` — настройка macOS/Linux и первая сборка;
- `install-shortcut.sh` — ярлык macOS или KDE/GNOME;
- `exec_codex.sh` — запуск Codex внутри готового контейнера;
- `start-codex-container.sh` — настройка split tunnel;
- `.env.example` — пример локальных параметров;
- `package.sh` — создание безопасного переносимого архива.

Подробная инструкция находится в `INSTALL.md`.

## Упаковка

```bash
./package.sh
```

Результат: `dist/cdx-portable.tar.gz`. Каталоги `workspace/` и `context/`
создаются пустыми; VPN-конфиги, токены, история и резервные образы исключаются.
