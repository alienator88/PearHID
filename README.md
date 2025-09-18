# PearHID
<p align="center">
  <img src="https://github.com/user-attachments/assets/c37566e7-144f-4189-b7c5-c27b80acd5a1" width="128" height="128" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>1.0.2
   <br />
   <a href="https://github.com/alienator88/PearHID/releases"><strong>Download</strong></a>
    · 
   <a href="https://github.com/alienator88/PearHID/commits">Commits</a>
   <br />
   <br />
</p>
</br>

Easily swap keyboard keys with a nice SwiftUI frontend for IOKit.hid/hidutil


## Features
- Save/clear multiple key combinations at once
- Save to launchd plist to persist reboots
- Turn off persist in settings to only affect the current session and disable launch daemon
- Helper tool to perform the launchd plist editing without asking for user password each time
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases


## Preview
<img width="932" height="766" alt="Screenshot 2025-09-18 at 3 30 28 PM" src="https://github.com/user-attachments/assets/498ec772-e74d-4dd2-b659-c62b971a9093" />


## Requirements
## Requirements
> [!NOTE]
> - Privileged Helper to auto-load hidutil plist on boot as a LaunchDaemon

| macOS Version | Codename | Supported |
|---------------|----------|-----------|
| 13.x          | Ventura  | ✅        |
| 14.x          | Sonoma   | ✅        |
| 15.x          | Sequoia  | ✅        |
| 26.x          | Tahoe    | ✅        |
| TBD           | Beta     | ❌        |
> Versions prior to macOS 13.0 are not supported due to missing Swift/SwiftUI APIs required by the app.


## Getting PearHID

<details>
  <summary>Releases</summary>

Pre-compiled, always up-to-date versions are available from my [releases](https://github.com/alienator88/PearHID/releases) page.
</details>

<details>
  <summary>Homebrew Coming Soon</summary>

You can add the app via Homebrew:
```

```
</details>


## License
> [!IMPORTANT]
> PearHID is licensed under Apache 2.0 with [Commons Clause](https://commonsclause.com/). This means that you can do anything you'd like with the source, modify it, contribute to it, etc., but the license explicitly prohibits any form of monetization for PearHID or any modified versions of it. See full license [HERE](https://github.com/alienator88/Sentinel/blob/main/LICENSE.md)

## Thanks
[This Gist](https://gist.github.com/bennlee/0f5bc8dc15a53b2cc1c81cd92363bf18)

[hidutil-key-remapping-generator](https://github.com/amarsyla/hidutil-key-remapping-generator)

## Some of my apps

[Pearcleaner](https://github.com/alienator88/Pearcleaner) - An opensource app cleaner with privacy in mind

[Sentinel](https://github.com/alienator88/Sentinel) - A GUI for controlling gatekeeper status on your mac

[Viz](https://github.com/alienator88/Viz) - Utility for extracting text from images, videos, qr/barcodes
