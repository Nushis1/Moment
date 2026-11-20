# MOMENT

Prywatna aplikacja na iPhone'a (iOS 26+, Swift 6, SwiftUI) do podejmowania decyzji w relacjach.
Analiza ma działać lokalnie, deterministycznie i bez generatywnego AI.

> **Status: Faza 1 (frontend).** Design System, nawigacja i wszystkie ekrany. Ten kod **nie był kompilowany**
> (pisany bez Xcode). Pierwszy build w Codemagic pokaże ewentualne błędy kompilacji, które trzeba poprawić.
> Dane żyją tylko w pamięci i znikają po zamknięciu aplikacji. Trwały zapis i silnik decyzji to Faza 2.

## Struktura

```
Moment.xcodeproj/        projekt (foldery synchronizowane: nowe pliki .swift dodają się same)
Moment-Info.plist        Face ID
codemagic.yaml           ios-unsigned (testy + .ipa do sideloadu), ios-signed (Ad Hoc, ręcznie)
Moment/                  target aplikacji
  App/                   MomentApp, RootView + TabView, Router (ścieżka na zakładkę), MomentStore, AppLock
  DesignSystem/          tokeny, powierzchnie, przyciski (Liquid Glass), chipsy, pola tekstu, wskaźniki, stany
  Features/              Onboarding, Home, NewMoment, ReplyStudio, History, People, Insights, Settings
  Temporary/             DemoAnalyzer + DemoData: ATRAPY do usunięcia w Fazie 2
  Assets.xcassets        kolory (Light/Dark osobno), ikona (placeholder)
  Localizable.xcstrings  EN (źródło) + PL
MomentCore/              pakiet SPM: model domeny, scoring, InsightsSummary, protokół MomentAnalyzing + testy
tools/                   l10n_extract.py (sprawdza brakujące tłumaczenia), build_catalog.py, pl.py
```

## Design System

| Token | Light | Dark |
|---|---|---|
| Background | #F7F7F5 | #101010 |
| Surface | #FFFFFF | #1C1C1E |
| Accent (tekst, ikony) | #6667CC | #9999F0 |
| Accent fill (przyciski) | #6667CC | #6A6BD6 |
| Text / Secondary | #151515 / #6B6B6B | #F5F5F5 / #929292 |

Odcienie akcentu zostały lekko przyciemnione względem specyfikacji (#7778D8 / #9999F0), żeby biały tekst
na przyciskach i akcent na jasnym tle miały kontrast co najmniej ~4,5:1.
Zasada: **szkło tylko na warstwie sterowania** (przyciski, pasek kart, toolbary), treść na nieprzezroczystych kartach.
Typografia: wyłącznie style systemowe (Dynamic Type). Kolory zawsze z `MomentColor`.

## Nawigacja

`TabView` (Start, Studio odpowiedzi, Historia, Osoby, Wnioski), każda zakładka ma własny `NavigationStack`
i własną ścieżkę w `Router`. Arkusze: `New Moment` (5 kroków, potem analiza i rekomendacja) oraz `Settings`.

## Lokalizacja

Kod używa angielskich literałów jako kluczy. Po dodaniu tekstu: dopisz tłumaczenie w `tools/pl.py`, potem
`python3 tools/build_catalog.py` i `python3 tools/l10n_extract.py` (zgłasza brakujące klucze).

## Co zostało z oryginalnego projektu Koda

Tylko szkielet budowania: struktura projektu Xcode, `codemagic.yaml`, `.gitignore`. Cały kod, zasoby, widgety,
Mac Catalyst i dokumentacja Kody zostały usunięte. Usunięto też `LICENSE` (GPL-3 dla Kody), bo nie zostało
nic z jej kodu. Jeśli to twój projekt, zdecyduj sam, jaką licencję chcesz dla MOMENT.
Bundle ID zmieniono na `ivors.Moment`; `DEVELOPMENT_TEAM` został z oryginału.

## Faza 2 (backend)

SwiftData (5 encji) i repozytoria, MOMENT CORE (Context/Language Analyzer, Scenario Evaluator,
Decision Engine, Personalization, Recommendation Builder, Feedback), Keychain, import zamiast atrap.
