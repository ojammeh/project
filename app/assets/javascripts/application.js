// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.blockUI
//= require bootstrap-datepicker
//= require_tree .

// function showRow(row)
// {
// var x=row.cells;
// document.getElementById("msisdn").value = x[0].innerHTML;
// }
// (function () {
//     if (window.addEventListener) {
//         window.addEventListener('load', run, false);
//     } else if (window.attachEvent) {
//         window.attachEvent('onload', run);
//     }

//     function run() {
//         var t = document.getElementById('myTable');
//         t.onclick = function (event) {
//             event = event || window.event; //IE8
//             var target = event.target || event.srcElement;
//             while (target && target.nodeName != 'TR') { // find TR
//                 target = target.parentElement;
//             }
//             //if (!target) { return; } //tr should be always found
//             var cells = target.cells; //cell collection - https://developer.mozilla.org/en-US/docs/Web/API/HTMLTableRowElement
//             //var cells = target.getElementsByTagName('td'); //alternative
//             if (!cells.length || target.parentNode.nodeName == 'THEAD') {
//                 return;
//             }
//             var f1 = document.getElementById('msisdn');
//             // var f2 = document.getElementById('lastname');
//             // var f3 = document.getElementById('age');
//             // var f4 = document.getElementById('total');
//             // var f5 = document.getElementById('discount');
//             // var f6 = document.getElementById('diff');
//             f1.value = cells[0].innerHTML;
//             // f2.value = cells[1].innerHTML;
//             // f3.value = cells[2].innerHTML;
//             // f4.value = cells[3].innerHTML;
//             // f5.value = cells[4].innerHTML;
//             // f6.value = cells[5].innerHTML;
//             //console.log(target.nodeName, event);
//         };
//     }

// })();
$("input#msisdn").on({
  keydown: function(e) {
    if (e.which === 32)
      return false;
  },
  change: function() {
    this.value = this.value.replace(/\s/g, "");
  }
});
function fillme(o){
    var inputs=document.getElementsByTagName('input');
    var tds=o.getElementsByTagName('td');

    for(a in tds){
        inputs[a].value=tds[a].innerHTML;
    }
}
 function isNumberKey(evt)
      {
         var charCode = (evt.which) ? evt.which : event.keyCode
         if (charCode > 31 && (charCode < 48 || charCode > 57))
            return false;

         return true;
      }

   	var downStrokeField;
		function autojump(fieldName,nextFieldName,fakeMaxLength)
		{
		var myForm=document.forms[document.forms.length - 1];
		var myField=myForm.elements[fieldName];
		myField.nextField=myForm.elements[nextFieldName];

		if (myField.maxLength == null)
		   myField.maxLength=fakeMaxLength;

		myField.onkeydown=autojump_keyDown;
		myField.onkeyup=autojump_keyUp;
		}

		function autojump_keyDown()
		{
		this.beforeLength=this.value.length;
		downStrokeField=this;
		}

		function autojump_keyUp()
		{
		if (
		   (this == downStrokeField) && 
		   (this.value.length > this.beforeLength) && 
		   (this.value.length >= this.maxLength)
		   )
		   this.nextField.focus();
		downStrokeField=null;
	}

	$(document).ready(function() { 
		
	    $('#deact_funring').click(function() { 
	        $.blockUI({ 
            message: '<h1>Deactivating FunRing...</h1>'}); 
	 
	        setTimeout(function() { 
	            $.unblockUI({ 
	                onUnblock: function(){ alert('Please Wait 3 Minutes for Deactivation to take effect.DO NOT REPEAT THIS ACTION.'); } 
	            }); 
	        }, 5000); 
	    }); 


    $('#show_tone').click(function() { 
        $.blockUI({ 
            message: '<h1>Loading Ring Tones...</h1>', 
            timeout: 4000 
        }); 
    });

    $('#active_jazeera').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Jazeera...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_jazeera').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Jazeera...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_sport').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Sport Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_sport').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Sport Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_prayertime').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Prayer Time...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_prayertime').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Prayer Time...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_names').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating 99 Names of Allah...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_names').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating 99 Names of Allah...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_boy').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Boy Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_boy').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Boy Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_girl').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Girl Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_girl').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Girl Service...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#deact_horoscope').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Horoscpe...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_kolareh').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Kolareh...</h1>', 
            timeout: 7000 
        }); 
    });

    $('#deact_kolareh').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating Kolareh...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#fix3g').click(function() { 
        $.blockUI({ 
            message: '<h1>Fixing 3G...</h1>', 
            timeout: 5000 
        }); 
    });

    $('#active_iclip').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating ICLIP...</h1>', 
            timeout: 9000 
        }); 
    });

    $('#deact_iclip').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating ICLIP...</h1>', 
            timeout: 6000 
        }); 
    });

    $('#active_validity').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Validity...</h1>', 
            timeout: 8000 
        }); 
    });

    $('#deact_validity').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating validity...</h1>', 
            timeout: 6000 
        }); 
    });

    $('#active_roaming').click(function() { 
        $.blockUI({ 
            message: '<h1>Activating Roaming...</h1>', 
            timeout: 8000 
        }); 
    });

    $('#deact_roaming').click(function() { 
        $.blockUI({ 
            message: '<h1>Deactivating roaming...</h1>', 
            timeout: 6000 
        }); 
    });

}); 
$(function () {
        $("#btnAdd").bind("click", function () {
          var div = $("<div />");
          div.html(GetDynamicTextBox(''));
          $("#TextBoxContainer").append(div);
        });

        $("body").on("click", ".remove", function () {
          $(this).closest("div").remove();
        });
      });
      var i = 0;
      function GetDynamicTextBox(value) {
        i++;
        var lname = "cug[number"+i+"]";
        return '<b>Number:</b> <input type="text" name ='+ lname +' required="" style="width: 15%; margin-left: 33px"/>&nbsp'
            + '<a class="remove" style="cursor: pointer;">x</a>'

  }

  function isNumberKey(evt)
      {
         var charCode = (evt.which) ? evt.which : event.keyCode
         if (charCode > 31 && (charCode < 48 || charCode > 57)) {
             alert("Please Enter Only Numeric Value:");
             return false;
         }
 
         return true;
      }

      $(document).ready(function(){  

      var checkField;

      //checking the length of the value of message and assigning to a variable(checkField) on load
      checkField = $("input#number").val().length;  

      var enableDisableButton = function(){         
        if(checkField > 6){
          $('#sendButton').removeAttr("disabled");
        } 
        else {
          $('#sendButton').attr("disabled","disabled");
        }
      }    
      //calling enableDisableButton() function on load
      enableDisableButton();            

      $('input#number').keyup(function(){ 
        //checking the length of the value of message and assigning to the variable(checkField) on keyup
        checkField = $("input#number").val().length;
        //calling enableDisableButton() function on keyup
        enableDisableButton();
      });
    });

      function validate()
    {
        if ( document.getElementById("txtNumericInput").value.length != 7 )
        {
            alert( "Invalid length, must be 7 numbers" );
            return false;
        }   
        return true;
    }