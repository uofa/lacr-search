// Javascript where to toggle the xml tags
function toggle_xml(e){
  $(e).toggleClass('btn-success');
  $(e).parents('.panel-body').children('.transcription').toggle("slow");
  $(window).trigger('resize'); // Fix for FullPageJS
}
