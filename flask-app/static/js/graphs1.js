// The base endpoint to receive data from. See update_url()
//function update_url() {
  //var foo = "?echoValue=" + document.getElementById("fname").value;
  //var url = "http://localhost:5000/echo/?echoValue=1966"
  //alert(foo)
  //var url = "/echo/" + foo
  //alert(foo)
$(document).ready(function() {
 
$( "#fname" ).change(function() {
  var url = "/echo/?echoValue=" + document.getElementById("fname").value;
  queue()
    .defer(d3.json, url)
    .await(makeGraphs);
});


//var q = queue()
//q = q.defer(d3.json, "/echo/?echoValue=1966")
//q.await(makeGraphs);
  
  
  //.defer(d3.json, url)
  //.await(alert(update_url()))
  //.defer(d3.json, "/echo")
  
  //console.log(url)
//}



/*queue()
    .defer(d3.json, "/echo/?echoValue=1967")
    //.defer(d3.json, "/echo" + bla)
    //.await(alert(update_url()))
    //.defer(d3.json, "/echo")
    .await(makeGraphs);
*/
function makeGraphs(error, data) {
  // Set margins
  var margin = {top: 30, right: 20, bottom: 30, left: 50},
    width = 500 - margin.left - margin.right,
    height = 270 - margin.top - margin.bottom;

	// Set x range
  var x = d3.scaleLinear()
    .domain([0, d3.max(data, function(d) { return parseFloat(d.centrality); })])
    .range([0, width]);

  // Set y range
  var y = d3.scaleLinear()
    .domain([0, d3.max(data, function(d) { return parseFloat(d.density); })])
    .range([height, 0]);

  // Set chart
  var chart = d3.select('#main')
    .append('svg:svg')
    .attr('width', width + margin.right + margin.left)
    .attr('height', height + margin.top + margin.bottom)
    .attr('class', 'chart')

  var main = chart.append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    .attr('width', width)
    .attr('height', height)
    .attr('class', 'main')  

  // Draw x axis
  var xAxis = d3.axisBottom()
    .scale(x)
    .tickValues([]);

  // Append x axis
  main.append('g')
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  // Draw y axis
  var yAxis = d3.axisLeft()
    .scale(y)
    .tickValues([]);

  // Append y axis
  main.append('g')
    .call(yAxis);

  // Draw data points
  var g = main.append("svg:g"); 
  var circle = g.selectAll("scatter-dots")
    .data(data)
    .enter().append("svg:circle")
    .attr("cx", function (d,i) { return x(parseFloat(d.centrality)); } )
    .attr("cy", function (d) { return y(parseFloat(d.density)); } )
    .attr("r", 5)
};



});