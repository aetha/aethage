# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_12 )
inherit python-single-r1 wrapper desktop xdg

DESCRIPTION="Retrieval-based Voice Conversion: voice timbre conversion / voice changer"
HOMEPAGE="https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI"
SRC_URI="https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Retrieval-based-Voice-Conversion-WebUI-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa cuda +gui jack oss pipewire"
# TODO: add +webui when gradio package available

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	gui? ( || ( alsa jack oss pipewire ) )
"

RDEPEND="
	${PYTHON_DEPS}
	=media-sound/rvc-data-0*
	media-video/ffmpeg
	sci-libs/faiss[python,${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/hyper-connections-0.1.8[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/local-attention-1.11.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-2.4.1[cuda(-)?,${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchaudio-2.4.1[cuda(-)?,${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchfcpe-0.0.4[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchvision-0.19.1[cuda(-)?,${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.49.0[torch,${PYTHON_SINGLE_USEDEP}]
	x11-misc/lndir

	$(python_gen_cond_dep '
		>=dev-python/av-15.1.0[${PYTHON_USEDEP}]
		>=dev-python/coloredlogs-15.0[${PYTHON_USEDEP}]
		>=dev-python/ffmpeg-python-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/matplotlib-3.8.2[${PYTHON_USEDEP}]
		>=dev-python/networkx-3.2.0[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
		>=dev-python/scikit-learn-1.6.0[${PYTHON_USEDEP}]
		>=dev-python/scipy-1.13.1[${PYTHON_USEDEP}]
		>=dev-python/soundfile-0.13.0[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.67.0[${PYTHON_USEDEP}]
		media-libs/opencv[python,${PYTHON_USEDEP}]
		>=sci-libs/librosa-0.10.2[${PYTHON_USEDEP}]
		>=sci-libs/onnxruntime-1.18.0[python,${PYTHON_USEDEP}]
		>=sci-libs/parselmouth-0.4.5[${PYTHON_USEDEP}]
		>=sci-ml/einops-0.8.0[${PYTHON_USEDEP}]
		>=sci-visualization/tensorboard-2.19.0[${PYTHON_USEDEP}]
	')

	cuda? (
		dev-libs/cudnn
		dev-util/nvidia-cuda-toolkit
	)

	gui? (
		media-libs/portaudio[alsa?,jack?,oss?]

		$(python_gen_cond_dep '
			dev-python/freesimplegui[${PYTHON_USEDEP}]
			>=dev-python/sounddevice-0.5.0[${PYTHON_USEDEP}]
		')

		pipewire? (
			media-libs/portaudio[jack]
			media-video/pipewire[jack-sdk]
		)
	)
"
# TODO: add gradio deps when package available
# 	webui? (
# 		$(python_gen_cond_dep '
# 			>=dev-python/gradio-3.14.0[${PYTHON_USEDEP}]
# 			<dev-python/gradio-3.15[${PYTHON_USEDEP}]
# 		')
# 	)

src_prepare() {
	default

	rm -f *.bat || die
}

src_install() {
	insinto "/usr/share/${PN}"
	doins -r configs i18n infer tools train requirments*.txt *.py
	# (Note: "requirments" is *upstream* typo.)

	python_setup
	python_optimize "${ED}/usr/share/${PN}"

	exeinto "/usr/libexec/"
	newexe "${FILESDIR}/launcher.sh" "${PN}-launcher.sh"

	local launcher="${EPREFIX}/usr/libexec/${PN}-launcher.sh"
	sed -i -e "s|@EPREFIX@|${EPREFIX}|g" -e "s|@EPYTHON@|${EPYTHON}|g" -e "s|@PN@|${PN}|g" \
		-e "s|@EXAMPLES@|/usr/share/doc/${PF}/examples|g" "${D}${launcher}" || die

	if use gui; then
		make_wrapper rvc-gui "${launcher} realtime_gui.py"
		make_desktop_entry rvc-gui "RVC Realtime GUI" rvc AudioVideo
	fi

	# if use webui; then
	# 	make_wrapper rvc-webui "${EPYTHON} webui.py" ${share_dir}
	# fi

	# TODO: next stable release, add wrapper(s) for cli tools, see docs/en/cli.md
	#make_wrapper rvc-infer-cli "${EPYTHON} infer/cli.py" ${share_dir}
	#make_wrapper rvc-pymss-cli "${EPYTHON} -m tools.pymss.cli infer" ${share_dir}

	dodoc -r README.md docs/*

	# Remove default config from /usr/share/rvc/configs, put into doc examples instead.
	rm -f "${ED}/usr/share/${PN}/configs/config.json" || die
	docinto examples
	dodoc configs/config.json
	docompress -x "/usr/share/doc/${PF}/examples"
}
