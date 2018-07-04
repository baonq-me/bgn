# -*- coding: utf-8 -*-

# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

import json
import base64
import sys
import time

import io
import binascii
from pythonds.basic.stack import Stack
import random

import os
import pickle

load utils.py

def test(var):
	print var
	print type(var)

class BGN():
	def __init__(self, size):
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
		self.sizeOfPlaintext = size
		self.k = 2 # Extension degree k = 2
		self.pos_lookup_table = None
		self.neg_lookup_table = None
		self.q = None

	def __dumpLookupTable(self, table, filename):
		s = time.time()

		export = [None] * len(table)

		i = 0
		for key, value in table.items():
			export[i] = {"key": str(key.polynomial().list()), "value": str(value)}
			i += 1

		file = open(filename,'wb') 
		file.write(Gzip.compress(json.dumps(export)))		# Compress table and write
		#file.write(json.dumps(export))						# Write uncompressed table
		file.close()

		e = time.time()

		print '__dumpLookupTable() take %.2f seconds' % (e-s)

	def __loadLookupTable(self, filename):

		s = time.time()

		file = open(filename,'rb') 
		data = json.loads(Gzip.decompress(file.read())) 	# Read and decompressed table
		#data = json.loads(file.read())						# Read table
		file.close()

		lookupTable = {}
		i = 0
		self.q = min(int(sqrt(2^(self.plaintextSpace - 1))), self.p1)
		#self.q = 2^(self.sizeOfPlaintext / 2) - 1

		while i < self.q:
			value = Integer(data[i]['value'])
			if value == 0:
				poly = Integer(0)*a + Integer(1)
			else:
				key = json.loads(str(data[i]['key']))
				poly = Integer(key[1])*a + Integer(key[0])
			lookupTable[poly] = value
			i += 1

		e = time.time()
		print '__loadLookupTable() take %.2f seconds' % (e-s)

		return lookupTable

	'''def __genLookupTableThread(self, loopFrom):
		j = loopFrom
		g = self.g ^ self.p2

		loopTo = loopFrom + self.fragment

		while j <= loopTo:
			a = g^j
			self.pos_lookup_table[a] = j
			self.neg_lookup_table[a^(-1)] = j
			j += 1'''

	# Parameters for decryption
	def __genLookupTable(self):
		s = time.time()

		self.q = min(int(sqrt(2^(self.sizeOfPlaintext - 1))), self.p1)
		#self.q = 2^(self.sizeOfPlaintext / 2) - 1

		self.pos_lookup_table = {} # lookup table for positive plaintexts
		self.neg_lookup_table = {} # lookup table for negative plaintexts

		g = self.g ^ self.p2

		#cpu_count = multiprocessing.cpu_count()
		#cpu_count = 1
		#if cpu_count == 1:
		for j in range(self.q):
			a = g^j
			self.pos_lookup_table[a] = j
			self.neg_lookup_table[a^(-1)] = j
		'''else:
			fragment = int(self.q / cpu_count)
			loopFrom = 0
			loopTo = fragment
			threads = []
			for i in range(cpu_count):
				thread = Thread(target=self.__genLookupTableThread, args=(g, loopFrom, loopTo, ))
				threads.append(thread)
				thread.start()

				loopFrom = loopTo + 1
				loopTo += fragment

			for thread in threads:
				thread.join()'''

		self.t2 = g^self.q
		self.t1 = self.t2^(-1)
		
		e = time.time()
		print '__genLookupTable() take %.2f seconds' % (e-s)

		#data = pickle.loads(dump)
		#data = pickle.dumps(self.neg_lookup_table, protocol=0)

	def __distortion_map(self, P):
		return self.EK(-P.xy()[0], self.i*P.xy()[1])

	def __init(self):
		prime_length = self.tau / 2 # Bit-length of primes
		stop = False
		ubound = (2^prime_length) - 1
		lbound = 2^(prime_length - 1)

		while not stop:
			self.p1 = 0
			self.p2 = 0
			# Generate two distinct large primes p1 and p2
			while self.p1 == self.p2:
				self.p1 = random_prime(ubound, False, lbound)
				self.p2 = random_prime(ubound, False, lbound)
			
			self.n = self.p1 * self.p2

			# Find the smallest positive integer L (0 < L < prime_length) such that p = L*n - 1 is prime and p = 3 mod 4
			n4 = 4 * self.n
			self.p = n4 - 1
			for self.L in range(1, self.tau^2):
				self.p += n4
				if self.p.is_prime():
					stop = True
					break

		self.F = GF(self.p, proof=False) # F = GF(p)
		self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F
		PolyRing.<x> = self.F[]
		self.K = GF(self.p^self.k, name='a', modulus=x^2+1, check_irreducible=False, proof=False) # K = GF(p^2)
		self.K.inject_variables(verbose=False)		# https://stackoverflow.com/questions/33239620/sage-polynomials-name-error
		self.EK = EllipticCurve(self.K, [1, 0]) # Let E to be defined over K
	
		# Find i in K such that i^2 = -1 in K
		e = (self.p * self.p - 1) / 4
		while True:
			self.i = self.K.random_element()
			self.i = (self.i^e)
			if self.i^2 == -1:
				break

		# Find base point G of order n
		pointAtInfinity = self.E(0)
		while True:
			self.G = (4*self.L*self.E.random_point())
			if self.n*self.G == pointAtInfinity:
				if self.p1*self.G != pointAtInfinity:
					if self.p2*self.G != pointAtInfinity:
						break

		# g = e(G, __distortion_map(G))
		self.g = self.EK(self.G).tate_pairing(self.__distortion_map(self.G), self.n, self.k)

		# Find a point H of order p2
		self.H = Integer(randrange(1,self.n)) * self.p1 * self.G

		#print self.g
		#print self.g.polynomial().list()


	def genKey(self, tau, dumpLookupTable = False, genLookupTable = False):
		s = time.time()

		self.tau = tau # Security parameter
		self.__init()

		if dumpLookupTable is True:
			self.__genLookupTable()
			self.__dumpLookupTable(self.pos_lookup_table, 'pos_lookup_table.bin')
			self.__dumpLookupTable(self.neg_lookup_table, 'neg_lookup_table.bin')
		else:
			self.q = min(int(sqrt(2^(self.sizeOfPlaintext - 1))), self.p1)
			self.t2 = (self.g ^ self.p2)^self.q
			self.t1 = self.t2^(-1)
			if genLookupTable:
				self.__genLookupTable()

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

		pkey_compressed = BinAscii.bin2text(Gzip.compress(pkey, compresslevel=9)).replace('\n', '')

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
		skey_compressed = BinAscii.bin2text(Gzip.compress(skey, compresslevel=9)).replace('\n', '')

		e = time.time()

		print 'genKey() take %.2f seconds' % (e-s)

		return pkey_compressed, skey_compressed

	def setPublicKey(self, pkey):
		s = time.time()
		try:
			pkey_restore = self.decode(pkey)
		except:
			raise TypeError("Public key is in malformed format.")

		self.p = Integer(pkey_restore[1])
		self.F = GF(self.p, proof=False) # F = GF(p)
		self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F

		self.n = Integer(pkey_restore[0])
		self.G = self.E([pkey_restore[2][0], pkey_restore[2][1], pkey_restore[2][2]])
		self.H = self.E([pkey_restore[3][0], pkey_restore[3][1], pkey_restore[3][2]])
		self.K = GF(self.p^self.k, name='a', modulus=x^2+1, check_irreducible=False, proof=False) # K = GF(p^2)
		self.K.inject_variables(verbose=False)		# https://stackoverflow.com/questions/33239620/sage-polynomials-name-error
		self.EK = EllipticCurve(self.K, [1, 0]) # Let E to be defined over K
		

		# Used by __distortion_map by mul()
		self.i = Integer(pkey_restore[4][1])*a + Integer(pkey_restore[4][0])

		e = time.time()
		print 'setPublicKey() take %.2f seconds' % (e-s)

		return self

	def setPrivateKey(self, skey):
		s = time.time()

		skey_restore = self.decode(skey)

		self.setPublicKey(skey_restore[0])

		self.p2 = Integer(skey_restore[1])
		self.t1 = Integer(skey_restore[2][1])*a + Integer(skey_restore[2][0])
		self.t2 = Integer(skey_restore[3][1])*a + Integer(skey_restore[3][0])
		self.g = Integer(skey_restore[4][1])*a + Integer(skey_restore[4][0])
		self.q = Integer(skey_restore[5])


		if os.path.exists('neg_lookup_table.bin') and os.path.exists('pos_lookup_table.bin'):
			# Load lookup table from file
			self.pos_lookup_table = self.__loadLookupTable('pos_lookup_table.bin')
			self.neg_lookup_table = self.__loadLookupTable('neg_lookup_table.bin')
		else:
			# Generate lookup table
			self.__genLookupTable()

		e = time.time()
		print 'setPrivateKey() take %.2f seconds' % (e-s)

		return self
		
	def encrypt(self, M):
		if (type(M) is not Integer and type(M) is not int) or M > 2^self.sizeOfPlaintext:
			raise TypeError("Plaintext should be an integer that smaller than 2^" + str(self.sizeOfPlaintext))
		else:
			s = time.time()

			r = Integer(randrange(1,self.n))
			C = M*self.G + r*self.H

			e = time.time()
			print 'encrypt() take %.2f seconds' % (e-s)

			return self.__exportCipher(C)

	'''@staticmethod
	def length(data):
		return len(Gzip.decompress(BinAscii.text2bin(data)))'''

	def decode(self, data):
		try:
			return json.loads(Gzip.decompress(BinAscii.text2bin(data)))
		except Exception as e:
			test(data)
			raise TypeError("Input data is in malformed format: " + str(e))

	def encode(self, data):
		return BinAscii.bin2text(Gzip.compress(data)).replace('\n', '')

	def __importCipherFromStr(self, c):
		try:
			c_arr = self.decode(c)
			if len(c_arr) == 2:		# C is a element in filed
				C = Integer(c_arr[1])*a + Integer(c_arr[0])
			else:					# C is a point on curve
				C = self.E([Integer(c_arr[0]), Integer(c_arr[1]), Integer(c_arr[2])])
		except Exception as e:
			test(c)

			raise TypeError("Cipher text is in malformed format: " + str(e))

		return C

	def __exportCipher(self, c):
		if type(c) is type(self.G):
			return self.encode(json.dumps([str(c[0]), str(c[1]), str(c[2])]))
		elif type(c) is type(self.i):
			c_arr = c.polynomial().list()
			return self.encode(json.dumps([str(c_arr[0]), str(c_arr[1])]))
		else:
			test(c)
			raise TypeError("Unsupported type of ciphertext.")

	# Require self.G, self,p2 (private), self.q, pos_lookup_table and neg_lookup_table, self.t1, self.t2, self.i
	def decrypt(self, c):
		s = time.time()

		if self.p2 is None or self.pos_lookup_table is None or self.neg_lookup_table is None:
			raise RuntimeError("Private key should be installed first")

		C = self.__importCipherFromStr(c)

		if type(C) is type(self.G):   # If C is not a point on curve
			C = self.__mul(C, self.G)   # C = C * G

		C = C ^ self.p2
		gamma1 = C
		gamma2 = C
		D = None
		
		i = 0
		while i < self.q:
			if gamma1 in self.pos_lookup_table:
				D = Integer(i*self.q + self.pos_lookup_table[gamma1])
				break
			gamma1 *= self.t1
			i += 1

		i = 0
		if D is None:
			while i < self.q:
				if gamma2 in self.neg_lookup_table:
					D = Integer(-i*self.q - self.neg_lookup_table[gamma2])
					break
				gamma2 *= self.t2
				i += 1


		e = time.time()

		print 'decrypt() take %.2f seconds' % (e-s)

		if D is None:
			raise RuntimeError("Could not finish decryption: plaintext is not in range [-2^" + str(self.sizeOfPlaintext-1) + ",2^" + str(self.sizeOfPlaintext-1) + "-1]")
		else:
			return D

	# Private function
	def __mul(self, c1, c2):
		s = time.time()

		if type(c1) is not type(self.G) or type(c2) is not type(self.G):
			test(c1)
			test(c2)
			raise TypeError("Ciphertext must be a point on E(GF(p^2))")

		C = self.EK(c1).tate_pairing(self.__distortion_map(c2), self.n, self.k)



		return C

	def mul(self, c1, c2):
		s = time.time()

		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)
		C = self.__mul(C1, C2)

		e = time.time()

		print 'mul() take %.2f seconds' % (e-s)

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

		s = time.time()

		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)

		C = self.__add(C1, C2)

		e = time.time()

		print 'add() take %.2f seconds' % (e-s)

		return self.__exportCipher(C)

	def sub(self, c1, c2):
		s = time.time()

		C1 = self.__importCipherFromStr(c1)
		C2 = self.__importCipherFromStr(c2)
		C = self.__add(C1, self.__minus(C2))

		e = time.time()
		print 'sub() take %.2f seconds' % (e-s)
		
		return self.__exportCipher(C)

	def __minus(self, C):
		if type(C) == type(self.G):
			C = -C
		else:
			C = C^(-1)

		return C

	def minus(self, c):
		s = time.time()

		C = self.__importCipherFromStr(c)
		C = self.__minus(C)

		e = time.time()

		print 'minus() take %.2f seconds' % (e-s)

		return self.__exportCipher(C)

	# Ref: http://interactivepython.org/runestone/static/pythonds/BasicDS/InfixPrefixandPostfixExpressions.html
	def __convertToPostfix(self, expr):
		prec = {}
		prec["*"] = 3
		#prec["/"] = 3
		prec["+"] = 2
		prec["-"] = 2
		prec["("] = 1
		opStack = Stack()
		postfixList = []
		tokenList = expr.split(" ")

		try:
			for token in tokenList:
				if token not in ['+', '-', '*', '(', ')']:
					postfixList.append(token)
				elif token == '(':
					opStack.push(token)
				elif token == ')':
					topToken = opStack.pop()
					while topToken != '(':
						postfixList.append(topToken)
						topToken = opStack.pop()
				else:
					while (not opStack.isEmpty()) and (prec[opStack.peek()] >= prec[token]):
						  postfixList.append(opStack.pop())
					opStack.push(token)
		except:
			raise RuntimeError("Expression is not in correct format")

		while not opStack.isEmpty():
			postfixList.append(opStack.pop())
		return " ".join(postfixList)

	# Ref: https://github.com/lilianweng/LeetcodePython/blob/master/expression.py
	def expr(self, expr):
		stack = []
		add = self.add
		mul = self.mul
		sub = self.sub
		ops = {'+': 'add', "*": 'mul', "-": 'sub'}
		
		expr = self.__convertToPostfix(expr)
		for ch in expr.split(" "):
			if ch not in ['+', '-', '*', '(', ')']:
				stack.append(ch)
			else:
				b = stack.pop()
				a = stack.pop()
				c = locals()[ops[ch]](a, b)
				stack.append(c)					
		return stack[-1]

