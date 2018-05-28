# Somewhat homomorphic encryption over elliptic curve using BGN algorithm 

import json
import zlib
import base64
import sys

import gzip
import io
import binascii

from bitarray import bitarray

CURVE = [0,1] #  y^2 = x^3 + 1


def random_between(j,k):
   a = int(random()*(k-j+1))+j
   return a


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
		self.n = None
		self.G = None
		self.H = None
		self.E = None

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

	def calcExtFp(self):
		k = 2
		p2 = self.p^k
		FpE.<a> = GF(p2, proof = False)	# Use pseudo primality test

	def initCurve(self, curve):
		self.E = EllipticCurve(self.Fp, curve)	# curve[0,1]: y^2 = x^3 + 1

	def randomPrime(self):
		return random_prime(2^self.size-1, True, 2^(self.size-1))	# Use true primality test

	def randomPoint(self):
		self.G = (3*self.l*self.E.random_point())	# G = (0,1,0)
		#print Q*self.N == self.E([0,1,0])
			
		self.U = int(1 + random() % 100) * self.G	# Create point U using G as a generator
		#print self.G
		#print self.U
		#print self.U*self.n

		self.H = self.p1 * self.U

	def genKey(self):
		self.calcFp()
		self.initCurve(CURVE)
		self.calcExtFp()
		self.randomPoint()

		pkey = json.dumps([
			str(self.n), 
			[str(self.G[0]), str(self.G[1]), str(self.G[2])], 
			[str(self.H[0]), str(self.H[1]), str(self.H[2])]
		])

		skey = str(self.p2)

		pkey_compressed = BinAscii.bin2text(Gzip.compress(pkey))
		skey_compressed = BinAscii.bin2text(Gzip.compress(skey)) 

		#print pkey_compressed

		#pkey_restore = Gzip.decompress(BinAscii.text2bin(pkey_compressed))

		#print pkey_restore

		#print "[Public key]\n" + pkey_compressed.replace('\n', '')
		#print "\n[Private key]\n" + skey_compressed

		return pkey_compressed, skey_compressed

		#pkey_restore = Gzip.decompress(BinAscii.text2bin(pkey_compressed))
		#skey_restore = Gzip.decompress(BinAscii.text2bin(skey_compressed))

		#assert pkey_restore == pkey
		#assert skey_restore == skey

	def setPublicKey(self, pkey):
		pkey_restore = json.loads(Gzip.decompress(BinAscii.text2bin(pkey)))

		self.n = int(pkey_restore[0])
		n3 = 3*n
		self.p = n3 - 1
		while is_prime(p) is False:
		    self.p = self.p + n3
		self.E = EllipticCurve(GF(self.p), CURVE)

		self.G = self.E([pkey_restore[1][0], pkey_restore[1][1], pkey_restore[1][2]])
		self.H = self.E([pkey_restore[2][0], pkey_restore[2][1], pkey_restore[2][2]])

	def setPrivateKey(self, skey):
		if (self.n is None) or (self.E is None) or (self.G is None) or (self.H is None):
			print 'Public key should be set first !'
			sys.exit(1)

		skey_restore = Gzip.decompress(BinAscii.text2bin(skey))
		self.p2 = int(skey_restore)

	def encrypt(self, bits):
		r = random_between(1, self.n)
		result = []

		for i in bits:			
			c = i*self.G + r*self.H
			result.append([int(c[0]), int(c[1]), int(c[2])])

		#binary = Gzip.compress(json.dumps(result));
		#print len(binary),' bytes'
		return BinAscii.bin2text(Gzip.compress(json.dumps(result)))

	def decrypt(self, ciphers):
		ciphers_restored = json.loads(Gzip.decompress(BinAscii.text2bin(ciphers)))

		result = bitarray()
		for point in ciphers_restored:
			p = self.E([int(point[0]), int(point[1]), int(point[2])])
			#print p
			#print self.p2 * self.G
			#print ''
			if self.p2 * self.G == p:
				result.append(1)
			else:
				result.append(0)

		print result


if __name__ == '__main__':
	bgn = BGN(64)			# Use 512 bit key length ~ RSA 8192 bit
	pkey,skey = bgn.genKey()
	bits = bitarray('010110')
	e = bgn.encrypt(bits)
	d = bgn.decrypt(e)
	assert bits == d