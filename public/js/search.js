var template = "<ul><li class='heading'><span>Seeds</span></li>{{#results}}<li><a href='{{magnet}}'><span>{{seeds}}</span>{{name}}</a></li>{{/results}}</ul>"

$(function(){
  $("#search form").bind('submit', function(e){
    var url = $(this).attr("action")
    var query = $(this).children("input[name=q]").first().val()
    var json_url = url+"/"+query
    if (rack_env == "development") {
      json_url = "http://thorrents.makevoid.com/search/"+query
      json_url = "/fixture.json"
    }
          
    $.ajax({
      url: json_url,
      dataType: 'json',
      success: function(data){      
        var html = Mustache.to_html(template, data)
        $("#results").html(html)
      }
    })
      
    e.preventDefault()
  })
})