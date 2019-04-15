//= require ISO_639_2.min.js
var $selected = {};

function download_zip(img){
  img = (img !== 'undefined') ? img : false;
  var n;
  $.ajax({
    type: 'POST',
    data: {'selected': $selected, 'img': img},
    url: 'ajax/download',
    cache:false,
    beforeSend: function(){
      $.noty.closeAll();
      n = noty({text: '<h4 class="text-center"><i class="fa fa-cog fa-spin fa-fw"></i> Creating an archive...</h4>',
                           layout: 'center',
                           type: 'information'});
    }
  }).success(
    function(response) {
      n.setType(response.type);
      n.setTimeout(5000);
      if (response.type == 'success') {
        n.setText('<h4 class="text-center"><i class="fa fa-check" aria-hidden="true"></i> '+response.msg+'</h4>');
        Download(response.url);
      }
      else {
        n.setText('<h4 class="text-center"><i class="fa fa-exclamation-circle" aria-hidden="true"></i> '+response.msg+'</h4>');
      }
    })
    .fail(function(response) {

        var byteArray = new Uint8Array(response);
        var blob = new Blob(byteArray, {type: "application/zip"});
        $('#file_download').html(blob);
      $.noty.closeAll();
      n = noty({timeout: 5000, text: '<h4 class="text-center"><i class="fa fa-exclamation-circle" aria-hidden="true"></i> Connection failure...</h4>', layout: 'center', type: 'error'});
    });
}

function show_browser(){
  // Show pages of the first Volume in the list
    var first_volume = $($("[data-collapse-group='volume']")[0]);
    var first_volume_pages = $(first_volume).attr('data-target');
    var first_volume_no = $(first_volume).attr('data-vol');
    // Collapse in the first volume
    $(first_volume_pages).collapse('show');
    //Add active class on the first volume
    $(first_volume).addClass('active');
    //Add active class on the first page
    $($(first_volume_pages)[1]).addClass('active');
    // Show documents browse
    $('#doc-browse').show();
    $('.doc-tools').show();


  // Load the first page of the first volume
    var first_page_no = $(first_volume_pages).children().first().attr('data-page');
    load_document(p=first_page_no, v=first_volume_no);
}

function load_document (p, v){
  $('#doc-title').html("Volume: "+v+" Page: "+p);
  $("#transcriptions").load("/doc/page-s?p="+p+"&v="+v, function(responseTxt, statusTxt, xhr){
        if(statusTxt == "success"){
          // Transform language codes
          $(".pr-language").each(function() {
            try { $(this).html(ISO_639_2[$(this).html()].native[0]); }
            catch (e) {}
          });
          // Event listener for add-to-list of selected entries
          init_selected_checkboxes();
        }
    });
  $("#doc_view").attr('href', "/doc/show?p="+p+"&v="+v);
  $('#doc_view').css('display', 'inline-block');
  $('div.active').removeClass("active");
  $('#vol-'+v+'-page-'+p).addClass("active");
}

function Download(url) {
    $('#file_download').attr('src', url);
}

