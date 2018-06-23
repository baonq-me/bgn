import time

class BGN:
    def KeyGen(self, tau):
        self.tau = tau # Security parameter
        prime_length = self.tau / 2 # Bit-length of primes
        ubound = 2^prime_length - 1
        lbound = 2^(prime_length - 1)
        stop = False

        while not stop:
            # Generate two distinct large primes p1 and p2
            #while self.p1 == self.p2:
            self.p1 = random_prime(ubound, False, lbound)
            self.p2 = random_prime(ubound, False, lbound)

            # Let n = p1*p2
            self.n = self.p1 * self.p2

            # Find the smallest positive integer L (0 < L < prime_length) such that p = L*n - 1 is prime and p = 3 mod 4
            n4 = 4 * self.n
            self.p = n4 - 1
            self.L = 1
            for L in range(self.tau^2):
                self.p = self.p + n4
                self.L = self.L + 1
                if self.p.is_prime():
                    stop = True
                    break

        print "p1 = %s" % self.p1
        print "p2 = %s" % self.p2
        print "n = p1 * p2 = %s" % self.n
        print "p = %s" % self.p

        self.k = 2 # Extension degree k = 2
        self.F = GF(self.p, proof=False) # F = GF(p)
        self.E = EllipticCurve(self.F, [1, 0]) # E is a super-singular elliptic curve y^2 = x^3 + x defined over F
        PolyRing.<x> = self.F[]
        self.K = GF(self.p^self.k, name='a', modulus=x^2+1, check_irreducible=False, proof=False) # K = GF(p^2)
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
            if self.p1*self.G != pointAtInfinity:
                if self.p2*self.G != pointAtInfinity:
                    if self.n*self.G == pointAtInfinity:
                        break

        # g = e(G, distortion_map(G))
        self.g = self.EK(self.G).tate_pairing(self.distortion_map(self.G), self.n, self.k)
        
        # Find a point H of order p2
        self.H = Integer(randrange(1,self.n)) * self.p1 * self.G
        
        
        print "G = %s" % self.G
        print "g = %s" % self.g
        print "H = %s" % self.H
                
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
    
    def minus(self, C1, C2):
        if type(C2) == type(self.G):
            C2 = - C2
        else:
            C2 = C2^(-1)
        return self.add(C1, C2)


            

bgn = BGN()

start = time.time()
bgn.KeyGen(512)
end = time.time()
print 'Time elapsed: %.2f seconds' % (end-start)
C1 = bgn.encrypt(3)
C2 = bgn.encrypt(7)
p = bgn.mul(C1, C2)
S = bgn.add(C1, C2)
diff = bgn.minus(C2, C1)
print(bgn.decrypt(C1))
print(bgn.decrypt(C2))
print(bgn.decrypt(S))
print(bgn.decrypt(p))
print(bgn.decrypt(bgn.add(C1, p)))
#print(bgn.decrypt(bgn.add(p, C2)))
#print(bgn.decrypt(bgn.add(p, p)))
print(bgn.decrypt(bgn.minus(S, C1)))
print(bgn.decrypt(bgn.minus(p, S)))