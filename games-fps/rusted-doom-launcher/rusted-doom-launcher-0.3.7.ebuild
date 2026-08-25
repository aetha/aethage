# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHECKREQS_DISK_BUILD="3G"
RUST_MIN_VER="1.88.0"

inherit cargo optfeature desktop xdg check-reqs

DESCRIPTION="Steam-like experience for DOOM maps & mods"
HOMEPAGE="https://github.com/stared/rusted-doom-launcher"

SRC_URI="
	https://github.com/stared/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/aetha/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
	https://github.com/aetha/gentoo-deps/releases/download/${P}/${P}-node_modules.tar.xz
"

LICENSE="MIT"
# Cargo dependency licenses:
LICENSE+=" Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CDLA-Permissive-2.0 ISC MIT MPL-2.0
	Unicode-3.0 ZLIB"
# Node dependency licenses:
LICENSE+=" Apache-2.0 BSD ISC MIT Unicode-3.0 ZLIB"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	app-accessibility/at-spi2-core
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/pango
"

RDEPEND="${DEPEND}"

BDEPEND="
	net-libs/nodejs
	virtual/pkgconfig
"

# QA doesn't like 'LauncherStore' category, even though it's a valid one, so skip the check.
# (see https://specifications.freedesktop.org/menu/latest/additional-category-registry.html)
QA_DESKTOP_FILE="usr/share/applications/${PN}.desktop"

pkg_setup() {
	check-reqs_pkg_setup
	rust_pkg_setup
}

src_compile() {
	export PATH="${WORKDIR}/node_modules/.bin:${PATH}"

	node scripts/generate-version.js || die "Version generation failed"
	vue-tsc -b || die "TypeScript check failed"
	vite build || die "Vite build failed"
	tauri build -c '{"build": {"beforeBuildCommand": ""}}' || die "Tauri build failed"
}

src_install() {
	dobin src-tauri/target/release/${PN}

	newicon -s 32 src-tauri/icons/32x32.png ${PN}.png
	newicon -s 128 src-tauri/icons/128x128.png ${PN}.png

	make_desktop_entry ${PN} "Rusted Doom Launcher" ${PN} "Game;Shooter;LauncherStore;"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "GZDOOM or UZDOOM engine install to actually play ;-)" \
		games-engines/uzdoom
	optfeature "auto extract IWADs from Inno Setup based installer (like from GOG)" \
		app-arch/innoextract
}
