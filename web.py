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

		if process in ['genkey', 'encryption', 'decryption', 'addition', 'substraction', 'multiplication']:
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
		
		self.output(status="success", process="genkey", more = {"pkey":pkey, "skey":skey})

class Encrypt(DefaultHandler):
	def post(self):
		if 'pkey' in self.request.arguments and 'data' in self.request.arguments:
			data = self.request.arguments['data']
			pkey = self.request.arguments['pkey']

			try:
				data = Integer(data)
				assert data < 2**32
			except:
				self.output(status="error", process="encryption", msg="Data must be an integer in range [-2^31,2^31-1]")
				return

			try:
				self.bgn.setPublicKey(pkey)
			except Exception as e:
				self.output(status="error", process="encryption", msg=str(e))
				return				

			try:
				C = self.bgn.encrypt(data)
				self.output(status="success", process="encryption", data=C)
			except Exception as e:
				self.output(status="error", process="encryption", msg=str(e))
		else:
			self.output(status="error", process="encryption", msg="Public key (pkey) and data (data) should be defined.")

class Decrypt(DefaultHandler):
	def post(self):
		if 'skey' in self.request.arguments and 'data' in self.request.arguments:
			data = self.request.arguments['data']
			skey = self.request.arguments['skey']

			if data == '' or skey == '':
				self.output(status="error", process="decryption", msg="Private key (pkey) and data (data) should be defined.")
		
			try:
				self.bgn.setPrivateKey(skey)
			except Exception as e:
				self.output(status="error", process="decryption", msg=str(e))
				return				

			try:
				D = self.bgn.decrypt(data)
				self.output(status="success", process="decryption", data=str(D))
			except Exception as e:
				self.output(status="error", process="decryption", msg=str(e))
		else:
			self.output(status="error", process="decryption", msg="Private key (pkey) and data (data) should be defined.")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = 'BGN Web API')
	parser.add_argument('-p', '--port', nargs = 1, help='Define listen port')
	parser.parse_args()
	args = parser.parse_args()

	application = tornado.web.Application([
		(r"/genkey", Genkey),
		(r"/encrypt", Encrypt),
		(r"/decrypt", Decrypt),
	], debug=True)

	application.listen(args.port[0])
	tornado.ioloop.IOLoop.instance().start()