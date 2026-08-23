#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    fmt           \
    libdecor      \
    libzip        \
    ninja         \
    nlohmann-json \
    sdl2          \
    spdlog        \
    tcc           \
    tinyxml2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

make-aur-package zenity-rs-bin

echo "Making stable build of Starship..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/Starship"
VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./Starship
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./Starship
patch -Np1 -i "../starship-stack-underflow-guard.patch"

cmake . \
    -Bbuild \
    -GNinja \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON

cmake --build build --config Release
cmake --build build --config Release --target GeneratePortO2R

mv -v build/assets ../AppDir/bin
mv -v build/StarshipSF64 ../AppDir/bin
mv -v build/config.yml ../AppDir/bin
mv -v build/starship.o2r ../AppDir/bin
#mv -v libultraship/libtcc.so ../AppDir/bin
wget -O ../AppDir/bin/gamecontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
cp -v logo.png ../AppDir/.DirIcon
mv -v logo.png ../AppDir/ghostship.png
