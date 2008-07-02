(function($) {
    $(document).ready(function(){

        /* save login provider */
        function toggleLoginProvider() {
            var current = "#" + $("#loginprovider_name").val();
            $(".loginprovider").hide();
            $(current).show();
            $.cookie("loginprovider", $("#loginprovider_name").val());
        }

        var loginProvider = $.cookie("loginprovider");

        if (loginProvider) {
            $("#loginprovider_name").val(loginProvider);
        }

        toggleLoginProvider();

        $("#loginprovider_name").change(function() {
            toggleLoginProvider();
        });

        /* save OpenID URL */

        var OpenIDURL = $.cookie("openid_url");
        var OpenIDRememberMe = $.cookie("openid_remember_me");
        if (OpenIDURL) {
            $("#openid_url").val(OpenIDURL);
        }
        if (OpenIDRememberMe) {
            $("#openid_remember_me").attr("checked", "checked");
        }

        $("#login").submit(function() {
            if ( $("#openid_remember_me:checked").length ) {
                var url = $("#openid_url").val();

                if ( url.length && url != "http://" ) {
                    $.cookie("openid_url", url);
                    $.cookie("openid_remember_me", true);
                }
                return true;
            } else {
                $.cookie("openid_url", null);
                $.cookie("openid_remember_me", null);
            }
        });
    });
})(jQuery);
