# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast and high quality sample-rate conversion library for Python"
HOMEPAGE="https://github.com/dofuuz/python-soxr"
LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-libs/soxr"

RDEPEND="
	${DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
"

BDEPEND="
	>=dev-python/nanobind-2[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-6.2[${PYTHON_USEDEP}]
"

# TODO: create dev-python/sphinx-book-theme ebuild
#distutils_enable_sphinx docs dev-python/sphinx-book-theme

distutils_enable_tests pytest

python_compile() {
	local -x SKBUILD_CMAKE_DEFINE="USE_SYSTEM_LIBSOXR=ON"
	distutils-r1_python_compile
}
