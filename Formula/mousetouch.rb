# Homebrew formula template. The release workflow fills in the version and
# checksums and pushes the result to github.com/Devace-93/homebrew-tap.
class Mousetouch < Formula
  desc "Apple Magic Mouse multitouch gestures for Linux/Wayland"
  homepage "https://github.com/Devace-93/mousetouch"
  version "0.1.3"
  license "MIT"

  on_intel do
    url "https://github.com/Devace-93/mousetouch/releases/download/v0.1.3/mousetouch-v0.1.3-x86_64-linux.tar.gz"
    sha256 "878e9b6ad371becd5298e03db39e028168f11bce1da8cfd9cfb40c374be6c637"
  end
  on_arm do
    url "https://github.com/Devace-93/mousetouch/releases/download/v0.1.3/mousetouch-v0.1.3-aarch64-linux.tar.gz"
    sha256 "1d3205d4a7afd55bb041a77468ceaebae95e80cb23e7cb63a1c3a3a0ec8bc0ad"
  end

  depends_on :linux

  def install
    bin.install "mousetouch", "mousetouch-settings"
    (share/"applications").install "io.github.Devace_93.MouseTouch.desktop"
    (share/"icons/hicolor/scalable/apps").install "io.github.Devace_93.MouseTouch.svg"
    pkgshare.install "60-mousetouch.rules", "mousetouch.conf"
    doc.install "README.md"
  end

  service do
    run [opt_bin/"mousetouch", "run"]
    keep_alive true
    log_path var/"log/mousetouch.log"
    error_log_path var/"log/mousetouch.log"
  end

  def caveats
    <<~EOS
      The daemon needs access to the mouse and to /dev/uinput. Install the udev
      rule once (needs sudo):
        sudo install -Dm644 #{opt_pkgshare}/60-mousetouch.rules /etc/udev/rules.d/60-mousetouch.rules
        sudo install -Dm644 #{opt_pkgshare}/mousetouch.conf /etc/modules-load.d/mousetouch.conf
        sudo modprobe uinput && sudo udevadm control --reload-rules && sudo udevadm trigger
      Then start it in the background:
        brew services start mousetouch
      The settings app needs python3-gi, python3-gi-cairo, GTK 4 and libadwaita from
      your distribution. Desktops do not look in Homebrew's share directory, so the
      daemon adds the app-menu entry itself the first time the service starts
      (~/.local/share/applications/io.github.Devace_93.MouseTouch.desktop; delete it
      after `brew uninstall`).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mousetouch --version")
  end
end
