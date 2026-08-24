# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"
CHECKREQS_DISK_BUILD="3G"

inherit cargo check-reqs

DESCRIPTION="RetroArch shader preset compiler and runtime"
HOMEPAGE="https://github.com/SnowflakePowered/librashader"

SRC_URI="
	https://github.com/SnowflakePowered/${PN}/archive/refs/tags/${PN}-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/aetha/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
"
S="${WORKDIR}/${PN}-${PN}-v${PV}"

LICENSE="|| ( GPL-3 MPL-2.0 ) MIT"
LICENSE+=" Apache-2.0 BSD-2 BSD ISC MIT MPL-2.0 MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="lto +opengl static-libs tools +vulkan"
REQUIRED_USE="|| ( opengl vulkan )"

RDEPEND="
	opengl? ( media-libs/libglvnd )
	vulkan? ( media-libs/vulkan-loader )
"

pkg_setup() {
	check-reqs_pkg_setup
	rust_pkg_setup
}

src_compile() {
	if use lto; then
		local -x CARGO_PROFILE_RELEASE_LTO="thin"
	else
		local -x CARGO_PROFILE_RELEASE_LTO="false"
	fi

	local features=()
	use opengl && features+=( "runtime-opengl" )
	use vulkan && features+=( "runtime-vulkan" )

	# Add a SONAME linker flag to the C API target
	RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-soname,librashader.so" \
		cargo_src_compile -p librashader-capi --no-default-features \
		--features $(IFS=,; echo "${features[*]}")

	if use tools; then
		cargo_src_compile -p librashader-cli
	fi
}

src_install() {
	insinto /usr/include/librashader
	doins include/*.h

	newlib.so "$(cargo_target_dir)/liblibrashader_capi.so" librashader.so

	if use static-libs; then
		newlib.a "$(cargo_target_dir)/liblibrashader_capi.a" librashader.a
	fi

	if use tools; then
		dobin "$(cargo_target_dir)/librashader-cli"
	fi

	einstalldocs
}
