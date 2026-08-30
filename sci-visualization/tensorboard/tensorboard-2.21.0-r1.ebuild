# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
inherit python-r1 pypi

DESCRIPTION="Web apps for inspecting/understanding TensorFlow runs and graphs"
HOMEPAGE="https://github.com/tensorflow/tensorboard https://www.tensorflow.org/tensorboard"
SRC_URI="$(pypi_wheel_url)"
S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

# Todo: tensorboard-data-server package, (requires only Rust/Cargo build)

RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/absl-py-0.4[${PYTHON_USEDEP}]
	dev-python/bleach[${PYTHON_USEDEP}]
	>=dev-python/google-auth-1.6.3[${PYTHON_USEDEP}]
	>=dev-python/google-auth-oauthlib-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/grpcio-1.74.0[${PYTHON_USEDEP}]
	>=dev-python/markdown-2.6.8[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.12.0[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/protobuf-6.31.1[${PYTHON_USEDEP}]
	>=dev-python/setuptools-41.0.0[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	>=dev-python/werkzeug-1.0.1[${PYTHON_USEDEP}]
	virtual/allow-pypi-wheels
"

BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	dev-python/installer[${PYTHON_USEDEP}]
	virtual/allow-pypi-wheels
"

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_install() {
	install_wheel() {
		python -m installer --overwrite-existing --destdir="${D}" "${WORKDIR}/${A}" || die
		python_optimize
	}

	python_foreach_impl install_wheel
}
