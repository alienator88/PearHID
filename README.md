# PearHID
<p align="center">
  <img src="https://github.com/user-attachments/assets/c37566e7-144f-4189-b7c5-c27b80acd5a1" width="128" height="128" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>1.0.1
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
![image](https://github.com/user-attachments/assets/e9887a1d-44d4-4b89-9b26-edc00551ca87)


## Requirements
- MacOS 13.0+ (App uses some newer SwiftUI functions/modifiers which don't work on anything lower than 13.0)


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
