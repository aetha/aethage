# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1

DESCRIPTION="Multiple residual streams from Bytedance's Hyper-Connections paper"
HOMEPAGE="https://github.com/lucidrains/hyper-connections"
COMMIT="e89e30357d1f79945b0d3558e6721451ff68789a"
SRC_URI="https://github.com/lucidrains/${PN}/archive/${COMMIT}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	$(python_gen_cond_dep '>=sci-ml/einops-0.8.1[${PYTHON_USEDEP}]')
	>=sci-ml/torch-einops-utils-0.0.20[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-2.5[${PYTHON_SINGLE_USEDEP}]
"

distutils_enable_tests pytest
