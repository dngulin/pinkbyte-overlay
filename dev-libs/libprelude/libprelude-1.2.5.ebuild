# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DISTUTILS_OPTIONAL=1
GENTOO_DEPEND_ON_PERL="no"
PYTHON_COMPAT=( python2_7 )
inherit autotools distutils-r1 eutils flag-o-matic multilib perl-module

DESCRIPTION="Prelude-IDS Framework Library"
HOMEPAGE="http://www.prelude-technologies.com"
SRC_URI="https://www.prelude-ids.org/attachments/download/351/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc lua perl python"

RDEPEND=">=dev-libs/libgcrypt-1.1.94
	>=net-libs/gnutls-1.0.17
	lua? ( dev-lang/lua )
	perl? ( dev-lang/perl )
	python? ( ${PYTHON_DEPS} )"

DEPEND="${RDEPEND}
	sys-devel/flex
	perl? ( dev-lang/swig )"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DISTUTILS_PATHS="bindings/low-level/python bindings/python"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-ruby.patch \
		"${FILESDIR}"/${P}-ptrdiff_t.patch

	# Avoid null runpaths in Perl bindings.
	sed -e 's/ LD_RUN_PATH=""//' -i bindings/Makefile.am bindings/low-level/Makefile.am || die "sed failed"

	# Python bindings are built/installed manually.
	sed -e "/^SUBDIRS =/s/ python//" -i bindings/low-level/Makefile.am bindings/Makefile.am || die "sed failed"

	# Autoconf script with wrong name
	mv configure.in configure.ac || die

	# Do not install docs if it's not requested
	if ! use doc; then
		 sed -i -e '/SUBDIRS/s/api //' docs/Makefile.am || die
	fi

	epatch_user
	eautoreconf
}

src_configure() {
	filter-lfs-flags

	# SWIG is needed to build Perl high-level bindings.
	# Ruby bindings building need to be reworked, disabled for now
	econf \
		--enable-easy-bindings \
		--without-ruby \
		$(use_with lua) \
		$(use_with perl) \
		$(use_with perl swig) \
		$(use_with python)
}

python_compile() {
	for i in ${DISTUTILS_PATHS}; do
		pushd $i 2>/dev/null || die
		distutils-r1_python_compile
		popd 2>/dev/null
	done
}

src_compile() {
	emake OTHERLDFLAGS="${LDFLAGS}"

	use python && distutils-r1_src_compile
}

python_install() {
	for i in ${DISTUTILS_PATHS}; do
		pushd $i 2>/dev/null || die
		distutils-r1_python_install
		popd 2>/dev/null
	done
}

src_install() {
	emake DESTDIR="${D}" INSTALLDIRS=vendor install
	prune_libtool_files --all

	if use perl; then
		perl_delete_localpod
		perl_delete_packlist
	fi

	use python && distutils-r1_src_install
}
