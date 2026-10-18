# rpcs3-deb-builder

Unofficial script that repackages an RPCS3 AppImage into a .deb. Not affiliated with RPCS3.

## Requirements
- Debian/Ubuntu-based Linux
- An RPCS3 AppImage from https://rpcs3.net

## Download
Grab the scripts directly:

```bash
wget https://raw.githubusercontent.com/HacksYT23-2/rpcs3-deb-builder/main/make-rpcs3-deb.sh
```

Or clone the whole repo:

```bash
git clone https://github.com/HacksYT23-2/rpcs3-deb-builder.git
cd rpcs3-deb-builder
```

## One-step install
Builds the .deb and installs it (run as your normal user, not root):

```bash
chmod +x install.sh make-rpcs3-deb.sh
./install.sh ./rpcs3.AppImage 0.0.1
```

## Build only
```bash
chmod +x make-rpcs3-deb.sh
./make-rpcs3-deb.sh ./rpcs3.AppImage 0.0.1
sudo apt install ./rpcs3_0.0.1_amd64.deb
```

Set `ARCH=arm64` for the ARM build.

## Notes
- This repo contains no RPCS3 binaries, PS3 firmware, or game files. You supply the AppImage yourself.
- RPCS3 is GPLv2 and belongs to its respective authors: https://github.com/RPCS3/rpcs3
- The package does not auto-update. Rebuild it to get a newer RPCS3 version.
