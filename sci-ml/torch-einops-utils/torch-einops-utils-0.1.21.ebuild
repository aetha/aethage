# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Some utility functions to help Phil Wang go faster with ML/AI work"
HOMEPAGE="https://github.com/lucidrains/torch-einops-utils"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=sci-ml/einops-0.8.1[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '>=sci-ml/pytorch-2.5[${PYTHON_USEDEP}]')
"

BDEPEND="
	test? (
		${RDEPEND}
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/networkx[${PYTHON_USEDEP}]
	)
"
distutils_enable_tests pytest
