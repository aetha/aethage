EAPI=9
DESCRIPTION="An extension for Tk to read SVG images based on nanosvg"
HOMEPAGE="https://github.com/tcltk-depot/tksvg"
SRC_URI="https://github.com/tcltk-depot/tksvg/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="tcltk"
SLOT="0.17"
KEYWORDS="~amd64"
IUSE="threads"
RDEPEND="=dev-lang/tcl-8* =dev-lang/tk-8*"
DEPEND="${RDEPEND}"

src_configure() {
	econf $(use_enable threads)
}
