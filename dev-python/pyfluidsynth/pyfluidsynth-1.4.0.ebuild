# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for FluidSynth, a MIDI synthesizer that uses SoundFont instruments"
HOMEPAGE="https://github.com/amberwhitehead/pyfluidsynth"
LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=media-sound/fluidsynth-2.0.0
	dev-python/numpy[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-python/pyaudio[${PYTHON_USEDEP}]
		>=dev-python/pytest-9.0[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
