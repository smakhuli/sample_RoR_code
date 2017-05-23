jQuery(document).ready(function() {


    if ($("#job_posting_form").length) {
	    $('.redactor').redactor({
			dragUpload: false,
			сlipboardUpload: false,
			minHeight: 100,
			buttons: ['formatting', '|', 'bold', 'italic', '|','unorderedlist', 'orderedlist', '|','image', 'video', 'link', '|', 'html']
		});

		$('.redactor-simple').redactor({
			dragUpload: false,
			сlipboardUpload: false,
			minHeight: 100,
			buttons: ['bold', 'italic', '|','unorderedlist', 'orderedlist', '|', 'html']
		});
    }

});