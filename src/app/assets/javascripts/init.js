// Store list of selected entries
s_list = Cookies.get('selected_entries');
var selected_list = s_list !== undefined ? s_list.split(',') : [];

var init_selected_checkboxes = function (){
  // Event listener for add-to-list of selected entries
  $('.add-to-list').click(function(){
    // Store the entry ID
    var entryID = $(this).attr('data-entry');

      if($(this).is(":checked")) {
        selected_list.push(entryID);
        Cookies.set('selected_entries', selected_list.toString());
        $("#documents-btn").hide();
        $("#documents-selected-btn").show();
        // Show tooltip if this is the first selected entry
        if (selected_list.length == 1) {
          $('#doc_caret').tooltip('show');
          // Set 5 sec timeout.
          setTimeout(function () { $('#doc_caret').tooltip('hide'); }, 5000);
        }

      } else {
        // Remove all records with this entryID
        selected_list = jQuery.grep(selected_list, function( a ) { return a !== entryID ;});
        Cookies.set('selected_entries', selected_list.toString());
        // If on select page remove hide the entry
        if (window.location.pathname == "/doc/selected") { $('#'+entryID).fadeOut(); }
        // Remove the cookie if no selected documents are left
        if (selected_list.length === 0) {
          $("#documents-selected-btn").hide();
          $("#documents-btn").show();
          Cookies.remove('selected_entries');
          // Redirect to documents
          if (window.location.pathname == "/doc/selected") { window.location.pathname="/doc"; }
        }
      }
  });

  // Set to checked add-to-list if it is already in the list
  $('.add-to-list').each(function () {$(this).prop('checked', selected_list.indexOf($(this).attr("data-entry")) >= 0);});
};

/* Adding a parameter to the URL
 * key - name of parameter
 * value - value of parameter
 * remove - parameter to be removed from url
 */
function insertParam(key, value, remove) {
  remove = (remove !== 'undefined') ? remove : '';
    key = encodeURI(key); value = encodeURI(value); remove = encodeURI(remove);
    var kvp = document.location.search.substr(1).split('&');
    var i=kvp.length, found=false;
    while(i--)
    {
        x = kvp[i].split('=');
        if (x[0]==remove) {kvp.splice(i, 1);}
        else if (x[0]==key && !found)
        {
            x[1] = value;
            kvp[i] = x.join('=');
            found=true;
        }
    }
    if(!found) {kvp[kvp.length] = [key,value].join('=');}
    //this will reload the page, it's likely better to store this until finished
    document.location.search = kvp.join('&');
  }

$(document).ready(function() {

  $('#documents-selected-btn').hover(function() {
    $('#doc_caret').tooltip('hide');
  });
  // Enable autocomplete
  $('.simple-search').autocomplete({minLength: 2,source: '/ajax/search/autocomplete'});
  $('#entry').autocomplete({minLength: 2, source: '/ajax/search/autocomplete-entry'});

  $('#adv-search').submit(function () {
    // Ignore empty values
    if($('#content').val() === ''){$('#content').attr('value', '*');}

    $(this).find('[name]').each(function(){
      if($(this).val() === ''){
        $(this).filter(function (input) {
          return !input.value;
        })
        .prop('name', '');
      }
    });

    // Ignore submit button
    $(this).find('[name="commit"]').filter(function (input) { return !input.value;}).prop('name', '');
  });
});
