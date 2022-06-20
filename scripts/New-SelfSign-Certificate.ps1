openssl req -new -newkey rsa:2048 -days 365 -nodes -x509  -keyout appcertificate.key  -out appcertificate.cert
cat appcertificate.cert appcertificate.key > appcertificatecombined.pem
openssl pkcs12 -export -out certificate.pfx -inkey appcertificate.key -in appcertificate.cert
rm ./appcertificate.cert ./appcertificate.key