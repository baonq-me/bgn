#from sage.parallel.multiprocessing_sage import pyprocessing

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
		self.N = self.p1 * self.p2

		N3 = 3 * self.N

		self.p = N3 - 1
		self.l = 1
		while is_prime(self.p) is False:
		    self.p = self.p + N3
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
		self.P = (3*self.l*self.E.random_point())	# P = (0,1,0)
		#print Q*self.N == self.E([0,1,0])
			
		self.Q = int(1 + random() % 100) * self.P
		print self.P
		print self.Q
		print self.Q*self.N

		self.h = self.p1 * self.Q
		

def test():
	bgn = BGN(512)

	bgn.calcFp()
	bgn.initCurve([0,1])
	bgn.calcExtFp()
	bgn.randomPoint()

if __name__ == '__main__':
	test()