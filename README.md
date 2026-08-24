# cyberleek-watch (Cloud)

Ueberwacht den X-(Twitter-)Account **@cyberleeeknet** rund um die Uhr auf GitHub
und schickt bei jedem neuen Post eine Push-Nachricht via [ntfy.sh](https://ntfy.sh)
aufs Handy. **Der eigene PC muss dafuer NICHT laufen.**

## Wie es funktioniert
- `.github/workflows/watch.yml` startet alle ~5 Minuten automatisch auf GitHubs Servern.
- `check.sh` liest den Post-Zaehler des Profils (ueber die kostenlosen Spiegel
  fxtwitter/vxtwitter, ohne X-Login/API).
- Ist der Zaehler groesser als der gespeicherte Wert in `state.txt`, wird eine
  ntfy-Push verschickt und der neue Wert zurueck ins Repo geschrieben.

## Einrichtung
1. Neues **privates** GitHub-Repo anlegen und diese Dateien hochladen.
2. Reiter **Actions** oeffnen und Workflows aktivieren.
3. In der **ntfy**-App (Android/iOS) das Thema abonnieren, das in
   `watch.yml` unter `NTFY_TOPIC` steht.
4. Fertig. Zum Testen: Actions -> "cyberleek-watch" -> **Run workflow**.

## Anpassen
- Anderes Konto oder Thema: Werte `USER_HANDLE` / `NTFY_TOPIC` in `watch.yml` aendern.
- Aus Sicherheitsgruenden ein **eigenes, geheimes** ntfy-Thema waehlen (jeder, der
  das Thema kennt, kann die Nachrichten mitlesen).
