#
# SignalK Server recipe modifications
#
# - add modifications to recipe generated by recipetool here.
#

# Disable lockdown because of missing checksums
NPM_SHRINKWRAP = ""
NPM_LOCKDOWN = ""

# Add runtime dependency to bash for all recipe's packages
RDEPENDS_${PN} = "nodejs bash openssl"
RDEPENDS_${PN}-js-quantities = "bash"
RDEPENDS_${PN}-leaflet = "bash"
RDEPENDS_${PN}-superagent = "bash"
RDEPENDS_${PN}-pem = "bash"

# Add systemd configuration
inherit systemd

SRC_URI += "file://signalk.service"
SRC_URI += "file://signalk.socket"

SYSTEMD_SERVICE_${PN} = "signalk.service"

# Add default configuration
SIGNALK_CONFIGDIR = "/home/root/.signalk"

SRC_URI += "file://defaults.json"
SRC_URI += "file://package.json"
SRC_URI += "file://settings.json"
SRC_URI += "file://security.json"
SRC_URI += "file://signalk-server"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/signalk.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/signalk.socket  ${D}${systemd_system_unitdir}

    install -d ${D}${SIGNALK_CONFIGDIR}
    install -m 0644 ${WORKDIR}/defaults.json  ${D}${SIGNALK_CONFIGDIR}
    install -m 0644 ${WORKDIR}/package.json   ${D}${SIGNALK_CONFIGDIR}
    install -m 0644 ${WORKDIR}/settings.json  ${D}${SIGNALK_CONFIGDIR}
    install -m 0744 ${WORKDIR}/security.json  ${D}${SIGNALK_CONFIGDIR}
    install -m 0744 ${WORKDIR}/signalk-server ${D}${SIGNALK_CONFIGDIR}
}

FILES_${PN} += "${SIGNALK_CONFIGDIR}/*"
FILES_${PN} += "${systemd_system_unitdir}/*"
