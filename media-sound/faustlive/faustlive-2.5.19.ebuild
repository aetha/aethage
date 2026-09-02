# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {17..21} )

inherit cmake llvm-r2 wrapper xdg

DESCRIPTION="Self-contained prototyping environment for the Faust DSP language"
HOMEPAGE="https://github.com/grame-cncm/faustlive"
SRC_URI="https://github.com/grame-cncm/${PN}/releases/download/${PV}/FaustLive-${PV}.tar.gz"
S="${WORKDIR}/FaustLive-${PV}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa doc jack netjack pipewire portaudio"
REQUIRED_USE="^^ ( alsa jack netjack pipewire portaudio )"

RDEPEND="
	dev-lang/faust[faust_backends_llvm,osc,shared,webui,${LLVM_USEDEP}]
	dev-qt/qtbase:6[gui,network,widgets]
	media-libs/libsndfile
	net-libs/libmicrohttpd:=
	net-misc/curl
	$(llvm_gen_dep 'llvm-core/llvm:${LLVM_SLOT}=')
	alsa? ( media-libs/alsa-lib )
	jack? ( virtual/jack )
	netjack? ( virtual/jack )
	pipewire? ( media-video/pipewire[jack-sdk] )
	portaudio? ( media-libs/portaudio )
"

DEPEND="${RDEPEND}"

BDEPEND="virtual/pkgconfig"

CMAKE_USE_DIR="${S}/Build"

src_configure() {
	local audio_backend
	use alsa      && audio_backend="alsa"
	use jack      && audio_backend="jack"
	use netjack   && audio_backend="netjack"
	use pipewire  && audio_backend="jack"
	use portaudio && audio_backend="portaudio"

	local mycmakeargs=(
		-DAUDIO="${audio_backend}"
		-DQT6=ON
		-DREMOTE=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use pipewire; then
		dodir /usr/libexec
		mv "${ED}/usr/bin/FaustLive" "${ED}/usr/libexec/FaustLive" || die
		make_wrapper FaustLive "pw-jack ${EPREFIX}/usr/libexec/FaustLive"
	fi

	if use doc; then
		mv "${ED}"/usr/share/doc/faustlive/* "${ED}/usr/share/doc/${PF}" || die
	fi

	rm -rf "${ED}/usr/share/doc/faustlive" || die
}
