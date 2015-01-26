curl = require 'node-curl'
fs   = require 'fs'

cal_addr = "https://docs.google.com/a/hi16.ca/presentation/d/1NFwUbKn6GhprK3ctcBA7h54t8SXycOzn8Qpm8rhAZYo/edit#slide=id.g4a9c01842_"
cal_tag =
    '201407':'049',  '201408':'033',  '201409':'041',  '201410':'022',  '201411':'02',   '201412':'014'
    '201501':'057',  '201502':'065',  '201503':'073',  '201504':'081',  '201505':'089',  '201506':'097'
    '201507':'0105', '201508':'0113', '201509':'0121', '201510':'0129'

gCal = {}

curl cal_addr + tag, (data) ->
    fs.appendFile 'data', data, (err) -> console.log err or data
    (data.match /"[0-9]{1,2}[^0-9a-zA-Z."][^"]*"/g).forEach (str) ->
        str.replace s, r for r, s of '\n':/\\u000b/, '\n':/\n+/
        if (a = str.split '\n').length > 1
            console.log a
            gCal[month + ('0' + a[0])[-2..]] = (a[1..]).join '\n'
