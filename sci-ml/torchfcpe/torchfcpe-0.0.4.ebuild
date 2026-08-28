# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1

DESCRIPTION="PyTorch-based library designed for audio pitch extraction and MIDI conversion"
HOMEPAGE="https://github.com/CNChTu/FCPE"
SRC_URI="https://github.com/CNChTu/FCPE/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/FCPE-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/librosa[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pretty_midi[${PYTHON_USEDEP}]
	dev-python/pydub[${PYTHON_USEDEP}]
	sci-libs/scipy[${PYTHON_USEDEP}]
	sci-ml/einops[${PYTHON_USEDEP}]
	sci-ml/local-attention[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		sci-ml/pytorch[${PYTHON_USEDEP}]
		sci-ml/torchaudio[${PYTHON_USEDEP}]
	')
"
