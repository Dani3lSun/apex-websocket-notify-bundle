!/bin/sh

echo "How many days should the certificate be valid?"
read certdays

if [ -z "$certdays"  ] ; then 
  $certdays=9999
fi

openssl genrsa -out key.pem 4096
openssl req -new -sha256 -key key.pem -out csr.pem
openssl x509 -req -sha256 -days $certdays -in csr.pem -signkey key.pem -out cert.pem
rm -f csr.pem
