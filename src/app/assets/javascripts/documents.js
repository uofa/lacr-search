//= require jquery.zoom.min.js
//= require prettify.js
//= require xml2html.js
//= require ISO_639_2.min.js

var jqxhr;

// Load partial content
var load_document = function (p, v){
  $('#doc-title').html("Volume: "+v+" Page: "+p);
  $("#transcription-image").load("/doc/page?p="+p+"&v="+v, function(responseTxt, statusTxt, xhr){
        if(statusTxt == "success"){
          // Transform language codes
          $(".pr-language").each(function() {
            try {
              $(this).html(ISO_639_2[$(this).html()].native[0]);
            } catch (e) {}
          });

          // Image zoom on hover
          $('#doc-image').zoom({
            url: $('#doc-image img').data('largeImage')
          });

          // Initialise prettify
          try {PR.prettyPrint(); } catch (e) {console.log(e);}

          // Event listener for add-to-list of selected entries
          init_selected_checkboxes();

          // If there is an image
          if($('#doc-image').length){
            // Enable scroll for transcriptions
            $('#doc-transcriptions').height("600px");
            $('#doc-transcriptions').css("overflow", "auto");
          }
        }
    });
  $('div.active').removeClass("active");
  $('#vol-'+v+'-page-'+p).addClass("active");

};

$(document).ready(function() {

  //Load the list of volumes and pages using ajax
  jqxhr = $.getJSON( "/ajax/doc/list")
      .done(function(data) {
        $.each( data, function( i, e ) {
            if($('#vol-'+e.volume).length === 0){
              $('<button id="vol-'+e.volume+'" class="btn btn-primary btn-block" data-toggle="collapse" data-target=".vol-'+e.volume+'">Volume '+e.volume+'</li>').appendTo('#doc_nav');
              $('<div class="vol-'+e.volume+' collapse">').appendTo('#doc_nav');
            }
            $('<div id="vol-'+e.volume+'-page-'+e.page+'"><a onclick="load_document(p='+e.page+', v='+e.volume+');">Page '+e.page+'</a></div>').appendTo('.vol-'+e.volume);
        });
      });
});
