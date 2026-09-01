# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Utility functions for handling MIDI data in a nice/intuitive way"
HOMEPAGE="https://github.com/craffel/pretty-midi"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/mido-1.1.16[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/pyfluidsynth-1.3.1[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/pretty-midi-0.2.11-no-backports.patch" )

distutils_enable_tests pytest
