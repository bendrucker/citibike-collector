request = require 'request'
stationEndpoint = 'http://citibikenyc.com/stations/json'

request.get stationEndpoint, (err, res, body) ->
	unless err
		stations = JSON.parse(body).stationBeanList
	else
		console.log err