#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "${SCRIPT_DIR}"/approot/{bin,lib,opt,usr/lib/helix}

# Install nodejs
NODE_VER='v24.8.0'
rm -rf "${SCRIPT_DIR}/approot/node-$NODE_VER-linux-x64"
wget -O- "https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-linux-x64.tar.xz" | tar -JxvC "${SCRIPT_DIR}"/approot

# Install helix
if [[ ! -d ${SCRIPT_DIR}/helix ]]; then
	git clone https://github.com/jgroboredo/helix.git "${SCRIPT_DIR}"/helix || exit
fi

HELIX_TARGET_CONFIG="/usr/lib/helix/config"
HELIX_TARGET_RUNTIME="${HELIX_TARGET_CONFIG}/runtime"

APPDIR_HELIX_TARGET_CONFIG="${SCRIPT_DIR}/approot/${HELIX_TARGET_CONFIG}"
APPDIR_HELIX_TARGET_RUNTIME="${APPDIR_HELIX_TARGET_CONFIG}/runtime"

(
	pushd "${SCRIPT_DIR}"/helix/helix-term || exit
	cargo build --release || exit
	popd || exit
	cp -r "${SCRIPT_DIR}"/helix/config "${APPDIR_HELIX_TARGET_CONFIG}"
	cp -r "${SCRIPT_DIR}"/helix/runtime "${APPDIR_HELIX_TARGET_RUNTIME}" 
	rm -rf "${APPDIR_HELIX_TARGET_RUNTIME}/grammars/sources"
	cp "${SCRIPT_DIR}"/helix/target/release/hx "${SCRIPT_DIR}"/approot/bin/hx
	cp "${SCRIPT_DIR}"/helix/contrib/Helix.desktop "${SCRIPT_DIR}"/approot/Helix.desktop
	cp "${SCRIPT_DIR}"/helix/contrib/helix.png "${SCRIPT_DIR}"/approot/helix.png
)

(
	echo '#!/bin/bash'
	echo 'APPDIR="$(dirname "$(readlink -f "${0}")")"'
	echo "HELIX_RUNTIME=\"\$APPDIR/${HELIX_TARGET_RUNTIME}\" PATH=\"\$APPDIR/bin:\$APPDIR/node-$NODE_VER-linux-x64/bin:\$PATH\" \"\$APPDIR/bin/hx\" -c \"\$APPDIR/${HELIX_TARGET_CONFIG}/config.toml\" \"\$@\""
) > "${SCRIPT_DIR}"/approot/AppRun
chmod +x "${SCRIPT_DIR}"/approot/AppRun


export PATH="${SCRIPT_DIR}/approot/bin:${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/bin:$PATH"

# Nodejs packages
"${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/bin/npm" i \
	--prefix "${SCRIPT_DIR}/approot/node-$NODE_VER-linux-x64/" -g \
	pyright \
	vscode-langservers-extracted \
	typescript \
	typescript-language-server \
	yaml-language-server@next \
	dockerfile-language-server-nodejs \
	@microsoft/compose-language-service \
	bash-language-server \
	@ansible/ansible-language-server

rm -r "${SCRIPT_DIR}/approot/node-${NODE_VER}-linux-x64/include"

# Ruff
test -f "${SCRIPT_DIR}/approot/bin/ruff" || \
	cargo install --git https://github.com/astral-sh/ruff.git ruff --root "${SCRIPT_DIR}/approot"

# Clangd
if [[ ! -e ${SCRIPT_DIR}/approot/bin/clangd ]]; then
    clang_archive_path="${SCRIPT_DIR}/approot/clangd-latest.zip"
    clang_extract_dir="${SCRIPT_DIR}/approot/clangd-extracted"
	curl -s https://api.github.com/repos/clangd/clangd/releases/latest \
	   | jq -r '.assets[] | select(.name | startswith("clangd-linux")) | .browser_download_url' \
	   | wget -qi -O "${clang_archive_path}" -
	mkdir -p "${clang_extract_dir}"
	unzip -q "${clang_archive_path}" -d "${clang_extract_dir}"
    clang_bin_dir="$(find "${clang_extract_dir}" -maxdepth 2 -type d -name bin | head -n 1)"
    mv "${clang_bin_dir}/*" "${SCRIPT_DIR}/approot/bin" 

    rm -rf "${clang_archive_path}" "${clang_extract_dir}"
fi

# jj
test -f "${SCRIPT_DIR}/approot/bin/jj" || \
	cargo install --git https://github.com/jj-vcs/jj.git jj-cli --root "${SCRIPT_DIR}/approot"

# lazyjj
test -f "${SCRIPT_DIR}/approot/bin/lazyjj" || \
	cargo install --git https://github.com/Cretezy/lazyjj.git --locked --root "${SCRIPT_DIR}/approot"

# yazi
test -f "${SCRIPT_DIR}/approot/bin/yazi" || \
	cargo install --force --git https://github.com/sxyazi/yazi.git yazi-build --root "${SCRIPT_DIR}/approot"

if [[ ! -e ${SCRIPT_DIR}/appimagetool-x86_64.AppImage ]]; then
	wget -P ${SCRIPT_DIR} https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
	chmod +x ${SCRIPT_DIR}/appimagetool-x86_64.AppImage
fi

${SCRIPT_DIR}/appimagetool-x86_64.AppImage "${SCRIPT_DIR}/approot/" ${SCRIPT_DIR}/hx-ai

