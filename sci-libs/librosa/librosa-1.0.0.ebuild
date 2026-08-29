# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for audio and music analysis"
HOMEPAGE="https://github.com/librosa/librosa https://librosa.org"
SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+display"

RDEPEND="
	>=dev-python/decorator-5.2.1[${PYTHON_USEDEP}]
	>=dev-python/joblib-1.2[${PYTHON_USEDEP}]
	>=dev-python/lazy-loader-0.3[${PYTHON_USEDEP}]
	>=dev-python/msgpack-1.0.5[${PYTHON_USEDEP}]
	>=dev-python/numba-0.61.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/pooch-1.7[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.6.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.15.0[${PYTHON_USEDEP}]
	>=dev-python/soundfile-0.12.1[${PYTHON_USEDEP}]
	>=dev-python/soxr-1.0.0[${PYTHON_USEDEP}]
	display? ( >=dev-python/matplotlib-3.10.0[${PYTHON_USEDEP}] )
"

# TODO: add test dependencies when ebuilds become available
#		>=dev-python/resampy-0.4.3[${PYTHON_USEDEP}]
#		dev-python/samplerate[${PYTHON_USEDEP}]
BDEPEND="
	test? (
		${RDEPEND}
		>=dev-python/matplotlib-3.10.0[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	)
"

# TODO: docs support needs ebuilds for mir_eval, presets, dev-python/umap-learn
#   + patch out deps? sphinxcontrib-svg2pdfconverter, sphinxcontrib-googleanalytics
#distutils_enable_sphinx docs \
#	>=dev-python/ipython-7.0
#	>=dev-python/matplotlib-3.10.0
#	>=dev-python/myst-parser-2.0
#	>=dev-python/numpydoc-1.8.0
#	>=dev-python/pandas-2.0
#	>=dev-python/pydata-sphinx-theme-0.18.0
#	>=dev-python/sphinx-copybutton-0.5.2
#	>=dev-python/sphinx-design-0.7.0
#	>=dev-python/sphinx-gallery-0.7

distutils_enable_tests pytest

# # Skip tests requiring resampy and samplerate packages
# EPYTEST_DESELECT=(
# 	tests/test_audio.py::test_resample_resampy
# 	tests/test_audio.py::test_resample_samplerate
# )

python_test() {
	local epytest_args=(
		# Override setup.cfg addopts to disable mandatory coverage checks (--cov)
		-o "addopts="
		# Exclude optional resampler backends (resampy & samplerate) and network downloads
		-k "not kaiser and not sinc and not linear and not zero_order_hold and not example and not cite and not loadx"
	)

	epytest "${epytest_args[@]}"
}
