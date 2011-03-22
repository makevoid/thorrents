$(function(){
  // search

  var template = $("#result_tmpl").html()
  
  $("#search form").bind('submit', function(e){
    $("#spinner").show("fast")
    //var url = $(this).attr("action")
    var url = "/search"  
    var query = $(this).children("input[name=q]").first().val()
    var json_url = url+"/"+query
    if (rack_env == "development") {
      json_url = "http://thorrents.makevoid.com/search/"+query
      json_url = "/fixture_no_results.json"
      json_url = "/fixture.json"
    }
          
    $.ajax({
      url: json_url,
      dataType: 'json',
      success: function(data){      
        $("#spinner").hide("fast")
        
        var html = Mustache.to_html(template, data)
        $("#results").html(html)
      }
    })
      
    e.preventDefault()
  })
  
  $("#search form input[name=q]").keyup(function(){
    if ($(this).val() == "")
      $("#results").html("")
  })
  
  
  // results
  
  $("#results li").live("click", function(evt){
    var url = $(this).children("a").attr("href") 
    if (url)
      document.location = url

    $(this).children(".fb_share").remove()      
    var fb_like = "<fb:like href='http://thorrents.com' layout='button_count' show_faces='false' width='100' font='lucida grande'></fb:like>"
    $(this).append("<div class='fb_share'>"+fb_like+"</div>")
    FB.init({appId: FB_APP_ID, status: true, cookie: true, xfbml: true});
      
    evt.preventDefault()
  })
})