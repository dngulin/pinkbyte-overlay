# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

GENTOO_DEPEND_ON_PERL="no"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit autotools distutils eutils perl-module

DESCRIPTION="Prelude-IDS framework for easy access to the Prelude database"
HOMEPAGE="http://www.prelude-siem.com"
SRC_URI="https://www.prelude-ids.org/attachments/download/352/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc mysql postgres perl python sqlite"

RDEPEND=">=dev-libs/libprelude-${PV}
	mysql? ( virtual/mysql )
	perl? ( dev-lang/perl )
	postgres? ( dev-db/postgresql-server )
	sqlite? ( =dev-db/sqlite-3* )"

DEPEND="${RDEPEND}
	dev-util/gtk-doc-am
	doc? ( dev-util/gtk-doc )"

DISTUTILS_SETUP_FILES=("bindings/python|setup.py")
PYTHON_MODNAME="preludedb.py"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${P}-ldflags.patch"

	# Avoid null runpaths in Perl bindings.
	sed -e 's/ LD_RUN_PATH=""//' -i bindings/Makefile.am || die

	# Python bindings are built/installed manually.
	sed \
		-e "s/^python: python-build/python:/" \
		-e "/cd python && \$(PYTHON) setup.py install/d" \
		-i bindings/Makefile.am || die

	# Autoconf script with wrong name
	mv configure.in configure.ac || die

	# Do not install docs if it's not requested
	if ! use doc; then
		 sed -i -e '/SUBDIRS/s/api //' docs/Makefile.am || die
	fi

	rm m4/gtk-doc.m4 || die

	epatch_user
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable doc gtk-doc) \
		$(use_with mysql) \
		$(use_with postgres postgresql) \
		$(use_with sqlite sqlite3) \
		$(use_with perl) \
		$(use_with python)
}

src_compile() {
	emake

	if use python; then
		distutils_src_compile
	fi
}

src_install() {
	emake -j1 DESTDIR="${D}" INSTALLDIRS=vendor install
	prune_libtool_files --all

	if use perl; then
		perl_delete_localpod
		perl_delete_packlist
	fi

	if use python; then
		distutils_src_install
	fi
}

pkg_postinst() {
	if use python; then
		distutils_pkg_postinst
	fi

	elog "For additional installation instructions go to"
	elog "https://www.prelude-ids.org/wiki/prelude/InstallingPreludeDbLibrary"
}

pkg_postrm() {
	if use python; then
		distutils_pkg_postrm
	fi
}