if __name__ == '__main__':
	

	print '256'

	pkey, skey = BGN(32).genKey(512)


	addtime = 0
	bgn = BGN(32)
	bgn.setPublicKey(pkey)
	bgn.setPrivateKey(skey)

	for i in range(1):
		print i
		n1 = 123
		n2 = 456
		print n1
		print n2

		c1 = bgn.encrypt(n1)
		c2 = bgn.encrypt(n1)

		s = time.time()
		add = bgn.add(c1,c2)
		print add
		print bgn.decrypt(add)
		print n1+n2
		e = time.time()
		addtime += e-s
		

	print addtime


	'''n1 = 2
	n2 = 5
	n3 = 6
	n4 = 4
	n5 = 8
	c1 = bgn.encrypt(n1)
	c2 = bgn.encrypt(n2)
	c3 = bgn.encrypt(n3)
	c4 = bgn.encrypt(n4)
	c5 = bgn.encrypt(n5)

	C = bgn.expr("( %s * %s ) - ( %s + %s ) * %s" % (c1, c2, c3, c4, c5))

	print pkey
	print "( %s * %s ) - ( %s + %s ) * %s" % (c1, c2, c3, c4, c5)
	D = bgn.decrypt(C)

	print "Result is: " + str(D)
	assert (n1 * n2) - (n3 + n4) * n5 == D'''

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

	#assert d == text

	# Average time:
	# Gen key: 4.7s
	# Encrypt each byte: 0.33s
	# Decrypt each byte: 0.48s (0.06s per bit)
	#
	# Average cipher size: 1 byte in plaintext cost 5040 bytes in cipher text
