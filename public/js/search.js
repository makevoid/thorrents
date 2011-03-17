

$(function(){
  $("#search form").bind('submit', function(e){
    var url = $(this).attr("action")
    var query = $(this).children("input[name=q]").first().val()
    var json_url = url+"/"+query
    if (rack_env == "development")
      json_url = "http://thorrents.makevoid.com/search/"+query
      json_url = "/fixture.json"
    console.log("oog")
          
    $.ajax({
      url: json_url,
      dataType: 'json',
      success: function(data){
        // data: 
        
        console.log("hi")
        console.log(data)
        


        var template = "<ul>{{#results}}<li><a href='{{magnet}}'>{{seeds}} - {{name}}</a></li>{{/results}}</ul>"

        var html = Mustache.to_html(template, data)
        
        $("#results").html(html)
      }
    })
      

    e.preventDefault()
  })
})