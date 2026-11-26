---
name: localize
description: Add or change user-facing text in WeatherForecast with English and Polish translations in Localizable.xcstrings, using the generated LocalizedStringResource symbols. Use whenever a change adds, renames or rewords any text shown in the app, including plurals and accessibility-size layouts.
---

# Localize

The app uses `WeatherForecast/Resources/Localizable.xcstrings`, with `en` as the source language and a full `pl` translation. `STRING_CATALOG_GENERATE_SYMBOLS` is on, so every manual key turns into a static `LocalizedStringResource` member. Swift code refers to strings as `.conditionClear` or `.sunrise`, never as string literals.

## Adding a string

1. Pick a camelCase key that names the meaning, not the wording: `precipitationChance`, not `rainPercent`. Grouped keys share a prefix, like `condition…` or `uv…`.
2. Add the entry in the same format as the existing ones, keeping keys in alphabetical order:

```json
"keyName" : {
  "comment" : "Where it appears and what it means, for the translator.",
  "extractionState" : "manual",
  "localizations" : {
    "en" : { "stringUnit" : { "state" : "translated", "value" : "English text" } },
    "pl" : { "stringUnit" : { "state" : "translated", "value" : "Polski tekst" } }
  }
}
```

3. Match the file's existing formatting, with `" : "` separators and two-space indentation, so Xcode doesn't reformat the whole file later.
4. Use the symbol in code: `Text(.keyName)`, `Label(.keyName, systemImage: …)`, or a `LocalizedStringResource` property.
5. For text with values, use format specifiers in both languages (`%@`, `%lld`), and use a matching typed argument in the symbol call.

## Polish rules

- Plurals need the `one`, `few`, `many` and `other` forms, for example 1 godzina, 2 godziny, 5 godzin and 1,5 godziny. Use `variations.plural` for `pl`. English needs only `one` and `other`.
- Use natural weather vocabulary: Bezchmurnie, Pochmurno, Mżawka, Odczuwalna, Porywy, Wilgotność, Widoczność, Indeks UV.
- Section headers are uppercased by the UI, so store them in sentence case.
- Keep short labels short. Polish runs about 20–30% longer than English, so check that tiles and rows still fit at accessibility text sizes.
- Units come from `Measurement` formatting. Never hardcode `°C`, `km/h` or `%` inside a translation.

## Afterwards

- Check that no key is left without a `pl` translation. The `verify` skill does this.
- If a key is no longer used, delete it rather than leaving it stale.
- `InfoPlist.xcstrings` holds the app name and permission texts. Translate those into both languages too.
