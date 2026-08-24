# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="An extension for Tk to read SVG images based on nanosvg"
HOMEPAGE="https://github.com/tcltk-depot/tksvg"
SRC_URI="https://github.com/tcltk-depot/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="tcltk"
SLOT="0"
KEYWORDS="~amd64"
IUSE="threads"

RDEPEND="
	=dev-lang/tcl-8*:=
	=dev-lang/tk-8*:=
"
DEPEND="${RDEPEND}"

src_configure() {
	econf $(use_enable threads)
}
