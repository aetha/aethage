# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )
PYTHON_REQ_USE="tk?"

inherit distutils-r1

DESCRIPTION="The free-forever Python Simple GUI software"
HOMEPAGE="https://github.com/spyoungtech/FreeSimpleGUI https://freesimplegui.readthedocs.io/"
MY_PV="${PV/_p/.post}"
SRC_URI="https://github.com/spyoungtech/FreeSimpleGUI/archive/refs/tags/v${MY_PV}.tar.gz ->
	${P}.gh.tar.gz"
S="${WORKDIR}/FreeSimpleGUI-${MY_PV}"
LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64"

# TODO: support the other frontends (Qt, wxWidgets, and web)
IUSE="doc tk"
REQUIRED_USE="|| ( tk )"

RDEPEND="${PYTHON_DEPS}"

# The only test included requires manual interaction
RESTRICT="test"

DOCS=( README.md NOTICE )

src_prepare() {
	default

	# Remove non-Tk frontends so setuptools only packages the core Tk backend
	rm -rf FreeSimpleGUIQt FreeSimpleGUIWx FreeSimpleGUIWeb || die
}

src_install() {
	distutils-r1_src_install

	if use doc; then
		docinto docs
		dodoc -r docs/*.{md,pdf,py}
	fi
}
