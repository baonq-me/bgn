# Somewhat homomorphic encryption over elliptic curve using BGN algorithm 

import json
import zlib
import base64

import gzip
import io
import binascii

# https://gist.github.com/Garrett-R/dc6f08fc1eab63f94d2cbb89cb61c33d
class Gzip():
	# Convert text into binary data with compression enable
	@staticmethod
	def compress(string_):
	    out = io.BytesIO()

	    with gzip.GzipFile(fileobj=out, mode='w') as fo:
	        fo.write(string_.encode())

	    bytes_obj = out.getvalue()

	    return bytes_obj
	    
	# Convert compressed binary data into original text
	@staticmethod
	def decompress(bytes_obj):
	    in_ = io.BytesIO()
	    in_.write(bytes_obj)
	    in_.seek(0)
	    with gzip.GzipFile(fileobj=in_, mode='rb') as fo:
	        gunzipped_bytes_obj = fo.read()

	    return gunzipped_bytes_obj.decode()

class BinAscii():
	@staticmethod
	def text2bin(data):
		return binascii.a2b_base64(data)
	
	@staticmethod
	def bin2text(data):
		return binascii.b2a_base64(data)

class BGN():
	def __init__(self, size):
		self.size = size

	def calcFp(self):
		#find a prime q such that q-1=0(mod N) (that is embedding degree k=1)

		self.p1 = self.randomPrime()
		self.p2 = self.randomPrime()
		self.n = self.p1 * self.p2

		n3 = 3 * self.n

		self.p = n3 - 1
		self.l = 1
		while is_prime(self.p) is False:
		    self.p = self.p + n3
		    self.l = self.l + 1

		self.Fp = GF(self.p)

		#print "P = " + str(self.p)
		#print "N = " + str(self.N)

	def calcExtFp(self):
		k = 2
		p2 = self.p^k
		FpE.<a> = GF(p2, proof = False)

	def initCurve(self, curve):
		self.E = EllipticCurve(self.Fp, curve)	# curve[0,1]: y^2 = x^3 + 1

	def randomPrime(self):
		return random_prime(2^self.size-1, True, 2^(self.size-1))

	def randomPoint(self):
		self.G = (3*self.l*self.E.random_point())	# P = (0,1,0)
		#print Q*self.N == self.E([0,1,0])
			
		self.U = int(1 + random() % 100) * self.G
		#print self.G
		#print self.U
		#print self.U*self.n

		self.H = self.p1 * self.U

	def genKey(self):
		self.calcFp()
		self.initCurve([0,1])
		self.calcExtFp()
		self.randomPoint()

		pkey = str(json.dumps([str(self.n), str(self.G), str(self.H)]))
		skey = str(self.p2)
		#print pkey

		pkey_compressed = BinAscii.bin2text(Gzip.compress(pkey))
		skey_compressed = BinAscii.bin2text(Gzip.compress(skey)) 

		#print pkey_compressed

		#pkey_restore = Gzip.decompress(BinAscii.text2bin(pkey_compressed))

		#print pkey_restore

		print "[Public key]\n" + pkey_compressed.replace('\n', '')
		print "\n[Private key]\n" + skey_compressed

		pkey_restore = Gzip.decompress(BinAscii.text2bin(pkey_compressed))
		skey_restore = Gzip.decompress(BinAscii.text2bin(skey_compressed))

		assert pkey_restore == pkey
		assert skey_restore == skey


if __name__ == '__main__':
	bgn = BGN(512)
	bgn.genKey()
