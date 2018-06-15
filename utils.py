#!/usr/bin/env python

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