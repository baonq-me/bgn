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
import StringIO
import re
import uuid
import subprocess

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

		self.bgn = BGN(2**32)
		self.start = time.time()

	def set_default_headers(self):
		self.set_header('Content-Type', 'application/json')

	def output(self, status = '', process = '', msg = '', data = '', more = {}):
		if status in ['success', 'error']:
			self.response['status'] = status
		else:
			self.response['status'] = 'unknown'

		if process in ['genkey', 'encrypt', 'decrypt', 'add', 'sub', 'mul', 'expr']:
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

		pkey, skey = BGN(32).genKey(length)
		
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
		if op not in ['add', 'mul', 'sub', 'expr']:
			self.output(status="error", process="", msg="Invalid operation: " + str(op))
			return
		elif self.test('key', self.request.arguments)  is False:
			self.output(status="error", process=op, msg="Public key should be defined.")
			return

		key = self.request.arguments['key']

		if op != 'expr':
			if self.test('data1', self.request.arguments) is False or self.test('data2', self.request.arguments) is False:
				self.output(status="error", process=op, msg="data1 and data2 should be defined.")
				return
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
		else:
			if self.test('expr', self.request.arguments) is False:
					self.output(status="error", process=op, msg="Expression (expr) should be defined.")
					return

			expr = self.request.arguments['expr']

			try:
				self.bgn.setPublicKey(key)
				C = self.bgn.expr(expr)
				self.output(status="success", process=op, data=C)
			except Exception as e:
				self.output(status="error", process=op, msg=str(e))	



class File(tornado.web.RequestHandler):
	def prepare(self):
		self.bgn = BGN(32)

	def parseCsv(self, line):
		data = line.split(",")

		result = {}

		try:
			# data[0] is employee ID
			result['basicSalary'] = data[1]
			result['daysOff'] = data[2]
			result['singleDayWage'] = data[3]
			result['overtime'] = data[4]
			result['singleHourWage'] = data[5]
			result['allowance'] = data[6]
			result['bonus'] = data[7]
		except:
			self.write({"status": "error", "msg": "Not enough parameters: basicSalary, daysOff, singleDayWage, overtime, singleHourWage, allowance, bonus", "debug": json.dumps(data)})
			return False

		for key, value in result.items():
			if value == "":
				self.write({"status": "error", "msg": "Parameter " + key + " has no value"})
				return False

			try:
				test = self.bgn.decode(value)
			except Exception as e:
				self.write({"status": "error", "msg": "Could not decode parameter " + key + " as a ciphertext: " + str(e)})
				return False

		return result

	def nestedAdd(self, numbers):
		result = self.bgn.encrypt(Integer(0))

		for number in numbers:
			result = self.bgn.add(result, number)

		return result


	def upload(self, content):
		filename = uuid.uuid4().hex
		file = open("uploads/" + filename +".csv", "w")
		file.write(content)
		file.close()

		# https://www.cyberciti.biz/faq/python-run-external-command-and-get-output/
		p = subprocess.Popen("curl --upload-file " + "uploads/" + filename +".csv https://transfer.sh/" + filename +".csv", stdout=subprocess.PIPE, shell=True)
		(output, err) = p.communicate()
		p_status = p.wait()

		self.write({"status": "success", "download": output})

		#os.remove("uploads/" + filename +".csv")

	def post(self):
		if 'file' not in self.request.files:
			self.write({"status": "error", "msg": "File (file) not found."})
			return

		if self.request.files['file'] == '':
			self.write({"status": "error", "msg": "File (file) can not be empty."})
			return

		file = self.request.files['file'][0]

		if re.match("^.*\.(csv|CSV)$", file['filename']) is None:
			self.write({"status": "error", "msg": "The server only accept CSV file."})
			return

		lines = file['body'].split("\n")
		pkey = lines[0]

		try:
			self.bgn.setPublicKey(pkey)
		except Exception as e:
			self.write({"status": "error", "msg": "Error when setting public key: " + str(e)})
			return

		for i in range(1, len(lines)):
			if len(lines[i].split(",")) <= 1:
				continue
			data = self.parseCsv(lines[i])

			if data is False:
				return

			try:
				dayOffSalary = self.bgn.minus(self.bgn.mul(data['daysOff'], data['singleDayWage']))
				overtimeSalary = self.bgn.mul(data['overtime'], data['singleHourWage'])
				totalSalary = self.nestedAdd([data['basicSalary'], dayOffSalary, overtimeSalary, data['allowance'], data['bonus']])
			except Exception as e:
				self.write({"status": "error", "msg": "Error when calculating: " + str(e)})
				return

			while lines[i].endswith(' ') or lines[i].endswith(','):
				lines[i] = lines[i][:-1]
			lines[i] += "," + totalSalary

		result = "\n".join(str(x) for x in lines)

		self.upload(result)


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = 'BGN Web API')
	parser.add_argument('-p', '--port', nargs = 1, help='Define listen port')
	parser.parse_args()
	args = parser.parse_args()

	application = tornado.web.Application([
		(r"/api/genkey", Genkey),
		(r"/api/crypt", Crypt),
		(r"/api/op", Operations),
		(r"/api/file", File)
	], debug=True)

	application.listen(args.port[0])
	tornado.ioloop.IOLoop.instance().start()