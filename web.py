#!/usr/bin/env python

import tornado.ioloop
import tornado.web
import importlib
import json
from bgn import BGN
import argparse


class MainHandler(tornado.web.RequestHandler):
    def get(self):
    	#self.write(json.dumps(self.request.body))
        #self.write("Hi Sandeep, Welcome to Tornado Web Framework.")
        pkey,skey = BGN(8).genKey()

        self.write(json.dumps({"pkey":pkey,"skey":skey}))


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = 'BGN Web API')
	parser.add_argument('-p', '--port', nargs = 1, help='Define listen port')
	parser.parse_args()
	args = parser.parse_args()

	application = tornado.web.Application([
		(r"/genkey", MainHandler),
	])

	application.listen(args.port[0])
	tornado.ioloop.IOLoop.instance().start()