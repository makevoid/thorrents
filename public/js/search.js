

$(function(){
  $("#search form").bind('submit', function(e){
    var url = $(this).attr("action")
    var query = $(this).children("input[name=q]").first().val()
    var json_url = url+"/"+query
    if (rack_env == "development")
      json_url = "/fixture.json"
    console.log("oog")
          
    $.ajax({
      url: json_url,
      dataType: 'json',
      success: function(data){
        console.log("hi")
        console.log(data)
      }
    })
      

    e.preventDefault()
  })
})