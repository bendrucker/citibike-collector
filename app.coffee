request = require 'request'
mongoose = require 'mongoose'
http = require 'http'

stationEndpoint = 'http://citibikenyc.com/stations/json'

stationSchema = new mongoose.Schema
	citiId:					Number
	stationName:			String
	geo:
		latitude:			Number
		longitude:			Number
	status:					String

	statuses: [{
		timestamp:
			type:			Date
			default:		Date.now

		bikes:				Number
		availableDocks:		Number
		totalDocks:			Number
	}]

Station = mongoose.model 'Station', stationSchema

initializeUpdate = () ->
	request.get stationEndpoint, (err, res, body) ->
		unless err
			stations = JSON.parse(body).stationBeanList
			stations.forEach (station) ->
				updateStation station
		else
			console.log err

updateStation = (stationUpdate) ->
	Station.findOne {citiId: stationUpdate.id}, (err, station) ->
		unless station
			station = new Station
				citiId:				stationUpdate.id
				stationName:		stationUpdate.stationName
				geo:
					longitude:		stationUpdate.longitude
					latitude:		stationUpdate.latitude
				status:				stationUpdate.status
		station.statuses.push
			bikes:				stationUpdate.availableBikes
			availableDocks:		stationUpdate.availableDocks
			totalDocks:			stationUpdate.totalDocks
		station.save (err, station) ->
			if err
				console.log err
			else
				return true

server = http.createServer (req, res) ->
	res.end()
server.listen 8080

mongoose.connect process.env.MONGO_URI
initializeUpdate()
setInterval initializeUpdate, 600000