#/usr/bin/env coffee

client = (require 'mongodb').MongoClient
client.connect "mongodb://localhost:7017/meteor", (err, db) -> 
	db.collection ''