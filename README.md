# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

Homomorphic encryption scheme is a kind of encryption scheme that allow performing basic operation on cipher text:
- Addition
- Subtraction
- Multiplication
- Division

## Todo

* [x] Convert public key into human-friendly form.
* [x] Write encrypt function
* [x] Write decrypt function
* [x] Convert plaintext or binary data into bit as a input for encryption/decryption process
* [x] Allow using string as input
* [x] Write an API gateway that allow RPC and/or load balancing
* [ ] Write addition function
* [ ] Write subtraction function
* [ ] Write multiplication function
* [ ] Write division function


## Installation (Ubuntu/Debian)

### Install SageMath

```
apt-add-repository -y ppa:aims/sagemath
apt-get update
apt install sagemath-upstream-binary
apt-get install python2.7 python-pip
```

### Install Python libraries

```
apt-get install zlib1g-dev
pip install binascii
pip install tornado
pip install importlib
sage -pip install bitarray
```

If you already upgraded pip to version `10.0.1`, you may see this error when calling pip

```
Traceback (most recent call last):
  File "/usr/bin/pip", line 9, in <module>
    from pip import main
ImportError: cannot import name main
```

The only solution is getting back to version `9.0.3`

```
python -m pip install --user --upgrade pip==9.0.3
```

### Disable security warning

Add `export PYTHONWARNINGS="ignore:not adding directory '' to sys.path"` into `.bashrc`

## Run

```
sage bgn.sage
mv bgn.sage.py bgn.py
sage web.py
```

or

```
./runme.sh
```

## Performance at 512 key length (5% error, increase linearly)

### Key pair generation

> These numbers are in real CPU time. User CPU time is about 20 percent smaller.

* `~18` seconds on `i7-6820HQ` (single core run at 3.6 GHz max)
* `~15` seconds on `Xeon E5-2676 v3` (single core run at 3 GHz max)
* `~23` seconds on `Xeon E5-2650 v4` (single core run at 2.9 GHz max)
* `~30` seconds on `Xeon X5650` (single core run at 3.06 GHz max) (vCPU model is kvm64)
* `~19` seconds on `Xeon X5650` (single core run at 3.06 GHz max) (vCPU model is host-passthrough)
* `~16` seconds on `Xeon E5-2670` (single core run at 3.3 GHz max)
* `~17` seconds on `Xeon E5-2683 v3` (single core run at 3 GHz max)
* `~25` seconds on `Xeon E5-2683 v3` (single core run at 3 GHz max) (vCPU model is kvm64)
* `~17` seconds on `Xeon E5-2683 v3` (single core run at 3.06 GHz max) (vCPU model is host-passthrough)

### Encryption

Each byte in plaintext take `~0.33` second to encrypt (measure on i7-6820HQ, single thread).

### Decryption

Each byte in ciphertext take `~0.48` second to decrypt (measure on i7-6820HQ, single thread).

### Size

Each byte in plaintext cost `~5030` bytes in cipher text.


## Sample output at 512 key length

