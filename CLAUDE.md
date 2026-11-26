# WeatherForecast

An iOS 17+ weather app in SwiftUI and Swift 6, using Open-Meteo for geocoding and forecasts. See README.md for features and screenshots.

## Layout

- `WeatherForecast/` is the app target and holds all UI: `App/` (entry point, `AppDependencies`, `AppRouter`), `Features/` (Home, Search, History, Forecast), `Shared/` (design system, city rows, weather presentation), `Resources/` (String Catalogs, assets).
- `Modules/` is a local Swift package with no UI: `Domain` (models, service protocols, validation), `Networking` (`HTTPClient`), `OpenMeteo` (API providers and response mapping), `Persistence` (file-backed search history).
- `Domain` depends on nothing. `OpenMeteo` and `Persistence` depend on `Domain`. The app uses the protocols, and only `AppDependencies` knows the concrete types.
- `WeatherForecastTests/` mirrors the app folders. Package tests are in `Modules/Tests/`.

## Commands

The package targets iOS only, so `swift build` and `swift test` fail on macOS. Use a simulator:

```bash
cd Modules && xcodebuild test -scheme Modules-Package -destination "platform=iOS Simulator,name=iPhone 17 Pro" -quiet
```

```bash
xcodebuild test -project WeatherForecast.xcodeproj -scheme WeatherForecast -destination "platform=iOS Simulator,name=iPhone 17 Pro" -quiet
```

CI (`.github/workflows/ci.yml`) runs both on Xcode 26.6 for pull requests and pushes to `main`.

## Code conventions

- View models and stores are `@Observable` classes with an explicit `State` enum. Views stay thin.
- New UI goes in the app target. New logic that doesn't need SwiftUI goes in the package.
- Errors shown to users go through `WeatherError`. Ignore `CancellationError`, and ignore results from cancelled tasks.
- Show times in the city's time zone, never the device's.
- Every user-facing string goes in `Localizable.xcstrings` with English and Polish. See the `localize` skill.

## Tests

- Use Swift Testing only (`import Testing`, `@Test`, `#expect`), with no XCTest.
- Inject dependencies through the protocols, and use the stubs in `Support/` folders (`StubCitySearch`, `StubForecastProvider`, `InMemoryHistoryRepository`, `City.stub`, `Forecast.stub`).

## Xcode project file

CI runs Xcode 26.6, so `WeatherForecast.xcodeproj/project.pbxproj` stays in the property list format with `objectVersion = 77`. Newer Xcode versions may rewrite it, so keep only the entries a change needs.

## Git

- Branch from `main`, and use one branch per pull request.
- Use Conventional Commits with a scope where it helps, for example `feat(forecast): …`, `fix(search): …`, `refactor: …` or `docs: …`.
