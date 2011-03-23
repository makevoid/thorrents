$(function(){
  // search
  
  var alreadyPushedHome = false
  var template = $("#result_tmpl").html()
  
  function pushToHome() {
    var title = "Thorrents"
    var stateObj = { action: {} }
    if (history.pushState)
      history.pushState(stateObj, title, "/")
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
        if (history.pushState)
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
        var stateObj = { action: {} }
        if (history.pushState)
          history.pushState(stateObj, title, "/")
        $("title").html(title)
      }
    }
  }

  function prevent_default(event) {
    event.preventDefault ? event.preventDefault() : event.returnValue = false
    if(event.preventDefault){ event.preventDefault()}
       else{event.stop()}
    
    event.stopPropagation()
  }

  $("#search form").live('submit', function(e){
    do_search()
    
    prevent_default(e)
    return false
  })
  
  $("#search form input.submit").click(function(e){
    do_search()
    prevent_default(e)
    return false
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