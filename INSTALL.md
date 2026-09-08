# Установка Codex Docker-стенда

Один архив поддерживает macOS с Docker Desktop и Linux с Docker Compose plugin.
На Linux графический ярлык совместим с KDE и GNOME.

## Требования

- macOS: установленный Docker Desktop;
- Linux: Docker Engine с Compose plugin и доступ пользователя к Docker;
- для AmneziaWG: доступный `/dev/net/tun`;
- интернет для первой сборки образа.

## Установка

```bash
mkdir -p ~/Projects
tar -xzf cdx-portable.tar.gz -C ~/Projects
cd ~/Projects/cdx
./install.sh
```

Установщик определит UID/GID и существующие каталоги `~/Projects`,
`~/WebstormProjects` и `~/PycharmProjects`, создаст локальный `.env`, соберёт
контейнер и установит ярлык для текущей ОС.

## Установка с AmneziaWG

```bash
./install.sh --awg-config /path/to/amneziawg.conf
```

Конфиг копируется в `secrets/amneziawg.conf` с правами `600`. Если конфиг не
передан, контейнер запускается без VPN. При наличии конфига через VPN идут
только IP, полученные при запуске для доменов из `OPENAI_VPN_DOMAINS`; остальной
трафик использует обычную сеть.

## Запуск

```bash
./exec_codex.sh
./exec_codex.sh resume --last
```

Перед каждым запуском появляется английский запрос режима подключения:

```text
How should Codex CLI Docker connect?
  1) Through AmneziaWG VPN
  2) Without VPN (direct connection)
Select an option [1-2] (default: 2):
```

Для первого варианта должен существовать `secrets/amneziawg.conf`. Второй
вариант и нажатие Enter используют прямое подключение без VPN.

## Выбор DNS

DNS-серверы перечисляются по одному IPv4-адресу на строку в
`dns-servers.txt`. Если в файле есть адреса, при запуске появляется отдельный
выбор DNS. Вариант `0` оставляет системный DNS Docker. Если файл пуст, вопрос не
задаётся. Выбранный DNS не направляется через AmneziaWG.

Установить или переустановить ярлык отдельно:

```bash
./install-shortcut.sh
```

## Состав переносимого архива

Каталоги `workspace/` и `context/` входят пустыми. В архив не входят `.env`,
`secrets/`, `codex-home/`, `backups/`, `dist/`, локальный файл `resume` и
служебные виртуальные окружения. Поэтому архив не содержит VPN-ключей,
авторизацию, историю Codex и рабочие данные.
