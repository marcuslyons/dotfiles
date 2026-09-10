# simple-bar-lite settings reference

Reference for every configuration option exposed by [simple-bar-lite](https://github.com/Jean-Tinland/simple-bar-lite), an Übersicht status bar widget for yabai. The upstream README promises a full settings table ("Coming soon!") but never delivers, so this doc reconstructs it from the source.

## How settings are loaded

- `default-settings.json` ships with the widget and defines every key the widget expects to exist.
- `custom-settings.json` is where you put overrides. It is merged into defaults via a deep merge (see `lib/services/settings.js`).
- Merge semantics:
  - Plain objects are merged recursively (missing keys fall back to the default).
  - Primitives are replaced wholesale.
  - **Arrays are replaced, not merged.** This matters for `customWidgets` and `customComponents`: if you define either key in your custom settings, your array fully replaces the default.
- Settings are read once at widget load. After editing `custom-settings.json`, refresh the widget in Übersicht (or the whole app) to pick up changes.

File location: `$HOME/Library/Application Support/Übersicht/widgets/simple-bar-lite/custom-settings.json`

## Top-level options

| Key | Type | Default | Description |
|---|---|---|---|
| `shell` | string | `"bash"` | Shell used to run the yabai init script (`lib/scripts/init.sh`). Swap to `zsh` or `sh` only if you have a specific reason. |
| `yabaiPath` | string | `"/usr/local/bin/yabai"` | Absolute path to the yabai binary. On Apple Silicon Homebrew this should be `"/opt/homebrew/bin/yabai"`. Used by the init script and by click-to-switch-space in `lib/services/yabai.js`. |
| `slidingAnimationPace` | number | `8` | Scroll speed (pixels-per-100ms factor) for the "current window title" marquee when it overflows `processWidth`. Higher = faster scroll. See `lib/services/slider.js`. |
| `themeScheme` | `"auto"` \| `"light"` \| `"dark"` | `"auto"` | Color scheme selector. `auto` follows macOS appearance via `prefers-color-scheme`. |
| `theme` | object | see below | Theme tokens. Split into `theme.dark`, `theme.light`, plus a shared block of layout/typography tokens. |
| `dataWidgets` | object | see below | Built-in widgets: battery, audio output, audio input, network, date/time. |
| `customWidgets` | array | `[]` | User-defined shell-command widgets. |
| `customComponents` | array | weather entry | User-defined React components (must be registered in `lib/custom-components/index.jsx`). |

## `theme`

### Scheme-specific palettes: `theme.dark` and `theme.light`

Each scheme object accepts the same keys. Values can be any valid CSS color.

| Key | Default (dark) | Default (light) | Used for |
|---|---|---|---|
| `main` | `#0f0f0f` | `#f5f5f5` | Bar background (`--spl-main`, `--spl-background`). |
| `mainAlt` | `#464646` | `#ddd` | Alt background used by some hover/active states (`--spl-main-alt`). |
| `minor` | `#2b2b2b` | `#eee` | Secondary background tone (`--spl-minor`). |
| `red` | `#e78482` | same | Accent. Also used for "low battery" state. |
| `green` | `#8fc8BB` | same | Accent. "Network active" color. |
| `blue` | `#6db3cE` | same | Accent. |
| `yellow` | `#ffd484` | same | Accent. Also aliased as `--spl-accent`. |
| `orange` | `#ffb374` | same | Accent. |
| `magenta` | `#ad82cB` | same | Accent. |
| `cyan` | `#7eddde` | same | Accent. |
| `foreground` | `#f5f5f5` | `#0f0f0f` | Default text/icon color (`--spl-foreground`, `currentColor`). |
| `gradient` | `linear-gradient(0.45turn, var(--spl-orange), var(--spl-red))` | same | Gradient used for the focused space and other highlights (`--spl-gradient`). Any valid CSS `background-image` value. |

### Shared palette

| Key | Default | Description |
|---|---|---|
| `theme.black` | `#0f0f0f` | Shared token (`--spl-black`), not scheme-dependent. |
| `theme.white` | `#f5f5f5` | Shared token (`--spl-white`). |

### Layout and typography tokens

All values are injected verbatim as CSS custom properties, so they accept any valid CSS value for that property.

| Key | Default | CSS var | Notes |
|---|---|---|---|
| `theme.barWidth` | `"100vw"` | `--spl-bar-width` | Width of the bar. Use `vw`, `%`, or `px`. |
| `theme.barHeight` | `"34px"` | `--spl-bar-height` | Height of the bar. |
| `theme.barVerticalOffset` | `"0px"` | `--spl-bar-vertical-offset` | Pushes bar away from the top edge. |
| `theme.barHorizontalOffset` | `"0px"` | `--spl-bar-horizontal-offset` | Pushes bar horizontally. |
| `theme.barInnerMargin` | `"3px"` | `--spl-bar-inner-margin` | Padding between bar edge and its contents. |
| `theme.barRadius` | `"0px"` | `--spl-bar-radius` | Corner radius of the bar itself. |
| `theme.barOpacity` | `"0.8"` | `--spl-bar-opacity` | Bar background opacity. String, not number. |
| `theme.spaceMargin` | `"0px 12px 0px 0px"` | `--spl-space-margin` | Margin around each space indicator. CSS shorthand. |
| `theme.processWidth` | `"320px"` | `--spl-process-width` | Max width of the current-window label before the marquee kicks in. |
| `theme.itemRadius` | `"18px"` | `--spl-item-radius` | Corner radius for widgets and space indicators. |
| `theme.itemMargin` | `"0px 0px 0px 4px"` | `--spl-item-margin` | Margin between data widgets. |
| `theme.itemInnerMargin` | `"3px 7px"` | `--spl-item-inner-margin` | Padding inside each widget. |
| `theme.fontFamily` | `"JetBrains Mono, monospace"` | `--spl-font-family` | Bar font stack. Must be installed on the system. |
| `theme.fontSize` | `"11px"` | `--spl-font-size` | Base font size. |
| `theme.shadow` | `"0 5px 10px rgba(0, 0, 0, 0.24)"` | `--spl-shadow` | Drop shadow applied to the bar. Disable via yabai's `window_shadow` config (the widget reads this and adds a `spl-bar--no-shadow` class when off). |
| `theme.transitionEasing` | `"cubic-bezier(0.4, 0, 0.2, 1)"` | `--spl-transition-easing` | Easing curve used across UI transitions. |

## `dataWidgets`

Every data widget shares a common shape. Extra keys apply only to specific widgets.

### Shared keys

| Key | Type | Description |
|---|---|---|
| `enabled` | boolean | Toggle the widget. When false it is skipped entirely. |
| `refreshFrequency` | number (ms) | How often to re-run the widget's fetch/query. |
| `color` | string | CSS color for the widget text/icon. `"currentColor"` inherits `--spl-foreground`. |
| `onClickCommand` | string \| null | Shell command to run when the widget is clicked. If set, the widget gets the clickable style. |
| `refreshOnClick` | boolean | If true, clicking the widget also re-runs its data fetch before executing `onClickCommand`. |

### `dataWidgets.battery`

Reads `pmset -g batt` and `pgrep caffeinate`. No widget-specific keys.

Defaults: `enabled: true`, `refreshFrequency: 10000`, `color: "currentColor"`, `onClickCommand: null`, `refreshOnClick: false`.

Visual states: normal, `spl-battery--low` (<20% and not charging), `spl-battery--caffeinate` (caffeinate process running).

### `dataWidgets.output` and `dataWidgets.input`

Both use the same Sound component, differentiated by `args.kind`.

| Key | Value |
|---|---|
| `args.kind` | `"output"` or `"input"`. **Do not change this.** It selects which volume the widget reads via `osascript`. |

Defaults: `enabled: true`, `refreshFrequency: 20000`. Output shows speaker icon + volume and dims when muted. Input shows mic icon + volume and dims when volume is 0 (macOS has no AppleScript path for input-muted).

### `dataWidgets.network`

| Key | Default | Description |
|---|---|---|
| `device` | `"en0"` | Network interface to query. Use `en1` for many wired adapters or alternate Wi-Fi interfaces. Check with `networksetup -listallhardwareports`. |

Reads `ifconfig <device>` and `networksetup -getairportnetwork <device>`. Shows the SSID (or `Searching...` / `Disabled`). Gets the `spl-network--active` class when status is `active`.

Defaults: `enabled: true`, `refreshFrequency: 12000`.

### `dataWidgets.dateTime`

Uses the JavaScript `Intl.DateTimeFormat` API.

| Key | Default | Description |
|---|---|---|
| `formatOptions` | `{ weekday: "short", month: "short", day: "numeric", hour: "numeric", minute: "numeric" }` | Options passed to `Intl.DateTimeFormat`. Any valid option is accepted: `year`, `second`, `timeZone`, `timeZoneName`, `hour12`, `hourCycle`, `era`, etc. |
| `overrideFormatOptions` | `null` | If set (non-null), used **instead of** `formatOptions`. Lets you keep a baseline and toggle an alternate layout. |
| `locale` | `"en-UK"` | BCP 47 locale tag. Note upstream default is `en-UK`, which is invalid; `en-GB` is the correct British English tag. `en-US` works fine. |

Defaults: `enabled: true`, `refreshFrequency: 60000`.

## `customWidgets`

Array of user-defined shell-command widgets. Each entry renders a widget whose visible text is the command's stdout.

| Key | Type | Default | Description |
|---|---|---|---|
| `enabled` | boolean | required | Skipped when false. |
| `command` | string | `'echo "Hello Wold!"'` (sic) | Shell command. Output is trimmed/cleaned. |
| `refreshFrequency` | number | `10000` | Poll interval in ms. |
| `color` | string | `"currentColor"` | Text color. |
| `className` | string | `undefined` | Extra CSS class for targeting with your own styles. |
| `onClickCommand` | string \| null | `undefined` | Shell command run on click. |
| `refreshOnClick` | boolean | `undefined` | Refresh before running `onClickCommand`. |

Example:

```json
"customWidgets": [
  {
    "enabled": true,
    "command": "uptime | awk -F'load averages: ' '{print $2}'",
    "refreshFrequency": 5000,
    "className": "spl-load",
    "color": "var(--spl-cyan)"
  }
]
```

## `customComponents`

Array of user-defined React components. The component file must live in `lib/custom-components/` and be registered in `lib/custom-components/index.jsx`. The ships-by-default example is `weather`.

### Shared keys (applied by `lib/custom-components/index.jsx`)

| Key | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Must match a key in the `theCustomComponents` registry. |
| `enabled` | boolean | required | Toggle. |
| `refreshFrequency` | number | `60000` | Poll interval. |
| `refreshOnClick` | boolean | `false` | Refresh on click. |
| `color` | string | `""` | Passed to the component as a prop. |
| `classes` | string | `""` | Passed as extra className. |

Each component can accept additional keys as props.

### Built-in: `weather`

Component lives at `lib/custom-components/weather.jsx`. Pulls from `https://wttr.in/<location>?format=j1`.

| Key | Default | Description |
|---|---|---|
| `location` | `"Gorinchem,ZH"` | Any wttr.in location string: city name, city+region, airport code, `~lat,lon`, etc. URL-unsafe characters should be quoted. |

Click behavior is hardcoded: opens `https://wttr.in/<location>` in the default browser.

Output format: `City Country, TEMP°C, WINDDIR WINDSPEED km/h, NEXT_HOUR_TEMP°C, NEXT_HOUR_WINDDIR NEXT_HOUR_WINDSPEED km/h`. No unit switching, no icon support. If you want °F or a different format, fork the component.

### Adding your own component

1. Create `lib/custom-components/<name>.jsx` exporting a default React component. It receives all config keys as props.
2. Register it in `lib/custom-components/index.jsx`:
   ```jsx
   import MyThing from './my-thing.jsx'
   const theCustomComponents = { weather: Weather, myThing: MyThing }
   ```
3. Add an entry to `customComponents` in `custom-settings.json`:
   ```json
   { "name": "myThing", "enabled": true, "refreshFrequency": 30000 }
   ```

## Array replacement gotcha

Because the merge replaces arrays outright, this:

```json
{ "customComponents": [{ "name": "weather", "enabled": false }] }
```

will drop every key the default weather entry had except `name` and `enabled`. To disable the default weather widget cleanly, either copy the full entry and flip `enabled`, or replace the array with `[]`.

## Interactive behavior (not configurable, but worth knowing)

- **Space switching:** clicking a space indicator calls `yabai -m space --focus <index>` when SIP is disabled, otherwise fakes `Ctrl+Left/Right` via `osascript` to move to the target space.
- **Window title marquee:** when the focused window's `app | title` string exceeds `processWidth`, hovering it starts a CSS-transform scroll animation whose duration is derived from `slidingAnimationPace`.
- **Auto-refresh:** the init script registers yabai signals (`space_changed`, `display_changed`, `window_focused`, `application_front_switched`, `window_destroyed`, `window_title_changed`) that refresh the Übersicht widget. These are added on every widget reload and are labeled, so yabai replaces them rather than stacking duplicates.
- **Shadow toggle:** the bar's drop shadow is disabled when `yabai -m config window_shadow` returns anything other than `on`.

## Minimal `custom-settings.json` example

```json
{
  "yabaiPath": "/opt/homebrew/bin/yabai",
  "themeScheme": "dark",
  "theme": {
    "dark": { "main": "#11111b", "foreground": "#cdd6f4" },
    "fontFamily": "MonoLisa, JetBrains Mono, monospace",
    "fontSize": "12px"
  },
  "dataWidgets": {
    "input": { "enabled": false },
    "network": { "device": "en0" },
    "dateTime": { "locale": "en-GB" }
  },
  "customComponents": [
    { "name": "weather", "enabled": true, "location": "Star,ID", "refreshFrequency": 900000 }
  ]
}
```

## Source map

If the defaults or behaviors drift, these files are the source of truth:

- `default-settings.json` - every default value
- `lib/services/settings.js` - merge logic
- `lib/services/styles.js` - CSS variable bindings
- `lib/services/slider.js` - `slidingAnimationPace`
- `lib/services/yabai.js` - space-switching
- `lib/scripts/init.sh` - yabai signal registration and initial data query
- `lib/components/*.jsx` - per-widget rendering and settings consumption
- `lib/custom-components/index.jsx` - custom-component registry and default props
