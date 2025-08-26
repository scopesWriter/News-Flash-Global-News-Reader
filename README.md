## NewsFlash

Your minimalist, fast, and localized SwiftUI news reader. Browse top headlines, read full articles, and switch languages seamlessly. Built with clean MVVM architecture, fully test-covered core logic, and zero external runtime dependencies.

## Attachments
![Icon Description](/Users/bishoybadie/Desktop/Simulator Screenshot - iPhone 16 Pro Max - 2025-08-26 at 18.11.54.png)
![Icon Description](/Users/bishoybadie/Desktop/Simulator Screenshot - iPhone 16 Pro Max - 2025-08-26 at 18.20.24.png)
![Icon Description](/Users/bishoybadie/Desktop/Simulator Screenshot - iPhone 16 Pro Max - 2025-08-26 at 18.11.12.png)
![Icon Description](/Users/bishoybadie/Desktop/Simulator Screenshot - iPhone 16 Pro Max - 2025-08-26 at 18.20.18.png)

---

### Highlights

- **SwiftUI-first UI**: Modern, reactive, and smooth.
- **MVVM architecture**: Clear separation of concerns with `View` ↔ `ViewModel` ↔ `Service`.
- **Localization**: English and Arabic with RTL support via `Resources/en.lproj` and `Resources/ar.lproj`.
- **Unit & UI tests**: Coverage for decoding, URL construction, and view model behavior.
- **No external deps**: Swift Package Manager ready; ships with system frameworks.
- **Custom fonts**: Bundled SF Pro AR Display for a polished look.

---

### Screenshots

Add your screenshots here (place them in `Resources/Assets.xcassets` or embed links):

- Headlines list view
- Article details view (LTR and RTL)

---

### Project Structure

```text
NewsFlash/
  NewsFlash/
    ArticleDetails/
      ArticleDetail.swift
    Headlines/
      HeadlinesView.swift
      HeadlinesViewModel.swift
    Models/
      Article.swift
    Services/
      NewsService.swift
    Views/
      ArticleRow.swift
    Resources/
      Assets.xcassets/
      Fonts/
      en.lproj/Localizable.strings
      ar.lproj/Localizable.strings
    Configs/
      Debug.xcconfig
    NewsFlashApp.swift
    Info.plist
  NewsFlashTests/
    ArticlesDecodingTests.swift
    HeadlinesViewModelTests.swift
    NewsServiceURLTests.swift
  NewsFlashUITests/
    NewsFlashUITests.swift
    NewsFlashUITestsLaunchTests.swift
```

---

### Architecture

- **Models**: Data structures like `Article`.
- **Views (SwiftUI)**: `HeadlinesView`, `ArticleRow`, `ArticleDetail`.
- **ViewModels (MVVM)**: `HeadlinesViewModel` handles state, transforms service data for views.
- **Services**: `NewsService` performs networking and data fetching.

Data flow: View triggers intent → ViewModel requests data from Service → Service returns domain models → ViewModel publishes state → View renders reactively.

---

### Requirements

- Xcode 15 or newer
- iOS 17 SDK or compatible
- Swift 5.9+

---

### Getting Started

1) Clone the repo

```bash
git clone https://github.com/<your-org-or-user>/NewsFlash.git
cd NewsFlash
```

2) Open the project

```bash
open NewsFlash.xcodeproj
```

3) Build & run

- Select the `NewsFlash` scheme.
- Choose an iOS Simulator (e.g., iPhone 15 Pro) or a connected device.
- Press Run (⌘R).

---

### Configuration

Out of the box, the app runs without external configuration. If you need to point to a live API or add secrets:

- Add keys/URLs to `NewsFlash/Configs/Debug.xcconfig`.
- Reference them in `Info.plist` or via compile-time flags.
- Ensure `NewsService.swift` reads configuration from a safe source (e.g., Info.plist or environment variables for CI).

Never commit secrets. Use user-specific xcconfig files or CI secrets.

---

### Testing

Run all tests from Xcode: Product → Test (⌘U) on the `NewsFlash` scheme.

CLI options with `xcodebuild`:

```bash
xcodebuild \
  -project NewsFlash.xcodeproj \
  -scheme NewsFlash \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  clean test | xcpretty
```

What’s covered:

- `ArticlesDecodingTests`: JSON decoding for `Article`.
- `HeadlinesViewModelTests`: state transitions and data loading.
- `NewsServiceURLTests`: request/URL building correctness.
- UI smoke tests under `NewsFlashUITests`.

---

### Localization

- Strings live in `Resources/en.lproj/Localizable.strings` and `Resources/ar.lproj/Localizable.strings`.
- Arabic (RTL) is supported. Verify layout in Simulator by changing the system language or using Xcode’s Preview locale.

Tips:

- Keep keys human-readable and consistent.
- Always update both languages when adding UI text.

---

### Fonts

Custom fonts are bundled in `Resources/Fonts/`:

- `SF Pro AR Display Regular.ttf`
- `SF Pro AR Display Semibold.ttf`

Ensure they are referenced in `Info.plist` under `UIAppFonts` and used via SwiftUI’s `.font` or custom Font assets.

---

### Development Notes

- Prefer value types for models; keep them `Codable`.
- Keep networking isolated in `NewsService` with clear APIs.
- Drive UI via observable state in ViewModels.
- Avoid leaking business logic into Views; Views render, ViewModels decide.

---

### Roadmap

- Search and category filters
- Offline caching and refresh controls
- Pull-to-refresh and background updates
- Share sheets and SafariViewController integration
- Image caching & progressive loading

---

### Contributing

1. Create a feature branch: `git checkout -b feat/<name>`
2. Make your changes with tests.
3. Run `⌘U` to ensure tests pass.
4. Open a PR with a clear description and screenshots.

---

### License

Specify your license here (e.g., MIT). If using bundled fonts/assets, confirm redistribution rights.

---

### Acknowledgements

- Built with SwiftUI and Combine.
- Apple’s SF Pro AR Display font included for Arabic typography.

---

### Contact

Questions or feedback? Open an issue or reach out via your preferred contact channel.


