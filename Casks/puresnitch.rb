cask "puresnitch" do
  version "0.1.0"
  sha256 "3be501f76646075e71b56958e68df9753bb8907901f6e56e3c6489b952c043ff"

  url "https://github.com/momenbasel/puresnitch/releases/download/v#{version}/PureSnitch-#{version}.dmg"
  name "PureSnitch"
  desc "Open-source application firewall for macOS"
  homepage "https://github.com/momenbasel/puresnitch"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

  app "PureSnitch.app"

  uninstall quit:        "io.moamenbasel.puresnitch",
            launchctl:   "io.moamenbasel.puresnitch.helper",
            delete:      "/Library/Application Support/PureSnitch",
            login_item:  "PureSnitch"

  zap trash: [
    "~/Library/Application Support/PureSnitch",
    "~/Library/Caches/io.moamenbasel.puresnitch",
    "~/Library/Preferences/io.moamenbasel.puresnitch.plist",
    "~/Library/Logs/PureSnitch",
  ]
end
