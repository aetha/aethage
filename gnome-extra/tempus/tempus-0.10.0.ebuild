# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..15} )

inherit distutils-r1 gnome2-utils desktop xdg

DESCRIPTION="A focused Pomodoro timer for GNOME"
HOMEPAGE="https://github.com/EmaLica/Tempus"
SRC_URI="https://github.com/EmaLica/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Tempus-${PV}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gnome-shell"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

RDEPEND="
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
	dev-libs/glib:2
	gui-libs/gtk:4[introspection]
	gui-libs/libadwaita:1
	media-libs/gstreamer:1.0[introspection]
	media-plugins/gst-plugins-meta:1.0
	gnome-shell? ( gnome-base/gnome-shell )
"

src_install() {
	distutils-r1_src_install

	domenu data/io.github.EmaLica.Tempus.desktop

	insinto /usr/share/metainfo
	doins data/io.github.EmaLica.Tempus.metainfo.xml

	insinto /usr/share/glib-2.0/schemas
	doins data/io.github.EmaLica.Tempus.gschema.xml

	insinto /usr/share/icons
	doins -r data/icons/hicolor

	if use gnome-shell; then
		local ext_dir="/usr/share/gnome-shell/extensions/${PN}@emalica.github.io"
		insinto "${ext_dir}"
		doins -r shell-extension/*
		rm -f "${ED}${ext_dir}/INSTALL.md"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
