<p align="center">
  <img src="docs/icon.png" width="120" alt="MOMENT icon"/>
</p>

<h1 align="center">MOMENT for iPhone</h1>

<p align="center">
  <b>A private, on-device companion for thinking through relationship decisions. Written in SwiftUI with Liquid Glass.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-26%2B-black?style=for-the-badge&logo=apple" alt="iOS 26 and newer"/>
  <img src="https://img.shields.io/badge/Swift-SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift and SwiftUI"/>
  <img src="https://img.shields.io/badge/AI-none-6667CC?style=for-the-badge" alt="No generative AI"/>
  <img src="https://img.shields.io/badge/Languages-EN%20%7C%20PL-6667CC?style=for-the-badge" alt="English and Polish"/>
</p>

MOMENT helps you slow down before you text, reply, wait, open up or step back. Describe what happened, say what you want and how you feel, and it lays out two or three realistic options, with a reason for each, how long to pause, what to do and an example of what to say. The decision is always yours. It works with no account and no internet, and nothing you write leaves your iPhone.

There is no chatbot behind it. The analysis is a local, rule-based engine (**MOMENT CORE**): the same input, preferences and history always give the same result, and every number comes from a rule you can read in the code.

## Status

MOMENT is in active development.

| Part | State |
|---|---|
| Design System, navigation and every screen | Done |
| MOMENT CORE (analysis, scoring, recommendations, Reply Studio, feedback) | Done, with unit tests |
| Saved history, people and preferences on disk (SwiftData) | **Next.** Until then, data lives in memory and is lost when the app quits |
| Keychain, file protection, export and delete from the real store | **Next** |

## Download

