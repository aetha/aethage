# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )
PYTHON_REQ_USE="tk"

inherit distutils-r1 virtualx

DESCRIPTION="A simple GUI builder for the Python Tkinter module"
HOMEPAGE="https://github.com/alejandroautalan/pygubu"
SRC_URI="https://github.com/alejandroautalan/pygubu/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

distutils_enable_tests unittest

python_test() {
	cd "${S}"/tests || die
	eunittest
}

src_test() {
	virtx distutils-r1_src_test
}
