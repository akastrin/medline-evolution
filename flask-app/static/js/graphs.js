var toggleSelected = true;

function sum(array) {
  var num = 0;
  for (var i = 0, l = array.length; i < l; i++) num += array[i];
  return num;
}

function mean(array) {
  return sum(array) / array.length;
}

function variance(array) {
  var mymean = mean(array);
  return mean(array.map(function(num) {return Math.pow(num - mymean, 2);}));
}
	
function standardDeviation(array) {
  return Math.sqrt(variance(array));
}

function zScores(array) {
  var mymean = mean(array);
  var mystandardDeviation = standardDeviation(array);
  return array.map(function(num) {
    return (num - mymean) / mystandardDeviation;
  });
}

$(document).ready(function() {
  // Display data for 1966 at the beginning
  var url_init = "/g1/?year=1966&size=10";
  queue()
    .defer(d3.json, url_init)
    .await(makeGraphs);
    document.getElementById("fyear").value = 1966

  // Later we can choose values
  $("select").change(function() {
    var url = "/g1/?year=" + document.getElementById("fyear").value + "&size=" + document.getElementById("fsize").value
    console.log(url)
    queue()
      .defer(d3.json, url)
      .await(makeGraphs);
  });

  function myFunction(x) {
    $.getJSON('/g2', {
      post: x
    }, function(data) {
      var response = data.result;
      //console.log(response);
    });
  var my_url = "/g2?post=" + x;
  queue()
    .defer(d3.json, my_url)
    .await(makeGraphs2)

}


// ---------------------------------------- MAKE GRAPHS 2 ------------------------------------

function makeGraphs2(error, data) {
  d3.selectAll("#zoo").remove();

  lut = data.reduce((p,c) => p[c.year[0]] ? p : (p[c.year[0]] = c, p), {});
  range = [1966,2015];
  result = Array(range[1]-range[0] + 1).fill().map((_,i) => lut[i+range[0]] ? lut[i+range[0]] : {year: [i+range[0]], weight: [0]});

  console.log(result)

  data = result;

  var width = 500;
  var height = 270;

  var margin = {top: 20, right: 20, bottom: 30, left: 50},
      width = width - margin.left - margin.right,
      height = height - margin.top - margin.bottom;

  // Parse the date
  var parseTime = d3.timeParse("%Y");

  // Set the ranges
  var x = d3.scaleTime().range([0, width]);
  var y = d3.scaleLinear().range([height, 0]);

  // Path generation function
  var valueline = d3.line()
    .x(function(d) { return x(d.year); })
    .y(function(d) { return y(d.weight); });

  // Add the SVG canvas
  var svg = d3.select("#main2").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .attr("id", "zoo")
    .append("g")
    .attr("transform","translate(" + margin.left + "," + margin.top + ")");





  // Format the data
  data.forEach(function(d) {
    d.year = parseTime(d.year);
    d.weight = +d.weight;
  });

  // Scale the range of the data
  x.domain(d3.extent(data, function(d) { return d.year; }));
  y.domain([0, d3.max(data, function(d) { return d.weight; })]);

  // Add the valueline path.
  svg.append("path")
    .data([data])
    .attr("class", "line")
    .attr("d", valueline)
    .attr("stroke", "steelblue")
    .attr("fill", "none")
    .attr("stroke-width", "1.5px");

  // Add the X Axis
  svg.append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));

  // Add the Y Axis
  svg.append("g")
    .call(d3.axisLeft(y));

}
// ---------------------------------------- MAKE GRAPHS ------------------------------------
function makeGraphs(error, data) {
  d3.selectAll("svg").remove();
  // Add handlers to data


  var data_list = new Array();
  for (var i = 0; i < data.length; ++i) {
    var centrality = data[i].centrality
    var density = data[i].density
    var id = data[i].cluster
    data_list.push({
      id: id,
      centrality: centrality,
      density: density,
    })
  }
  // Rewrite data back to data
  data = data_list




  var centrality = new Array()
  var density = new Array()
  var cluster = new Array()

  for (var i = 0; i < data.length; ++i) {
    centrality[i] = data[i].centrality
    density[i] = data[i].density
    cluster[i] = data[i].id
  }
  centrality = zScores(centrality)
  density = zScores(density)
  console.log(data_list)


  var data_list = new Array();
  for (var i = 0; i < data.length; ++i) {
    var cent = centrality[i]
    var dens = density[i]
    var id = data[i].id
    data_list.push({
      id: id,
      centrality: cent,
      density: dens,
    })
  }

data = data_list
console.log(data)


var margin = {top: 30, right: 30, bottom: 30, left: 30};

/*  var margin = {top: 30, right: 20, bottom: 30, left: 50},
    width = 500 - margin.left - margin.right,
    height = 270 - margin.top - margin.bottom;*/

width = 700 - margin.left - margin.right
height = 700 - margin.top - margin. bottom
padding = 10;

var tooltip = d3.select('body').append('div')
     .attr('id', 'tooltip');

  // Set the ranges
  /*var x = d3.scaleLinear()
    .domain([0, d3.max(data, function(d) { return parseFloat(d.centrality); })])
    .range([0, width]);*/

  /*var y = d3.scaleLinear()
    .domain([0, d3.max(data, function(d) { return parseFloat(d.density); })])
    .range([height, 0]);*/

  /*var xMean = d3.mean(data, function(d) { return parseFloat(d.centrality); })
  var yMean = d3.mean(data, function(d) { return parseFloat(d.density); })*/

/*var dataset = [];  // Initialize empty array
            var numDataPoints = 15;  // Number of dummy data points
            var maxRange = Math.random() * 10;  // Max range of new values
            for(var i=0; i<numDataPoints; i++) {
                var newNumber1 = Math.floor(Math.random() * maxRange);  // New random integer
                var newNumber2 = Math.floor(Math.random() * maxRange);  // New random integer
                dataset.push([newNumber1, newNumber2]);  // Add new number to array
            }*/



// Create a new svg container
/*var vis = d3.select("#main")
	    .append("svg:svg")
            .attr("width", width)
	    .attr("height", height)
           .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");*/

/*var svg = d3.select("#main")
    .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)*/
    //.append("g")
    //    .attr("transform", 
    //          "translate(" + margin.left + "," + margin.top + ")");

// Scales for new coordinate system
//var xScale = d3.scaleLinear().domain([6, -6]).range([0, width]);
//var yScale = d3.scaleLinear().domain([-6, 6]).range([height, 0]);

// set up the x scale
 

var vis = d3.select("#main")  // This is where we put our vis
                .append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


x0 = [-6, 6],
y0 = [-6, 6]

     var xScale = d3.scaleLinear()
        .domain([-6, 6])
        .range([0, width]); // actual length of axis

      // set up the y scale
      var yScale = d3.scaleLinear()
        .domain([-6, 6])
        .range([height, 0]); // actual length of axis

// define the x axis
      var xAxis = d3.axisBottom(xScale)
        //.scale(xScale)
        //.orient("bottom") // location of lables (default is bottom)
        //.innerTickSize([6]) // This is not working...
        //.outerTickSize([6]); // This is not working...

      // define the y axis
      var yAxis = d3.axisLeft(yScale)
        //.scale(yScale)
        //.orient("left")
        //.innerTickSize([6]) // This is not working...
        //.outerTickSize([6]); // This is not working...



var brush = d3.brush().on("end", brushended),
    idleTimeout,
    idleDelay = 350;
var clip = vis.append("defs").append("svg:clipPath")
     .attr("id", "clip")
     .append("svg:rect")
     .attr("width", width)
     .attr("height", height)
     .attr("x", 0)
     .attr("y", 0);

 /*var brush = d3.brush().extent([
       [0, 0],
       [width, height]
     ]).on("end", brushended),
     idleTimeout,
     idleDelay = 350;*/

  var scatter = vis.append("g")
     .attr("id", "scatterplot")
     .attr("clip-path", "url(#clip)");

   scatter.append("g")
     .attr("class", "brush")
     .call(brush);


//vis.append("g")
  //           .attr("id", "scatterplot")
    //         .attr("clip-path", "url(#clip)");
            // Create Circles
            scatter.selectAll(".dot")
                .data(data)
                .enter().append("circle")  // Add circle svg
                .attr("class", "dot")
                .attr("cx", function(d) {
                    return xScale(d.centrality);  // Circle's X
                })
                .attr("cy", function(d) {  // Circle's Y
                    return yScale(d.density);
                })
                .attr("r", 5)  // radius
//.attr("opacity", 0.5)
.attr("fill", "red")
.on('mouseover', d => {
       tooltip.transition()
         .duration(100)
         .style('opacity', .9);
       tooltip.html("Cluster: " + d.id + "</br>Centrality: " + d.centrality.toFixed(2) + "</br>Density: " + d.density.toFixed(2))
         .style('left', `${d3.event.pageX + 20}px`)
         .style('top', `${d3.event.pageY - 18}px`);
     })
     .on('mouseout', () => {
       tooltip.transition()
         .duration(400)
         .style('opacity', 0);
     })
.on('click', function(d){
    //console.log(d.id)
    if(toggleSelected == true) {
      div.style("display", "block")
      d3.select(this).attr("fill", "red")
      nodeClick(d.id)
      d3.select("#main4").style("display", "block")
      //$("#my_words").jQCloud(d.terms);
      toggleSelected = false;
    } else {
      div.style("display", "none")
      d3.select("#my_words")//.style("display", "none")
      d3.select(this).attr("fill", "black")
      $('#my_words').jQCloud('destroy');
      toggleSelected = true;
      d3.selectAll("#zoo").remove();
      d3.select("#main4").style("display", "none")
    }});




// Draw the x axis
/*var xAxis = d3.axisBottom()
              .scale(xScale)
              //.orient('center');
              //.tickSizeOuter(0)
              //.tickValues([]);

// Draw the y axis
var yAxis = d3.axisLeft()
              .scale(yScale)
              //.orient('right');
              //.tickSizeOuter(0)
              //.tickValues([]);


var xAxisPlot = vis.append("g")
		   .attr("class", "axis axis--x")
		   .attr("transform", "translate(0," + (height/2) + ")")
		   .call(xAxis.tickSize(-height, 0, 0));

var yAxisPlot = vis.append("g")
		   .attr("class", "axis axis--y")
		   .attr("transform", "translate("+ (width/2) +",0)")
		   .call(yAxis.tickSize(-width, 0, 0));
*/


/*xAxisPlot.selectAll(".tick line")
	 .attr("y1", (width - (2*padding))/2 * -1)
	 .attr("y2", (width - (2*padding))/2 * 1);

yAxisPlot.selectAll(".tick line")
	 .attr("x1", (width - (2*padding))/2 * -1)
	 .attr("x2", (width - (2*padding))/2 * 1);*/




      // call the xAxis function to generate the x axis 
      vis.append("g")
        .attr("class", "axis axis--x") // assign an axis class
        .attr("transform", "translate(0, " + (height / 2) + ")")
        .call(xAxis);

      // call the yAxis function to generate the x axis 
      vis.append("g")
        .attr("class", "axis axis--y") // assign an axis class
        .attr("transform", "translate(" + width / 2 + ", 0)")
        .call(yAxis)

/*
      vis.append("g")
            .attr("class", "brush")
            .call(brush);



        function brushended() {

            var s = d3.event.selection;
            if (!s) {
                if (!idleTimeout) return idleTimeout = setTimeout(idled, idleDelay);
                xScale.domain(x0);
                yScale.domain(y0)
                //xScale.domain(d3.extent(data, function (d) { return d.centrality; })).nice();
                //yScale.domain(d3.extent(data, function (d) { return d.density; })).nice();
            } else {
                
                xScale.domain([s[0][0], s[1][0]].map(xScale.invert, xScale));
                yScale.domain([s[1][1], s[0][1]].map(yScale.invert, yScale));
                vis.select(".brush").call(brush.move, null);
            }
            zoom();
        }

        function idled() {
            idleTimeout = null;
        }

        function zoom() {

            var t = vis.transition().duration(750);
            vis.select(".axis--x").transition(t).call(xAxis);
            vis.select(".axis--y").transition(t).call(yAxis);
            vis.selectAll("circle").transition(t)
            .attr("cx", function (d) { return xScale(d.centrality); })
            .attr("cy", function (d) { return yScale(d.density); });
        }
*/

// New
 function brushended() {

     var s = d3.event.selection;
     if (!s) {
       if (!idleTimeout) return idleTimeout = setTimeout(idled, idleDelay);
       //xScale.domain(d3.extent(data, function(d) {
       //  return d.centrality;
       //})).nice();
       //yScale.domain(d3.extent(data, function(d) {
       //  return d.density;
       //})).nice();
xScale.domain(x0);
                yScale.domain(y0)
     } else {

       xScale.domain([s[0][0], s[1][0]].map(xScale.invert, xScale));
       yScale.domain([s[1][1], s[0][1]].map(yScale.invert, yScale));
       scatter.select(".brush").call(brush.move, null);
     }
     zoom();
   }

   function idled() {
     idleTimeout = null;
   }

   function zoom() {

     var t = scatter.transition().duration(750);
     vis.select(".axis--x").transition(t).call(xAxis);
     vis.select(".axis--y").transition(t).call(yAxis);
     scatter.selectAll("circle").transition(t)
       .attr("cx", function(d) {
         return xScale(d.centrality);
       })
       .attr("cy", function(d) {
         return yScale(d.density);
       });
   }







// Border around svg
/*var borderPath = vis.append("rect")
  .attr("x", 0)
  .attr("y", 0)
  .attr("height", height)
  .attr("width", width)
  .style("stroke", "blue")
  .style("fill", "none")
  .style("stroke-width", 1);*/

/*svg.selectAll("circle")
        .data(data)
      .enter().append("circle")
        .attr("r", 3.5)
        .attr("cx", function(d) { return xAxis(parseFloat(d.x)); })
        .attr("cy", function(d) { return yAxis(parseFloat(d.y)); });*/


  // Define Zoom Function Event Listener
  /*function zoomFunction() {
    var transform = d3.zoomTransform(this);
    d3.select("#map_g")
      .attr("transform", "translate(" + transform.x + "," + transform.y + ") scale(" + transform.k + ")");
  }*/

  // Define Zoom Behavior
  /*var zoom = d3.zoom()
    .scaleExtent([1, 5])
    .on("zoom", zoomFunction)*/

/*  var tool_tip = d3.tip()
    .attr("class", "d3-tip")
    .offset([-8, 0])
    .html(function(d) {
    return "Cluster: " + d.id + "</br>Centrality: " + d.centrality.toFixed(2) + "</br>Density: " + d.density.toFixed(2);
  })*/
    
  /*var chart = d3.select('#main')
    .append('svg:svg')
    .attr('width', width + margin.right + margin.left)
    .attr('height', height + margin.top + margin.bottom)
    .attr('class', 'chart')
    .attr("id", "map_g")*/
    /*.call(zoom)
    .call(tool_tip)
    .on("mousedown.zoom", null)
    .on("touchstart.zoom", null)
    .on("touchmove.zoom", null)
    .on("touchend.zoom", null)
    .on('mousedown.drag', null)
    .on("mousemove.zoom", null)
    .on("dragstart", null);*/


/*chart.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "none")
    .style("pointer-events", "all")
    .call(d3.zoom()
        .scaleExtent([1 / 2, 4])
        .on("zoom", zoomed));

function zoomed() {
  chart.attr("transform", d3.event.transform);
}
*/





 /* function resetted() {
    chart.transition()
      .duration(750)
      .call(zoom.transform, d3.zoomIdentity);
  }

  d3.select("button")
    .on("click", resetted);*/


 /* var main = chart.append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    .attr('width', width)
    .attr('height', height)
    .attr('class', 'main')*/

  // Draw the x axis
  /*var xAxis = d3.axisBottom()
    .scale(x)
    //.orient('center')
    .tickSizeOuter(0)
    .tickValues([]);*/

  /*main.append('g')
    .attr('transform', 'translate(0,' + y(yMean) + ')')
    .attr('class', 'main axis date')
    .call(xAxis);*/

  // draw the y axis
  /*var yAxis = d3.axisLeft()
    .scale(y)
    //.orient('right')
    .tickSizeOuter(0)
    .tickValues([]);*/

  /*main.append('g')
    .attr('transform', 'translate(' + x(xMean) + ',0)')
    .attr('class', 'main axis date')
    .call(yAxis);*/







  //var g = main.append("svg:g"); 

  /*var circle = g.selectAll("scatter-dots")
    .data(data)
    .enter().append("svg:circle")
    .attr("cx", function (d,i) { return xAxis(parseFloat(d.centrality)); } )
    .attr("cy", function (d) { return yAxis(parseFloat(d.density)); } )
    .attr("r", 5)
    .attr("fill", "black")
    //.on('mouseover', tool_tip.show)
    //.on('mouseout', tool_tip.hide);*/


  //var g = vis.append("svg:g"); 
  /*var circle = g.selectAll("scatter-dots")
    .data(data)
    .enter().append("svg:circle")
    .attr("cx", function (d) { return xAxis(parseFloat(d.centrality)); } )
    .attr("cy", function (d) { return yAxis(parseFloat(d.density)); } )
    .attr("r", 5)
    .attr("fill", "black")*/


 // draw dots
  /*svg.selectAll("scatter-dots")
      .data(data)
    .enter().append("svg:circle")
      .attr("class", "dot")
      .attr("r", 3.5)
      .attr("cx", function (d) { return xAxis(d.x); } )
      .attr("cy", function (d) { return yAxis(d.y); } )
      .attr("fill", "black");*/
 




  //var circle1 = g.selectAll("scatter-dots")
  //.data(data)
  //.enter().append("text")
  //.attr("x", function (d,i) { return x(parseFloat(d.centrality)); } )
  //.attr("y", function (d) { return y(parseFloat(d.density)); } )
  //.attr("dx", ".71em")
  //.attr("dy", ".35em")
  //.text(function(d) { return d.id;})

 /* circle.on('click', function(d){
    //console.log(d.id)
    if(toggleSelected == true) {
      div.style("display", "block")
      d3.select(this).attr("fill", "red")
      nodeClick(d.id)
      d3.select("#main4").style("display", "block")
      //$("#my_words").jQCloud(d.terms);
      toggleSelected = false;
    } else {
      div.style("display", "none")
      d3.select("#my_words")//.style("display", "none")
      d3.select(this).attr("fill", "black")
      $('#my_words').jQCloud('destroy');
      toggleSelected = true;
      d3.selectAll("#zoo").remove();
      d3.select("#main4").style("display", "none")
    }*/
//}
//);

var div = d3.select("body")
  .append("div")
  .style("display", "none");

};
// ------------------------------------------------------------------------------------------------
function nodeClick(x) {
  $.getJSON('/g2', {
    post: x,
    year: document.getElementById("fyear").value
  }, function(data) {
    var response = data;
    var data_list = new Array();
    for (var i = 0; i < data.length; ++i) {
      var text = data[i].name
      var weight = Math.exp(data[i].z)
      data_list.push({text: text, weight: weight})
    }
    d3.select("#my_words")
    $("#my_words").jQCloud(data_list)
    $('#mesh_table').DataTable({
      destroy: true,
      searching: false,
      data: data,
      columns: [
      {
        data: "dui",
        title: "DUI",
        "render": function ( data, type, full, meta ) {
                 return '<a target="_blank" href="https://meshb.nlm.nih.gov/#/record/ui?ui='+data+'">' + data + '</a>';}
      },
      {
        data: "name",
        title: "Name"
      },
      {
        data: "z",
        title: "Weight",
        className: "dt-right",
        render: function (data, type, full) {
                           return parseFloat(data).toFixed(2);
                }
      }]});
});}


});
