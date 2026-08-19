# EasyEffects Quick Access

KDE Plasma 6 rendszertálca plasmoid az [EasyEffects](https://github.com/wwmm/easyeffects) gyors eléréséhez.

> **Megjegyzés az AI-közreműködésről:** A kód nagy része AI (Claude) segítségével
> készült, emberi tervezés, irányítás és folyamatos ellenőrzés mellett. A
> funkcionalitásért és a projekt irányáért a szerző felel.

## Funkciók

- **Bal kattintás**: megnyitja az EasyEffects alkalmazást
- **Jobb kattintás**: felsorolja a mentett profilokat (presetek), az éppen aktív
  kiemelésével; kattintásra betölti a kiválasztott profilt
- A profillista automatikusan frissül percenként, illetve profil betöltése után

## Telepítés

```bash
kpackagetool6 -i org.kde.easyeffectsquick
```

Frissítéshez:

```bash
kpackagetool6 -u org.kde.easyeffectsquick
```

Eltávolításhoz:

```bash
kpackagetool6 -r org.kde.easyeffectsquick
```

A telepítés/frissítés után érdemes a plasmashell-t is újraindítani:

```bash
kquitapp6 plasmashell && kstart plasmashell
```

## Követelmények

- KDE Plasma 6
- Telepített [EasyEffects](https://github.com/wwmm/easyeffects)
  (a `easyeffects` parancs elérhető kell legyen)

## Licenc

GPL-3.0-or-later