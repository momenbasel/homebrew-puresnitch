cask "puresnitch" do
  version "0.2.1"
  sha256 "e7ad873e58b8a97f82a9bcf0e1aab16b1183b2d7afd91dcf6bb48ae42da4c03f"

  url "https://github.com/momenbasel/puresnitch/releases/download/v#{version}/PureSnitch-#{version}.dmg"
  name "PureSnitch"
  desc "Open-source application firewall and outbound connection monitor"
  homepage "https://github.com/momenbasel/puresnitch"

  livecheck do
    url :url
    strategy :github_latest
  end

  # LSMinimumSystemVersion in the shipped bundle is 13.0, and the DMG is a
  # universal arm64 + x86_64 build.
  depends_on macos: :ventura

  app "PureSnitch.app"

  # No `delete:` for /Library/Application Support/PureSnitch on purpose. That
  # directory holds the root-owned rule database backing a live `pf` anchor,
  # and Homebrew cannot tell an active firewall from an abandoned one. Removing
  # the rules while the anchor is still loaded would leave the Mac enforcing
  # rules nothing can inspect. Enforcement Off + Remove Helper inside the app
  # tears that down in the correct order.
  # Source order has to match Homebrew's ORDERED_DIRECTIVES, which is also the
  # execution order: launchctl, quit, login_item, script.
  #
  # launchctl first because the helper is a LaunchDaemon — unloading it is what
  # stops launchd relaunching it while the app goes away.
  #
  # script last, and this is the part that matters. `launchctl remove` sends
  # SIGTERM, and the helper's SIGTERM path deliberately leaves the validated pf
  # subanchor loaded when enforcement is on, because it expects the next launchd
  # instance to adopt it. On uninstall there is no next instance: the .app
  # carrying the SMAppService definition goes too. Without this call the Mac is
  # left enforcing rules that nothing can inspect or remove.
  #
  # `PureSnitchHelper --cleanup` exists for exactly this
  # (Sources/Helper/main.swift). It requires root, refuses extra arguments, and
  # calls cleanupOrphanedStateForStandaloneProcess, which takes the same
  # cross-process pf lock as startup and asserts the daemon is gone before
  # touching anything. Homebrew runs the whole uninstall stanza before removing
  # the app artifact, so the binary is still on disk here, and by this directive
  # the daemon is already dead — the one window where that call is both possible
  # and safe. must_succeed: false so a failed teardown never blocks an uninstall.
  uninstall launchctl:  "io.moamenbasel.puresnitch.helper",
            quit:       "io.moamenbasel.puresnitch",
            login_item: "PureSnitch",
            script:     {
              executable:   "#{appdir}/PureSnitch.app/Contents/MacOS/PureSnitchHelper",
              args:         ["--cleanup"],
              sudo:         true,
              must_succeed: false,
            }

  # `~/Library/Application Support/PureSnitch` holds ui-cache.sqlite and is
  # created on every access by AppConstants.supportDir (Sources/Shared/Models.swift).
  # The Group Containers entry holds filter-rules.json, written by
  # SharedRuleBridge through the H3WXHVTP97.io.moamenbasel.puresnitch app group.
  # Neither is the root-owned database, which zap deliberately leaves alone.
  zap trash: [
    "~/Library/Application Support/PureSnitch",
    "~/Library/Caches/io.moamenbasel.puresnitch",
    "~/Library/Group Containers/H3WXHVTP97.io.moamenbasel.puresnitch",
    "~/Library/HTTPStorages/io.moamenbasel.puresnitch",
    "~/Library/Preferences/io.moamenbasel.puresnitch.plist",
    "~/Library/Saved Application State/io.moamenbasel.puresnitch.savedState",
  ]

  caveats <<~EOS
    PureSnitch runs as a menu bar item; it has no Dock icon.

    On first launch it registers a privileged helper. Approve it in
      System Settings > General > Login Items & Extensions > Allow in the Background
    Until that switch is on, macOS blocks the helper and the app sees no traffic.

    Before `brew uninstall`, turn Enforcement Off and choose Remove Helper in the
    app. Uninstalling does not modify `pf` state or delete the root-owned rule
    database under /Library/Application Support/PureSnitch.
  EOS
end
