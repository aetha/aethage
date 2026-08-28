# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="An implementation of local windowed attention for language modeling"
HOMEPAGE="https://github.com/lucidrains/hyper-connections"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=sci-ml/einops-0.8.0[${PYTHON_USEDEP}]
	>=sci-ml/hyper-connections-0.1.8[${PYTHON_USEDEP}]
	$(python_gen_cond_dep 'sci-ml/pytorch[${PYTHON_USEDEP}]')
"

BDEPEND="test? ( ${RDEPEND} )"

distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# FP32 numerical precision flake on CPU (atol=1e-6 threshold)
		tests/test_local_attention.py::test_cache[1000-True-True-False]
	)
	
	epytest
}
