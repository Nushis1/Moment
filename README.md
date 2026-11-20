# MOMENT

Prywatna aplikacja na iPhone'a (iOS 26+, Swift 6, SwiftUI) do podejmowania decyzji w relacjach.
Analiza ma działać lokalnie, deterministycznie i bez generatywnego AI.

> **Status: Faza 1 (frontend) + Faza 2a (MOMENT CORE).** Silnik decyzyjny działa lokalnie i jest podłączony do
> ekranów. Dane nadal żyją tylko w pamięci i znikają po zamknięciu aplikacji; trwały zapis (SwiftData), Keychain
> i ochrona plików to Faza 2b.

## Struktura

```
Moment.xcodeproj/        projekt (foldery synchronizowane: nowe pliki .swift dodają się same)
Moment-Info.plist        Face ID
codemagic.yaml           ios-unsigned (testy + .ipa do sideloadu), ios-signed (Ad Hoc, ręcznie)
Moment/                  target aplikacji
  App/                   MomentApp, RootView + TabView, Router (ścieżka na zakładkę), MomentStore, AppLock
  DesignSystem/          tokeny, powierzchnie, przyciski (Liquid Glass), chipsy, pola tekstu, wskaźniki, stany
  Features/              Onboarding, Home, NewMoment, ReplyStudio, History, People, Insights, Settings
  Temporary/             DemoData: przykładowa treść (wiersz w Ustawieniach), do usunięcia w Fazie 2b
  Assets.xcassets        kolory (Light/Dark osobno), ikona (placeholder)
  Localizable.xcstrings  EN (źródło) + PL
MomentCore/              pakiet SPM, bez zależności od UI i SwiftData
  Domain/                typy wejścia i wyniku, scoring, InsightsSummary
  Engine/                ContextAnalyzer, LanguageAnalyzer (NaturalLanguage + słowniki PL/EN), ScenarioEvaluator,
                         DecisionEngine, PersonalizationEngine, RecommendationBuilder, ReplyAdvisor, FeedbackEngine
  Resources/             Localizable.xcstrings z tekstami silnika (EN + PL)
  Tests/                 testy jednostkowe silnika (Swift Testing)
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

## MOMENT CORE: jak działa

`MomentEngine.analyze(input, context)` to czysta funkcja: ten sam opis sytuacji, preferencje i historia zawsze dają ten sam wynik.
Brak sieci i brak generatywnego AI; teksty powstają z ręcznie napisanych szablonów i wariantów.

1. **ContextAnalyzer** porządkuje dane: intensywność emocji, kompletność informacji (evidence 0-100), braki, ograniczenia bezpieczeństwa.
2. **LanguageAnalyzer** liczy cechy tekstu (pytania, wykrzykniki, WIELKIE LITERY, łagodzniki, absolutyzmy, ton napięty/ciepły).
   Pojedyncze słowo nigdy nie jest dowodem intencji. Rozpoznaje prośby o dystans po polsku i angielsku.
3. **ScenarioEvaluator** tworzy 3 realne opcje i ocenia każdą w 6 czynnikach (0-100).
   `Score = Goal×0.30 + Values×0.20 + Evidence×0.15 + Risk×0.15 + Emotion×0.10 + Profile×0.10`
4. **Ograniczenie bezpieczeństwa:** gdy druga osoba prosi o dystans, opcje kontaktu (pisanie, rozmowa) w ogóle nie są proponowane.
5. **DecisionEngine** sortuje opcje i ustala pewność (kompletność danych, braki, przewaga lidera), nie szansę powodzenia.
6. **PersonalizationEngine** używa deklarowanych preferencji oraz historii wyników. Historia wpływa dopiero po 3 obserwacjach
   dla danej akcji, maksymalnie o 15 punktów w czynniku Profile, i można ją wyłączyć w Ustawieniach.
7. **RecommendationBuilder** składa tekst; **ReplyAdvisor** oddziela obserwacje od domysłów i pisze odpowiedzi w języku wiadomości;
   **FeedbackEngine** waliduje wynik, ocenę (1-5) i refleksję.

## Faza 2b (dalej)

SwiftData (DecisionRecord, PersonContext, UserPreference, MessageAnalysis, DecisionFeedback), repozytoria, Keychain,
ochrona plików i kopii zapasowych, eksport i usuwanie z trwałego magazynu, usunięcie DemoData.
