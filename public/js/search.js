$(function(){
  // search
  
  var alreadyPushedHome = false
  var template = $("#result_tmpl").html()
  
  function pushToHome() {
    var title = "Thorrents"
    var stateObj = { action: {} };
    history.pushState(stateObj, title, "/");
    $("title").html(title)
    alreadyPushedHome = false
  }
  
  function do_search(mod) {
    //var url = $(this).attr("action")
    var url = "/search"  
    var query = $("#search form input[name=q]").first().val()
    var json_url = url+"/"+query+".json"
    if (rack_env == "development") {
      json_url = "http://thorrents.makevoid.com/search/"+query
      json_url = "/fixture_no_results.json"
      json_url = "/fixture.json"
    }
                
    if (query != "") {
      if (mod != "noPush") {
        var stateObj = { action: { search: query } };
        var title = "Thorrents search: "+query
        history.pushState(stateObj, title, "/search/"+query);
        $("title").html(title)      
      }
      
      $("#spinner").show("fast")
      $.ajax({
        url: json_url,
        dataType: 'json',
        success: function(data){                
          $("#spinner").hide("fast")
        
          var html = Mustache.to_html(template, data)
          $("#results").html(html)
        }
      })
    } else {
      if (mod != "noPush") {
        var title = "Thorrents"
        var stateObj = { action: {} };
        history.pushState(stateObj, title, "/");
        $("title").html(title)
      }
    }
  }

  
  $("#search form").bind('submit', function(e){
    do_search()
      
    e.preventDefault()
  })
  
  
  $("#search form input[name=q]").keyup(function(){
    if ($(this).val() == "") {
      $("#results").html("")
      if (!alreadyPushedHome) {
        pushToHome()
        alreadyPushedHome = true
      }
    }
  })
  
  window.onpopstate = function(event){
    state = event.state
    if (state.action.search) {
      $("#search form input[name=q]").val(state.action.search)
      do_search("noPush")
    } else {
      $("#results").html("")
      $("#search form input[name=q]").val("")
      alreadyPushedHome = true
    }
  }
  
  
  // results
  
  $("#results .res").live("click", function(evt){
    var url = $(this).children("a").attr("href") 

    $(this).parent().find(".fb_share").remove()      
    var fb_like = "<fb:like href='http://thorrents.com' layout='button_count' show_faces='false' width='100' font='lucida grande'></fb:like>"
    $(this).parent().append("<div class='fb_share'>"+fb_like+"</div>")
    FB.init({appId: FB_APP_ID, status: true, cookie: true, xfbml: true});
    
    if (url)
      document.location = url

      
    evt.preventDefault()
  })
})