//= require prettify.js
//= require xml2html.js
//= require ISO_639_2.min.js

$(document).ready(function() {
  // Deselect all
  $('#deselect-all').click(function() {
    noty({
      text: '<h4 class="text-center">Would you like to deselect all entries ?</h4>',
      layout: 'center',
      buttons: [
        { addClass: 'btn btn-default', text: 'Yes', onClick: function($noty) {
            $noty.close();
            Cookies.remove('selected_entries');
            window.location.href="/doc";
          }
        },
        { addClass: 'btn btn-default', text: 'Cancel', onClick: function($noty) { $noty.close(); }}
      ]
    });
  });

  // Transform language codes
  $(".pr-language").each(function() {
    try{ $(this).html(ISO_639_2[$(this).html()].native[0]); }
    catch (e){}
  });

  // Initialise prettyPrint
  PR.prettyPrint();

  /// Event listener for add-to-list of selected entries
  init_selected_checkboxes();
});
