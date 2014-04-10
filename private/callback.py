#!/usr/bin/python
import web
import pymongo
import requests

website_url = 'https://meteor-app-93356.usw1-2.nitrousbox.com/'

client = pymongo.MongoClient("localhost", 3001)
db = client.meteor
Profile = db.profile
app = web.application( ( '/(.*)', 'home' ), globals() )

class home:        
    def GET(self, name):
        param = web.input(code=None, _id=None)
        if 1:
            data = {
                'code': param.code,
                'grant_type': 'authorization_code',
                'client_id': 'af97412ac5b94e18af85ced8d55785bd',
                'client_secret': '737f18e661fd4f20aaa161b977398aac',
                'redirect_uri': 'http://meteor-app-93356.usw1-2.nitrousbox.com:8080/callback/' }
            r = requests.post('https://api.instagram.com/oauth/access_token', data=data)
            Profile.insert( { 'user_id': param._id, 'instagram': r.json() } )
            raise web.seeother('http://meteor-app-93356.usw1-2.nitrousbox.com/')

if __name__ == "__main__":
    app.run()