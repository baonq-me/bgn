#!/usr/bin/env python

# Somewhat homomorphic encryption over elliptic curve using BGN algorithm 

import json
import zlib
import base64
import sys

import gzip
import io
import binascii

from bitarray import bitarray

load utils.py

CURVE = [0,1] #  y^2 = x^3 + 1

K = 2

def random_between(j,k):
   a = int(random()*(k-j+1))+j
   return a

class BGN():
	def __init__(self, size = 0):
		self.size = size
		self.n = None
		self.G = None
		self.H = None
		self.E = None

	def setSize(self, size):
		self.size = size

	def calcFp(self):
		n3 = 3 * self.n

		self.p = n3 - 1
		self.l = 1

		while self.p.is_prime(proof=False) is False:
			self.p = self.p + n3
			self.l = self.l + 1

		self.Fp = GF(self.p, proof = False)

	def calcExtFp(self):
		FpE.<a> = GF(self.p^K, proof = False)	# Use pseudo primality test

	def initCurve(self, curve):
		self.p1 = self.randomPrime()
		self.p2 = self.randomPrime()
		self.n = self.p1 * self.p2

		self.calcFp()
		self.E = EllipticCurve(self.Fp, curve)	# curve[0,1]: y^2 = x^3 + 1

		# E.cardinality()
		# http://doc.sagemath.org/html/en/thematic_tutorials/explicit_methods_in_number_theory/elliptic_curves.html
		while self.E.cardinality() != self.p+1:
			self.calcFp()
			self.E = EllipticCurve(self.Fp, curve)

		self.calcExtFp()
		
	def randomPrime(self):
		return random_prime(2^self.size-1, False, 2^(self.size-1))	# Use true primality test

	def randomPoint(self):
		self.G = (3*self.l*self.E.random_point())	# self.G*self.n == self.E([0,1,0])
	
		self.U = int(1 + random() % 100) * self.G	# Create point U using G as a generator

		#print self.G
		#print self.U
		#print self.U*self.n

		self.H = self.p1 * self.U

	def genKey(self):
		self.initCurve(CURVE)
		self.randomPoint()

		pkey = json.dumps([
			str(self.n), 
			[str(self.G[0]), str(self.G[1]), str(self.G[2])], 
			[str(self.H[0]), str(self.H[1]), str(self.H[2])],
			str(self.p)		# Send E by sending p
		])

		skey = str(self.p2)

		pkey_compressed = BinAscii.bin2text(Gzip.compress(pkey)).replace('\n', '')
		skey_compressed = BinAscii.bin2text(Gzip.compress(skey)).replace('\n', '')

		return pkey_compressed, skey_compressed

	def setPublicKey(self, pkey):
		pkey_restore = json.loads(Gzip.decompress(BinAscii.text2bin(pkey)))

		self.n = int(pkey_restore[0])
		self.p = int(pkey_restore[3])

		self.E = EllipticCurve(GF(self.p), CURVE)

		self.G = self.E([pkey_restore[1][0], pkey_restore[1][1], pkey_restore[1][2]])
		self.H = self.E([pkey_restore[2][0], pkey_restore[2][1], pkey_restore[2][2]])

	def setPrivateKey(self, skey):
		if (self.n is None) or (self.E is None) or (self.G is None) or (self.H is None):
			print 'Public key should be set first !'
			sys.exit(1)

		skey_restore = Gzip.decompress(BinAscii.text2bin(skey))
		self.p2 = int(skey_restore)

	def encrypt(self, data):
		data = Integer(data)

		if data > 2^16:
			print 'Max size of data is 2^16'
		else:
			r = random_between(1, self.n)
			c = data*self.G + r*self.H

			return BinAscii.bin2text(Gzip.compress(json.dumps([int(c[0]), int(c[1]), int(c[2])])))

	def decrypt(self, ciphers, inputType):
		p = json.loads(Gzip.decompress(BinAscii.text2bin(ciphers)))

		C = self.E(int(p[0]), int(p[1]), int(p[2]))
		q = Interger(sqrt(self.p1 - 1))
		a,b = []*q

		for i in range(0, q+1):
			a[i] = q * i * self.G
			b[i] = C - j*self.G

		if 

		result = bitarray()
		for point in ciphers_restored:
			p = self.E([int(point[0]), int(point[1]), int(point[2])]) * self.p2
			result.append(self.p2 * self.G == p)

		if inputType == 'string':
			return bitarray(result).tobytes().decode('utf-8')
		else:
			return int(bitarray(result).to01(), 2)

	@staticmethod
	def length(data):
		return len(Gzip.decompress(BinAscii.text2bin(data)))

class OperatorsOnData():
	def __init__(self, data, pkey):
		pkey_restore = json.loads(Gzip.decompress(BinAscii.text2bin(pkey)))

		self.n = int(pkey_restore[0])
		self.p = int(pkey_restore[3])

		self.E = EllipticCurve(GF(self.p), CURVE)

		self.G = self.E([pkey_restore[1][0], pkey_restore[1][1], pkey_restore[1][2]])
		self.H = self.E([pkey_restore[2][0], pkey_restore[2][1], pkey_restore[2][2]])

		coordinate = json.loads(Gzip.decompress(BinAscii.text2bin(data)))
		self.data1 = self.a2p(coordinate)

	def getData(self):
		return self.data1

	def p2a(self, p):
		return [int(p[0]), int(p[1]), int(p[2])]

	def a2p(self, a):
		return self.E(int(p[0]), int(p[1]), int(p[2]))

	def __add__(self, data):
		self.data2 = data.getData()
		c = self.data1 + self.data2

		return BinAscii.bin2text(Gzip.compress(json.dumps(self.p2a(c))))

	def __mul__(self, data):
		self.data2 = data.getData()
		c = self.data1.tate_pairing(self.data2, self.n, K)

		return BinAscii.bin2text(Gzip.compress(json.dumps(self.p2a(c))))

	def __sub__(self, data):
		c = self.data1 + (-self.data2)

		return BinAscii.bin2text(Gzip.compress(json.dumps(self.p2a(c))))


if __name__ == '__main__':
	# Local machine
	pkey,skey = BGN(8).genKey()
	#sys.exit()

	# Server
	bgn = BGN(8)				# Use 512 bit key length ~ RSA 8192 bit
	bgn.setPublicKey(pkey)
	bgn.setPrivateKey(skey)

	c1 = bgn.encrypt(20)
	c2 = bgn.encrypt(5)

	d = OperatorsOnData(c1, pkey) + OperatorsOnData(c2, pkey)

	#print bgn.decrypt(d, 'int')

	print c1

	sys.exit()
	d = bgn.decrypt(c)
	
	'''print "[Public key] " + str(BGN.length(pkey)) + " bytes \n" + pkey
	print "\n[Private key] " + str(BGN.length(skey)) + " bytes \n" + skey
	print "\n[Plain text] " + str(len(text)) + " bytes \n" + text
	print "\n[Cipher text] " + str(BGN.length(c)) + " bytes \n" + c'''

	assert d == text

	# Average time:
	# Gen key: 4.7s
	# Encrypt each byte: 0.33s
	# Decrypt each byte: 0.48s (0.06s per bit)
	# 
	# Average cipher size: 1 byte in plaintext cost 5040 bytes in cipher text