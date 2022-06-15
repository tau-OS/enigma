Name:           enigma
Version:        1.0
Release:        1%{?dist}
Summary:        A simple text editor.

License:        GPLv3
URL:            https://tauos.co

Source0:        %{NAME}-%{VERSION}.tar.gz
Source1:        README.md
Source2:        COPYING

Requires:       gtk4
Requires:       libhelium
Requires:       gstreamer1

BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gtk4)
BuildRequires:  pkgconfig(gee-0.8)
BuildRequires:  pkgconfig(gmodule-2.0)
BuildRequires:  libhelium-devel

BuildRequires:  desktop-file-utils
BuildRequires:  gettext-devel
BuildRequires:  meson
BuildRequires:  vala
BuildRequires:  git

%description
A simple text editor.

%prep
%autosetup

%build
%meson \
    --wrap-mode=default
%meson_build

%install
%meson_install

# Install licenses
mkdir -p licenses
install -pm 0644 %SOURCE1 licenses/LICENSE

install -pm 0644 %SOURCE2 README.md

rm -rf %{buildroot}%{_bindir}/blueprint-compiler

%files
%{_bindir}/co.tauos.Enigma
%{_datadir}/glib-2.0/*
%{_datadir}/icons/*
%{_datadir}/metainfo/*
%{_datadir}/applications/*
%doc README.md
%license licenses/LICENSE

%changelog
* Tue Jun 14 2022 Jamie Murphy <jamie@fyralabs.com> - 1.0-1
- Initial Release
