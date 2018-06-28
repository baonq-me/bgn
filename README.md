# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

Homomorphic encryption scheme is a kind of encryption scheme that allow performing basic operation on cipher text:
- Encryption
- Decryption
- Addition
- Subtraction
- Multiplication
- Division (will never be implemented)

## Todo

* [x] Convert public key into human-friendly form.
* [x] Write encrypt function
* [x] Write decrypt function
* [x] Convert plaintext or binary data into bit as a input for encryption/decryption process
* [x] Allow using string as input
* [x] Write an API gateway that allow RPC and/or load balancing
* [x] Write addition function
* [x] Write subtraction function
* [x] Write multiplication function
* [ ] Write division function (will never be implemented)
* [ ] Running on multi threads
* [ ] Web API (working on)


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
./runme.sh
```

## Web API

### Generate key pairs

Updating ...

## Performance at security parameter 512bit (size of prime number is 256bit, 20% error)

> Measured on i7-6820HQ, single thread. These numbers are in real CPU time. User CPU time is 20 percent smaller.

### Key pair generation

`~20` seconds on `i7-6820HQ` (single core run at 3.6 GHz max)

### Encryption

`~3.1` second to encrypt a number in range [-2^31,2^31-1]

### Decryption

`~9.1` second to decrypt a number in range [-2^31,2^31-1]. Smaller the absolute value of the number, faster the decryption process.

### Sample output

```
[Public key] 709 bytes 
H4sIAGDGNFsC/82TyY1cMQxEUzH67AO34hKLMfmn4aeZi0MwGh8NSRRZm/58Ns0vtbudVorNkveoe9eyJ9YjPOTqirrcG6+NSbNqefgojuO0OJXndWRwZpppTVvV5OaK9arPaMx+RHZnepj24liMvd4lut7MuX9+//pkKm/D7syoiAMcDfsG1HTK9fake6efgJ3F8VnQcvk/3/V9GDsva6JsZuLeKufRC5vKtwnv8jPkyJFv6m7WxvmqC84JuPHekOzxSgD++STi9EB97LiXaKOpuqiAMNPRZE8oBWpKoAwdOZ393a16amlkqwA/K+QxCtQUIWoMBbtQsg4/r6PSkKVXhiWOG5fMUdJyC7Fym0LFj4Rzayh2pqofuWy72oJdxx1kUCEOoqwykSqhMZq9p/0zcpnNqeMrXg16aIlG4scrZa5XD3xwHzFUjENJUKu5Qb4wy0W13p3yoXXr4fPP19PxO0cHkn1hAJu9KygYe7AKdE0ZzqIhQCZs/ajCHNuCU6V/5xGbM5hizTyw4jTMyKPBeZARftUdZN1JFIACr57Z12vPTYJ9ExhNZ4SK24czCvMPOwr8h+p1sBxikc99Uo8dCxzyMz7EE5cKkDmIFcL8giOv6kWqyRc54nUApV8KYP5coOJE/HkOPL9mKJI/lVviHdXS6/tHVi6oYWr7P0La//5u4vP19ReV0EikeAQAAA==


