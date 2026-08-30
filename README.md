# homebrew-puresnitch

Homebrew tap for [PureSnitch](https://github.com/momenbasel/puresnitch) — a free,
open-source application firewall and outbound connection monitor for macOS.

## Install

```bash
brew tap momenbasel/puresnitch
brew trust --tap momenbasel/puresnitch
brew install --cask puresnitch
```

Homebrew 6 will not evaluate code from a third-party tap until you trust it.
Skipping the middle line fails with:

```
Error: Refusing to load cask momenbasel/puresnitch/puresnitch from untrusted tap momenbasel/puresnitch.
```

`brew trust` is a one-time opt-in recorded in `~/.homebrew/trust.json`. Undo it
with `brew untrust --tap momenbasel/puresnitch`.

## Upgrade

```bash
brew upgrade --cask puresnitch
```

The cask is bumped automatically: a scheduled job in this repo compares it
against the latest upstream release every six hours, recomputes the DMG
checksum from the published asset, and commits the bump. Publishing a release
upstream also dispatches the bump immediately.

## Uninstall

Turn Enforcement **Off** and choose **Remove Helper** in PureSnitch first, then:

```bash
brew uninstall --cask puresnitch
brew untap momenbasel/puresnitch
```

Uninstalling quits the app, unloads the privileged helper, and removes the login
item. It deliberately leaves `pf` state and the root-owned rule database under
`/Library/Application Support/PureSnitch` alone — Homebrew cannot distinguish a
live firewall from an abandoned one, and deleting the rules while the `pf`
anchor is still loaded would leave the Mac enforcing rules nothing can inspect.
Remove Helper performs that teardown in the correct order.

PureSnitch is MIT licensed. Source: https://github.com/momenbasel/puresnitch
