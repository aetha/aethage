# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit unpacker go-module desktop gnome2-utils xdg

DESCRIPTION="An unofficial GUI wrapper around the Tailscale CLI client"
HOMEPAGE="https://github.com/DeedleFake/trayscale"

SRC_URI="
	https://github.com/DeedleFake/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/DeedleFake/${PN}/releases/download/v${PV}/${PN}-vendor.tar.zst ->
		${P}-vendor.tar.zst
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	gui-libs/gtk:4
	gui-libs/libadwaita:1
"

RDEPEND="
	${DEPEND}
	net-vpn/tailscale
"

BDEPEND="
	app-arch/zstd
	>=dev-lang/go-1.26.2
	virtual/pkgconfig
"

src_unpack() {
	unpacker_src_unpack

	if [[ -d "${WORKDIR}/vendor" && ! -d "${S}/vendor" ]]; then
		mv "${WORKDIR}/vendor" "${S}/" || die
	fi
}

src_compile() {
	# Suppress gotk4's auto-generated CGO built-in declaration warning
	export CGO_CFLAGS="${CGO_CFLAGS} -Wno-builtin-declaration-mismatch"

	ego build -ldflags="-X 'deedles.dev/trayscale/internal/metadata.version=v${PV}'" -mod=vendor \
		-trimpath -v -o "${PN}" ./cmd/trayscale
}

src_install() {
	dobin trayscale

	domenu dev.deedles.Trayscale.desktop
	doicon -s 256 dev.deedles.Trayscale.png

	insinto /usr/share/metainfo
	doins dev.deedles.Trayscale.metainfo.xml

	insinto /usr/share/glib-2.0/schemas
	doins dev.deedles.Trayscale.gschema.xml

	einstalldocs
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	elog "Trayscale requires your user account to be set as a Tailscale operator."
	elog "Run the following command at least once from your command line:"
	elog "  sudo tailscale set --operator=\$USER"
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
