String.prototype.titleize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

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
          $("#thor_bg").fadeIn("slow")
        
          var html = Mustache.to_html(template, data)
          $("#results").html(html)
          if (data.results == [])
            $("#thor_bg").fadeOut("slow")
        }
      })
    } else {
      $("#thor_bg").fadeOut("slow")
      if (mod != "noPush") { // FIXME: home????
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
    if (state && state.action.search) {
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
    var query = $("#search form input[name=q]").first().val()
    var url = $(this).children("a").attr("href") 
    result = $(this).children("a").text()
    result = result.replace(/[^a-z1-9]+/gi, " ").trim().replace(/\s/g, "_").toLowerCase()
    $(".res").removeClass("shared")
    $(this).addClass("shared")
    
    $(".fb_share").remove()
    $(this).parent().find(".fb_share").remove()      
    var fb_like = "<fb:like href='"+fb_base_url+"/"+query+"/"+result+"' layout='button_count' show_faces='false' width='100' font='lucida grande'></fb:like>"
    $(this).parent().append("<div class='fb_share'>"+fb_like+"</div>")
    FB.init({appId: FB_APP_ID, status: true, cookie: true, xfbml: true});
    
    // adding result to history
    var query = $("#search form input[name=q]").first().val()
    var stateObj = { action: { search: query } };
    var title = "Thorrents search: "+query
    if (history.pushState)
      history.pushState(stateObj, title, "/search/"+query+"/"+result);
    $("title").html(title)
    
    // meta tags
    result_title = result.replace(/_/g, " ").titleize()
    $("meta[property=og:title]").attr("content", "I downloaded '"+result_title+"' with Thorrents")
    $("meta[property=og:url]").attr("content", fb_base_url+"/"+query+"/"+result)
    
    if (url)
      document.location = url

      
    evt.preventDefault()
  })
})