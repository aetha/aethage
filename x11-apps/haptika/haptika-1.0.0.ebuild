# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit gnome2-utils meson xdg optfeature

DESCRIPTION="Powerful Linux gamepad tester written in pure C"
HOMEPAGE="https://github.com/Gabriel2Silva/Haptika"
SRC_URI="https://github.com/Gabriel2Silva/Haptika/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Haptika-${PV}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pipewire"

RDEPEND="
	>=dev-libs/libevdev-1.11.0
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	>=media-libs/libsdl3-3.2.0
	>=virtual/libudev-249
	pipewire? ( media-video/pipewire:= )
"
DEPEND="${RDEPEND}"

BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-1.0.0-pipewire-option.patch"
)

src_configure() {
	local emesonargs=(
		$(meson_feature pipewire)
	)

	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	optfeature "udev rules for DualShock/DualSense and third-party controllers" \
		games-util/game-device-udev-rules

	elog "To use the raw evdev backend, your user must be added to the 'input' group:"
	elog "  gpasswd -a <username> input"
	elog "Then log out and back in for group changes to take effect."
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
