# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

Homomorphic encryption scheme is a kind of **asymmetric encryption scheme** that allow performing basic operation on **cipher text**:
- Addition
- Subtraction
- Multiplication
- Division (will never be implemented in this project because of its complexity)

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

### Install SageMath (binary package is available for Ubuntu/Debian)

```
apt-add-repository -y ppa:aims/sagemath
apt-get update
apt install sagemath-upstream-binary
apt-get install python2.7 python-pip
```

### Compiling SageMath

Follow instructions at [Sage Installation Guide - Install from Source Code](http://doc.sagemath.org/html/en/installation/source.html)

Estimated time: 10 hours (tested on i7-6820HQ using 8 threads)

### Installing python libraries

```
apt-get install zlib1g-dev
pip install binascii
pip install tornado
pip install importlib
pip install tornado
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

Add `export PYTHONWARNINGS="ignore:not adding directory '' to sys.path"` into `~/.bashrc`

## Run

```
./runme.sh
```

## Web API

### Generate key pairs

* Endpoint (your local machine): `http://localhost:8080/api/genkey`
* Endpoint (our server with LB and FW): `https://bgn.rainteam.xyz/api/genkey`
* Method: POST
* Params: length (key length, vary from 64 to 1024)
* Output: pkey (public key), skey (private key), length (size of key), time (time taken to process)

#### Example

Generating keys

```
curl -d '{"length": "64"}' -H "Content-Type: application/json" -X https://bgn.rainteam.xyz/api/genkey
```

```
{"status": "success", "pkey": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "skey": "H4sIAGVWNlsC/32Ny1LCQBBFf8WatVXOTPc8eokYMlAkODzCq1igEESRCgRD4OsZdG/vbt8698yZw7LdiLNxuiubTzDuDc7Fi/eb6Fh33mfkTmASqyoz2UaJlN7362576XRs/DC9fMssmZV701nO3lIfT4fZGvjeddo4rT9Xz7JbRVFTF5PRIW8Vp5bcr0aGcr/buTRbH7LJKO5tk+tXVG3yj1j64+o0OJd1hVHuoFD96+vP5bAZd10jHHt8YKC0BjJCiZDmTIJGTkITAFkjjCZt8V4xIUAbSYaIE4JAZSkUi/8hEMIarpXkCBzRgJao9R8lCG0gyaIkRQQEyO2vKbxQKiVNsIjgkmHB3iGmlQLFFjf1g7N3YwEAAA==", "process": "genkey", "length": "64", "time": "0.17", "msg": "", "data": ""}
```

### Crypt (Encryption and Decryption)

* Endpoint (your local machine): `https://bgn.rainteam.xyz/api/crypt`
* Endpoint (our server with LB and FW): `https://bgn.rainteam.xyz/api/crypt`
* Method: POST
* Params: op ("encrypt" and "decrypt"), key (use public key to encrypt and private key to decrypt), data
* Output: time (time taken to process) and data

#### Examples

Encrypt a number 2018

```
curl -d '{"key": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "op": "encrypt", "data": "2018"}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/crypt
```

```
{"status": "success", "process": "encrypt", "time": "0.01", "data": "H4sIALZZNlsC/xXJsQ2AQAwDwFVQago7Nok8C2L/NdBfe2/1etjRA2sVANq47quS2N6mPKDAnvQJ1vcDsfW2LzgAAAA=", "msg": ""}
```

Encrypt another number 2019

```
curl -d '{"key": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "op": "encrypt", "data": "2019"}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/crypt
```

```
{"status": "success", "process": "encrypt", "time": "0.01", "data": "H4sIADhaNlsC/xXJwQ2AMAwDwFVQ3jxqmzjuLIj916i4773FZtZgJJvLEyNg3VcJD7p7b0GmpTjRP6jvAF0GM6A5AAAA", "msg": ""}
```

Decrypt a number. Result is 2018
```
curl -d '{"key": "H4sIAGVWNlsC/32Ny1LCQBBFf8WatVXOTPc8eokYMlAkODzCq1igEESRCgRD4OsZdG/vbt8698yZw7LdiLNxuiubTzDuDc7Fi/eb6Fh33mfkTmASqyoz2UaJlN7362576XRs/DC9fMssmZV701nO3lIfT4fZGvjeddo4rT9Xz7JbRVFTF5PRIW8Vp5bcr0aGcr/buTRbH7LJKO5tk+tXVG3yj1j64+o0OJd1hVHuoFD96+vP5bAZd10jHHt8YKC0BjJCiZDmTIJGTkITAFkjjCZt8V4xIUAbSYaIE4JAZSkUi/8hEMIarpXkCBzRgJao9R8lCG0gyaIkRQQEyO2vKbxQKiVNsIjgkmHB3iGmlQLFFjf1g7N3YwEAAA==", "op": "decrypt", "data": "H4sIALZZNlsC/xXJsQ2AQAwDwFVQago7Nok8C2L/NdBfe2/1etjRA2sVANq47quS2N6mPKDAnvQJ1vcDsfW2LzgAAAA="}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/crypt
```

```
{"status": "success", "process": "decrypt", "time": "6.42", "data": "2018", "msg": ""}
```

### Operations (Addition, Substraction and Multiplication)

* Endpoint (your local machine): `http://localhost:8080/api/op`
* Endpoint (our server with LB and FW): `https://bgn.rainteam.xyz/api/op`
* Method: POST
* Params: op ("add", "sub" and "mul"), key (public key), data1 and data2
* Output: time (time taken to process) and data

#### Examples

Add two numbers (2018 and 2019). Run your own command to decrypt it :D

```
curl -d '{"key": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "op": "add", "data1": "H4sIALZZNlsC/xXJsQ2AQAwDwFVQago7Nok8C2L/NdBfe2/1etjRA2sVANq47quS2N6mPKDAnvQJ1vcDsfW2LzgAAAA=", "data2": "H4sIADhaNlsC/xXJwQ2AMAwDwFVQ3jxqmzjuLIj916i4773FZtZgJJvLEyNg3VcJD7p7b0GmpTjRP6jvAF0GM6A5AAAA"}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/op
```

```
{"status": "success", "process": "add", "time": "0.02", "data": "H4sIAE1aNlsC/x3JsQ3AMAgEwFUsahfPYx6YJcr+azhKcdU9RnkJnUJheqqTxbC9zDFUSJ8QDzLP9B/2XlNADXQ4AAAA", "msg": ""}
```

Substract two numbers (2018 and 2019). Run your own command to decrypt it :D

```
curl -d '{"key": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "op": "sub", "data1": "H4sIALZZNlsC/xXJsQ2AQAwDwFVQago7Nok8C2L/NdBfe2/1etjRA2sVANq47quS2N6mPKDAnvQJ1vcDsfW2LzgAAAA=", "data2": "H4sIADhaNlsC/xXJwQ2AMAwDwFVQ3jxqmzjuLIj916i4773FZtZgJJvLEyNg3VcJD7p7b0GmpTjRP6jvAF0GM6A5AAAA"}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/op
```

```
{"status": "success", "process": "sub", "time": "0.23", "data": "H4sIAIBgNlsC/xXJsQ0AIRADwVZeF3+AbbgztSD6bwNIVhrtChhTTLv3BC8GKMX/BamcDXKNG5vlbPUOYh8JzATvOQAAAA==", "msg": ""}
```

Multiply two numbers (2018 and 2019). Run your own command to decrypt it :D

```
curl -d '{"key": "H4sIAGVWNlsC/3WOSwpDQQgErxJcZ9Ht37M85v7XiEM22QQRxLIaH6G7QTNym2VMZsn7JaZbNQGYTVe30nHJI4YxjdB2LvEEC6pXUqfFptF2ndU79fQllHNVeqVXUGOiMzkEvgfhG2QrdtSwsxv4EfH3p5RzPuyqgWLHAAAA", "op": "mul", "data1": "H4sIALZZNlsC/xXJsQ2AQAwDwFVQago7Nok8C2L/NdBfe2/1etjRA2sVANq47quS2N6mPKDAnvQJ1vcDsfW2LzgAAAA=", "data2": "H4sIADhaNlsC/xXJwQ2AMAwDwFVQ3jxqmzjuLIj916i4773FZtZgJJvLEyNg3VcJD7p7b0GmpTjRP6jvAF0GM6A5AAAA"}' -H "Content-Type: application/json" -X POST https://bgn.rainteam.xyz/api/op
```

```
{"status": "success", "process": "mul", "time": "0.03", "data": "H4sIAJRaNlsC/w3D0Q2AUAgDwFUM3348oC10FuP+a+gl90QSsyw2W4ZgFXrivqLOJOYvH61XVjLj/QCwtT40NAAAAA==", "msg": ""}
```

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
* [Docs - Tornado Web Server](http://www.tornadoweb.org/en/stable/index.html)
