#!/bin/bash

cd "$(dirname "$0")"
MAIN_DIR="$(pwd)"

mkdir -p approot/{bin,lib,opt,usr/lib/helix}

# Install nodejs
NODE_VER='v20.14.0'
rm -rf "approot/node-$NODE_VER-linux-x64"
wget -O- "https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-linux-x64.tar.xz" | tar -JxvC approot

# Install helix
if [[ ! -d helix-editor ]]; then
	git clone https://github.com/sploders101/helix-editor || exit
fi
(
	cd helix-editor/helix-term
	git pull
	cargo build --release || exit
	cd ..
	cp -r runtime ../approot/usr/lib/helix/runtime 
	cp -r ../config.toml ../approot/usr/lib/helix/config.toml
	rm -rf ../approot/usr/lib/helix/runtime/grammars/sources
	cp target/release/hx ../approot/bin/hx
	cp contrib/Helix.desktop ../approot/Helix.desktop
	cp contrib/helix.png ../approot/helix.png
)

(
	echo '#!/bin/bash'
	echo 'APPDIR="$(dirname "$(readlink -f "${0}")")"'
	echo "HELIX_RUNTIME=\"\$APPDIR/usr/lib/helix/runtime\" PATH=\"\$APPDIR/bin:\$APPDIR/node-$NODE_VER-linux-x64/bin:\$PATH\" \"\$APPDIR/bin/hx\" -c \"\$APPDIR/usr/lib/helix/config.toml\" \"\$@\""
) > approot/AppRun
chmod +x approot/AppRun


export PATH="$(pwd)/approot/bin:$(pwd)/approot/node-$NODE_VER-linux-x64/bin:$PATH"
"./approot/node-$NODE_VER-linux-x64/bin/npm" i --prefix "./approot/node-$NODE_VER-linux-x64/" -g \
	pyright vscode-langservers-extracted typescript typescript-language-server \
	@vue/language-server yaml-language-server@next svelte-language-server \
	dockerfile-language-server-nodejs @microsoft/compose-language-service bash-language-server \
	@ansible/ansible-language-server perlnavigator-server intelephense awk-language-server emmet-ls
rm -r approot/node-$NODE_VER-linux-x64/include

if [[ ! -d rhai-lsp ]]; then
	git clone https://github.com/rhaiscript/rhai-lsp.git rhai-lsp
fi
(
	cd rhai-lsp
	git pull
	cargo build --release || exit
	cp target/release/rhai ../approot/bin/rhai
)

if [[ ! -e appimagetool-x86_64.AppImage ]]; then
	wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage
fi
./appimagetool-x86_64.AppImage approot/ hx-ai
