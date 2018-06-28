#!/usr/bin/python
# -*- coding: utf-8 -*-


# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

import json
import zlib
import base64
import sys
import time

import gzip
import io
import binascii
import os
import pickle

from bitarray import bitarray

load utils.py

def test(var):
	print var
	print type(var)

class BGN():
	def __init__(self):
		self.G = None
		self.H = None
		self.n = None
		self.p = None
		self.g = None
		self.t1 = None
		self.t2 = None
		self.E = None
		self.F = None
		self.p1 = 0
		self.p2 = 0
		self.SIZE_OF_PLAINTEXT = 32
		self.k = 2 # Extension degree k = 2
		self.pos_lookup_table = None
		self.neg_lookup_table = None
		self.q = None

	def __dumpLookupTable(self, table, filename):
		export = [None] * len(table)

		i = 0
		for key, value in table.items():
			export[i] = {"key": str(key.polynomial().list()), "value": str(value)}
			i += 1

		file = open(filename,'w') 
		file.write(Gzip.compress(json.dumps(export)))		# Compress table and write
		#file.write(json.dumps(export))						# Write uncompressed table
		file.close()

	def __loadLookupTable(self, filename):
		file = open(filename,'r') 
		data = json.loads(Gzip.decompress(file.read())) 	# Read and decompressed table
		#data = json.loads(file.read())						# Read table
		file.close()

		importer = {}
		i = 0
		self.q = min(2^(self.SIZE_OF_PLAINTEXT / 2) - 1, self.p2)
		#self.q = 2^(self.SIZE_OF_PLAINTEXT / 2) - 1
		while i < self.q:
			value = Integer(data[i]['value'])
			if value == 0:
				poly = Integer(0)*a + Integer(1)
			else:
				key = json.loads(str(data[i]['key']))
				poly = Integer(key[1])*a + Integer(key[0])
			importer[poly] = value
			i += 1

		return importer

	# Parameters for decryption
	def __genLookupTable(self):
		self.q = min(2^(self.SIZE_OF_PLAINTEXT / 2) - 1, self.p2)
		#self.q = 2^(self.SIZE_OF_PLAINTEXT / 2) - 1

		self.pos_lookup_table = {} # lookup table for positive plaintexts
		self.neg_lookup_table = {} # lookup table for negative plaintexts

		g = self.g ^ self.p2
		j = 0
		while j < self.q:
			a = g^j
			self.pos_lookup_table[a] = j
			self.neg_lookup_table[a^(-1)] = j
			j = j + 1

		self.t2 = g^self.q
		self.t1 = self.t2^(-1)

		self.__dumpLookupTable(self.pos_lookup_table, 'pos_lookup_table.bin')
		self.__dumpLookupTable(self.neg_lookup_table, 'neg_lookup_table.bin')
		
		#data = pickle.loads(dump)
		#data = pickle.dumps(self.neg_lookup_table, protocol=0)

	def __distortion_map(self, P):
		return self.EK(-P.xy()[0], self.i*P.xy()[1])

	def __init(self):
		prime_length = self.tau / 2 # Bit-length of primes
		stop = False

		while not stop:
			# Generate two distinct large primes p1 and p2
			while self.p1 == self.p2:
				self.p1 = random_prime(2^prime_length - 1, False, 2^(prime_length - 1))
				self.p2 = random_prime(2^prime_length - 1, False, 2^(prime_length - 1))

			# Let n = p1*p2
			self.n = self.p1 * self.p2

			# Find the smallest positive integer L (0 < L < prime_length) such that p = L*n - 1 is prime and p = 3 mod 4
			n4 = 4 * self.n
			self.p = n4 - 1 
			self.L = 1
			while self.L < self.tau^2:
			#for self.L in range(1,self.tau^2):
				self.p = self.p + n4
				if self.p.is_prime():
					stop = True
					break
				self.L = self.L + 1

		self.F = GF(self.p, proof=False) # F = GF(p)
		self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F
		PolyRing.<x> = self.F[]
		K.<a> = GF(self.p^self.k, name='a', modulus=x^2+1, check_irreducible=False, proof=False) # K = GF(p^2)
		self.K = K
		self.EK = EllipticCurve(self.K, [1, 0]) # Let E to be defined over K
	
		# Find i in K such that i^2 = -1 in K
		e = (self.p * self.p - 1) / 4
		while True:
			self.i = self.K.random_element()
			self.i = (self.i^e)
			if self.i^2 == -1:
				break

		# Find base point G of order n
		pointAtInf__inity = self.E(0)
		while True:
			self.G = (4*self.L*self.E.random_point())
			if self.n*self.G == pointAtInf__inity:
				if self.p1*self.G != pointAtInf__inity:
					if self.p2*self.G != pointAtInf__inity:
						break

		# g = e(G, __distortion_map(G))
		self.g = self.EK(self.G).tate_pairing(self.__distortion_map(self.G), self.n, self.k)

		# Find a point H of order p2
		self.H = Integer(randrange(1,self.n)) * self.p1 * self.G

		#print self.g
		#print self.g.polynomial().list()


	def genKey(self, tau, __dumpLookupTable = False):
		self.tau = tau # Security parameter
		self.__init()

		if __dumpLookupTable is True:
			self.__genLookupTable()
		else:
			self.q = min(2^(self.SIZE_OF_PLAINTEXT / 2) - 1, self.p2)
			self.t2 = (self.g ^ self.p2)^self.q
			self.t1 = self.t2^(-1)

		if os.path.isfile("pos_lookup_table.bin"):
			os.remove("pos_lookup_table.bin")
		if os.path.isfile("neg_lookup_table.bin"):
			os.remove("neg_lookup_table.bin")

		i = self.i.polynomial().list()
		pkey = json.dumps([
			str(self.n),
			str(self.p),		# Send E by sending p
			[str(self.G[0]), str(self.G[1]), str(self.G[2])],
			[str(self.H[0]), str(self.H[1]), str(self.H[2])],
			[str(i[0]), str(i[1])]
		])
		pkey_compressed = BinAscii.bin2text(Gzip.compress(pkey)).replace('\n', '')

		t1 = self.t1.polynomial().list()
		t2 = self.t2.polynomial().list()
		g = self.g.polynomial().list()

		skey = json.dumps([
			pkey_compressed,
			str(self.p2),
			[str(t1[0]), str(t1[1])],
			[str(t2[0]), str(t2[1])],
			[str(g[0]), str(g[1])],
			str(self.q)
		])
		skey_compressed = BinAscii.bin2text(Gzip.compress(skey)).replace('\n', '')

		return pkey_compressed, skey_compressed

	def setPublicKey(self, pkey):
		pkey_restore = json.loads(Gzip.decompress(BinAscii.text2bin(pkey)))

		self.p = Integer(pkey_restore[1])
		self.F = GF(self.p, proof=False) # F = GF(p)
		self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F

		# Used by decrypt()
		self.n = Integer(pkey_restore[0])
		self.G = self.E([pkey_restore[2][0], pkey_restore[2][1], pkey_restore[2][2]])
		self.H = self.E([pkey_restore[3][0], pkey_restore[3][1], pkey_restore[3][2]])

		self.K = GF(self.p^self.k, name='a', modulus=x^2+1, check_irreducible=False, proof=False) # K = GF(p^2)
		self.K.inject_variables(verbose=False)		# https://stackoverflow.com/questions/33239620/sage-polynomials-name-error
		self.EK = EllipticCurve(self.K, [1, 0]) # Let E to be defined over K

		# Used by __distortion_map by mul()
		self.i = Integer(pkey_restore[4][1])*a + Integer(pkey_restore[4][0])

		return self

	def setPrivateKey(self, skey):
		skey_restore = json.loads(Gzip.decompress(BinAscii.text2bin(skey)))

		self.setPublicKey(skey_restore[0])

		self.p2 = Integer(skey_restore[1])
		self.t1 = Integer(skey_restore[2][1])*a + Integer(skey_restore[2][0])
		self.t2 = Integer(skey_restore[3][1])*a + Integer(skey_restore[3][0])
		self.g = Integer(skey_restore[4][1])*a + Integer(skey_restore[4][0])
		self.q = Integer(skey_restore[5])

		if os.path.exists('neg_lookup_table.bin') and os.path.exists('pos_lookup_table.bin'):
			# Load lookup table from file
			time self.pos_lookup_table = self.__loadLookupTable('pos_lookup_table.bin')
			time self.neg_lookup_table = self.__loadLookupTable('neg_lookup_table.bin')
		else:
			# Generate lookup table
			self.__genLookupTable()

		return self
		
	def encrypt(self, M):
		if type(M) is not Integer or M > 2^self.SIZE_OF_PLAINTEXT:
			raise RuntimeError("Plaintext should be an integer that smaller than 2^" + str(self.SIZE_OF_PLAINTEXT))
		else:
			r = Integer(randrange(1,self.n))
			C = M*self.G + r*self.H

			return BinAscii.bin2text(Gzip.compress(json.dumps([int(C[0]), int(C[1]), int(C[2])])))

	'''@staticmethod
	def length(data):
		return len(Gzip.decompress(BinAscii.text2bin(data)))'''

	def __importCipherFromStr(self, c):
		c_arr = json.loads(Gzip.decompress(BinAscii.text2bin(c)))
		if len(c_arr) == 2:		# C is a element in filed
			C = Integer(c_arr[1])*a + Integer(c_arr[0])
		else:					# C is a point on curve
			C = self.E([Integer(c_arr[0]), Integer(c_arr[1]), Integer(c_arr[2])])

		return C

	def __exportCipher(self, c):
		if type(c) is type(self.G):
			return BinAscii.bin2text(Gzip.compress(json.dumps([str(c[0]), str(c[1]), str(c[2])])))
		elif type(c) is type(self.i):
			c_arr = c.polynomial().list()
			return BinAscii.bin2text(Gzip.compress(json.dumps([str(c_arr[0]), str(c_arr[1])])))
		else:
			test(c)
			raise TypeError("Unsupported type of ciphertext.")

	# Require self.G, self,p2 (private), self.q, pos_lookup_table and neg_lookup_table, self.t1, self.t2, self.i
	def decrypt(self, c):
		if self.p2 is None or self.pos_lookup_table is None or self.neg_lookup_table is None:
			raise RuntimeError("Private key should be installed first")

		C = self.__importCipherFromStr(c)

		if type(C) is type(self.G):   # If C is not a point on curve
			C = self.__mul(C, self.G)   # C = C * G

		C = C ^ self.p2
		
		gamma1 = C
		gamma2 = C
		
		i = 0
		while i < self.q:
			if gamma1 in self.pos_lookup_table:
				return Integer(i*self.q + self.pos_lookup_table[gamma1])
			if gamma2 in self.neg_lookup_table:
				return Integer(-i*self.q - self.neg_lookup_table[gamma2])
			gamma1 *= self.t1
			gamma2 *= self.t2
			i += 1

		raise RuntimeError("Could not finish decryption: plaintext is not in range [-2^" + str(self.SIZE_OF_PLAINTEXT-1) + ",2^" + str(self.SIZE_OF_PLAINTEXT-1) + "-1]")

	# Private function
	def __mul(self, c1, c2):
		if type(c1) is not type(self.G) or type(c2) is not type(self.G):
			raise TypeError("Ciphertext must be a point on E(GF(p^2))")

		return self.EK(c1).tate_pairing(self.__distortion_map(c2), self.n, self.k)

	# Require self.EK (require self.p), self.i, self.n, self.k = 2
	def mul(self, c1, c2):
		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)
		
		C = self.__mul(C1, C2)
		return self.__exportCipher(C)

	def __add(self, C1, C2):	
		if type(C1) == type(self.G):
			if type(C2) == type(self.G):
				C = C1 + C2
			else:
				C = self.__mul(self.EK(C1), self.G) * C2
		elif type(C1) == type(self.i):
			if type(C2) == type(self.G):
				C = self.__mul(self.EK(C2), self.G) * C1
			else:
				C = C1 * C2
		else:
			raise TypeError("Unknown type of ciphertext")

		return C

	def add(self, c1, c2):
		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)

		C = self.__add(C1, C2)
		return self.__exportCipher(C)

	def minus(self, c1, c2):
		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)

		if type(C2) == type(self.G):
			C2 = -C2
		else:
			C2 = C2^(-1)
		
		C = self.__add(C1, C2)
		return self.__exportCipher(C)

