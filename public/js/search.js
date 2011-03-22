$(function(){
  $("#search form").bind('submit', function(e){
    $("#spinner").show("fast")
    //var url = $(this).attr("action")
    var url = "/search"  
    var query = $(this).children("input[name=q]").first().val()
    var json_url = url+"/"+query
    if (rack_env == "development") {
      json_url = "http://thorrents.makevoid.com/search/"+query
      json_url = "/fixture.json"
      json_url = "/fixture_no_results.json"
    }
          
    $.ajax({
      url: json_url,
      dataType: 'json',
      success: function(data){      
        $("#spinner").hide("fast")
        var template = $("#result_tmpl").html()
        
        var html = Mustache.to_html(template, data)
        $("#results").html(html)
      }
    })
      
    e.preventDefault()
  })
})