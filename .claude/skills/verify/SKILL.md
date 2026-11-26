---
name: verify
description: Build and test the package and the app on an iOS simulator, then check the diff against project rules (pbxproj objectVersion, strings without a Polish translation). Use before saying a change is done, or when asked to run the tests or check a branch before a pull request.
---

# Verify

Run every step, even when an earlier one fails, then report each result.

## 1. Pick a simulator

```bash
xcrun simctl list devices available | grep -E "iPhone" | head
```

Use `iPhone 17 Pro` if it's in the list, otherwise any available iPhone. Use the same name in both test commands.

## 2. Package tests

The package is iOS only, so `swift test` doesn't work.

```bash
cd Modules && xcodebuild test -scheme Modules-Package -destination "platform=iOS Simulator,name=iPhone 17 Pro" -derivedDataPath ../DerivedData/Modules -quiet
```

## 3. App tests

```bash
xcodebuild test -project WeatherForecast.xcodeproj -scheme WeatherForecast -destination "platform=iOS Simulator,name=iPhone 17 Pro" -derivedDataPath DerivedData -quiet
```

Run both test commands in the background, because they can take several minutes. When one fails, show the failing test names and the `#expect` messages, not the whole log.

## 4. Diff checks

Compare against `main`, including uncommitted changes:

```bash
git diff main --stat
```

```bash
git diff main -- WeatherForecast.xcodeproj/project.pbxproj | grep -E "objectVersion|preferredProjectObjectVersion"
```

Any output from the second command is a blocker: CI on Xcode 26.6 needs `objectVersion = 77`. Point it out and don't fix it with `git checkout`, because that can throw away real project changes.

```bash
python3 -c "import json;d=json.load(open('WeatherForecast/Resources/Localizable.xcstrings'));print([k for k,v in d['strings'].items() if v.get('localizations',{}).get('pl',{}).get('stringUnit',{}).get('state')!='translated' and 'variations' not in v.get('localizations',{}).get('pl',{})])"
```

Any key in the output is missing its Polish translation. Add one with the `localize` skill.

## 5. Report

Give one line per step: passed, failed with the reason, or skipped with why. Don't call the change done while any step is failing.
