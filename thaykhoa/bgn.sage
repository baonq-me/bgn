import sys
from sage.misc.prandom import randrange
from sage.misc.randstate import current_randstate

def initRand():
	for i in range(1000):
		randrange(1000)


class BGN:
	def KeyGen(self, tau):
		self.tau = tau # Security parameter
		prime_length = self.tau / 2 # Bit-length of primes

		self.p1 = 0
		self.p2 = 0
		initRand();

		# Generate two distinct large primes p1 and p2
		while self.p1 == self.p2:
			self.p1 = random_prime(2^prime_length - 1, False, 2^(prime_length - 1))
			self.p2 = random_prime(2^prime_length - 1, False, 2^(prime_length - 1))
		
		# Let n = p1*p2
		self.n = self.p1 * self.p2

		# Find the smallest positive integer L (0 < L < prime_length) such that p = L*n - 1 is prime and p = 3 mod 4
		n4 = 4 * self.n
		self.p = n4 - 1
		for L in range(prime_length - 1):
			self.p = self.p + n4
			if self.p.is_prime():
				break

		# Recursion
		if self.p.is_prime() is False:
			print 'Recursion ...'
			self = BGN()
			self.KeyGen(tau)
			return

		self.k = 2 # Extension degree k = 2
		self.F = GF(self.p, proof=False) # F = GF(p)
		self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F
		self.K = GF(self.p^self.k, 'a', proof=False) # K = GF(p^2)
		self.EK = self.E.base_extend(self.K) # Let E to be defined over K
		
		

		# Find i in K such that i^2 = -1 in K
		e = (self.p * self.p - 1) / 4
		while True:
			self.i = (self.K.random_element())^e
			if self.i^2 == -1:
				break	

		# Find base point G of order n
		zeroPoint = self.E(0)
		while True:
			self.G = self.E.random_point()
			'''if self.p1*self.G != zeroPoint:
				if self.p2*self.G != zeroPoint:
					if self.n*self.G == zeroPoint:
						break'''
			if self.n*self.G == zeroPoint:
				break

		if (self.p1*self.G != self.E(0) and self.p2*self.G != self.E(0) and self.n*self.G == self.E(0)) is False:	
			print 'Wrong logic'

		# g = e(G, distortion_map(G))
		self.g = self.EK(self.G).tate_pairing(self.distortion_map(self.G), self.n, self.k)
		
		# Find a point H of order p2
		self.H = Integer(randrange(1,self.n)) * self.p1 * self.G
		
		'''print "p1 = %s" % self.p1
		print "p2 = %s" % self.p2
		print "n = p1 * p2 = %s" % self.n
		print "p = %s" % self.p
		print "G = %s" % self.G
		print "g = %s" % self.g
		print "H = %s" % self.H'''
				
	def encrypt(self, m):
		r = Integer(randrange(1,self.n))
		return m * self.G + r*self.H
		
	def decrypt(self, C):
		q = 2**16
		if type(C) == type(self.G):
			C = self.p2 * C
			G = self.p2 * self.G
			
			for m in range(q):
				if m*G == C:
					return m
			return -1
		else:
			C = C ^ self.p2
			g = self.g ^ self.p2
			for m in range(q):
				if g^m == C:
					return m
			return -1
	
	def distortion_map(self, P):
		return self.EK(-P.xy()[0], self.i*P.xy()[1])

	def mul(self, C1, C2):
		if type(C1) != type(self.G) or type(C2) != type(self.G):
			raise TypeError("C1 and C2 must be two points on E(GF(p^2)).")
		return self.EK(C1).tate_pairing(self.distortion_map(C2), self.n, self.k)
	
	def add(self, C1, C2):
		if type(C1) == type(self.G):
			if type(C2) == type(self.G):
				return C1 + C2
			else:
				return self.mul(self.EK(C1), self.G) * C2
		if type(C1) == type(self.i):
			if type(C2) == type(self.G):
				return self.mul(self.EK(C2), self.G) * C1
			else:
				return C1 * C2

while True:
	bgn = BGN()
	time bgn.KeyGen(512)
