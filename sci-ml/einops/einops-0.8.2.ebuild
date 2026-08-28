# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Flexible and powerful tensor operations for readable and reliable code"
HOMEPAGE="https://github.com/arogozhnikov/einops https://einops.rocks/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		dev-python/numpy[${PYTHON_USEDEP}]
		sci-ml/pytorch[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_test() {
	local -x EINOPS_TEST_BACKENDS="numpy"

	# Dynamically enable torch tests if pytorch is available for this target
	if python_has_version "sci-ml/pytorch[${PYTHON_USEDEP}]"; then
		EINOPS_TEST_BACKENDS+=",torch"
	fi

	epytest
}
