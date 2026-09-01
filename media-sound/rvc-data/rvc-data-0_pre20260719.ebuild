# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs

DESCRIPTION="Model weights and feature extractors for RVC"
HOMEPAGE="https://huggingface.co/lj1995/VoiceConversionWebUI"

HF_SRC="https://huggingface.co/lj1995/VoiceConversionWebUI/resolve"
GH_SRC="https://github.com/aetha/blobage/releases/download/${PN}"

SRC_URI="
	hubert-base? ( ${GH_SRC}/rvc-hubert_base-1be9d36.tar.xz )
	mute? ( ${HF_SRC}/f4ccd85380cf07c20c5a5b663a579f06a51ae953/mute.zip -> rvc-mute-f4ccd85.zip )
	pretrained? ( ${GH_SRC}/rvc-pretrained-b9addeb.tar.xz )
	pretrained-v2? ( ${GH_SRC}/rvc-pretrained_v2-b7e44b2.tar.xz )
	rmvpe? ( ${GH_SRC}/rvc-rmvpe-0d7ebae.tar.xz )
	uvr5-weights? ( ${GH_SRC}/rvc-uvr5_weights-fa1b500.tar.xz )
"
#	pymss-weights? ( ${GH_SRC}/rvc-pymss_weights-3a7e7d2.tar.xz )
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+hubert-base mute pretrained pretrained-v2 +rmvpe uvr5-weights"
# TODO: seperate rmvpe-pt & rmvpe-onnx use flags?
# TODO: add pymss-weights flag after next RVC release - bump to 0_pre20260722?

BDEPEND="mute? ( app-arch/unzip )"

set_check_reqs_limits() {
	local space_mb=100

	use hubert-base   && (( space_mb += 181 ))
	use pretrained    && (( space_mb += 1047 ))
	use pretrained-v2 && (( space_mb += 1242 ))
	#use pymss-weights && (( space_mb += 1917 ))
	use rmvpe         && (( space_mb += 518 ))
	use uvr5-weights  && (( space_mb += 474 ))

	# Round up space_mb to the nearest 100 MB ceiling
	space_mb=$(( (space_mb + 99) / 100 * 100 ))

	CHECKREQS_DISK_USR="${space_mb}M"
	CHECKREQS_DISK_BUILD="${space_mb}M"
}

pkg_pretend() {
	set_check_reqs_limits
	check-reqs_pkg_pretend
}

pkg_setup() {
	set_check_reqs_limits
	check-reqs_pkg_setup
}

src_install() {
	insinto /usr/share/rvc
	[[ -d assets ]] && doins -r assets

	insinto /usr/share/rvc/logs
	[[ -d mute ]] && doins -r mute
}
