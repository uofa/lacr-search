$(document).ready(function() {
  var dateFormat = 'dd/mm/yy';
  var minDate = '01/01/1398';
  var maxDate = '31/12/1511';
  // Initialise date fields for Advanced Search
  $( "#date_from" ).datepicker({
    showOtherMonths: true,
    selectOtherMonths: true,
    dateFormat: dateFormat,
    minDate: $.datepicker.parseDate( dateFormat, minDate ),
    maxDate: $.datepicker.parseDate( dateFormat, maxDate ),
    defaultDate: $.datepicker.parseDate( dateFormat, minDate )
  }).on( "change", function() {
    $( "#date_to" ).datepicker( "option", "minDate", getDate( this ) );
    if ($("#date_to").val() == ""){
      $("#date_to").val($("#date_from").val());
  }
    // if date_to not set, set to same value.
  });

  $( "#date_to" ).datepicker({
    showOtherMonths: true,
    selectOtherMonths: true,
    dateFormat: dateFormat,
    minDate: $.datepicker.parseDate( dateFormat, minDate ),
    maxDate: $.datepicker.parseDate( dateFormat, maxDate ),
    defaultDate: $.datepicker.parseDate( dateFormat, maxDate )
  }).on( "change", function() {
    $( "#date_from" ).datepicker( "option", "maxDate", getDate( this ) );
  });

  function getDate( element ) {
    var date;
    try {
      date = $.datepicker.parseDate( dateFormat, element.value );
    } catch( error ) {
      date = null;
    }
    return date;
  }

  window.onresize = function() {
    responsiveScreen();
  };

  var responsiveScreen = function() {
    screenCheck = $(window).height() > 630 && $(window).width() > 1024;
    $.fn.fullpage.setFitToSection(screenCheck);
    $.fn.fullpage.setAutoScrolling(screenCheck);
  };

  // Initialise FullPageJS
    $('#fullpage').fullpage({
      anchors:['homepage', 'advsearch', 'about'],
      navigation: true,
      paddingTop: '60px',
      scrollBar: true,
      onLeave: function(index, nextIndex, direction){
        // Hide datepicer after leaving Advanced Search section
        if(index == 2){
          $( ".datepicker" ).datepicker('hide');
        }
      },
      // Focus earch input field
      afterLoad: function(anchorLink, index){
         if(index == 1 || index == 2){$('.simple-search').eq(index-1).focus();}
       }
    });

    // Toggle spelling variants on Regular expressions selected
   $('input[name="sm"]').on('click', toggleMisspellings);
   toggleMisspellings();

});

var toggleMisspellings = function () {
  $disabled = $('input:checked[name="sm"]').val() == 5;
  $('#spellVar').prop('disabled', $disabled);
};

$('#adv-search-nav').click(function(){
    $.fn.fullpage.moveTo('advsearch');
});

$('#about-nav').click(function(){
    $.fn.fullpage.moveTo('about');
});

$('#home-nav').click(function(){
    $.fn.fullpage.moveTo('homepages');
});

$('.fp-controlArrow-down').click(function(){
    $.fn.fullpage.moveSectionDown();
});

$('input[name=vc]').on('change', function() {
  toggle_volume_list();
});

toggle_volume_list = function() {
  if ($("input[name=vc]:checked").val() == 0) {
    $('.volume-chooser .list').css('display', 'none');
    $("input.vol").prop('checked', true);
  } else {
    $('.volume-chooser .list').css('display', 'block');
  }
}

function submitForm(){
  var name=$('.vol');
  var str="";
  try {
    for(i=0;i<(name.length);i++){
      if(name[i].checked){
        str+=name[i].value+",";
      }
    }
    if(str.length>0){str=str.substring(0,str.length-1);} // remove the last comma
    $('input[name="v"]').attr('value', str);

  } catch (e) {}
  $('#adv-search').submit();
}
