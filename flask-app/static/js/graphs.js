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
  $('#fieldSize').val('20')
  // Display data for 1966 at the beginning
  var url_init = "/query1?year=1966&size=10";
  queue()
    .defer(d3.json, url_init)
    .await(makeGraphs);
    document.getElementById("fieldYear").value = 1966

  // Later we can choose values
  $("input").change(function() {
    var url = "/query1?year=" + document.getElementById("fieldYear").value + "&size=" + document.getElementById("fieldSize").value
    queue()
      .defer(d3.json, url)
      .await(makeGraphs);
  });
});


function makeGraphs(error, data) {
  // Remove svg canvas before drawing new data
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

  var margin = {top: 30, right: 30, bottom: 30, left: 30},
    width = 700 - margin.left - margin.right,
    height = 700 - margin.top - margin.bottom;

  var tooltip = d3.select('body').append('div')
                                 .attr('id', 'tooltip');


  var vis = d3.select("#scatterplot")
              .append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
              .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x0 = [-6, 6],
  y0 = [-6, 6]

  // Set up the x axis
  var xScale = d3.scaleLinear()
                 .domain(x0)
                 .range([0, width]);

  // Set up the y scale
  var yScale = d3.scaleLinear()
                 .domain(y0)
                 .range([height, 0]);

  // Define the x axis
  var xAxis = d3.axisBottom(xScale)

  // Define the y axis
  var yAxis = d3.axisLeft(yScale)

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

  var scatter = vis.append("g")
                   .attr("id", "scatterplot")
                   .attr("clip-path", "url(#clip)");

  scatter.append("g")
         .attr("class", "brush")
         .call(brush);

  scatter.selectAll(".dot")
         .data(data)
         .enter().append("circle")
         .attr("class", "dot")
         .attr("cx", function(d) {
           return xScale(d.centrality);
         })
         .attr("cy", function(d) {
           return yScale(d.density);
         })
         .attr("r", 5)
         .attr("fill", "black")
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
         .on("click", function(d) {
           d3.selectAll('.dot')
             .style('fill', 'black')
           d3.select(this)
             .style('fill', 'red');
           dotClick(d.id)
         })

  // Call the xAxis function to generate the x axis 
  vis.append("g")
     .attr("class", "axis axis--x") // assign an axis class
     .attr("transform", "translate(0, " + (height / 2) + ")")
     .call(xAxis);

  // Call the yAxis function to generate the x axis 
  vis.append("g")
     .attr("class", "axis axis--y") // assign an axis class
     .attr("transform", "translate(" + width / 2 + ", 0)")
     .call(yAxis)

  // Zoom functions
  function brushended() {
    var s = d3.event.selection;
    if (!s) {
      if (!idleTimeout) return idleTimeout = setTimeout(idled, idleDelay);
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

  $("#wordcloud").css({
    'height': ($("#scatterplot").height() + 'px')
  });
};

function dotClick(x) {
  $.getJSON('/query2', {
    cluster: x,
    year: document.getElementById("fieldYear").value
  }, function(data) {
    var response = data;
    var data_list = new Array();
    for (var i = 0; i < data.length; ++i) {
      var text = data[i].name
      var weight = Math.exp(data[i].z)
      data_list.push({text: text, weight: weight})
    }
    d3.select("#wordcloud")
    $("#wordcloud").jQCloud(data_list, {autoResize: true})
    $('#wordcloud').jQCloud('update', data_list);
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