$(document).ready(function() {

  function ajax_loader(){
    $.getJSON( "/ajax/doc/list").done(function(data) {
      // Clear content before loading
      $('#volume').html('');
      $('#page').html('');
      $selected = {};
      // Disable buttons when nothing has been $selected
      $('.doc-tools').attr("disabled", true);

      if (data.length === 0){
        $('#doc-title').html('No documents have been found.');
        $('.doc-tools').hide();
        $('#doc_view').hide();
        $('#doc-browse').hide();
      }
      else {
        var VolumeHTML = "";
        var PageHTML = "";
        var oldVol = null;
        var volumes = [];
          $.each( data, function( i, e ) {
              v = e.volume;
              p = e.page;
              if(oldVol !== v){
                oldVol = v;
                VolumeHTML += '<button id="vol-'+v+'"' +
                            'data-vol="'+v+'"'+
                            'data-collapse-group="volume"' +
                            'class="btn btn-primary btn-block"' +
                            'onclick="$(\'.vol-'+v+'\').collapse(\'show\');"' +
                            'data-target=".vol-'+v+'">' +
                            'Volume '+v+' <span id="badge-'+v+'" class="badge"></span>'+
                            '</button>';
                volumes[v] = '<a href="#" data-vol="'+v+'" data-page="'+
                             p+'" class="vol-'+v+' list-group-item row">'+
                            '<label><input type="checkbox" data-vol="'+v+'" data-page="all">'+
                            ' Select all</label></a>';
              }
              volumes[v] += '<a data-vol="'+v+'" '+
                                 'data-page="'+p+'" '+
                                 'class="list-group-item row" '+
                                 'onclick="$(\'a\').removeClass(\'active\');$(this).addClass(\'active\');load_document(p='+p+', v='+v+');">'+
                                '<input type="checkbox"'+
                                       'data-vol="'+v+'"'+
                                       'data-page="'+p+'"'+
                                       'name="vol-'+v+'-page-'+p+'"> Page '+p+
                           '</a>';
          });
          for(var i in volumes){
            PageHTML += '<div class="vol-'+i+' collapse">' + volumes[i] + "</div>";
          }
          $( "#volume" ).html( VolumeHTML );
          $( "#page" ).html( PageHTML );

          // Display the page after it has been build
          show_browser();

          // Collpse other volumes on open
          $("[data-collapse-group='volume']").click(function () {
              var $this = $(this);
              $("[data-collapse-group='volume']").removeClass('active');
              $(this).addClass('active');
              $("[data-collapse-group='volume']:not([data-target='" + $this.data("target") + "'])").each(function () {
                  $($(this).data("target")).removeClass("in").addClass('collapse');
              });
          });

          // Update badge value when checkbox has been changed
          $(":checkbox").change(function(){
            var $chkbox_vol = $(this).attr('data-vol');
            var $chkbox_page = $(this).attr('data-page');
            var $vol_badge = $('#badge-'+$chkbox_vol);

            // If select all
            if ($chkbox_page == 'all') {
              var $chk_boxes = $('input[data-page!="all"][data-vol="'+$chkbox_vol+'"]');
              $chk_boxes.prop('checked', $(this).is(":checked"));
              if ($(this).is(":checked")) {
                // Indicate with badge on the volume
                $vol_badge.html($chk_boxes.length);
                // Add checked page to list
                $chk_boxes.each(function(){
                  $selected[$(this).attr('name')] = {'volume': $chkbox_vol, 'page':$(this).attr('data-page')};
                });
              } else {
                // Remove chacked page from list
                $chk_boxes.each(function(){
                  delete $selected[$(this).attr('name')];
                });
                // Do not show 0 badge
                $vol_badge.html('');
              }
            }
            else {

              var $chkbox_name = $(this).attr('name');
              var badge_value = $vol_badge.html();

              // Convert "badge_value" from str to int
              if (badge_value) total_chked = parseInt(badge_value); else total_chked = 0;

              // If Checked
              if ($(this).is(":checked")) {
                // Indicate with badge on the volume
                $vol_badge.html(total_chked+1);
                // Add checked page to list
                $selected[$chkbox_name] = {'volume': $chkbox_vol, 'page':$chkbox_page};
              } else {
                // Remove chacked page from list
                delete $selected[$chkbox_name];
                // Do not show 0 badge
                if (total_chked <= 1) $vol_badge.html(''); else $vol_badge.html(total_chked-1);
              }
            }

            // Disable buttons when nothing has been $selected
            $('.doc-tools').attr("disabled", Object.keys($selected).length === 0);
          });
        }
    });}

  //Load the list of volumes and pages using ajax
  ajax_loader();

    $('#doc_download').click(function(){download_zip();});
    $('#doc_download_img').click(function(){download_zip(img="jpeg");});
    $('#doc_download_img_orig').click(function(){download_zip(img="tiff");});


    $('#doc_delete').click(function() {
      selected_len = Object.keys($selected).length;
      if (selected_len > 0) {
        var n;
        noty({
          text: '<h4 class="text-center"><i class="fa fa-exclamation" aria-hidden="true"></i> <b>'+selected_len+'</b> page(s) will be removed.<br />Do you want to continue?</h4>',
          layout: 'center',
          buttons: [
            {addClass: 'btn btn-danger', text: 'Yes', onClick: function($noty) {
                $noty.close();

                $.ajax({
                  type: 'POST',
                  data: {'selected': $selected},
                  url: 'ajax/doc/destroy',
                  cache:false,
                  beforeSend: function(){
                    $.noty.closeAll();
                    n = noty({text: '<h4 class="text-center"><i class="fa fa-cog fa-spin fa-fw"></i> Removing documents...</h4>',
                                         layout: 'center',
                                         type: 'information'});
                  }
                }).success(function(response) {
                    n.setType(response.type);
                    n.setTimeout(3000);
                    if (response.type == 'success') {
                      n.setText('<h4 class="text-center"><i class="fa fa-check" aria-hidden="true"></i> '+response.msg+'</h4>');
                      ajax_loader();
                    }
                    else {
                      n.setText('<h4 class="text-center"><i class="fa fa-exclamation-circle" aria-hidden="true"></i> '+response.msg+'</h4>');
                    }
                  })
                  .fail(function() {
                    $.noty.closeAll();
                    n = noty({timeout: 5000, text: '<h4 class="text-center"><i class="fa fa-exclamation-circle" aria-hidden="true"></i> Connection failure...</h4>', layout: 'center', type: 'error'});
                  });
              }
            },
            {addClass: 'btn btn-default', text: 'Cancel', onClick: function($noty) {$noty.close();}}
          ] // buttons:
        }); // noty({
      } // if ($selected.length > 0) {
    }); // $('#doc_delete').click(function() {
}); // $(document).ready(function()
