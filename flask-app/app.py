from flask import Flask
from flask import render_template, request, jsonify
from pymongo import MongoClient
import json
from bson import json_util
from bson.json_util import dumps
import sqlite3 as sql

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

# http://localhost:5000/g1/?year=1966&size=100
@app.route('/query1', methods=['GET'])
def echo():
    year = request.args.get('year', type=int)
    size = request.args.get('size', type=int)
    con = sql.connect("/home/andrej/Documents/dev/medline-evolution/data/medline.sqlite")
    con.row_factory = sql.Row
    cur = con.cursor()
    cur.execute('SELECT * FROM tab1 WHERE year = %d AND size > %d' % (year, size))
    rows = cur.fetchall();
    con.close()
    json_data = json.dumps( [dict(ix) for ix in rows] )
    return json_data

# http://akastrin.si/med2clu/g2?year=1965&post=1
@app.route('/query2', methods=['GET', 'POST'])
def check_selected():
    year = request.args.get('year', type=int)
    cluster = request.args.get('cluster', type=int)
    con = sql.connect("/home/andrej/Documents/dev/medline-evolution/data/medline.sqlite")
    con.row_factory = sql.Row
    cur = con.cursor()
    cur.execute('SELECT * FROM tab2 WHERE year = %d AND cluster = %d' % (year, cluster))
    rows = cur.fetchall()
    json_data = json.dumps( [dict(ix) for ix in rows] )
    return json_data

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=5000,debug=True)