```
[Public key] 1588 bytes 
H4sIAOBDDFsC/y2Ux3EDMQxFW/Hs2QfkUIvG/bfhh7V1kCiSIPAD8HlUw9JEKiTMNNXKfdXEWMX6SMyqd5lrhEp2RJaubKxthm0RbOFbHqUzpvwGkSVTvNLFmU82++M1mtnmvF8+s+NpxoOlObGEba94p+SqqC9bGm2tG2RsTZFpocyxZD+D3JIVJpM55kLKkBRWXlyvql7SjBoxM+460qpVG6l+79VujhYogdULap3Uak8VOPEBWU4P8NsmI8qf76/P0/E+REzDhTd1wdbWcAtw1DwTFKbTTSyseh25RsWQ2sYB9W7zpnFa3JYasRaRfdnIo2Z33Y+rHGdLFrzbVmATngwXTprKkcnlxHGkcUNOFCi08FdhG5IiovAlbENLVXZz3OgURyAiUSNcQQJCh4/Fy/eRRC4WvBFK3dqpgUhwy926asMKaVN5LrNSBg4SdM0l3pfBWAp3T9m4om/uJPwMeBchEAkmWpr6IW3N4KYa8Q49xGR4Lsddep4pbHlliBv8G79kAkHjZlU7vwBMCxWhqtK2qR/CgztHOPbSxrHx56H0SCxngXME41viLgpf+C5ODIx+QDDyEo83E3Noo7xgAsIwMq+NDyacxA9nv0yH1g28z4WENzZdVBXqqCxtWO4095BmaRE6DfgrqIt0fJIMR50+P2e+QwcZBmqvhXZsgYF76mzPUllJ4vFNxbNkQG+jKVHlYlDxLR9H91l+p64hcMfbHU4ADgQI9NCh6MQBt48vbFl7kwBnyOWh4tu8Su/RPBBFa6A3oApiiEXFtCouolU7/eXHA0akW3NQjahEcQx1aqCSnHWAAZWQiRUYNDQJQqE8uDEsSZCmE6lUF+4DvRwxHH8AXPrlCD6aUfC6b87zclbDv6cQlZbRljdfGBHEB15ljN1go2sAe43qi/kQBfdz+5r1Gg4+AzLtRh7NLheH44JF3S7/oulq5k0zRFDUabNMO2VATn8xW2/sOHV28NxlK7zPdpMSLwnsM0MJgwz6JM7hJD3lbozVddCJSIKbvH010wN4qxARzodhQDcz343mnII6OAULLrpgIuglGkDrnc/8g3BjWJKqYV7/3ffzC6x6m/80BgAA

[Private key] 155 bytes 
H4sIAOBDDFsC/xWNwREAQQjCWgJFwf4bu70XjyQDeVU6FiReazJLMsqdt1OZrB6Ulj/tydVFa8e1Lna3bmi/0ph9c927GTaA2HVC+m4wei7WYavgTRaqUQr3P8MM8nzRH0FSxQ6bAAAA

[Plain text] 15 bytes 
Nguyen Quoc Bao

[Cipher text] 75840 bytes 
H4sIAO5DDFsC/+2b0XFdIQwFW3EB7wNJIKAWT/pvI4tTRCaTnXzYjt8DIS3nSNf293d09OjssUaerpgxVq2Tc43I3WefuWre5JPdfQffjTh39unedXP13WPdrrXmunPX3nd1de6z5p68vOKuwZLd58bdNddbu3ecM6syxp69WDtP8MnIqjPuzsmGse6eeWauGDNvreSFOeYZbM3S+/a9OW7E5gR116kZzf5xat2Mmjmiok+u2cX7bw9eyEaRFau6R+wdEeud6wW5c2eNsyJ63l53BafaK++5hL9J0e1cWfvzdQ4rxhyVJ99x4wy+irPrzA7S8bJaY3CMJtLDfrM4+OmYM0lD7r0XQc3RlZyCV3Cae2ovth3UYLMWJ+GQl4zOMeaYk6hPjaQKs3IM3kxcRDXfJkRBLHPFnsX5iICFR9xXuri8isRN6rnIKTm+d7IdSaICd9Tc42WbrBJiUeVJeOQrOzK7Se+4RSLIH1U/K9kq4SeJBpCKf69QBE2Rz0ODaAbLbYggqMzKz1f8+nx9k/PJN6k1OWdVPmZcKKvR/TJAjkGDpdgJjjg8iLAvkb96cRAOSN0GZyC4TaLh4OwLcwvQeOlLGHyxC1hwuPvenw/Z89J4+6HK2+CeIlNldlkgTuJ52+N6rdHxqsqum3xc8g9cuVmDD11j8z/zEVf54GczMsvOEfcFXH1OAyegHWpL4aGJAoA/OSWcd7e4RXWKgKgedSNwtu5H1rsBHHVxFyo2SNbnizvJpbwFr4dNH9TcEU4Iu+SR7GQvvurgeBBBbm68+7n63YsoTs+aoMCu6xADaYocKw9fRtXbjjS9e05581CLn+v8UGX1sR/47zZvynDz1YFg3m16BwHLdZ4QsCik3JeiwcXqfSjheDeNtCU73YcAC9e7p0T8IkMEavMqwuOCgP1CIXJAQXCdyRYFhpRThzMmTJ21KeyGkFc22CapB2K4lfDM7R/vIv4k7g936p169zf0Tu7kTp/VZ/8Xn5U7uZM7uXOusL+zv3OukDvnCn1Wn7W/kzv7O31Wn7W/kzv7O31Wn7W/kzu5kzvnCvs7+zv7O/VOn5U7uZM7ubO/s7+zv7O/U+/UO/VOvVPv1Dv1Tr1T79Q79c7nKHInd3Ind3Ind84VzhXOFf6+sdw5z+qz+qw+q96pd+qdeuc8K3f6rD7rPCt3cmd/p8/qs+qdeqfeqXfqnXqn3ql36p3P7+RO7vRZfVafVe/0WbmTO7mTO/s7+zv7O38+K3dyJ3dy5zxrf2d/p96pd/qs3Mmd3Mmd3Mmd3Mmd3Mmd3PkcxecoPkdR79Q79U69U+/UO/XOuULu5E7u5M7+zv7O/k69U+/UO/XOv6+QO7mTO7mzv7O/s79T79Q79U69U+/UO/VOvVPv1Dv1Tr2TO7nTZ/VZfVa9U+/0WbmTO7mTO7mTO+cK5wrnCucK9U6flTu502f1Wf+eTO7kTu7kzrnC/s65Qu7kzrlCn7W/kzu5s7/TZ/VZ9U6902flTu7kTu7kTu7kTu7kTu7kzucoPkfxOYp6p97ps3Ind3Ind3Ind84VzhXOFc4V6p0+K3f6rD6rz/p77nJnf6fP6rP2d3Ind3Ind3Ind86zzhXOFc4V6p16p96pd3Ind/qsPqvPqnfqnT4rd3Ind3Ind3L373H36zdiNbJBQCgBAA==
```

## Notes

### SageMath

* [Sage Documentation - Constructions](http://doc.sagemath.org/html/en/constructions/index.html)
* [Sage Documentation - A Tour of Sage](http://doc.sagemath.org/html/en/a_tour_of_sage/index.html)
* [Sage Documentation - Installation](http://doc.sagemath.org/html/en/installation/index.html)

### Tools

* [Random text generator](http://www.randomtextgenerator.com/)
* [Text-Binary Conversion](http://www.online-toolz.com/tools/text-binary-convertor.php)
* [Base Conversion](https://www.mathsisfun.com/binary-decimal-hexadecimal-converter.html)

### Links

* [Convert string to list of bits and viceversa
](https://stackoverflow.com/questions/10237926/convert-string-to-list-of-bits-and-viceversa)
* [Compress and extract string using gzip](https://gist.github.com/Garrett-R/dc6f08fc1eab63f94d2cbb89cb61c33d)
* [Ubuntu - SAGE](https://help.ubuntu.com/community/SAGE)
* [Python Operator Overloading](http://thepythonguru.com/python-operator-overloading/)
* [Online Python](https://www.tutorialspoint.com/execute_python_online.php)
* [Project bitarray](https://pypi.org/project/bitarray/)
* [Python - Built-in Exceptions](https://docs.python.org/2/library/exceptions.html)
