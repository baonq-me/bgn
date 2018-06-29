#!/usr/bin/env python

import tornado.ioloop
import tornado.web
import tornado.log
import tornado.options
import logging
from tornado.log import enable_pretty_logging

from sage.all import *

import time

import importlib
import json
from bgn import BGN
import argparse

enable_pretty_logging()


# https://gist.github.com/mminer/5464753
class DefaultHandler(tornado.web.RequestHandler):
	"""Request handler where requests and responses speak JSON."""
	def prepare(self):
		# Incorporate request JSON into arguments dictionary.
		if self.request.body:
			try:
				json_data = json.loads(self.request.body)
				self.request.arguments.update(json_data)
			except ValueError:
				message = 'Unable to parse JSON.'
				self.send_error(400, message=message) # Bad Request

		# Set up response dictionary.
		self.response = dict()

		self.bgn = BGN()
		self.start = time.time()

	def set_default_headers(self):
		self.set_header('Content-Type', 'application/json')

	def output(self, status = '', process = '', msg = '', data = '', more = {}):
		if status in ['success', 'error']:
			self.response['status'] = status
		else:
			self.response['status'] = 'unknown'

		if process in ['genkey', 'encrypt', 'decrypt', 'add', 'sub', 'mul']:
			self.response['process'] = process
		else:
			self.response['process'] = 'unknown'

		self.response['msg'] = msg
		self.response['data'] = data

		for key, value in more.items():
			self.response[key] = value

		self.end = time.time()
		self.response['time'] = '%.2f' % (self.end - self.start)

		self.write(self.response)

	def test(self, key, data):
		if key not in data:
			return False
		if data[key] == '':
			return False
		return True

class Genkey(DefaultHandler):
	def get(self):
		self.post()

	def post(self):
		if 'length' in self.request.arguments:
			try:
				length = Integer(self.request.arguments['length'])
			except:
				length = 512
		else:
			length = 512

		pkey, skey = BGN().genKey(length, dumpLookupTable=False)
		
		self.output(status="success", process="genkey", more = {"pkey":pkey, "skey":skey, "length": str(length)})

class Crypt(DefaultHandler):
	def post(self):
		if self.test('op', self.request.arguments) is False:
			self.output(status="error", process="", msg="Operation (encrypt, decrypt) should be defined.")
			return

		op = self.request.arguments['op']
		if op not in ['encrypt', 'decrypt']:
			self.output(status="error", process="", msg="Invalid operation: " + str(op))
			return

		if self.test('key', self.request.arguments) is False:
			self.output(status="error", process="", msg="Key (key) should be defined.")
			return

		if self.test('data', self.request.arguments) is False:
			self.output(status="error", process="", msg="Data (data) not found.")
			return

		data = self.request.arguments['data']
		if op == "encrypt":
			try:
				data = Integer(data)					
			except Exception as e:
				self.output(status="error", process=op, msg=str(e))
				return

		try:

			key = self.request.arguments['key']

			encrypt = self.bgn.setPublicKey
			decrypt = self.bgn.setPrivateKey
			locals()[op](key)		# Set key

			encrypt = self.bgn.encrypt
			decrypt = self.bgn.decrypt
			result = locals()[op](data)		# Encrypt/Decrypt

			self.output(status="success", process=op, data=str(result))

		except Exception as e:
			self.output(status="error", process=op, msg=str(e))

class Operations(DefaultHandler):
	def post(self):
		if self.test('op', self.request.arguments) is False:
			self.output(status="error", process="", msg="Operation (add, sub, mul) should be defined.")
			return

		op = self.request.arguments['op']
		if op not in ['add', 'mul', 'sub']:
			self.output(status="error", process="", msg="Invalid operation: " + str(op))
			return
		elif self.test('key', self.request.arguments)  is False:
			self.output(status="error", process=op, msg="Public key should be defined.")
			return

		if self.test('data1', self.request.arguments) is False or self.test('data2', self.request.arguments) is False:
			self.output(status="error", process=op, msg="data1 and data2 should be defined.")
			return

		key = self.request.arguments['key']
		data1 = self.request.arguments['data1']
		data2 = self.request.arguments['data2']

		try:
			self.bgn.setPublicKey(key)
			add = self.bgn.add
			mul = self.bgn.mul
			sub = self.bgn.sub
			C = locals()[op](data1, data2)

			self.output(status="success", process=op, data=C)
		except Exception as e:
			self.output(status="error", process=op, msg=str(e))			

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = 'BGN Web API')
	parser.add_argument('-p', '--port', nargs = 1, help='Define listen port')
	parser.parse_args()
	args = parser.parse_args()

	application = tornado.web.Application([
		(r"/api/genkey", Genkey),
		(r"/api/crypt", Crypt),
		(r"/api/op", Operations),
	], debug=True)

	application.listen(args.port[0])
	tornado.ioloop.IOLoop.instance().start()