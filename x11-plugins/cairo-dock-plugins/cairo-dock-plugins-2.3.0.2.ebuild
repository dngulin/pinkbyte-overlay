# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit cmake-utils eutils versionator

MY_PN="${PN/plugins/plug-ins}"
MY_PV=$(replace_version_separator 3 '~')
MM_PV=$(get_version_component_range '1-2')
MMD_PV=$(get_version_component_range '1-3')

DESCRIPTION="Official plugins for cairo-dock"
HOMEPAGE="https://launchpad.net/cairo-dock-plug-ins/"
SRC_URI="http://launchpad.net/${MY_PN}/${MM_PV}/${MMD_PV}/+download/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa compiz exif gio gmenu gnome kde mail musicplayer network-monitor powermanager terminal tomboy webkit wifi xfce xgamma xklavier"

# "dbus-glib-1"
# "gthread-2.0" - glib
# "libxml-2.0"
# "librsvg-2.0"
# "dbus-1"
# "cairo"
# "gtk+-2.0"
# "gtkglext-1.0"
# "cairo-dock"

RDEPEND="
	dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libxml2
	gnome-base/librsvg
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	~x11-misc/cairo-dock-${PV}

	alsa? ( media-libs/alsa-lib )
	exif? ( media-libs/libexif )
	gmenu? ( gnome-base/gnome-menus )
	kde? ( kde-base/kdelibs )
	terminal? ( x11-libs/vte )
	webkit? ( >=net-libs/webkit-gtk-1.0 )
	xfce? ( xfce-base/thunar )
	xgamma? ( x11-libs/libXxf86vm )
	xklavier? ( x11-libs/libxklavier )
"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	epatch "${FILESDIR}/${P}-sandbox.patch"
}

# Additional config options
#dnd2share
#rssreader
#xrandr-in-show-desktop
#scooby-do
#src_configure() {
#	econf --disable-dependency-tracking       \
#		--disable-old-gnome-integration       \
#		$(use_enable alsa  alsa-mixer)        \
#		$(use_enable compiz compiz-icon)      \
#		$(use_enable exif)                    \
#		$(use_enable gio gio-in-gmenu)        \
#		$(use_enable gio gmenu)               \
#		$(use_enable gmenu)                   \
#		$(use_enable gnome gnome-integration) \
#		$(use_enable kde kde-integration)     \
#		$(use_enable mail)                    \
#		$(use_enable musicplayer)             \
#		$(use_enable network-monitor)         \
#		$(use_enable powermanager)            \
#		$(use_enable terminal)                \
#		$(use_enable tomboy)                  \
#		$(use_enable webkit weblets)          \
#		$(use_enable wifi)                    \
#		$(use_enable xfce  xfce-integration)  \
#		$(use_enable xgamma)                  \
#		$(use_enable xklavier keyboard-indicator)
#}