There is no App Store release. Get **`Moment.ipa`** from the artifacts of a [Codemagic](https://codemagic.io) build (see [Building](#building)). MOMENT needs iOS 26 or later.

## Installing

MOMENT isn't on the App Store, so you sign it yourself with your Apple ID, using any of these:

| Tool | How |
|---|---|
| [AltStore](https://altstore.io) | With AltServer running on your computer, open AltStore on the iPhone, go to **My Apps**, tap **+** and pick `Moment.ipa`. |
| [SideStore](https://sidestore.io) | The same, without needing a computer after setup. |
| [Sideloadly](https://sideloadly.io) | Connect the iPhone to your computer, drop `Moment.ipa` in, sign in and start. |

A free Apple ID's signature lasts seven days; AltStore and SideStore renew it for you. The first time, iOS may ask you to trust your Apple ID in **Settings → General → VPN & Device Management**.

Because the app is signed with a developer account, not by Apple, iOS needs **Developer Mode** on: **Settings → Privacy & Security → Developer Mode**. It appears after the first install and takes one restart.

## Features

### New Moment

- A five-step guided flow: what happened, who it is about, what you want to figure out, how you feel and how soon you need to decide, then anything else worth adding
- Two or three options, each with a reason, pros and cons, and a comparison score. The score only compares your options for you; it is not a prediction of how anyone will react
- **How long to wait, how to do it and what to say**: a rule-of-thumb duration, concrete steps and an example message you can copy and make your own
- A **confidence** level that describes how complete your input was, never a chance of success, plus the one thing that would sharpen the analysis
- Save the option you actually choose, which may differ from the suggested one

### Reply Studio

- Paste a message you received and get a clear split between **what can be noticed** in the wording and **what is only a possible reading**, plus what can't be known from text
- Reply ideas in the language of the message, in the intent and tone you pick (natural, direct, gentle, confident, light, flirty or neutral)
- Notes on your own draft: absolute words, capital letters, many exclamation marks
- If a message asks for distance, MOMENT offers one respectful acknowledgement and nothing that pushes for contact

### History, People and Insights

- A searchable history of saved decisions; record how it went, rate whether the suggestion helped and write what you learned
- Optional private notes about people. Nobody has to create a profile
- Insights drawn only from your own history: how things turned out and, once there are enough decisions, patterns. Observations, not verdicts, and nothing that rates other people

### Personalization

- Tell MOMENT how you like to communicate (style, pace, comfort with uncertainty, approach to conflict)
- Learning from your past outcomes only counts once an action has at least three recorded results, can shift a score by 15 points at most, and can be switched off

### Respecting boundaries

- If your text says someone asked you to stop contacting them, MOMENT stops suggesting contact at all and offers space, a pause or a quiet step back instead
- It never presents an interpretation of someone's feelings as a fact

### Settings, privacy and your data

- Optional **Face ID, Touch ID or passcode lock**, plus a privacy cover in the app switcher
- **Export** everything as a JSON file you control, or **delete** it all
- Light, Dark or system appearance, and Dynamic Type everywhere
- English and Polish

## How MOMENT CORE works

`MomentEngine.analyze(input, context)` runs these steps, all on the device:

1. **ContextAnalyzer** organizes the input: emotional intensity, how much usable information there is, what is missing and which safety limits apply.
2. **LanguageAnalyzer** counts features of a text (questions, exclamation marks, capital letters, softening and absolute words, tense or warm wording) with Apple's NaturalLanguage and hand-written Polish and English word lists. No single word is treated as proof of what someone means.
3. **ScenarioEvaluator** builds the options and rates each one from 0 to 100 on six factors.
4. **DecisionEngine** ranks them and sets the confidence.
5. **PersonalizationEngine** adjusts for your declared preferences and for patterns with enough observations.
6. **RecommendationBuilder** writes the result from hand-made templates and variants. **ReplyAdvisor** does the same for Reply Studio.
7. **FeedbackEngine** validates and records what happened afterwards.

```
Score = Goal × 0.30 + Values × 0.20 + Evidence × 0.15 + Risk × 0.15 + Emotion × 0.10 + Profile × 0.10
```

A higher `Risk` value means a lower risk of an outcome you would regret. The score is for comparing options, not a scientific measurement.

## Privacy

MOMENT has no analytics, no account and no server of its own, and its code makes no network requests. There is no generative AI and no external analysis of your messages. Text fields turn off Apple's Writing Tools so nothing you type is offered to a rewriting service. Exports are written with file protection and go only where you share them.

Saving to disk, and how far its protection goes, is the next step. The README will describe it exactly when it ships; SwiftData alone is not full encryption, and MOMENT won't claim it is.

## Building

Xcode 26 or later.

```sh
cd MomentCore && swift test                         # unit tests for the engine
xcodebuild -project Moment.xcodeproj -scheme Moment -destination 'generic/platform=iOS' build
python3 tools/l10n_extract.py                       # check the app's translations
python3 tools/l10n_extract.py --core                # check the engine's translations
python3 tools/build_catalog.py                      # regenerate the string catalogs from tools/pl*.py
```

CI runs on Codemagic and is defined in `codemagic.yaml`; builds and their artifacts are on the Codemagic Builds page. It has two workflows:

| Workflow | Runs | Result |
|---|---|---|
| `ios-unsigned` | Every push to `main` or `beta`, and pull requests | Tests `MomentCore`, then builds `Moment.ipa` with an ad-hoc signature, for AltStore, SideStore and Sideloadly, which re-sign it with your Apple ID (free) |
| `ios-signed` | Only when you start it by hand | An Ad Hoc signed `Moment.ipa` for iPhones registered in your Apple Developer account. Needs a paid Apple Developer Program account, an App Store Connect API key, and a `code-signing` variable group holding `CERTIFICATE_PRIVATE_KEY`; the steps are at the top of `codemagic.yaml` |

To use it, add the repository in Codemagic, choose `codemagic.yaml`, and create the webhook in the app's settings.

| Path | What |
|---|---|
| `MomentCore/` | Swift package with no UI and no SwiftData: the domain types, scoring and the whole engine, with its own translations and tests |
| `Moment/` | The SwiftUI app: `App/` (entry, tabs, router, store, app lock), `DesignSystem/` (tokens, Liquid Glass buttons, chips, inputs, states), `Features/` (one folder per screen) |
| `Moment/Temporary/` | Sample data behind a clearly labeled row in Settings; removed once saving to disk lands |
| `tools/` | Translation helpers: `pl.py` and `pl_core.py` hold the Polish strings |
| `codemagic.yaml` | Codemagic CI: the `ios-unsigned` and `ios-signed` (manual) workflows |

### Design System

| Token | Light | Dark |
|---|---|---|
| Background | `#F7F7F5` | `#101010` |
| Surface | `#FFFFFF` | `#1C1C1E` |
| Accent (text, icons) | `#6667CC` | `#9999F0` |
| Accent fill (buttons) | `#6667CC` | `#6A6BD6` |
| Text / Secondary | `#151515` / `#6B6B6B` | `#F5F5F5` / `#929292` |

Colors live in the asset catalog, with Light and Dark tuned separately. Liquid Glass is used on controls and navigation; content sits on opaque cards.

## Feedback

Found a bug or want something? Open an issue on this repository.

---

MOMENT is a thinking aid, not therapy, medical or legal advice. If you feel unsafe or in crisis, contact local emergency services or a trusted person.
