# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )
PYTHON_REQ_USE="tk"

inherit distutils-r1 desktop xdg

DESCRIPTION="A simple GUI designer for the Python Tkinter module"
HOMEPAGE="https://github.com/alejandroautalan/pygubu-designer"
SRC_URI="https://github.com/alejandroautalan/pygubu-designer/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# tests directory present, but no tests are actually functional.
RESTRICT="test"

RDEPEND="
	>=dev-python/autopep8-1.7[${PYTHON_USEDEP}]
	>=dev-python/blinker-1.6[${PYTHON_USEDEP}]
	>=dev-python/mako-1.1.4[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.4.0[${PYTHON_USEDEP}]
	>=dev-python/pygubu-0.41[${PYTHON_USEDEP}]
	>=dev-python/screeninfo-0.8[${PYTHON_USEDEP}]
"

src_install() {
	distutils-r1_src_install

	newicon -s scalable "${S}"/development/pygubuLogo/pyGubu_newLogo.svg pygubu-designer.svg
	newicon -s 64 "${S}"/src/pygubudesigner/data/images/images-png/pygubu.png pygubu-designer.png
	make_desktop_entry pygubu-designer "Pygubu Designer" pygubu-designer \
		"Development;GUIDesigner;" "StartupWMClass=Pygubudesigner"
}
