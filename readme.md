# Helix AppImage

This is the build script I use to prepare my editor (a personalized fork of Helix)
for portable deployment as an AppImage. Feel free to use this as a template for your
own bundler, but I built this for my own personal use, so YMMV. I have to develop a
lot on systems I don't own, or on lots of different systems, so this lets me take
my environment with me wherever I go with only one dependency (FUSE).

## Building

First, prepare the docker image:

```bash
docker build -t legacy-builder .
```

Next, create the `approot` folder:
```bash
mkdir approot
```

Then, simply run the build script:

```bash
./build.sh
```

This will create a container from the new image you prepared using `Dockerfile`, and
use it to build a copy of Helix. It will download a variety of LSPs, and install
everything into the approot folder. Then, it will download a copy of `appimagetool`
and wrap it all up into an executable that can be installed on your target system.
