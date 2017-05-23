jQuery(document).ready(function() {

    $("#customer_credit_card_billing_address_country_code_alpha2").change(function(){
        if( $(this).val() == "US" ) {
            $(".billing-zip").show();
        } else {
            $(".billing-zip").hide();
        }
    })

    $("#existing_card_true").click(function() {
        $(".edit_job_registration").hide();
        $(".select-existing-card").show();
    });
    $("#existing_card_false").click(function() {
        $(".edit_job_registration").show();
        $(".select-existing-card").hide();
    });

    $(".pay-existing-card").one("click", function() {
        $(this).text("Processing...");
        $(this).click(function () {
            return false;
        });
    });

});