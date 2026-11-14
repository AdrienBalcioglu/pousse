# Pousse

A plant in your Mac's menu bar that grows when you keep your focus sessions, and wilts when you skip them.

**[Website and download](https://adrienbalcioglu.github.io/pousse/)**

## How it works

- Start a focus session from the menu bar: 15, 25, 45 or 60 minutes. The countdown sits next to the plant.
- Each finished session makes the plant grow. It goes from a seed to full bloom in 21 sessions, through seven stages.
- Skip a working day and the plant gets thirsty. Skip three and it wilts. One session brings it back.
- Weekends do not count, unless you want them to.
- A small plant window can sit on your desktop and sway gently. Hide it from the menu if you prefer the menu bar only.

Abandoning a session costs nothing: the plant simply does not grow.

## Install

Download [`Pousse.dmg`](https://github.com/AdrienBalcioglu/pousse/releases/latest/download/Pousse.dmg), open it and drag Pousse to Applications.

The app is not notarized by Apple. On the first launch after a download, right-click the app, choose Open, then confirm.

Pousse lives in the menu bar and has no Dock icon. Quit it from its menu.

## Privacy

Pousse reads nothing from your Mac. It stores a session count and the days you worked, in its own preferences.

## Build

```bash
./build.sh
```

It needs the Xcode Command Line Tools only, not Xcode. The result is a universal app (Apple silicon and Intel) for macOS 13 or later. The app draws its own icon and artwork: `build/arm64 --render sheet.png` renders every stage.

## License

[MIT](LICENSE) © 2026 Adrien Balcioglu
