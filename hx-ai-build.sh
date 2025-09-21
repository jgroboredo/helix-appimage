#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "${SCRIPT_DIR}"/approot/{bin,lib,opt,usr/lib/helix}

# Install nodejs
NODE_VER='v24.8.0'
rm -rf "${SCRIPT_DIR}/approot/node-$NODE_VER-linux-x64"
wget -O- "https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-linux-x64.tar.xz" | tar -JxvC "${SCRIPT_DIR}"/approot

# Install helix
if [[ ! -d helix ]]; then
	git clone https://github.com/jgroboredo/helix.git "${SCRIPT_DIR}"/helix || exit
fi

(
	pushd "${SCRIPT_DIR}"/helix/helix-term || exit
	cargo build --release || exit
	popd || exit
	cp -r "${SCRIPT_DIR}"/helix/runtime "${SCRIPT_DIR}"/approot/usr/lib/helix/runtime 
	cp -r "${SCRIPT_DIR}"/config.toml "${SCRIPT_DIR}"/approot/usr/lib/helix/config.toml
	rm -rf "${SCRIPT_DIR}"/approot/usr/lib/helix/runtime/grammars/sources
	cp "${SCRIPT_DIR}"/helix/target/release/hx "${SCRIPT_DIR}"/approot/bin/hx
	cp "${SCRIPT_DIR}"/helix/contrib/Helix.desktop "${SCRIPT_DIR}"/approot/Helix.desktop
	cp "${SCRIPT_DIR}"/helix/contrib/helix.png "${SCRIPT_DIR}"/approot/helix.png
)

(
	echo '#!/bin/bash'
	echo 'APPDIR="$(dirname "$(readlink -f "${0}")")"'
	echo "HELIX_RUNTIME=\"\$APPDIR/usr/lib/helix/runtime\" PATH=\"\$APPDIR/bin:\$APPDIR/node-$NODE_VER-linux-x64/bin:\$PATH\" \"\$APPDIR/bin/hx\" -c \"\$APPDIR/usr/lib/helix/config.toml\" \"\$@\""
) > "${SCRIPT_DIR}"/approot/AppRun
chmod +x "${SCRIPT_DIR}"/approot/AppRun


export PATH="${SCRIPT_DIR}/approot/bin:${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/bin:$PATH"
	"${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/bin/npm" i --prefix "${SCRIPT_DIR}/approot/node-$NODE_VER-linux-x64/" -g \
	pyright vscode-langservers-extracted typescript typescript-language-server \
	@vue/language-server yaml-language-server@next svelte-language-server \
	dockerfile-language-server-nodejs @microsoft/compose-language-service bash-language-server \
	@ansible/ansible-language-server perlnavigator-server intelephense awk-language-server emmet-ls

rm -r "${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/include"

test -f "${SCRIPT_DIR}/approot/bin/ruff" || \
	cargo install --git https://github.com/astral-sh/ruff.git ruff --root "${SCRIPT_DIR}/approot"

if [[ ! -e appimagetool-x86_64.AppImage ]]; then
	wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage
fi
./appimagetool-x86_64.AppImage "${SCRIPT_DIR}/approot/" hx-ai

