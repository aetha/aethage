# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake xdg

DESCRIPTION="Multi-system emulator focusing on accuracy and preservation"
HOMEPAGE="https://github.com/ares-emulator/ares https://ares-emu.net/"
SRC_URI="https://github.com/ares-emulator/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="ISC Apache-2.0 BSD BSD-2 MIT MPL-2.0 ZLIB public-domain"
SLOT="0"
KEYWORDS="~amd64"

CORES=( a26 cv fc gb gba md ms msx myvision n64 ng ngp pce ps1 sfc sg spec ws )

IUSE="
	${CORES[@]/#/+ares_cores_} accuracy alsa ao +chdr +gtk +librashader lto openal oss
	pulseaudio qt6 sdl tools +udev
"
# TODO: add shaders flag to include slang-shaders when package finalised.

REQUIRED_USE="
	^^ ( gtk qt6 )
	|| ( ${CORES[@]/#/ares_cores_} )
"

DEPEND="
	alsa? ( media-libs/alsa-lib )
	ao? ( media-libs/libao )
	chdr? (
		app-arch/zstd:=
		virtual/zlib:=
	)
	gtk? ( x11-libs/gtk+:3 )
	openal? ( media-libs/openal )
	pulseaudio? ( media-libs/libpulse )
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
	sdl? ( media-libs/libsdl3 )
	udev? ( virtual/libudev:= )
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXrandr
"

RDEPEND="
	${DEPEND}
	ares_cores_n64? ( media-libs/vulkan-loader )
	librashader? ( media-libs/librashader[opengl] )
"
# TODO: Add slang-shaders to RDEPEND when package finalised.

BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	local -a cores=()
	local flag

	for flag in "${CORES[@]}"; do
		use "ares_cores_${flag}" && cores+=( "${flag}" )
	done

	local IFS=";" ;# expand cores list with semicolon separators

	local mycmakeargs=(
		-DARES_BUILD_LOCAL=OFF
		-DARES_BUILD_OFFICIAL=ON
		-DARES_BUNDLE_SHADERS=OFF
		-DARES_CORES="${cores[*]}"
		-DARES_ENABLE_MINIMUM_CPU=OFF
		-DARES_ENABLE_ALSA=$(usex alsa)
		-DARES_ENABLE_AO=$(usex ao)
		-DARES_ENABLE_CHD=$(usex chdr)
		-DARES_ENABLE_LIBRASHADER=$(usex librashader)
		-DARES_ENABLE_OPENAL=$(usex openal)
		-DARES_ENABLE_OSS=$(usex oss)
		-DARES_ENABLE_PULSEAUDIO=$(usex pulseaudio)
		-DARES_ENABLE_SDL=$(usex sdl)
		-DARES_ENABLE_UDEV=$(usex udev)
		-DARES_PROFILE_ACCURACY=$(usex accuracy)
		-DARES_SKIP_DEPS=ON
		-DARES_UNITY_CORES=ON
		-DENABLE_CCACHE=OFF
		-DENABLE_IPO=$(usex lto)
		-DUSE_QT6=$(usex qt6)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if ! use tools; then
		rm -f "${ED}/usr/bin/sourcery"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if use qt6; then
		ewarn "When running ares with the Qt6 interface on a Wayland session, you"
		ewarn "may need to set the environment variable:"
		ewarn "  QT_QPA_PLATFORM=xcb"
		ewarn "if you experience startup crashes or rendering issues."
	fi
}
