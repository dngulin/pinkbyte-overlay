# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

# Maintainer notes: Take a look at http://xmlrpc-c.sourceforge.net/release.html
# We use "stable" branch, so for the current release revision take look here:
# http://xmlrpc-c.svn.sourceforge.net/viewvc/xmlrpc-c/stable/version.mk?view=log
# e.g. for 1.33.12 corresponds following revision 2605.
# Now, export it through subversion:
# $ svn export -r 2605 http://svn.code.sf.net/p/xmlrpc-c/code/stable xmlrpc-c-1.33.12
# Pack directory into tarball and distribute on mirrors.
# It's possible to build net-libs/libwww without ssl support, but taking into
# account that libwww is not really well maintained and upstream is dead we
# better use it only in case ssl is required.

DESCRIPTION="A lightweigt RPC library based on XML and HTTP"
HOMEPAGE="http://xmlrpc-c.sourceforge.net/"
SRC_URI="http://dev.gentoo.org/~pinkbyte/distfiles/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x86-fbsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="abyss +cgi +curl +cxx +libxml2 static-libs threads test tools"

REQUIRED_USE="
	test? ( abyss curl cxx static-libs )
	tools? ( curl )"

DEPEND="
	sys-libs/ncurses
	sys-libs/readline
	curl? ( net-misc/curl )
	libxml2? ( dev-libs/libxml2 )"

RDEPEND="${DEPEND}"

pkg_setup() {
	use curl || ewarn "Curl support disabled: No client library will be built"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.32.05-Wimplicit.patch
	sed -i \
		-e "/CFLAGS_COMMON/s|-g -O3$||" \
		-e "/CXXFLAGS_COMMON/s|-g$||" \
		common.mk || die

	# Respect the user's LDFLAGS.
	export LADD="${LDFLAGS}"

	if ! use static-libs; then
		sed -e '/\(^TARGET_STATIC_LIBRARIES =\)/{s:\(^TARGET_STATIC_LIBRARIES =\).*:\1:;P;N;d;}' \
			-i common.mk || die
	fi

	epatch_user
}

src_configure() {
	#Disable libwww support due GBZ #409549 and #320253

	econf \
		--disable-wininet-client \
		$(use_enable libxml2 libxml2-backend) \
		--disable-libwww-client \
		--without-libwww-ssl  \
		$(use_enable threads abyss-threads) \
		$(use_enable cgi cgi-server) \
		$(use_enable abyss abyss-server) \
		$(use_enable cxx cplusplus) \
		$(use_enable curl curl-client)
}

src_compile() {
	emake
	use tools && emake -C tools
}

src_install() {
	default_src_install
	use tools && emake DESTDIR="${D}" -C tools install
}

src_test() {
	unset LDFLAGS LADD SRCDIR
	cd "${S}"/test/
	einfo "Building general tests"
	make || die "Make of general tests failed"
	einfo "Running general tests"
	./test || die "General tests failed"
	cd "${S}"/test/cpp/
	einfo "Running C++ tests"
	./test || die "C++ tests failed"
}