if __name__ == '__main__':

	# Local machine
	pkey,skey = BGN().genKey(512)

	c = BGN().setPublicKey(pkey).encrypt(123456789)

	print BGN().setPrivateKey(skey).decrypt(c)

	# Server
	'''bgn1 = BGN()
	bgn1.setPublicKey(pkey)
	n1 = 2353
	n2 = 2414
	c1 = bgn1.encrypt(n1)
	c2 = bgn1.encrypt(n2)
	c3 = bgn1.mul(c1, c2)
	c4 = bgn1.minus(c1, c2)
	c5 = bgn1.add(c3, c4)'''

	# Local machine
	#bgn2 = BGN()
	#time bgn2.setPrivateKey(skey)
	#d = bgn2.decrypt(c5)

	#test(d)

	#assert d == ((n1*n2) + (n1-n2))

	#sys.exit(0)

	#d = OperatorsOnData(c1, pkey) + OperatorsOnData(c2, pkey)

	#print bgn.decrypt(d, 'int')

	#print c1

	#sys.exit()
	#d = bgn.decrypt(c)

	'''print "[Public key] " + str(BGN.length(pkey)) + " bytes \n" + pkey
	print "\n[Private key] " + str(BGN.length(skey)) + " bytes \n" + skey
	print "\n[Plain text] " + str(len(text)) + " bytes \n" + text
	print "\n[Cipher text] " + str(BGN.length(c)) + " bytes \n" + c'''

	#assert d == text

	# Average time:
	# Gen key: 4.7s
	# Encrypt each byte: 0.33s
	# Decrypt each byte: 0.48s (0.06s per bit)
	#
	# Average cipher size: 1 byte in plaintext cost 5040 bytes in cipher text
