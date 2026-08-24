# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd

DESCRIPTION="Daemon that sends local hardware information to Home Assistant"
HOMEPAGE="https://github.com/tobias-kuendig/hacompanion"

SRC_URI="
	https://github.com/tobias-kuendig/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/aetha/gentoo-deps/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

RDEPEND="x11-libs/libnotify"
BDEPEND=">=dev-lang/go-1.23"

src_compile() {
	ego build -ldflags="-X 'main.Version=${PV}'" -trimpath -v -o hacompanion .
}

src_install() {
	dobin hacompanion

	if use systemd; then
		systemd_douserunit "${FILESDIR}"/hacompanion.service
	fi

	local DOCS=( hacompanion.toml.example README.md )
	einstalldocs
}

pkg_postinst() {
	elog "A user config file is required to run hacompanion. To make a new one:"
	elog "  bzcat /usr/share/doc/${PF}/hacompanion.toml.example.bz2 > ~/.config/hacompanion.toml"

	if use systemd; then
		elog ""
		elog "Once configured, enable the daemon via systemd:"
		elog "  systemctl --user enable --now hacompanion.service"
	fi
}
