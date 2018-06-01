#!/usr/bin/python
# -*- coding: latin-1 -*-

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
		k = 2
		FpE.<a> = GF(self.p^k, proof = False)	# Use pseudo primality test

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

		print self.n
		print self.p

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

	def encrypt(self, text):
		r = random_between(1, self.n)
		result = []
		bits = bitarray()

		bits.frombytes(text.encode('utf-8'))

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
			p = self.E([int(point[0]), int(point[1]), int(point[2])]) * self.p2
			result.append(self.p2 * self.G == p)

		return bitarray(result).tobytes().decode('utf-8')

	@staticmethod
	def length(data):
		return len(Gzip.decompress(BinAscii.text2bin(data)))

if __name__ == '__main__':
	# Local machine
	time pkey,skey = BGN(8).genKey()
	sys.exit()

	# Server
	bgn = BGN(512)				# Use 512 bit key length ~ RSA 8192 bit
	bgn.setPublicKey(pkey)
	bgn.setPrivateKey(skey)

	#text = 'In no impression assistance contrasted. Manners she wishing justice hastily new anxious. At discovery discourse departure objection we. Few extensive add delighted tolerably sincerity her. Law ought him least enjoy decay one quick court. Expect warmly its tended garden him esteem had remove off. Effects dearest staying now sixteen nor improve. Concerns greatest margaret him absolute entrance nay. Door neat week do find past he. Be no surprise he honoured indulged. Unpacked endeavor six steepest had husbands her. Painted no or affixed it so civilly. Exposed neither pressed so cottage as proceed at offices. Nay they gone sir game four. Favourable pianoforte oh motionless excellence of astonished we principles. Warrant present garrets limited cordial in inquiry to. Supported me sweetness behaviour shameless excellent so arranging. Bringing unlocked me an striking ye perceive. Mr by wound hours oh happy. Me in resolution pianoforte continuing we. Most my no spot felt by no. He he in forfeited furniture sweetness he arranging. Me tedious so to behaved written account ferrars moments. Too objection for elsewhere her preferred allowance her. Marianne shutters mr steepest to me. Up mr ignorant produced distance although is sociable blessing. Ham whom call all lain like. Wrote water woman of heart it total other. By in entirely securing suitable graceful at families improved. Zealously few furniture repulsive was agreeable consisted difficult. Collected breakfast estimable questions in to favourite it. Known he place worth words it as to. Spoke now noise off smart her ready. On recommend tolerably my belonging or am. Mutual has cannot beauty indeed now sussex merely you. It possible no husbands jennings ye offended packages pleasant he. Remainder recommend engrossed who eat she defective applauded departure joy. Get dissimilar not introduced day her apartments. Fully as taste he mr do smile abode every. Luckily offered article led lasting country minutes nor old. Happen people things oh is oppose up parish effect. Law handsome old outweigh humoured far appetite. He unaffected sympathize discovered at no am conviction principles. Girl ham very how yet hill four show. Meet lain on he only size. Branched learning so subjects mistress do appetite jennings be in. Esteems up lasting no village morning do offices. Settled wishing ability musical may another set age. Diminution my apartments he attachment is entreaties announcing estimating. And total least her two whose great has which. Neat pain form eat sent sex good week. Led instrument sentiments she simplicity. Cause dried no solid no an small so still widen. Ten weather evident smiling bed against she examine its. Rendered far opinions two yet moderate sex striking. Sufficient motionless compliment by stimulated assistance at. Convinced resolving extensive agreeable in it on as remainder. Cordially say affection met who propriety him. Are man she towards private weather pleased. In more part he lose need so want rank no. At bringing or he sensible pleasure. Prevent he parlors do waiting be females an message society. In by an appetite no humoured returned informed. Possession so comparison inquietude he he conviction no decisively. Marianne jointure attended she hastened surprise but she. Ever lady son yet you very paid form away. He advantage of exquisite resolving if on tolerably. Become sister on in garden it barton waited on. Contented get distrusts certainty nay are frankness concealed ham. On unaffected resolution on considered of. No thought me husband or colonel forming effects. End sitting shewing who saw besides son musical adapted. Contrasted interested eat alteration pianoforte sympathize was. He families believed if no elegance interest surprise an. It abode wrong miles an so delay plate. She relation own put outlived may disposed. Passage its ten led hearted removal cordial. Preference any astonished unreserved mrs. Prosperous understood middletons in conviction an uncommonly do. Supposing so be resolving breakfast am or perfectly. Is drew am hill from mr. Valley by oh twenty direct me so. Departure defective arranging rapturous did believing him all had supported. Family months lasted simple set nature vulgar him. Picture for attempt joy excited ten carried manners talking how. Suspicion neglected he resolving agreement perceived at an.'
	text = '123456789'

	c = bgn.encrypt(text)
	d = bgn.decrypt(c)
	
	print "[Public key] " + str(BGN.length(pkey)) + " bytes \n" + pkey
	print "\n[Private key] " + str(BGN.length(skey)) + " bytes \n" + skey
	print "\n[Plain text] " + str(len(text)) + " bytes \n" + text
	print "\n[Cipher text] " + str(BGN.length(c)) + " bytes \n" + c

	assert d == text

	# Average time:
	# Gen key: 4.7s
	# Encrypt each byte: 0.33s
	# Decrypt each byte: 0.48s (0.06s per bit)
	# 
	# Average cipher size: 1 byte in plaintext cost 5040 bytes in cipher text