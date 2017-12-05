from flask import Flask
from flask import render_template, request, jsonify
from pymongo import MongoClient
import json
from bson import json_util
from bson.json_util import dumps
import sqlite3 as sql

app = Flask(__name__)

#MONGODB_HOST = 'localhost'
#MONGODB_PORT = 27017
#DBS_NAME = 'test'
#COLLECTION_NAME = 'docs1'

@app.route("/")
def index():
    return render_template("index.html")

#@app.route("/data")
#def getData():
    #connection = MongoClient(MONGODB_HOST, MONGODB_PORT)
    #collection = connection[DBS_NAME][COLLECTION_NAME]
    #items = collection.find({"year":1966})
    #json_data = []
    #for item in items:
    #    json_data.append(item)
    #json_data = json.dumps(json_data, default=json_util.default)
    #connection.close()
    #return json_data

# http://localhost:5000/g1/?year=1966&size=100
@app.route('/g1/', methods=['GET'])
def echo():
    year = request.args.get('year', type=int)
    size = request.args.get('size', type=int)
    #connection = MongoClient(MONGODB_HOST, MONGODB_PORT)
    #collection = connection[DBS_NAME][COLLECTION_NAME]
    #items = collection.find({"year":int(year)})

    con = sql.connect("/home/andrej/Documents/dev/medline-evolution/data/medline.sqlite")
    #con = sql.connect("/home/andrej/Documents/dev/bilirubin/bilirubin.sqlite")
    con.row_factory = sql.Row
    cur = con.cursor()
    #year = ('1965',)
    #year = int(year)
    #size = 1
    cur.execute('SELECT * FROM tab1 WHERE size > %d AND year=%d' % (size, year))
    #cur.execute("select * from tab1 WHERE year=%d", year)
    rows = cur.fetchall();
    #json_data = jsonify(rows)

    #json_data = []
    #for item in rows:
    #    json_data.append(item)
    #json_data = json.dumps(json_data, default=json_util.default)
    con.close()
    #bla = "bla"
    bla = json.dumps( [dict(ix) for ix in rows] )
    return bla

# http://akastrin.si/med2clu/g2?year=1965&post=1
@app.route('/g2', methods=['GET', 'POST'])
#@app.route('/check_selected')
def check_selected():
    term = request.args.get('post', type=int)
    year = request.args.get('year', type=int)
    con = sql.connect("/home/andrej/Documents/dev/medline-evolution/data/medline.sqlite")
    #con = sql.connect("/home/andrej/Documents/dev/bilirubin/bilirubin.sqlite")
    con.row_factory = sql.Row
    cur = con.cursor()
    cur.execute('SELECT * FROM tab2 WHERE year=%d AND cluster=%d' % (year, term))
    rows = cur.fetchall()
    json_data = json.dumps( [dict(ix) for ix in rows] )
    return json_data




if __name__ == "__main__":
    app.run(host='0.0.0.0',port=5000,debug=True)
