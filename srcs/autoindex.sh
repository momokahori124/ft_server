if test "${AUTOINDEX}" = "off" ; then
	sed -i -e "s/autoindex on;/autoindex off;/" /etc/nginx/sites-available/default
fi
