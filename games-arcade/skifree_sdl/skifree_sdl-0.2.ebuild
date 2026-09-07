# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop xdg

DESCRIPTION="Port of the classic Microsoft Entertainment Pack game skifree to SDL2"
HOMEPAGE="https://github.com/jeff-1amstudios/skifree_sdl"

SRC_URI="
	https://github.com/jeff-1amstudios/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://archive.org/download/ski32_resources/ski32_resources.zip
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-ttf
"

DEPEND="${RDEPEND}"

BDEPEND="
	app-arch/unzip
	media-gfx/imagemagick
"

src_unpack() {
	unpack "${P}.tar.gz"

	cd "${S}/resources" || die
	unpack ski32_resources.zip
}

src_compile() {
	cmake_src_compile

	convert "${S}/resources/ICONSKI.ico[2]" -scale 512x512 \
		"${BUILD_DIR}/skifree_sdl.png" || die
}

src_install() {
	dobin "${BUILD_DIR}/skifree_sdl"

	doicon -s 512 "${BUILD_DIR}/skifree_sdl.png"
	make_desktop_entry skifree_sdl "SkiFree SDL" skifree_sdl "Game;ArcadeGame;"

	einstalldocs
}
