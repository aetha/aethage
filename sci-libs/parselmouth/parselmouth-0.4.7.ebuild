# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_PN="praat-${PN}"
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Parselmouth is a Python library for the Praat software"
HOMEPAGE="https://github.com/YannickJadoul/Parselmouth https://parselmouth.readthedocs.io/"
LICENSE="GPL-3+ GPL-2+ BSD MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-python/numpy-1.7[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

# Ugly dependency ladder here, cos there's not a better way to solve this problem:
# Docs are built only once, not for all PYTHON_TARGETS. When Parselmouth is emerged for multpile
# PYTHON_TARGETS we only need the Sphinx dependency chain to match one of them.
BDEPEND="
	${RDEPEND}
	>=dev-build/cmake-3.18
	dev-build/ninja
	>=dev-python/scikit-build-0.12[${PYTHON_USEDEP}]
	doc? (
		python_targets_python3_14? (
			dev-python/nbsphinx[python_targets_python3_14(-)]
			dev-python/sphinx[python_targets_python3_14(-)]
			dev-python/sphinx-rtd-theme[python_targets_python3_14(-)]
		)
		!python_targets_python3_14? (
			python_targets_python3_13? (
				dev-python/nbsphinx[python_targets_python3_13(-)]
				dev-python/sphinx[python_targets_python3_13(-)]
				dev-python/sphinx-rtd-theme[python_targets_python3_13(-)]
			)
			!python_targets_python3_13? (
				dev-python/nbsphinx[python_targets_python3_12(-)]
				dev-python/sphinx[python_targets_python3_12(-)]
				dev-python/sphinx-rtd-theme[python_targets_python3_12(-)]
			)
		)
	)
"

EPYTEST_PLUGINS=( pytest-lazy-fixtures )

PATCHES=(
	"${FILESDIR}/parselmouth-0.4.7-docs-conf.patch"
	"${FILESDIR}/parselmouth-0.4.7-pytest-lazy-fixtures.patch"
	"${FILESDIR}/parselmouth-0.4.7-tests-no-future.patch"
)

distutils_enable_sphinx docs
distutils_enable_tests pytest

# Override distutils_enable_sphinx's check to ensure python_setup ONLY selects a target that
# Parselmouth was actually compiled for.
python_check_deps() {
	use "python_targets_${EPYTHON//./_}" || return 1
	python_has_version "dev-python/sphinx[${PYTHON_USEDEP}]" && \
	python_has_version "dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]" && \
	python_has_version "dev-python/nbsphinx[${PYTHON_USEDEP}]"
}

python_compile_all() {
	if use doc; then
		local -x PYTHONPATH="$(echo "${S}-${EPYTHON//./_}"/build0/lib.*):${PYTHONPATH}"
		sphinx_compile_all
	fi
}

python_test() {
	local -x PYTHONPATH="$(echo "${BUILD_DIR}"/build0/lib.*):${PYTHONPATH}"
	epytest tests
}
