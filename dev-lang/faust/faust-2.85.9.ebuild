# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHECKREQS_DISK_BUILD="800M"
# LLVM 22 support coming >2.85.9? https://github.com/grame-cncm/faust/pull/1232
LLVM_COMPAT=( {17..21} )
LLVM_OPTIONAL=1
PYTHON_COMPAT=( python3_{10..15} )

inherit cmake llvm-r2 check-reqs python-single-r1 optfeature

DESCRIPTION="Functional programming language for signal processing and sound synthesis"
HOMEPAGE="https://github.com/grame-cncm/faust https://faust.grame.fr/"
SRC_URI="https://github.com/grame-cncm/${PN}/releases/download/${PV}/${P}.tar.gz"
LICENSE="LGPL-2.1+"
# TODO: not sure if we need to subslot, use `SLOT="0/${PV}"` if update breaks shared ABI
SLOT="0"
KEYWORDS="~amd64"

# TODO: test compile with no backends selected?
backends_default=( as c cmajor codebox cpp csharp dlang java jax julia jsfx \
	oldcpp rust sdf3 vhdl wasm )
backends_other=( fir interp llvm )

IUSE="
	${backends_default[@]/#/+faust_backends_}
	${backends_other[@]/#/faust_backends_}
	doc machine +osc +shared static-libs test +webui
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	faust_backends_llvm? ( ${LLVM_REQUIRED_USE} )
"

RESTRICT="!test? ( test )"

DEPEND="
	faust_backends_llvm? ( $(llvm_gen_dep 'llvm-core/llvm:${LLVM_SLOT}=') )
	webui? ( net-libs/libmicrohttpd:= )
"

RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
"

BDEPEND="
	>=dev-build/cmake-3.7.2
	media-libs/libpng
	virtual/pkgconfig
"

CMAKE_USE_DIR="${S}/build"

pkg_setup() {
	check-reqs_pkg_setup
	python-single-r1_pkg_setup

	if use faust_backends_llvm; then
		llvm-r2_pkg_setup
	fi
}

src_prepare() {
	cmake_src_prepare

	# Unneeded Windows script
	rm -f "${S}/tools/faust2appls/faust2wwise.cmd" || die

	# Fix generator scripts to source helpers from /usr/libexec instead of PATH
	local helper_dir="${EPREFIX}/usr/libexec/faust"
	local f
	for f in "${S}"/tools/faust2appls/*; do
		if [[ -f "${f}" ]]; then
			sed -i \
				-e "s|APPNAME=\`filename2ident |APPNAME=\`${helper_dir}/filename2ident |g" \
				-e "s|^\. usage\.sh|. \"${helper_dir}/usage.sh\"|g" \
				-e "s|^\. faustpath|. \"${helper_dir}/faustpath\"|g" \
				-e "s|^\. faustoptflags|. \"${helper_dir}/faustoptflags\"|g" \
				"${f}" || die
		fi
	done

	# Repair broken upstream PNG asset if it exists
	f="${S}/architecture/iOS/iOS/close.png"
	if [[ -f "${f}" ]]; then
		pngfix --out="${f}.tmp" "${f}"
		mv "${f}.tmp" "${f}"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DHTTPDYNAMIC=$(usex webui $(usex shared))
		-DINCLUDE_DYNAMIC=$(usex shared)
		-DINCLUDE_EXECUTABLE=ON
		-DINCLUDE_HTTP=$(usex webui)
		-DINCLUDE_ITP=$(usex machine)
		-DINCLUDE_LLVM_STATIC_IN_ARCHIVE=OFF
		-DINCLUDE_OSC=$(usex osc)
		-DINCLUDE_STATIC=$(usex static-libs)
		-DIOS=OFF
		-DITPDYNAMIC=$(usex machine $(usex shared))
		-DLIBSDIR="$(get_libdir)"
		-DLINK_LLVM_STATIC=OFF
		-DOSCDYNAMIC=$(usex osc $(usex shared))
		-DTEMPLATE_BACKEND=OFF
	)

	local b_targets="COMPILER"
	use shared && b_targets+=";DYNAMIC"

	# Gentoo hasn't supported static LLVM linking for a long time
	# (see https://wiki.gentoo.org/wiki/Project:LLVM/LLVM_10_packaging_changes)
	mycmakeargs+=( "-DLLVM_BACKEND=$(usex "faust_backends_llvm" "${b_targets}" "OFF")" )

	if use faust_backends_llvm && use static-libs; then
		ewarn "Note: libfaustwithllvm.a will not be built."
		ewarn "(Static linking with libLLVM is unsupported on Gentoo.)"
	fi

	use static-libs && b_targets+=";STATIC"

	local b
	for b in "${backends_default[@]}" "${backends_other[@]}"; do
		if [[ "${b}" == "llvm" ]]; then continue; fi
		mycmakeargs+=( "-D${b^^}_BACKEND=$(usex "faust_backends_${b}" "${b_targets}" "OFF")" )
	done

	cmake_src_configure
}

src_test() {
	# Note: most tests directories contain suites that are unmaintained, abandoned and broken.
	# On their GitHub Actions they only run impulse-tests and jax-tests.
	# Only the impulse-tests is found in the stable release (for now).
	# We can use that, but it's impractical to comprehensively run most/all tests in it.
	# That takes hours, needs >10GB disk free. So instead we just do a minimum set.

	rm -rf tests/impulse-tests/ir
	emake -C tests/impulse-tests filesCompare

	# This is modified from default found in tests/impulse-tests/Make.gcc, to compile faster.
	# If tests are failing, check that everything after our optimisation flags ('-pipe -O0 -g0')
	# matches the default (sans '-O3').
	local gcc_opt="-pipe -O0 -g0 -I../../architecture -I/usr/local/include/ap_fixed -Iarchs -pthread -std=c++11"

	emake -C tests/impulse-tests -f Make.gcc outdir=cpp/double lang=cpp arch=impulsearch.cpp \
		FAUSTOPTIONS="-I dsp -double" GCCOPTIONS="${gcc_opt}"
}

src_install() {
	cmake_src_install

	# Remove precompiled binary blobs from /usr/share and /usr/lib(64).
	# Doing this here rather than in src_prepare, cos Faust's CMake script is a fragile baby and
	# needs to install this crap first, otherwise it will cry and error out our build. I can't be
	# arsed to patch it, so we just clean up the poop afterwards.
	find "${ED}/usr/share" -type f \( -name "*.a" -o -name "*.so" \) -delete || die
	rm -rf "${ED}/usr/$(get_libdir)"/ios-* || die

	# Move internal shell helpers from /usr/bin into /usr/libexec.
	dodir /usr/libexec/faust
	local f
	for f in "${ED}"/usr/bin/{usage.sh,faustpath,faustoptflags,filename2ident}; do
		if [[ -f "${f}" ]]; then
			mv -v "${f}" "${ED}/usr/libexec/faust/" || die
		fi
	done

	python_fix_shebang "${ED}"/usr/bin

	if [[ -d "${S}/documentation/man/man1" ]]; then
		doman "${S}"/documentation/man/man1/*
	fi

	if use doc; then
		dodoc documentation/*.pdf
		[[ -d "${S}/documentation/misc" ]] && dodoc documentation/misc/*.pdf
	fi
}

pkg_postinst() {
	# Audio Drivers & Server Backends
	optfeature "ALSA audio architecture support" media-libs/alsa-lib
	optfeature "JACK audio architecture support" virtual/jack
	optfeature "PipeWire audio architecture support" media-video/pipewire
	optfeature "PulseAudio driver support" media-libs/libpulse
	optfeature "PortAudio driver support" media-libs/portaudio
	optfeature "RtAudio driver support" media-libs/rtaudio

	# Graphical Interface & Vision Toolkits
	optfeature "GTK3 graphical interface targets" x11-libs/gtk+:3
	optfeature "Qt graphical interface targets" dev-qt/qtbase:6
	optfeature "OpenCV video-driven UI control targets" media-libs/opencv

	# Audio File & Network Processing
	optfeature "Soundfile audio sample reading/writing" media-libs/libsndfile
	optfeature "Sample rate conversion for soundfiles" media-libs/libsamplerate
	if use osc; then
		optfeature "OSC (Open Sound Control) network support" media-libs/liblo
	fi

	# Plugin Architectures
	optfeature "LV2 plugin architecture targets" media-libs/lv2
	optfeature "LADSPA plugin architecture targets" media-libs/ladspa-sdk
	optfeature "DSSI plugin architecture targets" media-libs/dssi
	optfeature "Pure Data external targets" media-sound/pure-data
	optfeature "VST/LV2 template support" dev-libs/boost
}
