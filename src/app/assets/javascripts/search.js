//= require highlightRegex.min.js

toggle_search_tools_when_regex = function(){
  $disabled = $("select[name='sm']").val() == 5;
  $("select[name='m']").prop("disabled", $disabled);
};



$(function() {
  // Search method is Regex
  $('select').on('change', function() {
    toggle_search_tools_when_regex();
  });

  toggle_search_tools_when_regex();
  if($("select[name='sm']").val() == 5){
    $('.list-group-item').highlightRegex(new RegExp($("input.simple-search").val(), "ig"));
  }
});