[Private key] 1521 bytes 
H4sIAGDGNFsC/9VTx5LiSBD9lY2+9kaoTGaZwxxoPEJIeFoTe6AxDajxIBBfv087X7EXSVWql/lM1u+3Fl3blWat2Wtcq4FTo+JTLqL+sz5+tYytxJo2YTda7w80X6VbET2aG9cbDgbpPmDXu4r89nVfTo6XXpavjiu/Kjr+c5fEo/P2clk0zXtv+NU7r9bfx909FnFndlhOB4/0dDqNJvmE43no55dkHj3fB630sDrtFP1so3xJP/ebje4z/x4EpyzcBzV7LY7bSrSora9N2RqFfj3PVgaVO7rhJof+Is8CHUx8s3bN56ZzTe/dVXhfD6qch7fHIXe7JCs6jdzs7fSZ789VR5170lpl8es5/K69vw9HW1//8La7nc3D+HQ/o1svGaR1d/yYnsJj5bGMU+31XJr5/ic7PypB+N5/Vm/9cXt6jD6+bv3rNwUXkwyzcDLbbKdxk9fReNkpqrZR7EW3saPBa15s1Ol8XN+nhVXHzvL5lNm4Wo+P50eRDc+bKD37UyBei9MBxkWX2Tf6tX+adF1c0jnPavr5aL0a41291xmHd+5/0aMQU6lPujjOZhdaJ4n0yTMWi1Z2kJtK5+7D4vtzZSvhsi7S17m96VfTazDfVVu9e3VsJgE/m18Rb7avUfGg3SgqwuRjlVYG69t4mfZkp9GuVC9sU6nyZPTZ8fXnppfSMFS0eFXzKIkfF7d5P8nrx3ObLbwfH92y+nwV0cvW67wIs9q+3Vh03fc2zk02PReDBdNhXDlNXPiZ8OIYd+pBK4uTrt+HnXbwM8m3reVsaIJba7I1x8/pxSaiOw8CvlMOeYPVRNS32arSr1Qqv369/f3Xm5RSWKWUE6ylkISVJm2UYum1JscKb0HKktZKWLZSW4e19jjtvPGGSHshPBE7jYq/34xxwAktJLNTqOU0a1JKO68YlUk51hpgZYB0yqKKJyesdxonLPAAOJZWKhzS0mglsTLE1knBiqT0ouRniQwpYpaslTVOOesBcc574RmdUddLS8Z4dgKS7B/JZPGtpZeAWiPR1kkmLa33ng0LIyxOk7Sghm2U9M5ISLRMrGz513mrvXFwgTV7qQ2zIalAl6QB4RIqoNkQahrBxsJDnAZNTd4q6zSWymsHty2IM2FH+Ld//g8WKiWM1QIi4YtUBiaWLZQpx8VKCTmlnxoGa+8VkWAi1FWOjNbaKSkteAkYwAJknJOGMHnwWRB2GLmQYZxiKWCyF2hvMWUCZayQmFhoNcoojT5GwlKGnwypmv5YKEkIKqMCbYkDmFiA4IoEzNry6cuR1eALxqXZAjlqfBNaIk4BSqBgyiARRokiBktQRHrClyYCBMcF9MBFPJEs4BI/HcFZKTQ0GMPwyaKaRnoIgP7zEDJFGaXQhCQg0ZQqfUkCZTGD1inl4a1WuHqlaw6XTVqNfHD9MHYYOI2pkUqW3K3jcoEratnBJo+4FTo7FC5llPcc4Ut2UMMYDGCw4bwALdwHTKcvhxXcufTwDTOt8fUvv1jtF+0GAAA=


[Plain text] An integer in range [-2^31,2^31-1]
15091996

[Cipher text] 265 bytes 
H4sIAAvHNFsC/x2Oy20EAQhDW4nmnIPBYEMtq+2/jTARB8TH9vs80eu2yohSOAc2phMmNzyJGnZR6EzI01V3yy6g1uNcINSdMX1N7FNVBycnTLUb1Te42duL04cGjY3EKmjlDCJuu9zb5TE5dvH8/jzJweLVL4Jr0WfhPHFlj2d3uLxZh/3CMo7mEiyUOUb+57G29Dq1a3kekoY6VF1FBjJ38r6yScne7QDrdTRaKvE+DjEPtCKpFzCe7x/VDxIsRwEAAA==
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
* [curl POST examples](https://gist.github.com/subfuzion/08c5d85437d5d4f00e58)

### Links

* [Convert string to list of bits and viceversa
](https://stackoverflow.com/questions/10237926/convert-string-to-list-of-bits-and-viceversa)
* [Compress and extract string using gzip](https://gist.github.com/Garrett-R/dc6f08fc1eab63f94d2cbb89cb61c33d)
* [Ubuntu - SAGE](https://help.ubuntu.com/community/SAGE)
* [Python Operator Overloading](http://thepythonguru.com/python-operator-overloading/)
* [Online Python](https://www.tutorialspoint.com/execute_python_online.php)
* [Project bitarray](https://pypi.org/project/bitarray/)
* [Python - Built-in Exceptions](https://docs.python.org/2/library/exceptions.html)
