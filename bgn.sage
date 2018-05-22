# Somewhat homomorphic encryption over elliptic curve using BGN algorithm 

import json

def random_between(j,k):
   a = int(random()*(k-j+1))+j
   return a

class BGN():
	def __init__(self, size, ):
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

		print "Public key:  " + str(json.dumps([str(self.n), str(self.G), str(self.H)]))
		print "Private key: " + str(self.p2)


if __name__ == '__main__':
	bgn = BGN(512)
	bgn.genKey()