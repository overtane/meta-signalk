# Configure Avahi with Bonjour compatibility library
EXTRA_OECONF_append = " --enable-compat-libdns_sd"

# libdns-sd package
PACKAGES += " libdns-sd"

FILES_libdns-sd += " ${libdir}/libdns_sd.so.*"

FILES_libdns-sd-native += " ${libdir}/libdns_sd.so.*"
FILES_libdns-sd-native += " ${includedir}/dns_sd.h"

# add build-time headers for mnds node build
do_install_append() {
    install -d ${D}${includedir}/avahi-compat-libdns_sd
    cd ${D}${includedir}
    ln -s avahi-compat-libdns_sd/dns_sd.h dns_sd.h
}

# Install to native
BBCLASSEXTEND = "native"

