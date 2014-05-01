

$(document).ready(function() {
  
  //used in #show to make tags clickable.
  var tagTextArea = $("#new_tags");
  $(".tag_cloud >> li").each(function(i, element) {
   $(element).on("click", function() {
     tagTextArea.val(tagTextArea.val() + ", " + $(this).text())
   })
  });
  
  //used to filter by tags in #index
  
  //used to filter by states in #index
  $(".state_filter").on("click", function(element) {
    console.log("in the handler!");
    
  })
  
});//end of doc.ready 

