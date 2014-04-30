

$(document).ready(function() {
  var tagTextArea = $("#new_tags");
  $(".tag_cloud >> li").each(function(i, element) {
   $(element).on("click", function() {
     tagTextArea.val(tagTextArea.val() + ", " + $(this).text())
   })
  });
});//end of doc.ready 

