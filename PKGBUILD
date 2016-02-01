# Maintainer: Joakim Reinert <mail+aur@jreinert.com>

pkgname=ketchup-git
pkgver=
pkgrel=1
pkgdesc='a pomodoro timer using client <-> server architecture'
arch=(any)
url='https://github.com/jreinert/ketchup'
licence=('MIT')
depends=(libpcl)
makedepends=(crystal-git)

source=("${pkgname}::git+https://github.com/jreinert/ketchup.git")
sha512sums=(SKIP)
provides=('ketchup')
conflicts=('ketchup-bin')

pkgver() {
  cd "$pkgname"
  git describe --tags | sed 's/^v//;s/-/./g'
}

build() {
  make -C "$pkgname"
}

package() {
  make -C "$pkgname" PREFIX=/usr DESTDIR="$pkgdir" install
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

# vim:set ts=2 sw=2 et:
