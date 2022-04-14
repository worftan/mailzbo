#!/bin/bash
 DOCUMENT_ROOT=${DOCUMENT_ROOT:-"/data/websites"}
 PHP_DIR="/usr/local/etc";
 CUSTOM_FPM_CONF_DIR="php-fpm-custom.d";
 SOCKET_DIR="/dev/shm/php/$FPM_USER"

  if [[ ! -d "${SOCKET_DIR}" ]]; then
      echo -e "create soket dir ${SOCKET_DIR}\n"
      mkdir -p $SOCKET_DIR && chown -R $FPM_USER.$FPM_GROUP $SOCKET_DIR
  fi

   if [[ -f "${PHP_DIR}/php-fpm.conf" ]]; then
         mkdir -p ${PHP_DIR}/${CUSTOM_FPM_CONF_DIR};
  
   fi


config_mstp()
{
	EMAIL_HOST=${EMAIL_HOST:-"smtp.qq.com"}
	EMAIL_PORT=${EMAIL_PORT:-587}
  SMTP_TLS=${SMTP_TLS:-on}
	msmtprc_file=${SMTP_ETC_FILE:-"/etc/msmtprc"};
	  {
   	echo "# Set defaults."
	echo "defaults"
	echo 	"# Enable or disable TLS/SSL encryption."
	echo 	"tls ${SMTP_TLS}"
	echo 	"tls_starttls off"
	echo 	"tls_trust_file /etc/ssl/certs/ca-certificates.crt"
	echo 	"# Set up a default account's settings."
	echo 	"account default"
	 echo    "host ${EMAIL_HOST}"
	echo 	"port ${EMAIL_PORT}"
	echo 	"auth login"
	echo 	"user ${EMAIL_USER}"
	echo 	"password ${EMAIL_PASSWD}"
	echo 	"from  ${EMAIL_ADDRESS}"
	echo 	"logfile /var/log/msmtp/msmtp.log"
    }  > $msmtprc_file
    mkdir -p /var/log/msmtp
     chown ${FPM_USER}:${FPM_GROUP} /var/log/msmtp
     chmod 600  $msmtprc_file
     chown ${FPM_USER}:${FPM_GROUP} $msmtprc_file
}


  [[ "$EMAIL_USER" != "" ]] && [[ "$EMAIL_PASSWD" != "" ]] && [[ "$EMAIL_ADDRESS" != "" ]] && config_mstp;

if [[ ! -d "$DOCUMENT_ROOT" ]]; then
   echo -e "create dir ${DOCUMENT_ROOT}\n"
   mkdir -p $DOCUMENT_ROOT
fi

# Run hooks
for file in /hooks/*.sh; do
  if [ -x "${file}" ]; then
    echo "Running hook ${file}"
    "${file}"
  fi
done

exec "$@"