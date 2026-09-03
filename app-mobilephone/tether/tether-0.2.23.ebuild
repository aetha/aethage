# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd optfeature

DESCRIPTION="Linux + iPhone Continuity / iMessage / SMS"
HOMEPAGE="https://github.com/zackb/tether"
SRC_URI="https://github.com/zackb/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+bluetooth doc +systemd test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/glib:2
	>=dev-libs/openssl-3:=
	dev-libs/wayland
	gui-libs/gtk-layer-shell
	net-dns/avahi[dbus]
	x11-libs/gtk+:3
	x11-libs/libnotify
"

RDEPEND="
	${COMMON_DEPEND}
	bluetooth? ( >=net-wireless/bluez-5.86[experimental,extra-tools,obex] )
	systemd? ( sys-apps/systemd )
	!systemd? ( sys-libs/basu )
"

DEPEND="
	${COMMON_DEPEND}
	dev-cpp/nlohmann_json
	test? ( dev-cpp/gtest )
"

BDEPEND="
	>=dev-build/cmake-3.19
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}/tether-0.2.18-cmakelists.patch" )

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
		-DSYSTEMD_UNIT_DIR="$(systemd_get_systemunitdir)"
		-DTETHER_BUILD_EXTENSIONS=OFF
	)

	cmake_src_configure
}

src_test() {
	cmake_src_test -j1
}

src_install() {
	cmake_src_install

	newbin scripts/bt-probe.sh tether-bt-probe
	newbin scripts/tether-reset.sh tether-reset

	dodoc docs/BLUETOOTH.md

	if use doc; then
		dodoc docs/{DESIGN,PROTOCOL,TODO}.md
	fi

	docinto examples
	dodoc "${FILESDIR}/51-no-phone-audio.conf"
}

pkg_postinst() {
	if use bluetooth; then
		if ! use systemd; then
			elog "Tether's Bluetooth setup wizard is not designed to guide non-systemd users."
			elog "Check the documentation to help, though be warned, you're on your own."
			elog "  bzless /usr/share/doc/${PF}/BLUETOOTH.md.bz2"
		fi

		if has_version media-video/pipewire; then
			optfeature "preventing iPhone audio hijacking (HIGHLY RECOMMENDED)" media-video/wireplumber

			ewarn "If you use PipeWire and connect an iPhone via Bluetooth to Tether, by"
			ewarn "default this setup will hijack the phone's audio and redirect it to your"
			ewarn "computer. To avoid this, copy the WirePlumber config to your user account:"
			ewarn ""
			ewarn "  mkdir -p ~/.config/wireplumber/wireplumber.conf.d/"
			ewarn "  cp /usr/share/doc/${PF}/examples/51-no-phone-audio.conf ~/.config/wireplumber/wireplumber.conf.d/"
			ewarn "  systemctl --user restart wireplumber"
		fi
	fi
}
