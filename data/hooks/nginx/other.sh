#!/bin/bash
# vim:sw=4:ts=4:et

set -e

 genserver() {
       sslDir="/etc/ssl/mail/$1"
       server_name=$2;
       if [[ ! -d "${sslDir}" ]]; then
             sslDir=/etc/ssl/mail; 
       fi
     
      {  echo -en 'server {
             include /etc/nginx/conf.d/listen_plain.active;
             include /etc/nginx/conf.d/listen_ssl.active;
              if ($client_req_scheme = http) {
                   return 301 https://$host$request_uri;
             }
            
             ssl_certificate '${sslDir}'/cert.pem;
            ssl_certificate_key '${sslDir}'/key.pem;
        
            
            server_name '${server_name}';
            include /etc/nginx/conf.d/includes/'${3}'.conf;
      } ' ; } | tee > /etc/nginx/conf.d/${1}.conf
 }

 if [[ -n  "${MAILCOW_HOSTNAME}" ]]; then
        
          genserver ${MAILCOW_HOSTNAME} "${MAILCOW_HOSTNAME}" "sogo-mail";

 fi

 if [[ -n "${BACKEND_SERVER_NAME}" ]]; then
       genserver ${BACKEND_SERVER_NAME} "${BACKEND_SERVER_NAME} autodiscover.* autoconfig.*" "mail-admin";

 fi



for cert_dir in /etc/ssl/mail/*/ ; do
   echo $cert_dir;
  if [[ ! -f ${cert_dir}domains ]] || [[ ! -f ${cert_dir}cert.pem ]] || [[ ! -f ${cert_dir}key.pem ]]; then
    continue
  fi
  # do not create vhost for default-certificate. the cert is already in the default server listen
  domains="$(cat ${cert_dir}domains | sed -e 's/^[[:space:]]*//')"
  domain=${domains%%[[:space:]]*};
  case "${domains}" in
    "") continue;;
    "${MAILCOW_HOSTNAME}"*) continue;;
    "${BACKEND_SERVER_NAME}"*) continue;;
  esac
   { echo -n '
server {
  include /etc/nginx/conf.d/listen_ssl.active;
  ssl_certificate '${cert_dir}'cert.pem;
  ssl_certificate_key '${cert_dir}'key.pem;
';
  echo -n '
  server_name '${domains}';
  include /etc/nginx/conf.d/includes/'${domain}'.conf;
}
' ; } | tee > /etc/nginx/conf.d/${domain}.conf
done