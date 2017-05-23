jQuery(document).ready(function() {

    if ($("#job_registration_start_date").length) {
        $("#job_registration_start_date").datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: "d MM yy"
        });

        $(function() {
    	    $('input.radio_buttons').each(function() {
    	        if (this.checked) $(this).closest('li').addClass('selected');
    	    });
    	});
    }
    
});