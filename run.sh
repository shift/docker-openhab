if [ -z "${OPENHAB_CONF_REPO}" ]
then
  echo "Please define OPENHAB_CONF_REPO with a URL"
  exit 1
fi

if [ -z "${OPENHAB_ETC_REPO}" ]
then
  echo "Please define OPENHAB_ETC_REPO with a URL"
  exit 1
fi

if [ -z "${CHECKOUT_PRIVATEKEY}" ]
then
  echo "Please define CHECKOUT_PRIVATEKEY with a URL"
  exit 1
fi

if [ -z "${OPENHAB_SECRET}" ]
then
  echo "Please define OPENHAB_SECRET with a URL"
  exit 1
fi

if [ -z "${OPENHAB_UUID}" ]
then
  echo "Please define OPENHAB_UUID with a URL"
  exit 1
fi

export JAVA_HOME=/opt/jdk7
export PATH=$PATH:$JAVA_HOME/bin
wget -O /etc/privatekey $CHECKOUT_PRIVATEKEY
mkdir /root/.ssh
ssh-keyscan github.com >> /root/.ssh/known_hosts
ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

wget -O /etc/ca.pem https://www.startssl.com/certs/ca.pem
$JAVA_HOME/bin/keytool -import -trustcacerts -noprompt -keystore $JAVA_HOME/jre/lib/security/cacerts -alias StartCom-Root-CA -file /etc/ca.pem -storepass changeit


chmod 0600 /etc/privatekey
rm -rf /srv/openhab/runtime/configurations
ssh-agent bash -c 'ssh-add /etc/privatekey; git clone $OPENHAB_CONF_REPO /srv/openhab/runtime/configurations'
rm -rf /srv/openhab/runtime/etc
ssh-agent bash -c 'ssh-add /etc/privatekey; git clone $OPENHAB_ETC_REPO /srv/openhab/runtime/etc'
echo $OPENHAB_UUID >  /srv/openhab/runtime/webapps/static/uuid
echo $OPENHAB_SECRET >  /srv/openhab/runtime/webapps/static/secret
rm -rf /srv/openhab/runtime/addons
ln -s /srv/openhab/addons-available /srv/openhab/runtime/addons
rm -rf /srv/openhab/runtime/addons/*sonos*
exec /srv/openhab/runtime/start_debug.sh
