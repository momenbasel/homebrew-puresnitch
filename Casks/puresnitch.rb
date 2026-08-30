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
  # launchctl before quit: the helper is a LaunchDaemon, and unloading it first
  # is what stops launchd relaunching anything while the app is going away.
  uninstall launchctl:  "io.moamenbasel.puresnitch.helper",
            quit:       "io.moamenbasel.puresnitch",
            login_item: "PureSnitch"

  zap trash: [
    "~/Library/Caches/io.moamenbasel.puresnitch",
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
