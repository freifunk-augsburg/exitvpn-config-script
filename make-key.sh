#!/bin/sh

if [ ! -f ./vars ]; then
	echo "You need to install these files into an easy-rsa folder!"
	exit
fi

if [ -z "$1" -o -z "$2" ]; then
	echo "Please specify two parameters: common name and email"
	exit
fi

name="$1"
mail="$2"

. ./vars > /dev/null
setupscript="configscript/hostscripts/${name}-exitvpn-setup.sh"

export KEY_EMAIL="$mail"

./build-key $1 || {
	echo "Building the key failed! Make sure easy-rsa is installed and working. Exiting."
	exit
}

cat configscript/template-checkdepencies.txt > $setupscript
cat configscript/template-setup.txt >> $setupscript

# Add openvpn config

echo "cat << EOF > /etc/openvpn/exitvpn/exitvpn.conf" >> $setupscript
cat configscript/template-ovpn.txt >> $setupscript
echo "cert /etc/openvpn/exitvpn/${name}.crt" >> $setupscript
echo "key /etc/openvpn/exitvpn/${name}.key" >> $setupscript
echo "EOF" >> $setupscript

# Add up script
echo "cat << EOF > /etc/openvpn/exitvpn/up.sh" >> $setupscript
cat configscript/template-up.txt >> $setupscript
echo "EOF" >> $setupscript

# Add down script
echo "cat << EOF > /etc/openvpn/exitvpn/down.sh" >> $setupscript
cat configscript/template-down.txt >> $setupscript
echo "EOF" >> $setupscript

# Add common functions
echo "cat << EOF > /etc/openvpn/exitvpn/functions.sh" >> $setupscript
cat configscript/template-functions.txt >> $setupscript
echo "EOF" >> $setupscript

echo "chmod +x /etc/openvpn/exitvpn/up.sh" >> $setupscript
echo "chmod +x /etc/openvpn/exitvpn/down.sh" >> $setupscript
echo "chmod +x /etc/openvpn/exitvpn/functions.sh" >> $setupscript

# Add ca.crt
echo "cat << EOF > /etc/openvpn/exitvpn/ca.crt" >> $setupscript
cat keys/ca.crt >> $setupscript
echo "EOF" >> $setupscript

# add host cert
echo "cat << EOF > /etc/openvpn/exitvpn/${name}.crt" >> $setupscript
cat keys/${name}.crt >> $setupscript
echo "EOF" >> $setupscript
echo "chmod 600 /etc/openvpn/exitvpn/${name}.crt" >> $setupscript

# add host key
echo "cat << EOF > /etc/openvpn/exitvpn/${name}.key" >> $setupscript
cat keys/${name}.key >> $setupscript
echo "EOF" >> $setupscript
echo "chmod 600 /etc/openvpn/exitvpn/${name}.key" >> $setupscript

# finally add some foo to restart services
cat configscript/template-servicerestart.txt >> $setupscript



