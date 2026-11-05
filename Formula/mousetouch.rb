# Homebrew formula template. The release workflow fills in the version and
# checksums and pushes the result to github.com/Devace-93/homebrew-tap.
class Mousetouch < Formula
  desc "Apple Magic Mouse multitouch gestures for Linux/Wayland"
  homepage "https://github.com/Devace-93/mousetouch"
  version "0.1.12"
  license "MIT"

  on_intel do
    url "https://github.com/Devace-93/mousetouch/releases/download/v0.1.12/mousetouch-v0.1.12-x86_64-linux.tar.gz"
    sha256 "03d138a09a9e371e9c797f457a3179a7cc37720339f4339371292a00a707e6e7"
  end
  on_arm do
    url "https://github.com/Devace-93/mousetouch/releases/download/v0.1.12/mousetouch-v0.1.12-aarch64-linux.tar.gz"
    sha256 "4c730ecf4f1f58711ccd8faa7137fe6e3eb2e74519dbc9088381e17726afff2c"
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
      After `brew upgrade` the running daemon restarts itself (0.1.10 and later;
      older versions need `brew services restart mousetouch`).
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
