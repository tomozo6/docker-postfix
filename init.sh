#!/bin/bash
# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
postconf -e "inet_protocols = ${INET_PROTOCOLS:=ipv4}"
postconf -e "mynetworks = ${MYNETWORKS:=127.0.0.0/8}"
postconf -e "mydestination = ${MYDESTINATION:=localhost}"

if [ -n "${RELAYHOST}" ]; then
    postconf -e "relayhost = ${RELAYHOST}"
fi

if [ -n "${TRANSPORT}" ]; then
    postconf -e "transport_maps = hash:/etc/postfix/transport"
    echo -e "${TRANSPORT}" > /etc/postfix/transport
    postmap /etc/postfix/transport
fi

# -----------------------------------------------------------------------------
# Domain
# -----------------------------------------------------------------------------
postconf -e "mydomain = ${MYDOMAIN}"
postconf -e "myorigin = ${MYORIGIN:=\$mydomain}"

if [ -n "${MYHOSTNAME}" ]; then
    postconf -e "myhostname = ${MYHOSTNAME}"
else
    postconf -e "myhostname = $(hostname).${MYDOMAIN}"
fi

# -----------------------------------------------------------------------------
# Envelope-From (Return-Path)
# -----------------------------------------------------------------------------
if [ -n "${ENVELOPE_FROM}" ]; then
    postconf -e "sender_canonical_classes = envelope_sender"
    postconf -e "sender_canonical_maps = regexp:/etc/postfix/canonical.regexp"
    echo ${ENVELOPE_FROM} > /etc/postfix/canonical.regexp
fi

# -----------------------------------------------------------------------------
# TLS
# -----------------------------------------------------------------------------
postconf -e "smtp_use_tls = ${SMTP_USE_TLS:=yes}"
postconf -e "smtp_tls_security_level = ${SMTP_TLS_SECURITY_LEVEL:=may}"
postconf -e "smtp_tls_note_starttls_offer = ${SMTP_TLS_NOTE_STARTTLS_OFFER:=yes}"

# -----------------------------------------------------------------------------
# SASL
# -----------------------------------------------------------------------------
if [ "${SASL_ENABLE}" == "yes" ]; then
    if [ -n "${SASL_PASSWD}" ]; then
        postconf -e "smtp_sasl_auth_enable = yes"
        postconf -e "smtp_sasl_security_options = noanonymous"
        postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
        echo ${SASL_PASSWD} >/etc/postfix/sasl_passwd
        chmod 600 /etc/postfix/sasl_passwd
        postmap /etc/postfix/sasl_passwd
    else
        echo "ERROR: SASL_ENABLE is defined 'yes' but SASL_PASSWD is not defined."
        exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Custom Header
# -----------------------------------------------------------------------------
if [ -n "${CUSTOM_HEADER}" ]; then
    postconf -e "smtp_header_checks=regexp:/etc/postfix/add_custom_header"
    echo "/^From:/ PREPEND ${CUSTOM_HEADER}" >/etc/postfix/add_custom_header
fi
