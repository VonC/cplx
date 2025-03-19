%echo Generating cplx OpenPGP key
Key-Type: RSA
Key-Length: 4096
Name-Real: cplx
Name-Email: cplx@acme.com
Expire-Date: 0
Passphrase: cplx is key
%pubring cplx.pub
%secring cplx.sec
%commit
%echo cplx OpenPGP key generation done